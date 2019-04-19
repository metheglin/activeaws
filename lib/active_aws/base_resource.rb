module ActiveAws
  class BaseResource < Base

    @attributes = []

    class << self
      attr_accessor :resource_name, :resource_id_name, :resource_identifier_name
      
      def inherited( klass )
        klass.resource_name = @resource_name
        klass.resource_id_name = @resource_id_name
        klass.resource_identifier_name = @resource_identifier_name
      end
    end

    class << self
      def find( id )
        find_one(**Hash[{
          :"#{resource_id_name.pluralize}" => [id], 
        }])
      end

      def find_by_name( name )
        condition = if resource_identifier_name.present?
          Hash[{
            :"#{resource_identifier_name.pluralize}" => [name],
          }]
        else
          {
            filters: [{ name: "tag:Name", values: [name] }], 
          }
        end
        find_one( **condition )
      end

      def find_one( **args )
        response = client.send("describe_#{resource_name.pluralize}", args)
        list = detect_resources_from( response )
        return nil if list.blank?
        new( **list[0].to_h )
      end

      def where( **args )
        filter_params = args.map{|k, v| { name: k, values: Array.wrap(v) }}
        response = client.send("describe_#{resource_name.pluralize}", {
          filters: filter_params, 
        })
        list = detect_resources_from( response )
        list.map{|i| new( **i.to_h )}
      end

      def all
        response = client.send("describe_#{resource_name.pluralize}")
        list = detect_resources_from( response )
        list.map{|i| new( **i.to_h )}
      end

      def detect_resources_from( response )
        response.send(resource_name.pluralize)
      end
    end

    def id
      self.send( self.class.resource_id_name )
    end

    def name
      self.class.resource_identifier_name.present? ?
        self.send( self.class.resource_identifier_name ) :
        name_by_tag
    end

    def name_by_tag
      name_tag = tags.detect{|t| t[:key].to_s == "Name"}
      return nil unless name_tag
      name_tag[:value]
    end

    def reload
      self.class.find( id )
    end
  end
end
