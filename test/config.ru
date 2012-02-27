require "ruby_mapscript/mapserver"

mapfile = ENV['MAP'] || "#{File.dirname(__FILE__)}/test.map"

use Rack::Reloader if ENV['RACK_ENV'] == 'development'
run RubyMapscript::Mapserver.new(mapfile)
