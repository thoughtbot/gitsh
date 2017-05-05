module Gitsh
  module TabCompletion
    module DSL
      class ChoiceFactory
        attr_reader :choices

        def initialize(choices)
          @choices = choices
        end

        def build(start_state, options = {})
          end_state = options.fetch(:end_state) { Automaton::State.new('choice') }
          choices.each do |choice|
            choice.build(start_state, options.merge(end_state: end_state))
          end
          end_state
        end
      end
    end
  end
end
