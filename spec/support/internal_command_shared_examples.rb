shared_examples_for 'an internal command' do
  it 'has a .help_message method' do
    expect {
      described_class.help_message
    }.to_not raise_exception
  end
end
