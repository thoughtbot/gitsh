RSpec::Matchers.define :delegate do |original_method|
  chain :to do |target_object, target_method|
    @target_object = target_object
    @target_method = target_method
  end

  match do |original_object|
    result = double
    allow(@target_object).to receive(@target_method).
      and_return(result)

    expect(original_object.send(original_method)).to eq result
  end
end
