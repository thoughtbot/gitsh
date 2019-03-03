require 'gitsh/error'

module Gitsh
  module TabCompletion
    module DSL
      class ParseError < Gitsh::Error
        TOKEN_TO_DESCRIPTION = {
          BLANK: 'blank line',
          INDENT: 'indent',

          LEFT_PAREN: 'opening paren',
          RIGHT_PAREN: 'closing paren',

          MAYBE: 'operator (?)',
          OR: 'operator (|)',
          PLUS: 'operator (+)',
          STAR: 'operator (*)',

          OPTION: 'option (%{value})',
          VAR: 'variable ($%{value})',
          OPT_VAR: 'variable ($opt)',
          WORD: 'word (%{value})',
        }.freeze

        def initialize(reason, token)
          @reason = reason
          @token = token
        end

        def to_s
          'Tab completion configuration error: '\
            "#{reason} #{token_description} at line #{line}, column #{column} "\
            "in file #{path}"
        end

        private

        attr_reader :reason, :token

        def token_description
          TOKEN_TO_DESCRIPTION.fetch(token.type, token.type) % {
            value: token.value,
          }
        end

        def line
          token.position.line_number
        end

        def column
          token.position.line_offset + 1
        end

        def path
          token.position.file_name
        end
      end
    end
  end
end
