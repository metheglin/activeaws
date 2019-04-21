module ActiveAws
  class Route53HostedZone < Base
    
    @client_class_name = 'Aws::Route53::Client'
    @attributes = [
      :id,
      :name,
      :caller_reference,
      :config,
      :resource_record_set_count,
      :linked_service,
    ]

    attr_accessor *attributes

    class << self
      def find_by_name( name )
        resp = client.list_hosted_zones_by_name({
          dns_name: name,
        })
        new( **resp.hosted_zones[0] )
      end

      def create!( name )
        resp = client.create_hosted_zone({ name: name })
        new( **resp.hosted_zone )
      end
    end

    def id
      @id.sub('/hostedzone/', '')
    end

    def set!( name, type, value, weight: nil, comment: nil )
      resource_record_set = {
        name: name, 
        weight: weight,
        
      }
      resource_record_set = if type.to_sym == :alias
        resource_record_set.merge(
          alias_target: value.alias_target,
          # alias_target: {
          #   dns_name: "d123rk29d0stfj.cloudfront.net", 
          #   evaluate_target_health: false, 
          #   hosted_zone_id: "Z2FDTNDATAQYW2", 
          # },
          type: "A",
        )
      else
        values = Array.wrap( value )
        resource_record_set.merge(
          resource_records: values.map{|a| { value: a }},
          type: type, 
          ttl: 300, 
        )
      end
      puts resource_record_set
      self.class.client.change_resource_record_sets({
        change_batch: {
          changes: [
            {
              action: "UPSERT", 
              resource_record_set: resource_record_set,
              # resource_record_set: {
              #   name: name, 
              #   resource_records: values.map{|a| { value: a }}
              #   ttl: 300, 
              #   type: type, 
              #   weight: weight,
              # }, 
            }, 
          ], 
          comment: comment, 
        }, 
        hosted_zone_id: id, 
      })
    end
  end
end
