module TabCompletionHelpers
  def stub_option_matcher
    klass = Gitsh::TabCompletion::Matchers::OptionMatcher
    matcher = instance_double(klass)
    allow(klass).to receive(:new).and_return(matcher)
    matcher
  end

  def stub_text_matcher(text)
    klass = Gitsh::TabCompletion::Matchers::TextMatcher
    matcher = instance_double(klass)
    allow(klass).to receive(:new).with(text).and_return(matcher)
    matcher
  end
end

RSpec.configure do |config|
  config.include TabCompletionHelpers
end
