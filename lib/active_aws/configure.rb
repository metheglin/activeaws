module ActiveAws
  class Configure
    attr_accessor :profile, 
      :access_key, 
      :secret_key, 
      :region

    def initialize( **params )
      params.each do |k,v|
        self.send("#{k}=", v) if self.methods.include?(k)
      end
      yield( self ) if block_given?
    end

    def credentials
      @credentials ||= profile ?
        Aws::SharedCredentials.new( profile_name: profile ) :
        Aws::Credentials.new( access_key, secret_key )
      @credentials
    end

    def default_client_params
      {
        region: region,
        credentials: credentials,
      }
    end
  end
end
