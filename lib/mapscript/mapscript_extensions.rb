# Ruby Mapscript API extensions

require "mapscript"

module Mapscript

  class MapLayers
    include Enumerable
 
    def initialize(map)
      @map = map
    end
 
    def each
      0.upto(@map.numlayers-1) do |idx|
        yield @map.getLayer(idx)
      end if @map.numlayers > 0
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
          nil
      end
    end

    def <<(layer)
      @map.insertLayer(layer, @map.numlayers-1)
    end

    def to_a
      if @map.numlayers > 0
        (0..@map.numlayers-1).collect { |idx| @map.getLayer(idx) }
      else
        []
      end
    end
  end

  class LayerClasses
    include Enumerable
 
    def initialize(layer)
      @layer = layer
    end
 
    def each
      0.upto(@layer.numclasses-1) do |idx|
        yield @layer.getClass(idx)
      end if @layer.numclasses > 0
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
          nil
      end
    end

    def <<(newclass)
      @layer.insertClass(newclass, @layer.numclasses-1)
    end

    def to_a
      if @layer.numclasses > 0
        (0..@layer.numclasses-1).collect { |idx| @layer.getClass(idx) }
      else
        []
      end
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
      (0..[-1,numprocessing-1].max).collect { |idx| getProcessing(idx) }
    end
  end

  # ClassObj extensions
  class ClassObj
    # Return StyleObj array
    def styles
      (0..[-1,numstyles-1].max).collect { |idx| getStyle(idx) }
    end
  end

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
