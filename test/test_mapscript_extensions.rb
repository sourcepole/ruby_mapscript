require 'test/unit'
require "ruby_mapscript"
include Mapscript

class TestMapscriptExtension < Test::Unit::TestCase
  def setup
    mapfile = File.dirname(__FILE__) + '/test.map'
    @map = MapObj.new(mapfile)
  end

  def test_arrays
    assert_equal 0, @map.getLayersDrawingOrder[0]
    style = @map.layers['shppoly'].classes.first.styles.last
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

    #Test Empty Hash
    metadata = @map.web.metadata
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
    assert_equal @map.numlayers, @map.layers.to_a.size
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

  def test_empty_map
    mapfile = File.dirname(__FILE__) + '/empty.map'
    @map = MapObj.new(mapfile)
    assert_equal 0, @map.layers.to_a.size
    assert_nil @map.layers[0]
    assert_nil @map.layers['wms_layer']
    @map.layers.each { }
  end

  def test_draw
    mapimage = @map.draw
    assert mapimage.getSize >= 2338
  end
end
