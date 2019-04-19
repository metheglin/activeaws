module ActiveAws
  class ElasticLoadBalancingV2 < BaseResource

    @resource_name = 'load_balancer'
    @resource_id_name = 'load_balancer_arn'
    @resource_identifier_name = 'name'
    @client_class_name = 'Aws::ElasticLoadBalancingV2::Client'
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
      def find_by_name( name )
        super
      rescue Aws::ElasticLoadBalancingV2::Errors::LoadBalancerNotFound => e
        return nil
      end
    end

    def name
      load_balancer_name
    end

    def target_groups
      @target_groups ||= TargetGroup.where( load_balancer_arn: load_balancer_arn )
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
