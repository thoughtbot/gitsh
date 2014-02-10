require 'gitsh/git_repository'

module Gitsh
  class Environment
    DEFAULT_GIT_COMMAND = '/usr/bin/env git'.freeze

    attr_reader :output_stream, :error_stream
    attr_accessor :git_command

    def initialize(options={})
      @output_stream = options.fetch(:output_stream, $stdout)
      @error_stream = options.fetch(:error_stream, $stderr)
      @git_command = DEFAULT_GIT_COMMAND
      @variables = Hash.new
      @repo = options.fetch(:repository_factory, Gitsh::GitRepository).new(self)
    end

    def [](key)
      variables[key.to_sym] || repo.config(key.to_s)
    end

    def []=(key, value)
      variables[key.to_sym] = value
    end

    def fetch(key, default)
      variables.fetch(key.to_sym, repo.config(key.to_s, default))
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

    def repo_heads
      repo.heads
    end

    def repo_current_head
      repo.current_head
    end

    def repo_initialized?
      repo.initialized?
    end

    def repo_has_modified_files?
      repo.has_modified_files?
    end

    def repo_has_untracked_files?
      repo.has_untracked_files?
    end

    def git_commands
      repo.commands
    end

    def git_aliases
      (repo.aliases + local_aliases).sort
    end

    private

    attr_reader :variables, :repo

    def local_aliases
      variables.keys.
        select { |key| key.to_s.start_with?('alias.') }.
        map { |key| key.to_s.sub('alias.', '') }
    end
  end
end
