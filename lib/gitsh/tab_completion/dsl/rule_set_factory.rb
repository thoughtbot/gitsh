module Gitsh
  module TabCompletion
    module DSL
      class RuleSetFactory
        attr_reader :rules

        def initialize(rules)
          @rules = rules
        end

        def build(start_state)
          rules.each { |rule| rule.build(start_state) }
        end
      end
    end
  end
end
