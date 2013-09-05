require_relative 'unbound_multi_method'
require_relative 'multi_method'

module MultiDispatch

  module ClassMethods

    def def_multi(_name, *args, &body)
#       _name = args.shift
      # closure (to prevent namespace pollution)
      multi_methods = {}

      # only at first invocation
      define_singleton_method :instance_multi_methods do 
        multi_methods.values.flatten
      end
      
      define_singleton_method :instance_multi_method do |name, *args|
        mthd = self.instance_multi_methods.select do |m| 
          m.match?(name, args) 
        end.sort_by { |m| m.match_distance(args) }.first
        unless mthd
          raise NoMethodError,
            "undefined method `#{name}' for class `#{singleton_class}'"
        end
        mthd
      end

      define_singleton_method :def_multi do |name, *args, &body|
        multi_methods[name] ||= []
        multi_methods[name].unshift(UnboundMultiMethod.new(name, *args, body ))
        if !method_defined?(name)
          define_method name do |*params|
            singleton_class.instance_multi_method(name, *params).
            bind(self).call(*params)
          end
        end
      end
      self.send(:def_multi, *([_name]+args), &body)
    end

  end

  def self.def_multi(name, *args, &body)
      Object.instance_eval do
        include MultiDispatch
        def_multi(name, *args, &body)
      end
  end

  def self.instance_multi_methods ; [] end
  def self.instance_multi_method(name, obj)
    raise NoMethodError,
      "undefined method `#{name}' for class `#{obj.class}'"
  end

end

