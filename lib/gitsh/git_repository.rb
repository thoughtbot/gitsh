require 'open3'
require 'shellwords'

module Gitsh
  class GitRepository
    def initialize(env)
      @env = env
    end

    def initialized?
      git_dir && File.exist?(git_dir)
    end

    def current_head
      current_branch_name || current_tag_name || abbreviated_sha
    end

    def has_untracked_files?
      status.untracked_files.any?
    end

    def has_modified_files?
      status.modified_files.any?
    end

    def heads
      git_output(%{for-each-ref --format='%(refname:short)'}).
        lines.
        map { |line| line.chomp }
    end

    def commands
      git_output('help -a').
        lines.
        select { |line| line =~ /^  [a-z]/ }.
        map { |line| line.split(/\s+/) }.
        flatten.
        reject { |cmd| cmd.empty? || cmd =~ /--/ }.
        sort
    end

    def aliases
      git_output(%q(config --get-regexp '^alias\.')).
        lines.
        map { |line| line.split(' ').first.sub(/^alias\./, '') }
    end

    def config(name, default=nil)
      command = git_command("config --get #{Shellwords.escape(name)}")
      out, err, status = Open3.capture3(command)
      if status.success?
        out.chomp
      else
        default
      end
    end

    private

    attr_reader :env

    def current_branch_name
      branch_name = git_output('symbolic-ref HEAD --short')
      unless branch_name.empty?
        branch_name
      end
    end

    def current_tag_name
      tag_name = git_output('describe --exact-match HEAD')
      unless tag_name.empty?
        tag_name
      end
    end

    def abbreviated_sha
      sha = git_output('rev-parse HEAD')
      unless sha.empty?
        "#{sha[0,7]}..."
      end
    end

    def status
      StatusParser.new(git_output('status --porcelain'))
    end

    def git_dir
      git_output('rev-parse --git-dir')
    end

    def git_output(command)
      Open3.capture3(git_command(command)).first.chomp
    end

    def git_command(sub_command)
      "#{env.git_command} #{sub_command}"
    end

    class StatusParser
      def initialize(status_porcelain)
        @status_porcelain = status_porcelain
      end

      def untracked_files
        status_porcelain.lines.select { |l| l.start_with?('??') }
      end

      def modified_files
        status_porcelain.lines.select { |l| l =~ /^ ?[A-Z]/ }
      end

      private

      attr_reader :status_porcelain
    end
  end
end
