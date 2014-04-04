require 'spec_helper'

describe 'Command started with #' do
  it 'does nothing' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '#cd'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output_nothing
    end
  end
end
