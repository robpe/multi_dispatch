module MultiDispatch

  class UnboundMultiMethod
    attr_accessor :patterns, :body, :name

    def initialize(name, *args, body)
      @name, @patterns, @body = name, args, body
    end
    
    def match?(name, params)
      name == @name &&
      params.size == arity &&
      params.zip(@patterns).all? do |param, pattern|
        # match by type (Class)
        (pattern.is_a?(Class) && param.kind_of?(pattern)) ||
        # match by condition passed in Proc object
        (pattern.is_a?(Proc) && pattern.call(param) rescue false) ||
        # match by value
        param == pattern
      end
    end

    def match_distance(params)
      params.zip(@patterns).reduce(0) do |dist, pair|
        prm, ptr = pair
        if prm == ptr ; dist -= 1 
        else
          if (ptr.is_a?(Class) && prm.kind_of?(ptr)) 
            # calculates the distance from given type to parent type
            prm = prm.class
            while (dist+=1 ; prm != ptr) do 
              prm = prm.superclass
            end
          end
        end
        dist
      end
    end
    
    def bind(obj)
      MultiMethod.new(obj, self)
    end

    def arity 
      @patterns.size 
    end

    def eql?(mthd)
      self.body == mthd.body
    end

    def to_s
      "#{self.class}: #{self.class}##{name} (#{@patterns.map { |p| p.is_a?(Proc) ? Proc : p }})"
    end

    def parameters
      @patterns
    end

  end

end
