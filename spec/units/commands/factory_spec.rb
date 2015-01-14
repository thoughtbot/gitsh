require 'spec_helper'
require 'gitsh/commands/factory'

describe Gitsh::Commands::Factory do
  describe '#build' do
    it 'returns an instance of the given command class' do
      env = stub('env')
      instance = stub('instance')
      command_class = stub('command_class', new: instance)
      context = { env: env, cmd: 'status' }
      factory = Gitsh::Commands::Factory.new(command_class, context)

      built_instance = factory.build

      expect(built_instance).to be instance
      expect(command_class).to have_received(:new).with(
        env,
        'status',
        instance_of(Gitsh::ArgumentList),
      )
    end
  end
end
