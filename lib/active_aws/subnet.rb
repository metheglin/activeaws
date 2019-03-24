module ActiveAws
  class Subnet < Base

    @attributes = [
      :availability_zone,
      :availability_zone_id,
      :available_ip_address_count,
      :cidr_block,
      :default_for_az,
      :map_public_ip_on_launch,
      :state,
      :subnet_id,
      :vpc_id,
      :owner_id,
      :assign_ipv_6_address_on_creation,
      :ipv_6_cidr_block_association_set,
      :tags,
      :subnet_arn,
    ]

    attr_accessor *attributes

    class << self
      def client
        Aws::EC2::Client.new( **configure.default_client_params )
      end

      def find( vpc_id )
        response = client.describe_subnets({
          vpc_ids: [vpc_id], 
        })
        return nil unless response.subnets
        new( **response.subnets[0].to_h )
      end

      def find_by_name( name )
        response = client.describe_subnets({
          filters: [{ name: "tag:Name", values: ["#{name}*"] }], 
        })
        return nil unless response.subnets
        new( **response.subnets[0].to_h )
      end

      # Usage:
      # Vpc::where( :"tag:Role" => "web" )
      # Vpc::where( :"vpc-id" => "vpc-xxxxyyyyzzzz" )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_subnets({
          filters: filter_params, 
        })
        vpc_params = response.subnets
        vpc_params.map{|i| new( **i.to_h )}
      end

      def all
        response = client.describe_subnets()
        vpc_params = response.subnets
        vpc_params.map{|i| new( **i.to_h )}
      end
    end

    def name
      name_tag = tags.detect{|t| t[:key].to_s == "Name"}
      return nil unless name_tag
      name_tag[:value]
    end

    def vpc
      Vpc.find( vpc_id )
    end
  end
end
