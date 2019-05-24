require 'yaml'
require_relative './configure'

module ActiveAws
  class Base

    @attributes = []
    @pool = nil

    class << self
      attr_accessor :attributes, :client_class_name
      attr_reader :pool
      
      def inherited( klass )
        klass.attributes = @attributes
        klass.client_class_name = @client_class_name
      end

      def load_config!( args, default_config=:default )
        raise "Config was already loaded!! You can't modify loaded config!!" if @pool.present?

        @pool = ConfigurePool.new( default_config, Thread.current )
        @specs = if args.is_a? Hash
          args
        elsif File.file?( args.to_s )
          YAML.load_file( args.to_s )
        else
          raise ArgumentError
        end

        @specs.each do |key, spec|
          @pool.add!( key, Configure.new( **spec.symbolize_keys ) )
        end
      end

      def configure
        c = Base.pool.get_with_context( Thread.current )
        raise "Configure couldn't be resolved!! Please confirm `aws.yml`." unless c
        c
      end

      def client
        client_class_name.constantize.new( **configure.default_client_params )
      end

      def with_configure( config_key )
        t = Thread.new(config_key) do |config_key|
          Base.pool.add_context!( Thread.current, config_key )
          yield
          # TODO: remove context.
        end
        t.join
      end
    end

    def initialize( **params )
      self.class.attributes.each do |k|
        method = "#{k}="
        self.send(method, params[k]) if params[k].present?
      end
      yield( self ) if block_given?
    end

    def to_h
      self.class.attributes.reduce({}) do |acc,k|
        acc[k] = self.send( k )
        acc
      end
    end
  end
end
