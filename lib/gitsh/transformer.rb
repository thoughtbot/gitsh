require 'parslet'
require 'gitsh/commands/git_command'
require 'gitsh/commands/internal_command'
require 'gitsh/commands/noop'
require 'gitsh/commands/shell_command'
require 'gitsh/commands/tree'

module Gitsh
  class Transformer < Parslet::Transform
    def self.command_rule(type, command_class)
      rule(type => simple(:cmd)) do |context|
        command_class.new(context[:env], context[:cmd])
      end

      rule(type => simple(:cmd), args: sequence(:args)) do |context|
        command_class.new(context[:env], context[:cmd], context[:args].compact)
      end
    end

    rule(literal: simple(:literal)) do
      literal
    end

    rule(empty_string: simple(:empty_string)) do
      ''
    end

    rule(var: simple(:var)) do |context|
      key = context[:var]
      context[:env][key]
    end

    rule(arg: subtree(:parts)) do |context|
      parts = Array(context[:parts]).compact
      if parts.any?
        parts.join('')
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
