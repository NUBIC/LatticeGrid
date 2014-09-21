module LatticeGrid
  module Importer
    class Configuration
      attr_writer :faculty_publication_source

      def initialize(&config)
        self.enhance(&config) if config
      end

      def faculty_publication_source
        @faculty_publication_source ||= :pub_med
      end

      ##
      # Updates the configuration via the {ConfiguratorLanguage DSL}.
      #
      # @return [Configuration] itself
      def enhance(&additional_config)
        Configurator.new(self, &additional_config)
        self
      end
    end

    module ConfiguratorLanguage
      def method_missing(m, *args, &block)
        if @config.respond_to?(:"#{m}=")
          @config.send(:"#{m}=", *args)
        else
          super
        end
      end
    end

    ##
    # @private
    class Configurator
      include ConfiguratorLanguage

      def initialize(target, &block)
        @config = target
        instance_eval(&block)
      end
    end
  end
end