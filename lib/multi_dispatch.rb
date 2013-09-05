require 'forwardable'

require_relative 'multi_dispatch/version'
require_relative 'multi_dispatch/dispatch'


module MultiDispatch

  def self.included(base)
    base.extend ClassMethods
  end

end
