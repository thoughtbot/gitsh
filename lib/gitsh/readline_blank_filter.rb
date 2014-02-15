require 'gitsh/module_delegator'

class ReadlineBlankFilter < ModuleDelegator
  def readline(prompt, add_hist = false)
    module_delegator_target.readline(prompt, add_hist).tap do |result|
      if add_hist && result.strip.empty?
        module_delegator_target::HISTORY.pop
      end
    end
  end
end
