require 'spec_helper'

describe 'Completing things with tab' do
  it 'completes known porcelain commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      gitsh.type("checko\t -b my-feature")

      expect(gitsh).to prompt_with 'my-feature@ '

      gitsh.type("com\t --allow-empty -m 'Some commit'")

      expect(gitsh).to output /Some commit/

      gitsh.type("bra\t")

      expect(gitsh).to output /my-feature/
    end
  end

  it 'completes aliases' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('config --local alias.zecho "!echo zzz"')

      gitsh.type("zec\t")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /zzz/
    end
  end

  it 'completes internal commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      gitsh.type(":se\t arthur 'Arthur Dent <arthur@tea.example.com>'")
      gitsh.type('commit --allow-empty --author $arthur -m "More tea"')
      gitsh.type('log --format="%ae - %s"')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /^arthur@tea\.example\.com - More tea$/
    end
  end

  it 'completes branch names' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m "Some commit"')
      gitsh.type('branch my-feature')

      gitsh.type("checkout my-\t")

      expect(gitsh).to prompt_with 'my-feature@ '
    end
  end

  it 'completes paths' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      write_file('foo.txt')
      gitsh.type("add f\t")
      gitsh.type('commit -m "Add foo.txt"')
      gitsh.type('ls-files')

      expect(gitsh).to output /foo\.txt/
    end
  end
end
