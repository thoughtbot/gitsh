module FileSystemHelper
  def write_file(name, contents="Some content")
    File.open("./#{name}", 'w') { |f| f << "#{contents}\n" }
  end

  def in_a_temporary_directory(&block)
    Dir.mktmpdir do |path|
      chdir_and_allow_nesting(path, &block)
    end
  end

  def chdir_and_allow_nesting(path)
    original_path = Dir.getwd
    Dir.chdir(path)

    begin
      yield
    ensure
      Dir.chdir(original_path)
    end
  end
end

RSpec.configure do |config|
  config.include FileSystemHelper
end
