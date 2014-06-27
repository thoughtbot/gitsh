RSpec::Matchers.define :execute do
  chain :successfully do
    @exit_status_matcher = eq(0)
    @error_matcher = eq('')
  end

  chain :with_exit_status do |exit_status|
    @exit_status_matcher = eq(exit_status)
  end

  chain :with_output_matching do |output_pattern|
    @output_matcher = match_regex(output_pattern)
  end

  chain :with_error_output_matching do |output_pattern|
    @error_matcher = match_regex(output_pattern)
  end

  match do
    output, error, exit_status = Open3.capture3(actual)

    @output_matcher ||= be_empty

    [
      @exit_status_matcher.matches?(exit_status.exitstatus),
      @output_matcher.matches?(output),
      @error_matcher.matches?(error),
    ].all?
  end

  failure_message_for_should do
    [
      @exit_status_matcher.failure_message_for_should,
      @output_matcher.failure_message_for_should,
      @error_matcher.failure_message_for_should,
    ].join("\n")
  end
end
