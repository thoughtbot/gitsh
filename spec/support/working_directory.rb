module WorkingDirectory
  def cwd_basename
    File.basename(Dir.getwd)
  end
end

RSpec.configure do |config|
  config.include WorkingDirectory
end
