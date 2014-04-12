Ruby MapScript API extensions
=============================

This gem extends the `SWIG MapScript API <http://mapserver.org/mapscript/mapscript.html>`_
of `UMN MapServer <http://mapserver.org/>`_ with Ruby-like iterators and other API methods.

Installation
------------

ruby_mapscript requires the MapScript API library to be installed.
On Debian/Ubuntu systems::

  sudo apt-get install libmapscript-ruby

A Mapserver binary (CGI) is not required for executing ruby_mapscript code.

To use the gem, add it to your Gemfile or install it manually::

  gem install ruby_mapscript

Trouble loading mapscript
-------------------------


If you get::

  cannot load such file -- mapscript (LoadError)

when you run 'rake test' or try to use ruby_mapscript in a rails application, the following *might* solve the problem (on Debian/Ubuntu systems):

1. find where mapscript.so is hiding::

  sudo updatedb
  locate mapscript.so

2. it could be something like:

  /usr/lib/ruby/1.9.1/x86_64-linux/mapscript.so

3. add the path, in this case:

  /usr/lib/ruby/1.9.1/x86_64-linux

to your config/environment.rb, for instance, like this:

  $: << '/usr/lib/ruby/1.9.1/x86_64-linux'

  

Usage
-----

To use ruby_mapscript, require the gem and include Mapscript in your class/module or globally::

  require "rubygems"
  require "ruby_mapscript"
  include Mapscript

ruby_mapscript provides a Ruby-like iterator interface to MapScript collections::

  map = MapObj.new('test.map')
  map.layers.each do |layer|
    puts layer.name
  end
  mapimage = map.draw
  mapimage.save('test.png')

With the generic SWIG API iterating would look like::

  0.upto(map.numlayers-1) do |i|
    layer = map.getLayer(i)
    puts layer.name
  end

ruby_mapscript iterators include Enumerable which gives you the same methods as Ruby Arrays and Hashes::

  wms_layers = map.layers.select { |layer| layer.connectiontype == MS_WMS }


To run a MapScript based WMS server as a Rack application create config.ru::

  require "ruby_mapscript/mapserver"

  run RubyMapscript::Mapserver.new('test.map')

and call::

  rackup config.ru

To include a WMS server in a Rails application, require "ruby_mapscript/mapserver" and add a line to your routes.rb::

  match "/wms" => RubyMapscript::Mapserver.new('test.map')


*Copyright (c) 2012 Pirmin Kalberer, Sourcepole AG*
