module Gitsh
  class QuoteDetector
    def call(text, index)
      index > 0 && text[index - 1] == '\\' && !call(text, index - 1)
    end
  end
end
