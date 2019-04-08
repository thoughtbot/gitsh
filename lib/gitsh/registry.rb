require 'singleton'

module Gitsh
  class Registry
    include Singleton

    module Client
      def use_registry_for(*keys)
        keys.each do |key|
          define_method(key) { Registry[key] }
          private(key)
        end
      end
    end

    def self.[]=(name, value)
      instance[name] = value
    end

    def self.[](name)
      instance[name]
    end

    def self.clear
      instance.clear
    end

    def self.env
      instance[:env]
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
