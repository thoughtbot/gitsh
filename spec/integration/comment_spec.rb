require 'spec_helper'

describe 'Comments' do
  it 'supports commenting out an entire command with #' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '#cd'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output_nothing
    end
  end

  it 'supports commenting out part of a command with #' do
    GitshRunner.interactive do |gitsh|
      gitsh.type 'init'
      gitsh.type 'commit --allow-empty -m Message # Comment'

      expect(gitsh).to output_no_errors

      gitsh.type 'show HEAD'

      expect(gitsh).not_to output(/Comment/)
    end
  end
end
