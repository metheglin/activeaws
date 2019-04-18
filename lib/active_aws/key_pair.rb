module ActiveAws
  class KeyPair < Base

    @attributes = [
      :is_generated,
      :key_name,
      :key_fingerprint, 
      :key_material,
    ]

    attr_accessor *attributes

    class << self
      def client
        Aws::EC2::Client.new( **configure.default_client_params )
      end

      # def find( vpc_id )
      #   response = client.describe_key_pairs({
      #     vpc_ids: [vpc_id], 
      #   })
      #   return nil if response.key_pairs.blank?
      #   new( **response.key_pairs[0].to_h )
      # end

      def find_by_name( name )
        response = client.describe_key_pairs({
          key_names: [name],
        })
        return nil if response.key_pairs.blank?
        new( **response.key_pairs[0].to_h )
      rescue Aws::EC2::Errors::InvalidKeyPairNotFound => e
        return nil
      end

      # Usage:
      # KeyPair::where( :"tag:Role" => "web" )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_key_pairs({
          filters: filter_params, 
        })
        kp_params = response.key_pairs
        kp_params.map{|i| new( **i.to_h )}
      end

      def all
        response = client.describe_key_pairs()
        kp_params = response.key_pairs
        kp_params.map{|i| new( **i.to_h )}
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
