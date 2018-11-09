require 'yaml'
require_relative './configure'

module ActiveAws
  class Base

    @attributes = []

    class << self
      attr_accessor :attributes
      attr_reader :root_configure
      
      def inherited( klass )
        klass.attributes = @attributes
      end

      def load_config!( args )
        @config = if args.is_a? Hash
          args
        elsif File.file?( args.to_s )
          YAML.load_file( args.to_s )
        else
          raise ArgumentError
        end
        @root_configure = Configure.new( **@config.symbolize_keys )
      end

      def configure
        Base.root_configure
      end
    end

    def initialize( **params )
      self.class.attributes.each do |k|
        method = "#{k}="
        self.send(method, params[k]) if params[k].present?
      end
      yield( self ) if block_given?
    end

    def name
      name_tag = tags.detect{|t| t[:key].to_s == "Name"}
      return nil unless name_tag
      name_tag[:value]
    end

    def to_h
      self.class.attributes.reduce({}) do |acc,k|
        acc[k] = self.send( k )
        acc
      end
    end
  end
end
