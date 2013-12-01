require 'parslet'
require 'gitsh/git_command'

module Gitsh
  class Transformer < Parslet::Transform
    rule(literal: simple(:literal)) { literal }

    rule(arg: subtree(:parts)) { parts.join('') }

    rule(git_cmd: simple(:cmd)) { GitCommand.new(cmd) }
    rule(git_cmd: simple(:cmd), args: subtree(:args)) { GitCommand.new(cmd, args) }
  end
end
