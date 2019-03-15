require 'gitsh/error'

module Gitsh::Commands
  module InternalCommand
    def self.new(command, arg_values)
      command_class(command).new(command, arg_values)
    end

    def self.commands
      COMMAND_CLASSES.keys.map { |key| ":#{key}" }
    end

    def self.command_class(command)
      COMMAND_CLASSES.fetch(command.to_sym, Unknown)
    end

    class Base
      def initialize(command, arg_values)
        @command = command
        @arg_values = arg_values
      end

      def execute
        raise NotImplementedError,
          'InternalCommand::Base subclasses must provide an #execute method'
      end

      def self.help_message
        raise NotImplementedError,
          'InternalCommand::Base subclasses must provide a .help_message method'
      end

      private

      attr_reader :command, :arg_values
    end

    class Set < Base
      def self.help_message
        <<-TXT
usage: :set variable value
Sets a variable in the gitsh environment to the given value. The value of the
variable can be used in subsequent commands using the variable name with a
dollar prefix.
TXT
      end

      def execute(env)
        if valid_arguments?
          key, value = arg_values
          env[key] = value
          true
        else
          env.puts_error 'usage: :set variable value'
          false
        end
      end

      private

      def valid_arguments?
        arg_values.length == 2
      end
    end

    class Echo < Base
      def self.help_message
        <<-TXT
usage: :echo string ...
Prints the given strings to standard output, followed by a newline. All
whitespace is collapsed into one space. This can be useful for viewing the value
of a variable.
TXT
      end

      def execute(env)
        env.puts arg_values.join(' ')
        true
      end
    end

    class Chdir < Base
      def self.help_message
        <<-TXT
usage: :cd [path]
Changes directory to the given path. Run with no arguments to change to the
repository's root directory.
TXT
      end

      def execute(env)
        if valid_arguments?
          change_directory(env)
        else
          env.puts_error 'usage: :cd path'
          false
        end
      end

      private

      def valid_arguments?
        arg_values.length == 0 || arg_values.length == 1
      end

      def change_directory(env)
        Dir.chdir(path(env))
      rescue Errno::ENOENT
        env.puts_error 'gitsh: cd: No such directory'
        false
      rescue Errno::ENOTDIR
        env.puts_error 'gitsh: cd: Not a directory'
        false
      end

      def path(env)
        if arg_values.empty?
          env.fetch(:_root)
        else
          File.expand_path(arg_values.first)
        end
      end
    end

    class Exit < Base
      def self.help_message
        <<-TXT
usage: :exit
Ends the gitsh session. You can also do this with an EOF character, usually by
pressing ctrl+d.
TXT
      end

      def execute(_env)
        exit
      end
    end

    class Help < Base
      def self.help_message
        <<-TXT
usage: :help [command]
Displays help about the given command. Run with no arguments for a list of all
commands.
TXT
      end

      def execute(env)
        env.puts InternalCommand.command_class(subject(env)).help_message
        true
      end

      private

      def subject(env)
        arg_values.first.to_s.sub(/^:/, '')
      end
    end

    class Source < Base
      USAGE_MESSAGE = 'usage: :source path'.freeze

      def self.help_message
        <<-TXT
#{USAGE_MESSAGE}
Runs the commands in the given file.
TXT
      end

      def execute(env)
        if valid_arguments?
          run_script(env)
        else
          env.puts_error USAGE_MESSAGE
          false
        end
      end

      private

      def run_script(env)
        Gitsh::FileRunner.run(env: env, path: path)
        true
      rescue Gitsh::ParseError => e
        env.puts_error("gitsh: #{e.message}")
        false
      end

      def valid_arguments?
        arg_values.length == 1
      end

      def path
        File.expand_path(arg_values.first)
      end
    end

    class Unknown < Base
      def execute(env)
        env.puts_error("gitsh: #{command}: command not found")
        false
      end

      def self.help_message
        <<-TXT
You may use the following built-in commands:
#{InternalCommand.commands.sort.map { |c| "\t#{c}" }.join("\n")}

Type :help [command] for more specific info
TXT
      end
    end

    COMMAND_CLASSES = {
      set: Set,
      cd: Chdir,
      exit: Exit,
      q: Exit,
      echo: Echo,
      help: Help,
      source: Source,
    }.freeze
  end
end
