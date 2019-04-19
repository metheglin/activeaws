module ActiveAws
  class SecurityGroup < BaseResource

    @resource_name = 'security_group'
    @resource_id_name = 'group_id'
    @resource_identifier_name = 'group_name'
    @client_class_name = 'Aws::EC2::Client'
    @attributes = [
      :group_id, 
      :group_name,
      :description,
      :ip_permissions,
      :ip_permissions_egress,
      :tags,
      :vpc_id,
    ]

    attr_accessor *attributes

    class << self
      def find_by_name( name )
        super
      rescue Aws::EC2::Errors::InvalidGroupNotFound => e
        return nil
      end

      # ip_permissions_egress: [
      #   {
      #     from_port: 1,
      #     ip_protocol: "String",
      #     ip_ranges: [
      #       {
      #         cidr_ip: "String",
      #         description: "String",
      #       },
      #     ],
      #     ipv_6_ranges: [
      #       {
      #         cidr_ipv_6: "String",
      #         description: "String",
      #       },
      #     ],
      #     prefix_list_ids: [
      #       {
      #         description: "String",
      #         prefix_list_id: "String",
      #       },
      #     ],
      #     to_port: 1,
      #     user_id_group_pairs: [
      #       {
      #         description: "String",
      #         group_id: "String",
      #         group_name: "String",
      #         peering_status: "String",
      #         user_id: "String",
      #         vpc_id: "String",
      #         vpc_peering_connection_id: "String",
      #       },
      #     ],
      #   },
      # ],

      # ip_permissions_ingress: [
      #   {
      #     from_port: 22, 
      #     ip_protocol: "tcp", 
      #     ip_ranges: [
      #       {
      #         cidr_ip: "203.0.113.0/24", 
      #         description: "SSH access from the LA office", 
      #       }, 
      #     ], 
      #     to_port: 22, 
      #   }, 
      # ], 
      def create!( vpc_id:, group_name:, description:, ip_permissions_ingress: nil, ip_permissions_egress: nil )
        response = client.create_security_group(
          description: description, 
          group_name: group_name, 
          vpc_id: vpc_id, 
        )
        sg = find( response.group_id )
        if ip_permissions_ingress.present?
          sg.authorize_ingress!( ip_permissions: ip_permissions_ingress )
        end
        if ip_permissions_egress.present?
          sg.authorize_egress!( ip_permissions: ip_permissions_egress )
        end
        sg.set_tags!( :"Name" => group_name )
        sg.reload
      end
    end

    def model
      @model ||= Aws::EC2::SecurityGroup.new( group_id, client: self.class.client )
    end

    def authorize_ingress!( ip_permissions: )
      model.authorize_ingress( ip_permissions: ip_permissions )
    end

    def authorize_egress!( ip_permissions: )
      model.authorize_egress( ip_permissions: ip_permissions )
    end

    def set_tags!( tags )
      model.create_tags(tags: tags.map{|k,v| { key: k, value: v }})
    end
  end
end
