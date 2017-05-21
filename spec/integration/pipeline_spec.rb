require 'spec_helper'

describe 'Pipeline' do
  it 'passes output of first command to second command' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty --message "Empty commit"')
      gitsh.type('log --oneline | !wc -l')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /\b1\b/
    end
  end

  it 'runs processes in parallel' do
    GitshRunner.interactive do |gitsh|
      gitsh.type_without_waiting('!yes hello | !sed -e "s/ello/i/"')
      gitsh.wait_for_output
      gitsh.send_sigint

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /hi\nhi\n/
    end
  end

  it 'considers the pipeline to have failed if either command fails' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo $unset | !wc && :echo Success')

      expect(gitsh).to output_error /unset/
      expect(gitsh).not_to output /Success/
    end
  end

  it 'supports multi-stage pipelines' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m First --author "A <a@example.com>"')
      gitsh.type('commit --allow-empty -m Second --author "B <b@example.com>"')
      gitsh.type('commit --allow-empty -m Third --author "A <a@example.com>"')
      gitsh.type('commit --allow-empty -m Fourth --author "C <c@example.com>"')
      gitsh.type('log --format="%aN" | !sort -u | !wc -l')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /\b3\b/
    end
  end
end
