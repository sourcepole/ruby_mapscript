# OGC compliant map server Rack Application
# OWS requests include WMS, WFS, WCS and SOS requests supported by MapServer

require "mapscript"

module RubyMapscript

class Mapserver

  def initialize(mapfile)
    @wms = Mapscript::MapObj.new(mapfile)
  end

  def call(env)
    req = Mapscript::OWSRequest.new
    %w(REQUEST_METHOD QUERY_STRING HTTP_COOKIE).each do |var|
      ENV[var] = env[var]
    end
    req.loadParams
    #Returns the number of name/value pairs collected.
    #Warning: most errors will result in a process exit!

    # redirect stdout & handle request
    Mapscript::msIO_installStdoutToBuffer()
    retval = @wms.OWSDispatch(req)
    #Returns MS_DONE (2) if there is no valid OWS request in the req object,
    # MS_SUCCESS (0) if an OWS request was successfully processed and
    # MS_FAILURE (1) if an OWS request was not successfully processed.
    content_type = Mapscript::msIO_stripStdoutBufferContentType()
    map_image = Mapscript::msIO_getStdoutBufferBytes()
    Mapscript::msIO_resetHandlers()

    [200, {'Content-Type' => content_type}, map_image]
  end
end

end