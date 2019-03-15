require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Unknown do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'outputs an error message' do
      env = spy('env', puts_error: nil)
      command = described_class.new('notacommand', [])

      command.execute(env)

      expect(env).to have_received(:puts_error).with(
        'gitsh: notacommand: command not found'
      )
    end
  end
end
