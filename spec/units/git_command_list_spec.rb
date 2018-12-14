require 'spec_helper'
require 'gitsh/git_command_list'

describe Gitsh::GitCommandList do
  describe '#to_a' do
    it 'produces the list of porcelain commands' do
      commands = Gitsh::GitCommandList.new(env).to_a

      expect(commands).to include %(add)
      expect(commands).to include %(commit)
      expect(commands).to include %(checkout)
      expect(commands).to include %(status)
      expect(commands).not_to include %(add--interactive)
      expect(commands).not_to include ''
    end
  end

  def env
    double(git_command: '/usr/bin/env git')
  end
end
