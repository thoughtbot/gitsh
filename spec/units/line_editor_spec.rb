require 'spec_helper'
require 'gitsh/line_editor'

describe Gitsh::LineEditor do
  INPUTRC = 'INPUTRC'
  SAVED_ENV = %w[COLUMNS LINES]

  before do
    @saved_env = ENV.values_at(*SAVED_ENV)
    @inputrc, ENV[INPUTRC] = ENV[INPUTRC], IO::NULL

    @saved_line_editor_settings = {
      completer_quote_characters: described_class.completer_quote_characters || '',
      completer_word_break_characters: described_class.completer_word_break_characters || ' ',
      completion_append_character: described_class.completion_append_character,
      completion_suppress_quote: described_class.completion_suppress_quote,
      completion_case_fold: described_class.completion_case_fold,
      completion_proc: described_class.completion_proc,
      pre_input_hook: described_class.pre_input_hook,
      special_prefixes: described_class.special_prefixes,
    }

    described_class.completion_append_character = ' '
    described_class.completion_suppress_quote = false
    described_class.delete_text
    described_class.point = 0
  end

  after do
    ENV[INPUTRC] = @inputrc

    @saved_line_editor_settings.each do |key, value|
      described_class.send("#{key}=", value)
    end

    described_class::HISTORY.clear
    described_class.delete_text
    described_class.point = 0
    described_class.input = nil
    described_class.output = nil
    SAVED_ENV.each_with_index {|k, i| ENV[k] = @saved_env[i] }
  end

  describe '.readline' do
    it 'returns what the user typed as a tainted string' do
      with_temp_stdio do |stdio|
        stdio.type("user input\n")

        line = described_class.readline('> ', false)

        expect(line).to eq 'user input'
        expect(line).to be_tainted
      end
    end

    it 'outputs the prompt' do
      with_temp_stdio do |stdio|
        stdio.type("user input\n")

        described_class.readline('> ', false)

        expect(stdio.output).to start_with '> '
      end
    end

    context 'when passed add_hist' do
      it 'adds the input to the history' do
        with_temp_stdio do |stdio|
          stdio.type("user input\n")

          described_class.readline('> ', true)

          expect(described_class::HISTORY.length).to eq 1
          expect(described_class::HISTORY[0]).to eq 'user input'
        end
      end
    end

    context 'when the output stream is closed' do
      it 'raises an IOError' do
        IO.pipe do |read, write|
          described_class.input = read
          described_class.output = write
          write.close

          expect { described_class.readline }.to raise_exception(IOError)
        end
      end
    end

    context 'when $SAFE is 1' do
      it 'raises when given a tainted prompt' do
        with_temp_stdio do |stdio|
          stdio.type("user input\n")
          expect {
            Thread.start {
              $SAFE = 1
              described_class.readline('> '.taint)
            }.join
          }.to raise_exception(SecurityError)
        end
      end

      it 'does not raise when given an untainted prompt' do
        with_temp_stdio do |stdio|
          stdio.type("user input\n")
          expect {
            Thread.start {
              $SAFE = 1
              described_class.readline('> ')
            }.join
          }.not_to raise_exception
        end
      end
    end
  end

  describe '.input=' do
    it 'raises when given something other than a File' do
      expect { described_class.input = $stdin }.not_to raise_exception
      expect { described_class.input = :input }.to raise_exception(TypeError)
    end
  end

  describe '.output=' do
    it 'raises when given something other than a File' do
      expect { described_class.output = $stdout }.not_to raise_exception
      expect { described_class.output = :output }.to raise_exception(TypeError)
    end
  end

  describe 'line editing' do
    REVERSE_HISTORY_SEARCH = "\C-r"

    it 'supports reverse history search' do
      with_temp_stdio do |stdio|
        described_class::HISTORY << "hello"
        stdio.type("#{REVERSE_HISTORY_SEARCH}e\n")

        line = described_class.readline

        expect(line).to eq "hello"
      end
    end

    it 'supports reverse history search with multi-byte history' do
      unless Encoding.find("locale") == Encoding::UTF_8
        skip 'this test needs UTF-8 locale'
      end

      with_temp_stdio do |stdio|
        described_class::HISTORY << "\u3042\u3093"
        described_class::HISTORY << "\u3044\u3093"
        described_class::HISTORY << "\u3046\u3093"

        stdio.type "#{REVERSE_HISTORY_SEARCH}\u3093\n\n"
        stdio.type "#{REVERSE_HISTORY_SEARCH}\u3042\u3093"
        stdio.stdin.close

        expect(described_class.readline('', true)).to eq "\u3046\u3093"
        expect(described_class.readline('', true)).to eq "\u3042\u3093"
        expect(described_class.readline('', true)).to be_nil
      end
    end
  end

  describe 'tab completion' do
    describe '.completion_proc=' do
      it 'raises when given something without a #call method' do
        expect { described_class.completion_proc = :not_a_proc }.
          to raise_exception(ArgumentError)
      end
    end

    describe '.completion_proc' do
      it 'returns the completion proc passed to completion_proc=' do
        my_proc = proc { |input| input }

        described_class.completion_proc = my_proc

        expect(described_class.completion_proc).to eq my_proc
      end
    end

    describe '.quoting_detection_proc=' do
      it 'raises when given something without a #call method' do
        expect { described_class.quoting_detection_proc = :not_a_proc }.
          to raise_exception(ArgumentError)
      end
    end

    describe '.quoting_detection_proc' do
      it 'returns the value passed to quoting_detection_proc=' do
        my_proc = proc { |input| input }

        described_class.quoting_detection_proc = my_proc

        expect(described_class.quoting_detection_proc).to eq my_proc
      end
    end

    describe '.completion_quote_character' do
      context 'while completing an unquoted argument' do
        it 'returns nil' do
          with_temp_stdio do |stdio|
            stdio.type("input\t")
            quote_character = nil
            described_class.completion_proc = -> (_) do
              quote_character = described_class.completion_quote_character
              []
            end
            described_class.completer_quote_characters = '\'"'
            described_class.readline("> ", false)

            expect(quote_character).to be_nil
          end
        end
      end

      context 'while completing a quoted argument' do
        it 'returns a string containing the quote character' do
          with_temp_stdio do |stdio|
            stdio.type("~input\t")
            quote_character = nil
            described_class.completion_proc = -> (_) do
              quote_character = described_class.completion_quote_character
              []
            end
            described_class.completer_quote_characters = '~'
            described_class.readline("> ", false)

            expect(quote_character).to eq '~'
          end
        end
      end

      context 'after completion is finished' do
        it 'returns nil' do
          with_temp_stdio do |stdio|
            stdio.type("\"input\t")
            described_class.completion_proc = -> (_) { [] }
            described_class.completer_quote_characters = '\'"'
            described_class.readline("> ", false)

            expect(described_class.completion_quote_character).to be nil
          end
        end
      end
    end

    it 'passes the last word of the user input to the completion proc' do
      with_temp_stdio do |stdio|
        passed_text = nil
        described_class.completion_proc = ->(text) { passed_text = text }
        stdio.type("first second\t")

        described_class.readline("> ", false)

        expect(passed_text).to eq "second"
      end
    end

    context 'when no options are returned' do
      it 'does not modify the user input' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = ->(text) {[]}

          stdio.type("first\t")
          line1 = described_class.readline("> ")
          stdio.type("\n")
          line2 = described_class.readline("> ")

          expect(line1).to eq "first"
          expect(line2).to eq ""
          expect(described_class.line_buffer).to eq ""
        end
      end
    end

    context 'when a single completion option is returned' do
      it 'replaces the last word of the user input with the completion' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = ->(text) { ['output'] }
          stdio.type("first second\t")

          line = described_class.readline('> ', false)

          expect(line).to eq 'first output '
        end
      end
    end

    context 'when multiple completion options are returned' do
      it 'replaces the last word of the user input with the longest common prefix' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = ->(text) { ['abc123', 'abcdef'] }
          stdio.type("first second\t")

          line = described_class.readline('> ', false)

          expect(line).to eq 'first abc'
        end
      end

      context 'with multi-byte completion options' do
        it 'replaces the last word of the user input with the longest common prefix' do
          unless Encoding.find("locale") == Encoding::UTF_8
            skip 'this test needs UTF-8 locale'
          end

          with_temp_stdio do |stdio|
            results = %W"\u{3042 3042} \u{3042 3044}"
            described_class.completion_proc = ->(text) { results }
            stdio.type("first second\t")

            line = described_class.readline('> ', false)

            expect(line).to eq "first \u3042"
          end
        end
      end
    end

    context 'when completion_case_fold is set' do
      it 'replaces the last word of the user input with the longest common prefix, ignoring case' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = ->(text) { ['ABC123', 'abcdef'] }
          described_class.completion_case_fold = true

          stdio.type("first second\t")
          line = described_class.readline('> ', false)

          expect(line).to eq 'first ABC'
        end
      end

      context 'with multi-byte completion options' do
        it 'replaces the last word of the user input with the longest common prefix' do
          unless Encoding.find("locale") == Encoding::UTF_8
            skip 'this test needs UTF-8 locale'
          end

          with_temp_stdio do |stdio|
            results = %W"\u{3042 3042} \u{3042 3044}"
            described_class.completion_proc = ->(text) { results }
            described_class.completion_case_fold = true
            stdio.type("first second\t")

            line = described_class.readline('> ', false)

            expect(line).to eq "first \u3042"
          end
        end
      end
    end

    context 'when completion_append_character is set' do
      it 'adds the character to the end of the completion' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = ->(text) { ['output'] }
          described_class.completion_append_character = 'x'

          stdio.type("first second\t")
          line = described_class.readline('> ', false)

          expect(line).to eq 'first outputx'
        end
      end
    end

    context 'when completion_suppress_quote is set' do
      it 'does not append a closing quote' do
        with_temp_stdio do |stdio|
          described_class.completion_proc = -> (_text) do
            described_class.completion_suppress_quote = true
            ['output']
          end
          described_class.completer_quote_characters = "'"

          stdio.type("first 'second\t")
          line = described_class.readline('> ', false)

          expect(line).to eq "first 'output "
        end
      end
    end

    context 'when completer_word_break_characters are set' do
      it 'uses those characters to identify where to apply completions' do
        with_temp_stdio do |stdio|
          passed_text = nil
          described_class.completion_proc = -> (text) do
            passed_text = text
            ['output']
          end
          described_class.completer_word_break_characters = ':'

          stdio.type("first:second\t")
          line = described_class.readline('> ', false)

          expect(passed_text).to eq 'second'
          expect(line).to eq 'first:output '
        end
      end
    end

    context 'when completer_quote_characters are set' do
      it 'uses those characters to identify arguments spanning word boundaries' do
        with_temp_stdio do |stdio|
          passed_text = nil
          described_class.completion_proc = -> (text) do
            passed_text = text
            ['output']
          end
          described_class.completer_quote_characters = '~'

          stdio.type("first ~second third\t")
          line = described_class.readline('> ', false)

          expect(passed_text).to eq 'second third'
          expect(line).to eq 'first ~output~ '
        end
      end
    end

    context 'when special_prefixes is set' do
      it 'includes the prefix in the value passed to the completion proc' do
        with_temp_stdio do |stdio|
          passed_text = nil
          described_class.completion_proc = -> (text) do
            passed_text = text
            ['@example.com']
          end
          described_class.completer_word_break_characters = ' @'
          described_class.special_prefixes = '@'

          stdio.type("user@ex\t")
          line = described_class.readline('> ', false)

          expect(passed_text).to eq '@ex'
          expect(line).to eq 'user@example.com '
        end
      end
    end

    context 'with multi-byte completion options in an incompatible encoding' do
      it 'raises' do
        unless Encoding.find("locale") == Encoding::UTF_8
          skip 'this test needs UTF-8 locale'
        end

        with_temp_stdio do |stdio|
          incompatible_encoding = Encoding::EUC_JP
          results = %W"\u{3042 3042} \u{3042 3044}"
          results.map! {|s| s.encode(incompatible_encoding)}
          described_class.completion_proc = -> (text) { results }
          stdio.type("\t")

          expect {
            described_class.readline
          }.to raise_exception(Encoding::CompatibilityError)
        end
      end
    end

    context 'with quoting_detection_proc set' do
      it 'determines if a word break character really applies' do
        with_temp_stdio do |stdio|
          passed_text = nil
          described_class.completion_proc = -> (text) do
            passed_text = text
            ['completion']
          end
          described_class.completer_quote_characters = '\'"'
          described_class.completer_word_break_characters = ' '
          described_class.quoting_detection_proc = -> (text, index) do
            index > 0 && text[index-1] == '\\'
          end

          stdio.type("first second\\ third\t")
          line = described_class.readline('> ', false)

          expect(passed_text).to eq 'second\\ third'
          expect(line).to eq 'first completion '
        end
      end
    end

    context 'with quoting_detection_proc set and multibyte input' do
      it 'determines if a word break character really applies' do
        with_temp_stdio do |stdio|
          passed_text = nil
          escaped_char_indexes = []
          described_class.completion_proc = -> (text) do
            passed_text = text
            ['completion']
          end
          described_class.completer_quote_characters = '\'"'
          described_class.completer_word_break_characters = ' '
          described_class.quoting_detection_proc = -> (text, index) do
            escaped = index > 0 && text[index-1] == '\\'
            escaped_char_indexes << index if escaped
            escaped
          end

          stdio.type("\u3042\u3093 second\\ third\t")
          line = described_class.readline('> ', false)

          expect(escaped_char_indexes).to eq [10]
          expect(passed_text).to eq 'second\\ third'
          expect(line).to eq "\u3042\u3093 completion "
        end
      end
    end
  end

  describe 'pre-input hooks' do
    it 'can be set' do
      my_proc = proc {}

      described_class.pre_input_hook = my_proc

      expect(described_class.pre_input_hook).to eq my_proc

      described_class.pre_input_hook = nil

      expect(described_class.pre_input_hook).to be_nil
    end

    it 'can modify text' do
      with_temp_stdio do |stdio|
        described_class.pre_input_hook = proc do
          described_class.insert_text("hello ")
          described_class.redisplay
        end

        stdio.type("world\n")
        line = described_class.readline("> ")

        expect(line).to eq "hello world"
        expect(stdio.output).to eq "> hello world\n"
      end
    end
  end

  describe '.completion_case_fold' do
    it 'returns the value passed to completion_case_fold=' do
      described_class.completion_case_fold = 'a string'
      expect(described_class.completion_case_fold).to eq 'a string'
    end
  end

  describe '.get_screen_size' do
    it 'returns the current screen size as an array of rows and columns' do
      res = described_class.get_screen_size

      expect(res).to be_an(Array)

      rows, columns = *res

      expect(rows).to be_an(Integer)
      expect(rows).to be >= 0
      expect(columns).to be_an(Integer)
      expect(columns).to be >= 0
    end
  end

  describe '.insert_text' do
    it 'adds text to the line' do
      expect([nil, '']).to include(described_class.line_buffer)

      str = 'test insert text'
      described_class.insert_text(str)

      expect(described_class.point).to eq str.length
      expect(described_class.line_buffer).to eq str
      expect(described_class.line_buffer.encoding).
        to eq get_default_internal_encoding
    end
  end

  describe '.delete_text' do
    it 'removes the specified text from the line' do
      described_class.insert_text('test insert text')

      described_class.delete_text(1, 3)
      expect(described_class.line_buffer).to eq 't insert text'
      described_class.delete_text(11)
      expect(described_class.line_buffer).to eq 't insert te'
      described_class.delete_text(-3...-1)
      expect(described_class.line_buffer).to eq 't inserte'
      described_class.delete_text(-3..-1)
      expect(described_class.line_buffer).to eq 't inse'
      described_class.delete_text(3..-3)
      expect(described_class.line_buffer).to eq 't ise'
      described_class.delete_text(3, 1)
      expect(described_class.line_buffer).to eq 't ie'
      described_class.delete_text(1..1)
      expect(described_class.line_buffer).to eq 'tie'
      described_class.delete_text(1...2)
      expect(described_class.line_buffer).to eq 'te'
      described_class.delete_text
      expect(described_class.line_buffer).to eq ''
    end

    it 'leaves the cursor position in a surprising state' do
      str = 'test_insert_text'
      described_class.insert_text(str)
      described_class.delete_text

      expect(described_class.line_buffer).to eq ''
      expect(described_class.point).to eq str.length

      described_class.insert_text(str)
      expect(described_class.line_buffer).to eq ''
      expect(described_class.point).to eq 2 * str.length
    end

    context 'when passed too many arguments' do
      it 'raises an argument error' do
        expect {
          described_class.delete_text(1, 2, 3)
        }.to raise_exception(ArgumentError, /wrong number of arguments/)
      end
    end
  end

  describe '.point' do
    it 'returns the position of the cursor in the line' do
      described_class.point = 0

      described_class.insert_text('12345')

      expect(described_class.point).to eq 5
    end
  end

  describe '.point=' do
    it 'sets the position of the cursor in the line' do
      described_class.insert_text('12345')
      described_class.point = 4
      described_class.insert_text('abc')

      expect(described_class.line_buffer).to eq '1234abc5'
    end
  end

  describe 'editing modes' do
    it 'allows the user to switch between vi and emacs' do
      expect(described_class).not_to be_vi_editing_mode
      expect(described_class).to be_emacs_editing_mode

      described_class.vi_editing_mode
      expect(described_class).to be_vi_editing_mode
      expect(described_class).not_to be_emacs_editing_mode
      described_class.vi_editing_mode
      expect(described_class).to be_vi_editing_mode
      expect(described_class).not_to be_emacs_editing_mode

      described_class.emacs_editing_mode
      expect(described_class).not_to be_vi_editing_mode
      expect(described_class).to be_emacs_editing_mode
      described_class.emacs_editing_mode
      expect(described_class).not_to be_vi_editing_mode
      expect(described_class).to be_emacs_editing_mode
    end
  end

  def with_temp_stdio
    TempStdio.new.apply do |stdio|
      described_class.input = STDIN
      described_class.output = STDOUT
      yield stdio
    end
  end

  def get_default_internal_encoding
    return Encoding.default_internal || Encoding.find("locale")
  end
end

class TempStdio
  FILE_MODE = File::RDWR | File::EXCL

  attr_reader :stdin, :stdout

  def initialize
    @stdin_tempfile = Tempfile.new("test_readline_stdin")
    @stdout_tempfile = Tempfile.new("test_readline_stdout")
  end

  def apply
    File.open(stdin_tempfile.path, FILE_MODE) do |writeable_stdin|
      File.open(stdout_tempfile.path, FILE_MODE) do |readable_stdout|
        replace_stdio do
          @stdin = writeable_stdin
          @stdout = readable_stdout
          yield self
        end
      end
    end
  end

  def type(input)
    stdin.write(input)
    stdin.flush
  end

  def output
    stdout.rewind
    stdout.read
  end

  private

  attr_reader :stdin_tempfile, :stdout_tempfile

  def replace_stdio
    open(stdin_tempfile.path, "r") do |stdin|
      open(stdout_tempfile.path, "w") do |stdout|
        orig_stdin = STDIN.dup
        orig_stdout = STDOUT.dup
        orig_stderr = STDERR.dup
        STDIN.reopen(stdin)
        STDOUT.reopen(stdout)
        STDERR.reopen(stdout)
        begin
          yield
        ensure
          STDERR.reopen(orig_stderr)
          STDIN.reopen(orig_stdin)
          STDOUT.reopen(orig_stdout)
          orig_stdin.close
          orig_stdout.close
          orig_stderr.close
        end
      end
    end
  end
end
