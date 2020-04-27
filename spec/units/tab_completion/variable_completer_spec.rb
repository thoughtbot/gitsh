require 'spec_helper'
require 'gitsh/tab_completion/variable_completer'

describe Gitsh::TabCompletion::VariableCompleter do
  describe '#call' do
    context 'with a variable not wrapped in braces' do
      it 'produces variable completions that match the input' do
        register_line_editor
        register_env(
          available_variables: [:'user.name', :'user.email', :'greeting'],
        )
        completer = described_class.new('$us')

        expect(completer.call).to match_array ['$user.name', '$user.email']
      end

      it 'prefixes the completions with the prefix, if there is one' do
        register_line_editor
        register_env(
          available_variables: [:'user.name', :'user.email', :'greeting'],
        )
        completer = described_class.new('name=$us')

        expect(completer.call).
          to match_array ['name=$user.name', 'name=$user.email']
      end

      it 'configures the line editor to append a space and not close quotes' do
        register_env(available_variables: [])
        line_editor = register_line_editor
        completer = described_class.new('$us')

        completer.call

        expect(line_editor).
          to have_received(:completion_append_character=).with(nil)
        expect(line_editor).
          to have_received(:completion_suppress_quote=).with(true)
      end
    end

    context 'with a variable wrapped in braces' do
      it 'produces variable completions that match the input' do
        register_line_editor
        register_env(
          available_variables: [:'user.name', :'user.email', :'greeting'],
        )
        completer = described_class.new('${us')

        expect(completer.call).to match_array ['${user.name', '${user.email']
      end

      it 'configures the line editor to append a closing brace and not close quotes' do
        register_env(available_variables: [])
        line_editor = register_line_editor
        completer = described_class.new('${us')

        completer.call

        expect(line_editor).
          to have_received(:completion_append_character=).with('}')
        expect(line_editor).
          to have_received(:completion_suppress_quote=).with(true)
      end
    end
  end

  def build_env(variables: [])
    double(
      'Environment',
      available_variables: variables.map(&:to_sym),
    )
  end
end
