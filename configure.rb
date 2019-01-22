require 'rbconfig'

VAR_PATTERN = /\$\((?<name>[a-z_]+)\)/i

REPLACEMENTS = Hash[RbConfig::MAKEFILE_CONFIG.map do |key, value|
  ["$(#{key})", value]
end]

def expand_config(path)
  if path =~ VAR_PATTERN
    new_path = path.gsub(VAR_PATTERN, REPLACEMENTS)
    expand_config(new_path)
  else
    path
  end
end

puts expand_config(ARGV[0])
