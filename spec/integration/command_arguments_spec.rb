require 'spec_helper'

describe 'Command arguments' do
  it 'supports empty strings' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':echo Hello "" World'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output "Hello  World\n"
    end
  end
end
