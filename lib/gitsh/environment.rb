require 'gitsh/error'
require 'gitsh/git_repository'
require 'gitsh/line_editor'
require 'gitsh/magic_variables'
require 'gitsh/registry'

module Gitsh
  class Environment
    extend Registry::Client
    use_registry_for :repo

    DEFAULT_GIT_COMMAND = '/usr/bin/env git'.freeze
    DEFAULT_CONFIG_DIRECTORY = '/usr/local/etc/gitsh'.freeze

    attr_reader :input_stream, :output_stream, :error_stream, :config_directory

    def initialize(
      input_stream: $stdin, output_stream: $stdout, error_stream: $stderr,
      config_directory: DEFAULT_CONFIG_DIRECTORY
    )
      @input_stream = input_stream
      @output_stream = output_stream
      @error_stream = error_stream
      @config_directory = config_directory
      @variables = Hash.new
    end

    def initialize_copy(original)
      super
      @variables = variables.clone
      self
    end

    def git_command(force_default = false)
      if force_default
        DEFAULT_GIT_COMMAND
      else
        fetch('gitsh.gitCommand', true) { DEFAULT_GIT_COMMAND }
      end
    end

    def git_command=(git_command)
      self['gitsh.gitCommand'] = git_command
    end

    def []=(key, value)
      variables[key.to_sym] = value
    end

    def fetch(key, force_default_git_command = false, &block)
      magic_variables.fetch(key.to_sym) do
        variables.fetch(key.to_sym) do
          repo.config(key.to_s, force_default_git_command, &block)
        end
      end
    rescue KeyError
      raise Gitsh::UnsetVariableError, "Variable '#{key}' is not set"
    end

    def available_variables
      (
        magic_variables.available_variables +
        variables.keys +
        repo.available_config_variables
      ).uniq.sort
    end

    def config_variables
      Hash[variables.select { |key, value| key.to_s.include?('.') }]
    end

    def print(*args)
      output_stream.print(*args)
    end

    def puts(*args)
      output_stream.puts(*args)
    end

    def puts_error(*args)
      error_stream.puts(*args)
    end

    def tty?
      input_stream.tty?
    end

    def local_aliases
      variables.keys.
        select { |key| key.to_s.start_with?('alias.') }.
        map { |key| key.to_s.sub('alias.', '') }
    end

    private

    attr_reader :variables

    def magic_variables
      @_magic_variables ||= MagicVariables.new
    end
  end
end
