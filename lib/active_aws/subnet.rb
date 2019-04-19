module ActiveAws
  class Subnet < BaseResource

    @resource_name = 'subnet'
    @resource_id_name = 'subnet_id'
    @resource_identifier_name = nil
    @client_class_name = 'Aws::EC2::Client'
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

    def vpc
      @vpc ||= Vpc.find( vpc_id )
    end
  end
end
