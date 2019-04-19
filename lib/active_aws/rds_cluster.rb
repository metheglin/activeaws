module ActiveAws
  class RdsCluster < BaseResource

    @resource_name = 'db_cluster'
    @resource_id_name = 'db_cluster_identifier'
    @resource_identifier_name = 'db_cluster_identifier'
    @client_class_name = 'Aws::RDS::Client'
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

      def find( id )
        raise "id must be specified." if id.blank?
        find_one( db_cluster_identifier: id )
      end

      def find_by_name( name )
        return nil if name.blank?
        find( name )
      rescue Aws::RDS::Errors::DBClusterNotFoundFault => e
        return nil
      end
    end
  end
end
