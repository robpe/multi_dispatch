module MultiDispatch
 
  class MultiMethod
    extend Forwardable

    def_delegators :@unbound_method, :arity, :eql?, :to_s, :owner, :name

    def initialize(obj, unbnd_mthd)
      @obj, @unbound_method = obj, unbnd_mthd
    end

    def call(*args)
      if args.size != arity
        raise ArgumentError,
          "wrong number of arguments(#{args.size} for #{arity})"
      end
      @obj.instance_exec(*args, &@unbound_method.body)
    end

    def unbind
      @unbound_method
    end

    def receiver 
      @obj 
    end

    def to_proc
      Proc.new { |*args| call(*args) }     
    end

  end

end
