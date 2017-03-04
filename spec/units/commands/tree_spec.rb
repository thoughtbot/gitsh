require 'spec_helper'
require 'gitsh/commands/tree'

describe Gitsh::Commands::Tree do
  let(:t) { double(execute: true) }
  let(:f) { double(execute: false) }
  let(:env) { double(:env) }

  describe Gitsh::Commands::Tree::Or do
    it 'executes f, then t' do
      Gitsh::Commands::Tree::Or.new(f, t).execute(env)

      expect(t).to have_received(:execute).once.with(env)
      expect(f).to have_received(:execute).once.with(env)
    end

    it 'executes t, then stops' do
      Gitsh::Commands::Tree::Or.new(t, f).execute(env)

      expect(t).to have_received(:execute).once.with(env)
      expect(f).not_to have_received(:execute)
    end
  end

  describe Gitsh::Commands::Tree::And do
    it 'executes f, then stops' do
      Gitsh::Commands::Tree::And.new(f, t).execute(env)

      expect(t).not_to have_received(:execute)
      expect(f).to have_received(:execute).once.with(env)
    end

    it 'executes t, then executes f' do
      Gitsh::Commands::Tree::And.new(t, f).execute(env)

      expect(t).to have_received(:execute).once.with(env)
      expect(f).to have_received(:execute).once.with(env)
    end
  end

  describe Gitsh::Commands::Tree::Multi do
    it 'executes all regardless of return value' do
      Gitsh::Commands::Tree::Multi.new(
        Gitsh::Commands::Tree::Multi.new(f, t),
        Gitsh::Commands::Tree::Multi.new(t, f)
      ).execute(env)

      expect(t).to have_received(:execute).twice.with(env)
      expect(f).to have_received(:execute).twice.with(env)
    end
  end

  describe 'complex combinations of commands' do
    it 'calls t, t, then short circuts' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(t, t),
        f
      ).execute(env)

      expect(t).to have_received(:execute).twice.with(env)
      expect(f).not_to have_received(:execute)
    end

    it 'calls all t, f, t' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(t, f),
        t
      ).execute(env)

      expect(t).to have_received(:execute).twice.with(env)
      expect(f).to have_received(:execute).once.with(env)
    end

    it 'calls f, short circuts, then calls f' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        f
      ).execute(env)

      expect(t).not_to have_received(:execute)
      expect(f).to have_received(:execute).twice.with(env)
    end

    it 'calls f, short circuts, calls f, calls t' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        Gitsh::Commands::Tree::Or.new(f, t)
      ).execute(env)

      expect(t).to have_received(:execute).once.with(env)
      expect(f).to have_received(:execute).twice.with(env)
    end

    it 'calls f, short circuts, calls t, short circuts' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        Gitsh::Commands::Tree::Or.new(t, t)
      ).execute(env)

      expect(t).to have_received(:execute).once.with(env)
      expect(f).to have_received(:execute).once.with(env)
    end
  end
end
