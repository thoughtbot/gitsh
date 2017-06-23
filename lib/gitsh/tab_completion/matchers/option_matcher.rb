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

        def completions(token)
          if token.start_with?('-')
            options_without_args.select { |option| option.start_with?(token) }
          else
            []
          end
        end

        def eql?(other)
          self.class == other.class &&
            options_without_args == other.options_without_args &&
            options_with_args == other.options_with_args
        end

        def hash
          self.class.hash + options_without_args.hash + options_with_args.hash
        end

        protected

        attr_reader :options_without_args, :options_with_args
      end
    end
  end
end
