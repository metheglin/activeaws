module ActiveAws
  class ElasticLoadBalancingV2 < Base
    @attributes = [
      :load_balancer_arn,
      :dns_name, :canonical_hosted_zone_id, :created_time, 
      :load_balancer_name,
      :scheme, :vpc_id, 
      :state, :type, :availability_zones,
      :security_groups
    ]

    attr_accessor *attributes

    class << self
      def client
        Aws::ElasticLoadBalancingV2::Client.new( **configure.default_client_params )
      end

      def find( load_balancer_arn )
        response = client.describe_load_balancers({
          load_balancer_arns: [load_balancer_arn], 
        })
        return nil unless response
        new( **response.load_balancers[0].to_h )
      end

      def find_by_name( name )
        response = client.describe_load_balancers({
          names: [name], 
        })
        return nil unless response
        new( **response.load_balancers[0].to_h )
      end
    end

    def name
      load_balancer_name
    end

    def reload
      self.class.find( load_balancer_arn )
    end

    def target_groups
      TargetGroup.where( load_balancer_arn: load_balancer_arn )
    end

    # `waiter_name` can be checked with the command below.
    # ActiveAws::ElasticLoadBalancingV2.client.waiter_names
    # 
    # Usage:
    # alb.wait_until :load_balancer_available do |i|
    #   i.max_attempts = 5
    #   i.delay = 5
    # end
    def wait_until( waiter_name=:load_balancer_available, &block )
      self.class.client.wait_until(waiter_name, load_balancer_arns: [load_balancer_arn], &block)
    end
  end
end
