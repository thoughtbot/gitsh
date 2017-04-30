require 'spec_helper'

describe 'Completing things with tab' do
  it 'completes known porcelain commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      gitsh.type("checko\t -b my-feature")

      expect(gitsh).to prompt_with "#{cwd_basename} my-feature@ "

      gitsh.type("com\t --allow-empty -m 'Some commit'")

      expect(gitsh).to output(/Some commit/)

      gitsh.type("bra\t")

      expect(gitsh).to output(/my-feature/)
    end
  end

  it 'completes aliases' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('config --local alias.zecho "!echo zzz"')

      gitsh.type("zec\t")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/zzz/)

      gitsh.type(':set alias.yecho "!echo yyy"')

      gitsh.type("yec\t")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/yyy/)
    end
  end

  it 'completes internal commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      gitsh.type(":se\t arthur 'Arthur Dent <arthur@tea.example.com>'")

      expect(gitsh).to output_no_errors

      gitsh.type('commit --allow-empty --author $arthur -m "More tea"')
      gitsh.type('log --format="%ae - %s"')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/^arthur@tea\.example\.com - More tea$/)
    end
  end

  it 'completes commands after operators' do
    GitshRunner.interactive do |gitsh|
      gitsh.type("init && :ec\t Hello")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/Hello/)
    end
  end

  it 'completes commands in subshells' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m "First"')
      gitsh.type(":echo $(bran\t)")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/\bmaster\b/)
    end
  end

  it 'completes branch names' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m "Some commit"')
      gitsh.type('branch my-feature')

      gitsh.type("checkout my-\t")

      expect(gitsh).to prompt_with "#{cwd_basename} my-feature@ "
    end
  end

  it 'completes paths' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      write_file('some text file.txt')
      write_file('another file.txt')
      gitsh.type("add som\t")

      expect(gitsh).to output_no_errors

      gitsh.type("add another\\ f\t")

      expect(gitsh).to output_no_errors

      gitsh.type('commit -m "Add some text file"')
      gitsh.type('ls-files')

      expect(gitsh).to output(/another file\.txt/)
      expect(gitsh).to output(/some text file\.txt/)
    end
  end

  it 'completes quoted paths' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      make_directory('sub directory')
      write_file('sub directory/some text file.txt')
      write_file('sub directory/some other file.txt')
      gitsh.type("add 'sub\tso\tother\t")

      expect(gitsh).to output_no_errors

      gitsh.type('commit -m "First commit"')
      gitsh.type('ls-files')

      expect(gitsh).to output(/sub directory\/some other file\.txt/)
    end
  end

  it 'completes variables' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':set greeting "Hello, world"')
      gitsh.type(":echo $gre\t")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/Hello, world/)
    end
  end

  it 'completes after punctuation' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m First')
      gitsh.type('commit --allow-empty -m Second')
      gitsh.type('commit --allow-empty -m Third')
      gitsh.type("log --format=%s master~2..mas\t")

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/\AThird\nSecond\n\Z/)
    end
  end
end
