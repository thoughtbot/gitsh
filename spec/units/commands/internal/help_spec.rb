require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Help do
  it_behaves_like "an internal command"

  describe "#execute" do
    context "with no arguments" do
      it "prints out some stuff" do
        env = spy('env', puts: nil)
        command = described_class.new('help', [])

        expect(command.execute(env)).to be_truthy
        expect(env).to have_received(:puts).at_least(1).times
      end
    end

    context "with an argument that matches an existing command" do
      it "prints out command-specific information" do
        env = spy('env', puts: nil)
        command = described_class.new('help', ['set'])
        set_command = double('Set', help_message: 'Sets variables')
        allow(Gitsh::Commands::InternalCommand).to receive(:command_class).
          with('set').
          and_return(set_command)

        expect(command.execute(env)).to be_truthy
        expect(env).to have_received(:puts).with('Sets variables')
      end
    end

    context 'with a colon-prefixed argument' do
      it 'strips the colon' do
        env = spy('env', puts: nil)
        command = described_class.new('help', [':set'])
        set_command = double('Set', help_message: 'Sets variables')
        allow(Gitsh::Commands::InternalCommand).to receive(:command_class).
          with('set').
          and_return(set_command)

        expect(command.execute(env)).to be_truthy
        expect(env).to have_received(:puts).with('Sets variables')
      end
    end

    context "with arguments that don't match an existing command" do
      it "prints out some stuff" do
        env = spy('env', puts: nil)
        command = described_class.new(
          'help',
          ["we don't do this here"],
        )

        expect(command.execute(env)).to be_truthy
        expect(env).to have_received(:puts).at_least(1).times
      end
    end
  end
end
