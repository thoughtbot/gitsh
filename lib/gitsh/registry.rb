require 'singleton'

module Gitsh
  class Registry
    include Singleton

    module Client
      def use_registry_for(*keys)
        keys.each do |key|
          define_method(key) { Registry.instance[key] }
          private(key)
        end
      end
    end

    def self.populate(conf_dir:)
      require 'gitsh/environment'
      require 'gitsh/git_repository'
      require 'gitsh/line_editor_history_filter'
      require 'gitsh/line_editor'

      instance[:repo] = Gitsh::GitRepository.new
      instance[:env] = Gitsh::Environment.new(config_directory: conf_dir)
      instance[:line_editor] = Gitsh::LineEditorHistoryFilter.new(
        Gitsh::LineEditor,
      )
    end

    def self.clear
      instance.clear
    end

    def initialize
      clear
    end

    def []=(name, value)
      objects[name] = value
    end

    def [](name)
      objects.fetch(name)
    end

    def clear
      @objects = {}
    end

    private

    attr_reader :objects
  end
end
