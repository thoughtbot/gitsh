require 'spec_helper'

describe 'Escaping commands' do
  it 'does not pass aribtrary strings to a shell' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init ; echo Injection')

      expect(gitsh).not_to output /Injection/
      expect(gitsh).to output_error /echo/
    end
  end
end
