module ActiveAws
  class TargetGroup < Base

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
      def client
        Aws::ElasticLoadBalancingV2::Client.new( **configure.default_client_params )
      end

      def find( target_group_arn )
        response = client.describe_target_groups({
          target_group_arns: [target_group_arn], 
        })
        return nil unless response
        new( **response.target_groups[0].to_h )
      end

      def find_by_name( name )
        response = client.describe_target_groups({
          names: [name], 
        })
        return nil unless response
        new( **response.target_groups[0].to_h )
      end

      # Usage:
      # where( load_balancer_arn: ["xxxx"] )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_target_groups( args )
        response.target_groups.map{|i| new( **i.to_h )}
      end
    end

    def name
      target_group_name
    end

    def reload
      self.class.find( target_group_arn )
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
