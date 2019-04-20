module ActiveAws
  class Ec2 < BaseResource

    @resource_name = 'instance'
    @resource_id_name = 'instance_id'
    @resource_identifier_name = nil
    @client_class_name = 'Aws::EC2::Client'
    @attributes = [
      :block_device_mappings,
      :image_id, :instance_id, :instance_type, :key_name,
      :launch_time, :network_interfaces, 
      :private_ip_address, :private_dns_name,
      :public_ip_address, :public_dns_name,
      :root_device_name, :security_groups, :subnet_id, :tags, :vpc_id,
    ]

    attr_accessor *attributes

    class << self
      def detect_resources_from( response )
        return nil if response.reservations.blank?
        response.reservations[0].send( resource_name.pluralize )
      end
    end

    def create_image!( name: nil, description: nil, no_reboot: true, block_device_mappings: nil )
      name ||= "#{self.name}-#{Time.current.strftime('%Y%m%d%H%M')}"
      description ||= name
      block_device_mappings ||= [{
        device_name: '/dev/xvda',
        ebs: {
          volume_size: 8,
        },
      }]
      self.class.client.create_image({
        block_device_mappings: block_device_mappings,
        description: description,
        instance_id: instance_id,
        name: name,
        no_reboot: no_reboot,
      })
    end

    # `waiter_name` can be checked with the command below.
    # ActiveAws::Ec2.client.waiter_names
    # 
    # Usage:
    # ec2.wait_until :instance_running do |i|
    #   i.max_attempts = 5
    #   i.delay = 5
    # end
    def wait_until( waiter_name=:instance_running, &block )
      self.class.client.wait_until(waiter_name, instance_ids: [instance_id], &block)
    end
  end
end
