require 'spec_helper'
require 'gitsh/tree'

describe Gitsh::Tree do
  let(:t) { stub(execute: true) }
  let(:f) { stub(execute: false) }

  describe Gitsh::Tree::Or do
    it 'executes f, then t' do
      Gitsh::Tree::Or.new(f, t).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end

    it 'executes t, then stops' do
      Gitsh::Tree::Or.new(t, f).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).never
    end
  end

  describe Gitsh::Tree::And do
    it 'executes f, then stops' do
      Gitsh::Tree::And.new(f, t).execute

      expect(t).to have_received(:execute).never
      expect(f).to have_received(:execute).once
    end

    it 'executes t, then executes f' do
      Gitsh::Tree::And.new(t, f).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end
  end

  describe Gitsh::Tree::Multi do
    it 'executes all regardless of return value' do
      Gitsh::Tree::Multi.new(
        Gitsh::Tree::Multi.new(f, t),
        Gitsh::Tree::Multi.new(t, f)
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).twice
    end
  end

  describe 'complex combinations of commands' do
    it 'calls t, t, then short circuts' do
      Gitsh::Tree::Or.new(
        Gitsh::Tree::And.new(t, t),
        f
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).never
    end

    it 'calls all t, f, t' do
      Gitsh::Tree::Or.new(
        Gitsh::Tree::And.new(t, f),
        t
      ).execute

      expect(t).to have_received(:execute).twice
      expect(f).to have_received(:execute).once
    end

    it 'calls f, short circuts, then calls f' do
      Gitsh::Tree::Or.new(
        Gitsh::Tree::And.new(f, t),
        f
      ).execute

      expect(t).to have_received(:execute).never
      expect(f).to have_received(:execute).twice
    end

    it 'calls f, short circuts, calls f, calls t' do
      Gitsh::Tree::Or.new(
        Gitsh::Tree::And.new(f, t),
        Gitsh::Tree::Or.new(f, t)
      ).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).twice
    end

    it 'calls f, short circuts, calls t, short circuts' do
      Gitsh::Tree::Or.new(
        Gitsh::Tree::And.new(f, t),
        Gitsh::Tree::Or.new(t, t)
      ).execute

      expect(t).to have_received(:execute).once
      expect(f).to have_received(:execute).once
    end
  end
end
