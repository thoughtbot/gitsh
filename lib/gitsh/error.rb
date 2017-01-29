module Gitsh
  class Error < StandardError
  end

  class UnsetVariableError < Error
  end

  class NoInputError < Error
  end

  class ParseError < Error
  end
end
