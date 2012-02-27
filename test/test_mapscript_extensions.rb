require 'test/unit'
require "ruby_mapscript"
include Mapscript

class TestMapscriptExtension < Test::Unit::TestCase
  def setup
    mapfile = File.join(File.dirname(__FILE__), 'test.map')
    @map = MapObj.new(mapfile)
  end

  def test_arrays
    assert_equal 0, @map.getLayersDrawingOrder[0]
    style = @map.layers['shppoly'].classes.first.styles[-1]
    assert_equal SWIG::TYPE_p_double, style.pattern.class
    if defined?(Doublearray)
      pattern = Doublearray.frompointer(style.pattern)
      assert_equal 4.0, pattern[0]
      assert_equal 4.0, pattern[style.patternlength-1]
    else
      puts "Warning: Mapscript library does not support Doublearray"
    end
  end

  def test_hashtable
    layer = @map.layers['wms_layer']
    metadata = layer.metadata

    assert metadata.has_key?("wms_title")
    assert metadata.key?("wms_title")
    assert metadata.include?("wms_title")
    assert !metadata.key?("XXX")

    assert_equal 6, metadata.numitems
    assert_equal metadata.numitems, metadata.length
    assert_equal metadata.numitems, metadata.keys.size

    assert metadata.keys.include?("wms_title")
    assert_equal "WMS Layer", metadata["wms_title"]

    metadata.each do |k, v|
      assert_equal metadata[k], v
    end

    #Update entry
    metadata["wms_title"] = "New Title"
    assert_equal "New Title", metadata["wms_title"]

    #Add new entry
    metadata["new_key"] = "New Value"
    assert_equal 7, metadata.numitems

    metadata.delete("new_key")
    assert_equal 6, metadata.numitems

    assert_equal "EPSG:4326", metadata.to_hash["wms_srs"]

    #Enumerable
    assert_equal metadata.keys, metadata.collect { |k, v| k }
    assert_equal ["wms_srs", "EPSG:4326"], metadata.to_a.first

    #Test Map Metadata
    metadata = @map.web.metadata
    assert_equal 5, metadata.numitems
    assert_equal "Rackup Test WMS", metadata["wms_title"]

    #Test Empty Hash
    metadata = @map.layers['shppoly'].metadata
    assert !metadata.key?("wms_title")
    assert_equal 0, metadata.numitems
    assert_equal metadata.numitems, metadata.length
    assert_equal metadata.numitems, metadata.keys.size
    assert metadata.keys.empty?
    assert_nil metadata["wms_title"]
    metadata.each {}
    metadata["new_key"] = "New Value"
    assert_equal 1, metadata.numitems
    metadata.delete("new_key")
    assert_equal 0, metadata.numitems
    assert_equal({}, metadata.to_hash)
  end

  def test_layer_access
    assert_equal @map.numlayers, @map.layers.size
    assert_equal @map.numlayers, @map.layers.count #From Enumerable
    assert_equal @map.numlayers, @map.layers.to_a.size #to_a from Enumerable
    assert_equal @map.numlayers, @map.layers[0..-1].size
    assert_equal 0, @map.layers.first.index
    @map.layers.each_with_index do |l, i|
      assert_equal i, @map.layers[i].index
    end
    assert_equal 'wms_layer', @map.layers[0].name
    assert_equal 'wms_layer', @map.layers[-@map.numlayers].name
    assert_nil @map.layers[99]
    assert_equal 'wms_layer', @map.layers['wms_layer'].name
    assert_nil @map.layers['xxx']
    oldcnt = @map.numlayers
    @map.layers << @map.layers.first
    assert_equal oldcnt+1, @map.numlayers
    assert_equal @map.numlayers, @map.layers.to_a.size
    assert_equal @map.numlayers, @map.layers[0..-1].size

    assert !@map.layers.first.visible?
  end

  def test_class_access
    layer = @map.layers['shppoly']
    assert_equal layer.numclasses, layer.classes.to_a.size
    assert_equal layer.numclasses, layer.classes[0..-1].size
    assert_equal 'test1', layer.classes[0].name
    assert_equal 'test1', layer.classes[-layer.numclasses].name
    assert_nil layer.classes[99]
    assert_equal 'test1', layer.classes['test1'].name
    assert_nil layer.classes['xxx']
    oldcnt = layer.numclasses
    layer.classes << layer.classes.first
    assert_equal oldcnt+1, layer.numclasses
    assert_equal layer.numclasses, layer.classes.to_a.size
    assert_equal layer.numclasses, layer.classes[0..-1].size
  end

  def test_iterators
    assert_equal 0, LabelObj.new.styles.size

    assert_equal 0, ResultCacheObj.new.results.size

    shapefile = File.join(File.dirname(__FILE__), 'data', 'world_testpoly.shp')
    shapefile_obj = ShapefileObj.new(shapefile)
    assert_equal 4, shapefile_obj.shapes.size
    shape = shapefile_obj.shapes[0]
    assert_equal 0, shape.index
    assert_equal 1, shape.lines.size
    lines = shape.lines[0]
    assert_equal 0, shape.values.size
    assert_equal 5, lines.points.size
    point = lines.points[0]
    assert_not_nil point

    symbol_set = SymbolSetObj.new
    assert_equal 1, symbol_set.symbols.size
    assert_not_nil symbol_set.symbols[0]
  end

  def test_empty_map
    mapfile = File.join(File.dirname(__FILE__), 'empty.map')
    @map = MapObj.new(mapfile)
    assert_equal 0, @map.layers.to_a.size
    assert_nil @map.layers[0]
    assert_nil @map.layers[-1]
    assert_nil @map.layers['wms_layer']
    @map.layers.each { }
  end

  def test_draw
    mapimage = @map.draw
    assert mapimage.getSize >= 2338
  end

  def test_map_io
    #MapObj -> String
    mapstr = @map.to_s
    assert mapstr =~ /NAME "Test Map"/
    assert mapstr =~ %r(CONNECTION "http://iceds.ge.ucl.ac.uk/cgi-bin/icedswms\?")
    assert mapstr =~ %r(DATA "data/world_testpoly.shp")

    #String -> MapObj
    map = MapObj.from_s(mapstr)
    assert_equal @map.name, map.name
    assert_equal @map.layers.size, map.layers.size
    assert_equal @map.layers.first.name, map.layers.first.name
    assert_equal @map.layers[-1].name, map.layers[-1].name

    #String -> LayerObj
    layerstr =<<EOS
      LAYER
        NAME redline
        TYPE line
        DATA "data/world_testpoly.shp"
        STATUS ON
        CLASS
          STYLE
              COLOR 255 0 0
              WIDTH 5
          END
        END
      END
EOS
    layer = LayerObj.from_map(layerstr)
    assert_equal "redline", layer.name
    @map.insertLayer(layer)
    assert_equal layer.name, @map.layers[-1].name

    #String -> OutputFormatObj
    formaststr =<<EOS
      OUTPUTFORMAT
        NAME "png8"
        DRIVER AGG/PNG8
        MIMETYPE "image/png; mode=8bit"
        IMAGEMODE RGB
        EXTENSION "png"
        FORMATOPTION "QUANTIZE_FORCE=on"
        FORMATOPTION "QUANTIZE_COLORS=256"
        FORMATOPTION "GAMMA=0.75"
      END
EOS
    output_format = OutputFormatObj.from_map(formaststr)
    assert_equal "png8", output_format.name
    assert_equal '256', output_format.getOption('QUANTIZE_COLORS')
  end

  def test_examples
    map = @map
    map.layers.each do |layer|
      #puts layer.name
    end
    mapimage = map.draw
    #mapimage.save('/tmp/test.png')
    assert mapimage.getSize >= 2338

    0.upto(map.numlayers-1) do |i|
      layer = map.getLayer(i)
      #puts layer.name
    end

    wms_layers = map.layers.select { |layer| layer.connectiontype == MS_WMS }
    assert_equal 1, wms_layers.size
  end

end
