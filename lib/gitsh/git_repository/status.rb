module Gitsh
  class GitRepository
    class Status
      def initialize(status_porcelain, git_dir)
        @status_porcelain = status_porcelain
        @git_dir = git_dir
      end

      def initialized?
        if @initialized.nil?
          @initialized = File.exist?(git_dir)
        end
        @initialized
      end

      def has_untracked_files?
        status_porcelain.lines.select { |l| l.start_with?('??') }.any?
      end

      def has_modified_files?
        status_porcelain.lines.select { |l| l =~ /^ ?[A-Z]/ }.any?
      end

      private

      attr_reader :status_porcelain, :git_dir
    end
  end
end
