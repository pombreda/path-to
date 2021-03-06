require "path-to/with_params"

module PathTo
  #
  # Builds on the chaining and param collection of WithParams to provide chainable references to URIs.  Delegates the modelling of the
  # web application to a parent (or ancestor) application object, so that this configuration is in one place (and perhaps the result of a
  # discovery process).
  #
  class Path < WithParams
    #
    # Finds (and remembers) the application in the parent hierarchy.
    #
    def application
      @application ||= parent.application if parent
    end
    
    #
    # Delegated to the application object (see Application#child_class_for for details).
    #
    def child_class_for(instance, service, args)
      application.child_class_for(instance, service, args)
    end
    
    #
    # Returns the http_client of the application; override if necessary.  See also HTTPClient.
    #
    def http_client
      @http_client ||= application.http_client
    end
    
    #
    # Generate a URI for this object, using application.uri_for (see Application#uri_for for details).
    #
    def uri
      application.uri_for(service, params)
    end
    
    #
    # Generate a URI for this object, using application.uri_for (see Application#uri_for for details).
    #
    def uri_template
      application.uri_template_for(self, service, params)
    end
    #
    # GET request on this object's URI
    #
    def get(*args)
      http_client.get(uri, *merge_http_options(args))
    end
    
    #
    # PUT request on this object's URI
    #
    def put(*args)
      http_client.put(uri, *merge_http_options(args))
    end
    
    #
    # POST request on this object's URI
    #
    def post(*args)
      http_client.post(uri, *merge_http_options(args))
    end
    
    #
    # DELETE request on this object's URI
    #
    def delete(*args)
      http_client.delete(uri, *merge_http_options(args))
    end
    
    #
    # Include application.http_options (if exists) in args, either appending it or reverse-merging with the last element of args if it's a Hash
    #
    def merge_http_options(args)
      if (http_options = application.http_options)
        if args[-1].kind_of?(Hash)
          args[-1] = http_options.merge(args[-1])
        else
          args << http_options
        end
      end
      args
    end
    
    
    def inspect  #:nodoc:
      "#{uri} #<#{self.class.name}:#{"0x%x" % object_id} service=#{service.inspect}, params=#{params.inspect}>"
    end
  end
end
