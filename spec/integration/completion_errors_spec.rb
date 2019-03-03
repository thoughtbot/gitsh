require 'spec_helper'
require 'gitsh/tab_completion/dsl/parse_error'

describe 'Completion file with syntax errors' do
  it 'fails to start up in interactive mode' do
    with_a_temporary_home_directory do |home|
      config_path = "#{home}/.gitsh_completions"
      write_file(config_path, "??????\n******\n+++++++")

      expect { starting_gitsh }.to raise_exception(
        Gitsh::TabCompletion::DSL::ParseError,
        /Unexpected operator \(\?\) at line 1, column 1 in file #{config_path}/,
      )
    end
  end

  it 'is not a problem in non-interactive mode'

  def starting_gitsh
    GitshRunner.new.start_interactive
  end
end
