module ActiveAws
  class TargetGroup < BaseResource

    @resource_name = 'target_group'
    @resource_id_name = 'target_group_arn'
    @resource_identifier_name = 'name'
    @client_class_name = 'Aws::ElasticLoadBalancingV2::Client'
    @attributes = [
      :target_group_arn,
      :target_group_name, 
      :protocol, :port, :vpc_id,
      :health_check_protocol, :health_check_port, 
      :health_check_interval_seconds, :health_check_timeout_seconds,
      :healthy_threshold_count, :unhealthy_threshold_count,
      :health_check_path, :matcher, 
      :load_balancer_arns, :load_balancer_arns, 
      :target_type,
    ]

    attr_accessor *attributes

    class << self
      def find_by_name( name )
        super
      rescue Aws::ElasticLoadBalancingV2::Errors::TargetGroupNotFound => e
        return nil
      end
    end

    def name
      target_group_name
    end

    def health_descriptions
      response = self.class.client.describe_target_health({
        target_group_arn: target_group_arn
      })
      response.target_health_descriptions
    end

    def target_ids
      health_descriptions.map{|a| a.target.id }
    end

    def register!( ids )
      response = self.class.client.register_targets({
        target_group_arn: target_group_arn,
        targets: ids.map{|a| { id: a }}, 
      })
    end

    def deregister!( ids )
      response = self.class.client.deregister_targets({
        target_group_arn: target_group_arn,
        targets: ids.map{|a| { id: a }}, 
      })
    end

    def set!( ids )
      present_ids     = target_ids
      register_ids    = ids.select{|a| ! present_ids.include?( a ) }
      deregister_ids  = present_ids.select{|a| ! ids.include?( a ) }
      # pp register_ids
      # pp deregister_ids
      register!( register_ids ) if register_ids.present?
      deregister!( deregister_ids ) if deregister_ids.present?
      target_ids
    end
  end
end
