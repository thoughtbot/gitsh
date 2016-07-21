require 'gitsh/module_delegator'

class LineEditorHistoryFilter < ModuleDelegator
  def readline(prompt, add_hist = false)
    module_delegator_target.readline(prompt, add_hist).tap do |input|
      if add_hist && input && should_not_have_been_added_to_history?
        history.pop
      end
    end
  end

  private

  def should_not_have_been_added_to_history?
    empty? || duplicate?
  end

  def empty?
    history[-1].empty?
  end

  def duplicate?
    history.length > 1 && history[-1] == history[-2]
  end

  def history
    module_delegator_target::HISTORY
  end
end
