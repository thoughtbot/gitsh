require 'parslet'
require 'gitsh/argument_builder'
require 'gitsh/argument_list'
require 'gitsh/commands/factory'
require 'gitsh/commands/git_command'
require 'gitsh/commands/internal_command'
require 'gitsh/commands/noop'
require 'gitsh/commands/shell_command'
require 'gitsh/commands/tree'

module Gitsh
  class Transformer < Parslet::Transform
    def self.command_rule(type, command_class)
      rule(type => simple(:cmd)) do |context|
        Commands::Factory.new(command_class, context).build
      end

      rule(type => simple(:cmd), args: sequence(:args)) do |context|
        Commands::Factory.new(command_class, context).build
      end
    end

    rule(literal: simple(:literal)) do
      lambda { |arg_builder| arg_builder.add_literal(literal) }
    end

    rule(empty_string: simple(:empty_string)) do
      lambda { |arg_builder| arg_builder.add_literal('') }
    end

    rule(var: simple(:var)) do
      lambda { |arg_builder| arg_builder.add_variable(var) }
    end

    rule(arg: subtree(:parts)) do
      Gitsh::ArgumentBuilder.build do |arg_builder|
        Array(parts).each do |part|
          part.call(arg_builder)
        end
      end
    end

    rule(blank: simple(:blank)) do |context|
      Commands::Noop.new
    end

    rule(comment: simple(:comment)) do |context|
      Commands::Noop.new
    end

    command_rule(:git_cmd, Commands::GitCommand)
    command_rule(:internal_cmd, Commands::InternalCommand)
    command_rule(:shell_cmd, Commands::ShellCommand)

    rule(multi: { left: subtree(:left), right: subtree(:right) }) do
      Commands::Tree::Multi.new(left, right)
    end

    rule(or: { left: subtree(:left), right: subtree(:right) }) do
      Commands::Tree::Or.new(left, right)
    end

    rule(and: { left: subtree(:left), right: subtree(:right) }) do
      Commands::Tree::And.new(left, right)
    end
  end
end
