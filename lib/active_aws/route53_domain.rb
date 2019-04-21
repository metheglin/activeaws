module ActiveAws
  class Route53Domain < Base
    
    @client_class_name = 'Aws::Route53Domains::Client'
    @attributes = [
      :domain_name,
      :auto_renew,
      :transfer_lock,
      :expiry,
    ]

    attr_accessor *attributes

    class << self
      def client
        client_class_name.constantize.new(
          **configure.default_client_params.merge(region: 'us-east-1')
        )
      end

      def find_by_name( name )
        res = client.get_domain_detail({ domain_name: name })
        new( res )
      rescue Aws::Route53Domains::Errors::InvalidInput => e
        return nil
      end

      def check_availability( name )
        res = client.check_domain_availability({ domain_name: name })
        res.availability == 'AVAILABLE'
      end
    end
  end
end
