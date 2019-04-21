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
      def find( id )
        find_by_name( id )
      end

      def find_by_name( name )
        client.head_bucket({ bucket: name })
        new( name: name )
      rescue Aws::S3::Errors::NotFound => e
        return nil
      rescue Aws::S3::Errors::Http301Error => e
        raise "This bucket is already reserved!! Please use other name"
      end

      def create_public_hosting!( name )
        client.create_bucket(
          bucket: name,
          create_bucket_configuration: {
            location_constraint: configure.region,
          },
        )
        new( name: name )
      end

      def create_website_hosting!( name )
        raise "Not Implemented yet"
      end
    end
  end
end
