module Gitsh
  class Error < StandardError
  end

  class UnsetVariableError < Error
  end

  class NoInputError < Error
  end
end
