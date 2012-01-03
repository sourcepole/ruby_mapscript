# Ruby Mapscript API extensions

require "mapscript"

module Mapscript

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
      end if size > 0
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

    def to_a
      (0..size-1).collect { |idx| @parent.send(@getter, idx) }
    end
  end

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


  # MapObj extensions
  class MapObj
    # Return LayerObj array
    def layers
      @map_layers ||= MapLayers.new(self)
    end
  end

  # LayerObj extensions
  class LayerObj
    def classes
      @classes ||= LayerClasses.new(self)
    end

    # Return string array
    def processings
      @processings ||= MapscriptEnumerable.new(self, :numprocessing, :getProcessing)
    end
  end

  # ClassObj extensions
  class ClassObj
    # Return StyleObj array
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
end
