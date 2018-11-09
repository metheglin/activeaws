module ActiveAws
  class Ec2Provisioner < Base

    ATTRIBUTES = [
      :instance_type, 
      :key_name, 
      :image_id, 
      :security_group_ids,
      :subnet_id,
      :user_data,
      :block_device_mappings,
      :tag_specifications,
      :network_interfaces,
      :launch_template,
    ]

    attr_accessor :name
    attr_accessor *ATTRIBUTES
    attr_reader :tag_specs

    def initialize( name, **params )
      @name = name

      ATTRIBUTES.each do |k|
        method = "#{k}="
        self.send(method, params[k]) if params[k].present?
      end

      yield( self ) if block_given?
    end

    def tag_specs
      specifications = @tag_specifications || []
      unless specifications.detect{|a| a[:resource_type] == "instance"}
        specifications << {
          resource_type: "instance",
          tags: []
        }
      end
      TagSpec.parse( specifications )
    end

    def exec!( extra_tags={} )
      ec2 = ActiveAws::Ec2.find_by_name( name )
      return ec2 if ec2
      forced_exec!( extra_tags )
    end

    def forced_exec!( extra_tags={} )
      client = ActiveAws::Ec2.client
      response = client.run_instances( self.to_h )
      ActiveAws::Ec2.new( **response.instances[0] )
    end

    def to_h( extra_tags={} )
      extra_tags = extra_tags.merge({ "Name" => self.name })
      attrs = ATTRIBUTES.reduce({}) do |acc,k|
        acc[k] = self.send( k )
        acc
      end
      attrs = attrs.merge(
        max_count: 1,
        min_count: 1,
        tag_specifications: tag_specs.map {|ts|
          ts = if ts.resource_type == "instance"
            ts.merge( extra_tags )
          else
            ts
          end
          ts.to_param
        }
      )
      attrs
    end
  end
end
