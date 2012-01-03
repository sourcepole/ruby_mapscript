# Ruby Mapscript API extensions

require "mapscript"

module Mapscript

  # Generic iterator for Mapscript collections
  class MapscriptEnumerable
    include Enumerable

    def initialize(parent, size_method, getter)
      @parent, @size_method, @getter  = parent, size_method, getter
    end

    def size
      @parent.send(@size_method)
    end

    def each
      0.upto(size-1) do |idx|
        yield @parent.send(@getter, idx)
      end
    end

    def [](idx)
      case idx
        when Fixnum
          if idx >= 0
            @parent.send(@getter, idx)
          else
            @parent.send(@getter, size+idx)
          end
        when Range
          to_a[idx]
        else
          raise TypeError, "Unsupported type for index"
      end
    end

  end

  # LayerObj iterator
  class MapLayers < MapscriptEnumerable

    def initialize(map)
      super(map, :numlayers, :getLayer)
      @map = map
    end

    def [](idx)
      case idx
        when Fixnum
          if idx >= 0
            @map.getLayer(idx)
          else
            @map.getLayer(@map.numlayers+idx)
          end
        when Range
          to_a[idx]
        when String
          @map.getLayerByName(idx)
        else
          raise TypeError, "Unsupported type for index"
      end
    end

    def <<(layer)
      @map.insertLayer(layer, @map.numlayers-1)
    end
  end

  # ClassObj iterator
  class LayerClasses < MapscriptEnumerable

    def initialize(layer)
      super(layer, :numclasses, :getClass)
      @layer = layer
    end
 
    def [](idx)
      case idx
        when Fixnum
          if idx >= 0
            @layer.getClass(idx)
          else
            @layer.getClass(@layer.numclasses+idx)
          end
        when Range
          to_a[idx]
        when String
          find { |cls| cls.name == idx }
        else
          raise TypeError, "Unsupported type for index"
      end
    end

    def <<(newclass)
      @layer.insertClass(newclass, @layer.numclasses-1)
    end
  end


  # ClassObj extensions
  class ClassObj
    # Return StyleObj iterator
    def styles
      @styles ||= MapscriptEnumerable.new(self, :numstyles, :getStyle)
    end
  end

  # HashTableObj extensions
  class HashTableObj
    include Enumerable

    def [](key)
      get(key)
    end

    def []=(key, value)
      set(key, value)
    end

    def each_key
      key = nextKey(nil)
      while key
        yield key
        key = nextKey(key)
      end
    end

    def has_key?(key)
      !get(key).nil?
    end

    alias :key? :has_key?
    alias :include? :has_key?

    def keys
      ary = []
      each_key { |key| ary << key }
      ary
    end

    alias :length :numitems
    alias :size :numitems

    def empty?
      numitems == 0
    end

    alias :delete :remove

    def each_pair
      key = nextKey(nil)
      while key
        yield key, get(key)
        key = nextKey(key)
      end
    end

    alias :each :each_pair

    def to_hash
      h = {}
      each_pair { |key, value| h[key] = value }
      h
    end

    def inspect
      to_hash.inspect
    end

  end

  # LabelObj extensions
  class LabelObj
    # Return styleObj iterator
    def styles
      @styles ||= MapscriptEnumerable.new(self, :numstyles, :getStyle)
    end
  end

  # LayerObj extensions
  class LayerObj
    # Return ClassObj iterator
    def classes
      @classes ||= LayerClasses.new(self)
    end

    # Return string iterator
    def processings
      @processings ||= MapscriptEnumerable.new(self, :numprocessing, :getProcessing)
    end
  end

  # LineObj extensions
  class LineObj
    # Return pointObj iterator
    def points
      @points ||= MapscriptEnumerable.new(self, :numpoints, :get)
    end
  end

  # MapObj extensions
  class MapObj
    # Return LayerObj iterator
    def layers
      @map_layers ||= MapLayers.new(self)
    end
  end

  # ResultCacheObj extensions
  class ResultCacheObj
    # Return resultCacheObj iterator
    def results
      @results ||= MapscriptEnumerable.new(self, :numresults, :getResult)
    end
  end

  # ShapefileObj extensions
  class ShapefileObj
    # Return shapeObj iterator
    def shapes
      @shapes ||= MapscriptEnumerable.new(self, :numshapes, :getShape)
    end
  end

  # ShapeObj extensions
  class ShapeObj
    # Return lineObj iterator
    def lines
      @lines ||= MapscriptEnumerable.new(self, :numlines, :get)
    end

    # Return shape attribute (string) iterator
    def values
      @values ||= MapscriptEnumerable.new(self, :numvalues, :getValue)
    end
  end

  # SymbolSetObj extensions
  class SymbolSetObj
    # Return symbolObj iterator
    def symbols
      @symbols ||= MapscriptEnumerable.new(self, :numsymbols, :getSymbol) #:getSymbolByName
    end
  end
end
