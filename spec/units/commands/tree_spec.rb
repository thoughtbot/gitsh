require 'spec_helper'
require 'gitsh/commands/tree'

describe Gitsh::Commands::Tree do
  let(:t) { stub(execute: true) }
  let(:f) { stub(execute: false) }

  describe Gitsh::Commands::Tree::Or do
    it 'executes f, then t' do
      Gitsh::Commands::Tree::Or.new(f, t).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end

    it 'executes t, then stops' do
      Gitsh::Commands::Tree::Or.new(t, f).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).never
    end
  end

  describe Gitsh::Commands::Tree::And do
    it 'executes f, then stops' do
      Gitsh::Commands::Tree::And.new(f, t).execute

      expect(t).to have_received(:execute).never
      expect(f).to have_received(:execute).once
    end

    it 'executes t, then executes f' do
      Gitsh::Commands::Tree::And.new(t, f).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end
  end

  describe Gitsh::Commands::Tree::Multi do
    it 'executes all regardless of return value' do
      Gitsh::Commands::Tree::Multi.new(
        Gitsh::Commands::Tree::Multi.new(f, t),
        Gitsh::Commands::Tree::Multi.new(t, f)
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).twice
    end
  end

  describe 'complex combinations of commands' do
    it 'calls t, t, then short circuts' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(t, t),
        f
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).never
    end

    it 'calls all t, f, t' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(t, f),
        t
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).once
    end

    it 'calls f, short circuts, then calls f' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        f
      ).execute

      expect(t).to have_received(:execute).never
      expect(f).to have_received(:execute).twice
    end

    it 'calls f, short circuts, calls f, calls t' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        Gitsh::Commands::Tree::Or.new(f, t)
      ).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).twice
    end

    it 'calls f, short circuts, calls t, short circuts' do
      Gitsh::Commands::Tree::Or.new(
        Gitsh::Commands::Tree::And.new(f, t),
        Gitsh::Commands::Tree::Or.new(t, t)
      ).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end
  end
end
