class ModuleDelegator < Module
  def initialize(module_delegator_target)
    @module_delegator_target = module_delegator_target
  end

  def method_missing(method_name, *args, &block)
    module_delegator_target.send(method_name, *args, &block)
  end

  def respond_to_missing?(method_name, include_all)
    module_delegator_target.respond_to?(method_name, include_all)
  end

  def const_missing(const_name)
    module_delegator_target.const_get(const_name)
  end

  private

  attr_reader :module_delegator_target
end
