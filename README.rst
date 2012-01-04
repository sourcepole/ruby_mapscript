Ruby MapScript API extensions
=============================

This gem extends the `SWIG MapScript API <http://mapserver.org/mapscript/mapscript.html>`_
of `UMN MapServer <http://mapserver.org/>` with Ruby-like iterators and other API methods.

Installation
------------

ruby_mapscript requires the MapScript API library to be installed.
On Debian/Ubuntu systems::

  sudo apt-get install libmapscript-ruby

A Mapserver binary (CGI) is not required for executing ruby_mapscript code.

To use the Gem, add it to your Gemfile or install it manually::

  gem install ruby_mapscript


Usage
-----

To use ruby_mapscript require the gem and include Mapscript in your class/module or globally::

    require "rubygems"
    require "ruby_mapscript"
    include Mapscript

ruby_mapscript provides a Ruby-like iterator interface to MapScript collections::

  map.layers.each do |layer|
    puts layer.name
  end

With the native SWIG API this would be something like::

  0.upto(map.numlayers-1) do |i|
    layer = map.getLayer(i)
    puts layer.name
  end

ruby_mapscript iterators include Enumerable which gives you the same methods as Ruby Arrays and Hashes have::

  wms_layers = map.layers.select { |layer| layer.connectiontype == MS_WMS }



*Copyright (c) 2012 Pirmin Kalberer, Sourcepole AG*
