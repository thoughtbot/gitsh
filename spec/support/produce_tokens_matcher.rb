RSpec::Matchers.define(:produce_tokens) do |expected|
  match do |actual|
    @expected = expected.join("\n")
    @actual = described_class.lex(actual).map(&:to_s).join("\n")
    values_match? @expected, @actual
  end

  diffable
end

