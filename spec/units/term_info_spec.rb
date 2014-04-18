require 'spec_helper'
require 'gitsh/term_info'

describe Gitsh::TermInfo do
  describe '#color_support?' do
    context 'on a 256 color terminal' do
      it 'returns true' do
        stub_tput_invocation output: "256\n"

        result = Gitsh::TermInfo.instance.color_support?

        expect(result).to be_true
      end
    end

    context 'on a black and white terminal' do
      it 'returns false' do
        stub_tput_invocation output: "-1\n"

        result = Gitsh::TermInfo.instance.color_support?

        expect(result).to be_false
      end
    end

    context 'when tput fails' do
      it 'returns false' do
        stub_tput_invocation error: "unknonwn capability\n", success: false

        result = Gitsh::TermInfo.instance.color_support?

        expect(result).to be_false
      end
    end
  end

  context '#lines' do
    it 'returns the number of lines the terminal has' do
      stub_tput_invocation output: "24\n"

      result = Gitsh::TermInfo.instance.lines

      expect(result).to eq 24
    end
  end

  context '#cols' do
    it 'returns the number of columns the terminal has' do
      stub_tput_invocation output: "80\n"

      result = Gitsh::TermInfo.instance.cols

      expect(result).to eq 80
    end
  end

  def stub_tput_invocation(options = {})
    Open3.stubs(:capture3).returns [
      options.fetch(:output, ''),
      options.fetch(:error, ''),
      stub('exit_status', success?: options.fetch(:success, true))
    ]
  end
end
