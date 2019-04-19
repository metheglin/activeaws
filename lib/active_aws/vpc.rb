module ActiveAws
  class Vpc < BaseResource

    @resource_name = 'vpc'
    @resource_id_name = 'vpc_id'
    @resource_identifier_name = nil
    @client_class_name = 'Aws::EC2::Client'
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
