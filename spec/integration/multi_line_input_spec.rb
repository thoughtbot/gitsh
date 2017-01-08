require 'spec_helper'

describe 'Multi-line input' do
  it 'supports escaped line breaks within commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo Hello \\')

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with('> ')

      gitsh.type('world')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/Hello world/)
    end
  end

  it 'supports line breaks after logical operators' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo Hello &&')

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with('> ')

      gitsh.type(':echo World')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/Hello\nWorld/)
    end
  end

  it 'supports line breaks within strings' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo "Hello, world')

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with('> ')

      gitsh.type('')
      gitsh.type('Goodbye, world"')

      expect(gitsh).to output(/\AHello, world\n\nGoodbye, world\Z/)
    end
  end

  it 'supports line breaks within parentheses' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('(:echo 1')

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with('> ')

      gitsh.type(':echo 2')
      gitsh.type(':echo 3)')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/1\n2\n3/)
    end
  end

  it 'supports line breaks within subshells' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo $(')
      gitsh.type(' :set greeting Hello')
      gitsh.type(' :echo $greeting')
      gitsh.type(')')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/Hello/)
    end
  end

  it 'supports comments in the middle of multi-line commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('(:echo 1 # comment')

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with('> ')

      gitsh.type(':echo 2')
      gitsh.type('# another comment')
      gitsh.type(')')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/1\n2/)
    end
  end

  it 'supports line breaks within strings in scripts' do
    in_a_temporary_directory do
      write_file('multiline.gitsh', ":echo 'foo\nbar'")

      expect("#{gitsh_path} multiline.gitsh").
        to execute.successfully.
        with_output_matching(/foo\nbar/)
    end
  end
end
