require 'spec_helper'
require 'gitsh/terminal'
require 'rspec/mocks/standalone'

describe Gitsh::Terminal do
  describe '#color_support?' do
    context 'on a 256 color terminal' do
      it 'returns true' do
        stub_command 'tput colors', output: "256\n"

        result = Gitsh::Terminal.new.color_support?

        expect(result).to be_truthy
      end
    end

    context 'on a black and white terminal' do
      it 'returns false' do
        stub_command 'tput colors', output: "-1\n"

        result = Gitsh::Terminal.new.color_support?

        expect(result).to be_falsey
      end
    end

    context 'when tput fails' do
      it 'returns false' do
        stub_command 'tput colors', success: false

        result = Gitsh::Terminal.new.color_support?

        expect(result).to be_falsey
      end
    end
  end

  describe '#size' do
    it 'returns an array containing the number of lines and columns the terminal has' do
      stub_command 'stty size', output: "24 80\n"

      result = Gitsh::Terminal.new.size

      expect(result).to eq [24, 80]
    end

    context 'when stty fails' do
      it 'falls back to tput without environment variables' do
        stub_command 'stty size', success: false
        stub_command 'env LINES="" tput lines', output: "24\n"
        stub_command 'env COLUMNS="" tput cols', output: "80\n"

        result = Gitsh::Terminal.new.size

        expect(result).to eq [24, 80]
      end
    end

    context 'when stty and tput without environment variables fail' do
      it 'falls back to tput with environment variables' do
        stub_command 'stty size', success: false
        stub_command 'env LINES="" tput lines', success: false
        stub_command 'env COLUMNS="" tput cols', success: false
        stub_command 'tput lines', output: "24\n"
        stub_command 'tput cols', output: "80\n"

        result = Gitsh::Terminal.new.size

        expect(result).to eq [24, 80]
      end
    end

    context 'when everything fails' do
      it 'raises' do
        stub_command anything, success: false

        expect { Gitsh::Terminal.new.size }.
          to raise_error(Gitsh::Terminal::UnknownSizeError)
      end
    end
  end

  def stub_command(command, options = {})
    CommandStubber.new(
      command,
      options.fetch(:success, true),
      options.fetch(:output, '')
    ).stub
  end

  class CommandStubber
    include RSpec::Mocks::ExampleMethods

    def initialize(command, success, output)
      @command = command
      @success = success
      @output = output
    end

    def stub
      allow(IO).to receive(:popen).with(command, err: '/dev/null') do
        stub_exit_status
        output
      end
    end

    private

    attr_reader :command, :success, :output

    def stub_exit_status
      ensure_exit_status_exists
      allow($?).to receive(:success?).and_return(success)
    end

    def ensure_exit_status_exists
      `pwd`
    end
  end
end
