module ActiveAws
  class S3Bucket < Base
    
    @client_class_name = 'Aws::S3::Client'
    @attributes = [
      :name,
      :creation_date,
      # :location,
    ]

    attr_accessor *attributes

    class << self
      def create_public_hosting!( name )
        client.create_bucket(
          bucket: name,
          create_bucket_configuration: {
            location_constraint: configure.region,
          },
        )
      end

      def create_website_hosting!( name )
        raise "Not Implemented yet"
      end
    end
  end
end
