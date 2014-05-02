require 'parslet'
require 'gitsh/comment'
require 'gitsh/git_command'
require 'gitsh/internal_command'
require 'gitsh/shell_command'

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

    rule(comment: simple(:comment)) do |context|
      Comment.new
    end

    command_rule(:git_cmd, GitCommand)
    command_rule(:internal_cmd, InternalCommand)
    command_rule(:shell_cmd, ShellCommand)

    rule(multi: { left: subtree(:left), right: subtree(:right) }) do
      Tree::Multi.new(left, right)
    end

    rule(or: { left: subtree(:left), right: subtree(:right) }) do
      Tree::Or.new(left, right)
    end

    rule(and: { left: subtree(:left), right: subtree(:right) }) do
      Tree::And.new(left, right)
    end
  end
end
