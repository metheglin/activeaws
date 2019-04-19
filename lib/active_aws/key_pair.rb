module ActiveAws
  class KeyPair < BaseResource
    
    @resource_name = 'key_pair'
    @resource_id_name = nil
    @resource_identifier_name = 'key_name'
    @client_class_name = 'Aws::EC2::Client'
    @attributes = [
      :is_generated,
      :key_name,
      :key_fingerprint, 
      :key_material,
    ]

    attr_accessor *attributes

    class << self
      def find( id )
        find_one( key_names: [id], )
      end

      def find_by_name( name )
        super
      rescue Aws::EC2::Errors::InvalidKeyPairNotFound => e
        return nil
      end
      
      def create!( key_name )
        response = client.create_key_pair( key_name: key_name )
        new( **response.to_h.merge( is_generated: true ) )
      end
    end

    def generated?
      !! is_generated
    end
  end
end
