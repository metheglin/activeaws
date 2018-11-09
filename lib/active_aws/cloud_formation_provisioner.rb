module ActiveAws
  class CloudFormationProvisioner < Base

    attr_reader :name, :template_path, :parameters

    class << self
      def client
        Aws::CloudFormation::Client.new( **configure.default_client_params )
      end

      def find( stack_name )
        response = client.describe_stacks( stack_name: stack_name )
      end
    end

    def initialize( name, template_path, parameters={} )
      @name = name
      @template_path = template_path
      @parameters = parameters
    end

    def template_body
      @template_body ||= File.read( template_path )
    end

    def normalized_name
      # self.class.configure.cfn_stack_name_prefix + name
      name
    end

    def normalized_parameters
      parameters.map do |k,v|
        {
          parameter_key: k,
          parameter_value: v,
        }
      end
    end

    def to_h
      {
        stack_name: normalized_name,
        template_body: template_body,
        parameters: normalized_parameters,
        capabilities: ["CAPABILITY_IAM"],
        # on_failure: "DELETE",
      }
    end

    def exists?
      res = self.class.client.describe_stacks( stack_name: normalized_name )
      return res.stacks.length > 0
    rescue => e
      return false
    end

    def save!
      response = if exists?
        self.class.client.update_stack( self.to_h )
      else
        self.class.client.create_stack( self.to_h )
      end
    end

    # `waiter_name` can be checked with the command below.
    # ActiveAws::CloudFormationProvisioner.client.waiter_names
    # 
    # Usage:
    # prov.wait_until :instance_running do |i|
    #   i.max_attempts = 5
    #   i.delay = 5
    # end
    def wait_until( waiter_name, &block )
      self.class.client.wait_until(waiter_name, stack_name: normalized_name, &block)
    end
  end
end
