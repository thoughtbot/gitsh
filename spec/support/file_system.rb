module FileSystemHelper
  def write_file(name, contents="Some content")
    File.open("./#{name}", 'w') { |f| f << "#{contents}\n" }
  end

  def in_a_temporary_directory(&block)
    Dir.mktmpdir do |path|
      Dir.chdir(path, &block)
    end
  end
end

RSpec.configure do |config|
  config.include FileSystemHelper
end
