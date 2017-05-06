module Gitsh
  module TabCompletion
    module Matchers
      class OptionMatcher
        def initialize(options_without_args, options_with_args)
          @options_without_args = options_without_args
          @options_with_args = options_with_args
        end

        def name
          'opt'
        end

        def match?(word)
          word =~ /\A--?[^-]+\Z/ && !options_with_args.include?(word)
        end

        def completions(_)
          options_without_args
        end

        private

        attr_reader :options_without_args, :options_with_args
      end
    end
  end
end
