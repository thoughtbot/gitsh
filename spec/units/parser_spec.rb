require 'spec_helper'
require 'gitsh/parser'

describe Gitsh::Parser do
  describe '#parse_and_transform' do
    it 'returns an object built from the parsed command' do
      env = double('Environment', fetch: nil)
      transformed = double('Transformed')
      transformer = double('Transformer', apply: transformed)
      transformer_factory = double('TransformerFactory', new: transformer)
      parser = described_class.new(env: env, transformer_factory: transformer_factory)

      result = parser.parse_and_transform('status')

      expect(transformer).to have_received(:apply).with({ git_cmd: 'status' }, env: env)
      expect(result).to eq transformed
    end
  end

  describe '#parse' do
    let(:parser) { described_class.new(env: {}) }

    it 'parses a blank line' do
      expect(parser).to parse('').as(blank: '')
    end

    it 'parses a line containing only whitespace' do
      expect(parser).to parse('   ').as(blank: '   ')
    end

    it 'parses a comment command' do
      expect(parser).to parse('#cd').as(comment: '#cd')
    end

    it 'parses a git command with no arguments' do
      expect(parser).to parse('status').as(git_cmd: 'status')
    end

    it 'parses a git command with trailing whitespace' do
      expect(parser).to parse('status  ').as(git_cmd: 'status')
    end

    it 'parses a git command with a trailing comment' do
      expect(parser).to parse('status #comment').as(git_cmd: 'status')
    end

    it 'parses an internal command with no arguments' do
      expect(parser).to parse(':set').as(internal_cmd: 'set')
    end

    it 'parses upper and lower case letters' do
      expect(parser).to parse('STATUS').as(git_cmd: 'STATUS')
    end

    it 'parses a shell command with no arguments' do
      expect(parser).to parse('!pwd').as(shell_cmd: 'pwd')
    end

    it 'parses an absolute shell command' do
      expect(parser).to parse('!/tmp/great_script.sh').as(shell_cmd: '/tmp/great_script.sh')
    end

    it 'parses a relative shell command' do
      expect(parser).to parse('!./bin/setup').as(shell_cmd: './bin/setup')
    end

    it 'parses a command with a long option argument' do
      expect(parser).to parse('log --format="%ae - %s"').as(
        git_cmd: 'log',
        args: [
          { arg: parser_literals('--format=%ae - %s') }
        ]
      )
    end

    it 'parses a command with string arguments' do
      expect(parser).to parse(%q(commit 'George' "Hello world")).as(
        git_cmd: 'commit',
        args: [
          { arg: parser_literals('George') },
          { arg: parser_literals('Hello world') }
        ]
      )
    end

    it 'parses a command with empty string arguments' do
      expect(parser).to parse(%q(commit '' "")).as(
        git_cmd: 'commit',
        args: [
          { arg: [{ empty_string: "''" }] },
          { arg: [{ empty_string: '""' }] }
        ]
      )
    end

    it 'parses a command with unquoted arguments' do
      expect(parser).to parse(':set author').as(
        internal_cmd: 'set',
        args: [{ arg: parser_literals('author') }]
      )
    end

    it 'parses a command with unquoted arguments containing escaped characters' do
      [' ', '"', '\'', '\\', '$', '&', '|', ';', '#'].each do |char|
        expect(parser).to parse("add first pre\\#{char}post third").as(
          git_cmd: 'add',
          args: [
            { arg: parser_literals('first') },
            { arg: parser_literals("pre#{char}post") },
            { arg: parser_literals('third') }
          ]
        )
      end
    end

    it 'parses a command with variable arguments' do
      expect(parser).to parse('foo $bar $f_o-o.bar $_bar').as(
        git_cmd: 'foo',
        args: [
          { arg: [{ var: 'bar' }] },
          { arg: [{ var: 'f_o-o.bar' }] },
          { arg: [{ var: '_bar' }] }
        ]
      )
    end

    it 'parses a command with unquoted arguments containing variables' do
      expect(parser).to parse('foo prefix$bar ${bar}suffix $path/file').as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix') + [{ var: 'bar' }] },
          { arg: [{ var: 'bar' }] + parser_literals('suffix') },
          { arg: [{ var: 'path' }] + parser_literals('/file') }
        ]
      )
    end

    it 'parses a command with double-quoted arguments containing variables' do
      expect(parser).to parse('foo "prefix $bar" "${bar}suffix" "$path/file"').as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix ') + [{ var: 'bar' }] },
          { arg: [{ var: 'bar' }] + parser_literals('suffix') },
          { arg: [{ var: 'path' }] + parser_literals('/file') }
        ]
      )
    end

    it 'parses a command with a subshell argument' do
      expect(parser).to parse(':echo $(status)').as(
        internal_cmd: 'echo',
        args: [
          { arg: [{ subshell: 'status' }] }
        ]
      )
    end

    it 'parses a command with a nested subshell argument' do
      expect(parser).to parse(':echo $(:echo $(status))').as(
        internal_cmd: 'echo',
        args: [
          { arg: [{ subshell: ':echo $(status)' }] }
        ]
      )
    end

    it 'parses a command with a double-quoted argument containing a subshell' do
      expect(parser).to parse(':echo "In $(!pwd)"').as(
        internal_cmd: 'echo',
        args: [
          { arg: parser_literals('In ') + [{ subshell: '!pwd' }] }
        ]
      )
    end

    it 'parses a command with double-quoted arguments containing escaped characters' do
      ['"', '\\', '$'].each do |char|
        expect(parser).to parse("add \"pre\\#{char}post\"").as(
          git_cmd: 'add',
          args: [
            { arg: parser_literals("pre#{char}post") },
          ]
        )
      end
    end

    it 'does not interpret all \ characters in double-quoted arguments as escapes' do
      ['a', ' ', '\'', '&', '|', ';', '#'].each do |char|
        expect(parser).to parse("add \"pre\\#{char}post\"").as(
          git_cmd: 'add',
          args: [
            { arg: parser_literals("pre\\#{char}post") },
          ]
        )
      end
    end

    it 'parses a command with string arguments containing the comment prefix' do
      expect(parser).to parse(%q(commit "Not a #comment")).as(
        git_cmd: 'commit',
        args: [
          { arg: parser_literals('Not a #comment') },
        ]
      )
    end

    it 'parses a command with single-quoted arguments containing variable-like strings' do
      expect(parser).to parse("foo 'prefix $bar' '${bar}suffix' '$path/file'").as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix $bar') },
          { arg: parser_literals('${bar}suffix') },
          { arg: parser_literals('$path/file') }
        ]
      )
    end

    it 'parses a command with single-quoted arguments containing escaped characters' do
      ['\'', '\\'].each do |char|
        expect(parser).to parse("add 'pre\\#{char}post'").as(
          git_cmd: 'add',
          args: [
            { arg: parser_literals("pre#{char}post") },
          ]
        )
      end
    end

    it 'does not interpret all \ characters in single-quoted arguments as escapes' do
      ['a', ' ', '"', '&', '|', ';', '#', '$'].each do |char|
        expect(parser).to parse("add 'pre\\#{char}post'").as(
          git_cmd: 'add',
          args: [
            { arg: parser_literals("pre\\#{char}post") },
          ]
        )
      end
    end

    it 'parses a shell command with arguments' do
      expect(parser).to parse("!echo 'Hello World'").as(
        shell_cmd: 'echo',
        args: [
          { arg: parser_literals('Hello World') }
        ]
      )
    end

    it 'parses a command with leading whitespace' do
      expect(parser).to parse("  \t commit").as(git_cmd: 'commit')
    end

    it 'parses mutliple commands separated by semicolons' do
      expect(parser).to parse('add -p; commit -v').as(
        multi: {
          left: {
            git_cmd: 'add',
            args: [
              { arg: parser_literals('-p') }
            ]
          },
          right: {
            git_cmd: 'commit',
            args: [
              { arg: parser_literals('-v') }
            ]
          }
        }
      )
    end

    it 'parses a single command with a trailing semicolon' do
      expect(parser).to parse('init;').as(
        multi: {
          left: { git_cmd: 'init' },
          right: { blank: [] },
        }
      )
    end

    it 'parses mutliple commands separated by &&' do
      expect(parser).to parse('add -p && commit -v').as(
        and: {
          left: {
            git_cmd: 'add',
            args: [
              { arg: parser_literals('-p') }
            ]
          },
          right: {
            git_cmd: 'commit',
            args: [
              { arg: parser_literals('-v') }
            ]
          }
        }
      )
    end

    it 'parses mutliple commands separated by ||' do
      expect(parser).to parse('add -p || commit -v').as(
        or: {
          left: {
            git_cmd: 'add',
            args: [
              { arg: parser_literals('-p') }
            ]
          },
          right: {
            git_cmd: 'commit',
            args: [
              { arg: parser_literals('-v') }
            ]
          }
        }
      )
    end

    it 'parses mutliple commands separated by ||, &&, and semicolons' do
      command = 'add -p && commit -v; push origin || reset --soft HEAD'
      expect(parser).to parse(command).as(
        multi: {
          left: {
            and: {
              left: {
                git_cmd: 'add',
                args: [
                  { arg: parser_literals('-p') }
                ]
              },
              right: {
                git_cmd: 'commit',
                args: [
                  { arg: parser_literals('-v') }
                ]
              }
            }
          },
          right: {
            or: {
              left: {
                git_cmd: 'push',
                args: [
                  { arg: parser_literals('origin') }
                ]
              },
              right: {
                git_cmd: 'reset',
                args: [
                  { arg: parser_literals('--soft') },
                  { arg: parser_literals('HEAD') }
                ]
              }
            }
          }
        }
      )
    end

    context 'with autocorrect enabled' do
      it 'drops the git prefix from commands' do
        parser = described_class.new(env: { 'help.autocorrect' => '1' })

        expect(parser).to parse('git init').as(git_cmd: 'init')
      end
    end

    context 'with autocomplete disabled' do
      it 'treats a command with a git prefix as a normal git command' do
        parser = described_class.new(env: { 'help.autocorrect' => '0' })

        expect(parser).to parse('git init').as(
          git_cmd: 'git',
          args: [ { arg: parser_literals('init') } ],
        )
      end
    end
  end
end
