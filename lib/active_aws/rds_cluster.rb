module ActiveAws
  class RdsCluster < Base

    @attributes = [
      :db_cluster_identifier,
      :database_name,
      :db_cluster_parameter_group,
      :db_subnet_group,
      :status,
      :endpoint,
      :reader_endpoint,
      :multi_az,
      :engine,
      :engine_version,
      :read_replica_identifiers,
      :db_cluster_members,
      :vpc_security_groups,
      :db_cluster_arn,
    ]

    attr_accessor *attributes

    class << self
      def client
        Aws::RDS::Client.new( **configure.default_client_params )
      end

      def find( id )
        raise "id must be specified." if id.blank?
        response = client.describe_db_clusters({
          db_cluster_identifier: id,
        })
        return nil if response.db_clusters.blank?
        new( **response.db_clusters[0].to_h )
      end

      def find_by_name( name )
        return nil if name.blank?
        find( name )
      rescue Aws::RDS::Errors::DBClusterNotFoundFault => e
        return nil
      end

      # Usage:
      # Vpc::where( :"tag:Role" => "web" )
      # Vpc::where( :"instance-type" => "t2.micro" )
      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.describe_db_clusters({
          filters: filter_params, 
        })
        vpc_params = response.db_clusters
        vpc_params.map{|i| new( **i.to_h )}
      end

      def all
        response = client.describe_db_clusters()
        vpc_params = response.db_clusters
        vpc_params.map{|i| new( **i.to_h )}
      end
    end

    def name
      db_cluster_identifier
    end

    
  end
end
