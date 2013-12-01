require 'parslet'
require 'gitsh/git_command'

module Gitsh
  class Transformer < Parslet::Transform
    rule(literal: simple(:literal)) { literal }

    rule(arg: subtree(:parts)) { parts.join('') }

    rule(git_cmd: simple(:cmd)) do |context|
      GitCommand.new(context[:env], context[:cmd])
    end

    rule(git_cmd: simple(:cmd), args: subtree(:args)) do |context|
      GitCommand.new(context[:env], context[:cmd], context[:args])
    end
  end
end
