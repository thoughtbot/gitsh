require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Help do
  it_behaves_like "an internal command"

  describe "#execute" do
    context "with no arguments" do
      it "prints out some stuff" do
        env = stub('env', puts: nil)
        command = described_class.new(env, 'help', arguments())

        expect(command.execute).to be_truthy
        expect(env).to have_received(:puts).at_least_once
      end
    end

    context "with an argument that matches an existing command" do
      it "prints out command-specific information" do
        env = stub('env', puts: nil)
        command = described_class.new(env, 'help', arguments('set'))
        set_command = stub('Set', help_message: 'Sets variables')
        Gitsh::Commands::InternalCommand.stubs(:command_class).
          with('set').
          returns(set_command)

        expect(command.execute).to be_truthy
        expect(env).to have_received(:puts).with('Sets variables')
      end
    end

    context 'with a colon-prefixed argument' do
      it 'strips the colon' do
        env = stub('env', puts: nil)
        command = described_class.new(env, 'help', arguments(':set'))
        set_command = stub('Set', help_message: 'Sets variables')
        Gitsh::Commands::InternalCommand.stubs(:command_class).
          with('set').
          returns(set_command)

        expect(command.execute).to be_truthy
        expect(env).to have_received(:puts).with('Sets variables')
      end
    end

    context "with arguments that don't match an existing command" do
      it "prints out some stuff" do
        env = stub('env', puts: nil)
        command = described_class.new(
          env,
          'help',
          arguments("we don't do this here"),
        )

        expect(command.execute).to be_truthy
        expect(env).to have_received(:puts).at_least_once
      end
    end
  end
end
