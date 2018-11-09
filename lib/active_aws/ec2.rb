module ActiveAws
  class Ec2 < Base

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
      def client
        Aws::EC2::Client.new( **configure.default_client_params )
      end

      def find( instance_id )
        response = client.describe_instances({
          instance_ids: [instance_id], 
        })
        return nil unless response.reservations[0]
        new( **response.reservations[0].instances[0].to_h )
      end

      def find_by_name( name )
        response = client.describe_instances({
          filters: [{ name: "tag:Name", values: [name] }], 
        })
        return nil unless response.reservations[0]
        new( **response.reservations[0].instances[0].to_h )
      end

      # Usage:
      # Ec2::where( :"tag:Role" => "web" )
      # Ec2::where( :"instance-type" => "t2.micro" )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_instances({
          filters: filter_params, 
        })
        instance_params = response.reservations.map{|r| r.instances }.flatten
        instance_params.map{|i| new( **i.to_h )}
      end
    end

    def name
      name_tag = tags.detect{|t| t[:key].to_s == "Name"}
      return nil unless name_tag
      name_tag[:value]
    end

    def reload
      self.class.find( instance_id )
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
