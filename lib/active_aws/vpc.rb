module ActiveAws
  class Vpc < Base

    @attributes = [
      :cidr_block,
      :dhcp_options_id, 
      :state,
      :vpc_id,
      :owner_id,
      :instance_tenancy,
      :ipv_6_cidr_block_association_set,
      :cidr_block_association_set,
      :is_default,
      :tags,
    ]

    attr_accessor *attributes

    class << self
      def client
        Aws::EC2::Client.new( **configure.default_client_params )
      end

      def find( vpc_id )
        response = client.describe_vpcs({
          vpc_ids: [vpc_id], 
        })
        return nil unless response.vpcs
        new( **response.vpcs[0].to_h )
      end

      def find_by_name( name )
        response = client.describe_vpcs({
          filters: [{ name: "tag:Name", values: ["#{name}*"] }], 
        })
        return nil unless response.vpcs
        new( **response.vpcs[0].to_h )
      end

      # Usage:
      # Vpc::where( :"tag:Role" => "web" )
      # Vpc::where( :"instance-type" => "t2.micro" )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_vpcs({
          filters: filter_params, 
        })
        vpc_params = response.vpcs
        vpc_params.map{|i| new( **i.to_h )}
      end

      def all
        response = client.describe_vpcs()
        vpc_params = response.vpcs
        vpc_params.map{|i| new( **i.to_h )}
      end
    end

    def name
      name_tag = tags.detect{|t| t[:key].to_s == "Name"}
      return nil unless name_tag
      name_tag[:value]
    end

    def subnets
      ActiveAws::Subnet.where( :'vpc-id' => vpc_id )
    end

    def private_subnets
      ActiveAws::Subnet.where( :'vpc-id' => vpc_id, :'tag:Network' => 'Private' )
    end

    def public_subnets
      ActiveAws::Subnet.where( :'vpc-id' => vpc_id, :'tag:Network' => 'Public' )
    end
  end
end
