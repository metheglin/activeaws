module ActiveAws
  class ConfigurePool

    def initialize( default_config_key, default_context_key )
      @configures = {}
      @contexts = Hash[{
        default_context_key => default_config_key.to_sym
      }]
    end

    def add!( config_key, config )
      @configures[config_key.to_sym] = config
    end

    def add_context!( context_key, config_key )
      @contexts[context_key] = config_key
    end

    def get_with_context( context_key )
      @configures[@contexts[context_key]]
    end
  end
end
