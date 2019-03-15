require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Exit do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'exits the program' do
      command = described_class.new('exit', [])
      expect { command.execute(double('env')) }.to raise_exception(SystemExit)
    end
  end
end
