module ActiveAws
  class TagSpec

    class << self
      def parse( tag_specifications )
        tag_specifications.map do |spec|
          spec = spec.deep_symbolize_keys
          self.new(
            spec[:resource_type], 
            spec[:tags].map{|t| [t[:key], t[:value]]}.to_h 
          )
        end
      end
    end

    attr_reader :resource_type, :tags
    def initialize( resource_type, tags )
      @resource_type = resource_type
      @tags = tags
    end

    def add_tag!( key, value )
      @tags[key.to_s] = value
    end

    def merge( extra_tags )
      self.class.new( resource_type, tags.merge(extra_tags) )
    end

    def to_param
      {
        resource_type: resource_type,
        tags: tags.map{|k,v| { key: k, value: v}}
      }
    end
  end
end
