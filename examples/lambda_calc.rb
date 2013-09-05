require_relative '../lib/multi_dispatch.rb'

class Interpreter
  include MultiDispatch

  def initialize
    @env = Env.new
  end

  class Env < Hash
  end
  
  class Expression 

  end

  class Var < Expression
    attr_accessor :name
    def initialize(name)
      @name = name
    end
  end

  class Num < Expression
    attr_accessor :value
    def initialize(value) ; @value = value end
  end

  class Bool < Expression
    attr_accessor :value
    def initialize(value) ; @value = value end
  end

  class Plus < Expression 
    attr_accessor :left, :right
    def initialize(left, right)
      @left, @right = left, right
    end
  end
  
  class Minus < Expression 
    attr_accessor :left, :right
    def initialize(left, right)
      @left, @right = left, right
    end
  end

  class Func < Expression
    attr_accessor :var_name, :body
    def initialize(var_name, body)
      @var_name, @body = var_name, body
    end
  end 

  class Closure
    attr_accessor :var_name, :body
    def initialize(var_name, body)
      @var_name, @body = var_name, body
    end
  end

  class Call < Expression
    attr_accessor :func, :param
    def initialize(func, param)
      @func, @param = func, param 
    end
  end

  class LetDirect
    attr_accessor :var, :expr, :body
    def initialize(var, expr, body)
      @var, @expr, @body = var, expr, body
    end
  end
  
  class LetByFunc
    attr_accessor :var, :expr, :body
    def initialize(var, expr, body)
      @var, @expr, @body = var, expr, body
    end
  end

  class If
    attr_accessor :cond, :if_true, :if_false
    def initialize(cond, if_true, if_false)
      @cond, @if_true, @if_false = cond, if_true, if_false
    end
  end

  def_multi :evaluate, Num do |num|
    num.value
  end

  def_multi :evaluate, Plus do |plus|
    evaluate(plus.left) + evaluate(plus.right)
  end

  def_multi :evaluate, Minus do |minus|
    evaluate(minus.left) - evaluate(minus.right)
  end

  def_multi :evaluate, Bool do |bool|
    bool.value
  end

  def_multi :evaluate, Var do |var|
    @env[var.name]
  end

  def_multi :evaluate, Func do |func|
    Closure.new(func.var_name, func.body)
  end

  def_multi :evaluate, Call do |call|
    closure = evaluate(call.func)
    @env[closure.var_name] = evaluate(call.param)
    evaluate(closure.body)
  end

  def_multi :evaluate, If do |stat|
    evaluate(stat.cond) ? evaluate(stat.if_true) : evaluate(stat.if_false)
  end

  def_multi :evaluate, LetDirect do |let_dir| 
    @env[let_dir.var] = evaluate(let_dir.expr)
    ret = evaluate(let_dir.body) ; @env.delete(let_dir.var) ; ret
  end  
  
  def_multi :evaluate, LetByFunc do |let_func|
    evaluate(Call.new(Func.new(let_func.var, let_func.body), let_func.expr))
  end


  def test
    p evaluate(Num.new(7))
    p evaluate(Plus.new(Num.new(3), Num.new(5)))
    p evaluate(Minus.new(Num.new(4), Num.new(4)))
    p evaluate(Plus.new(Num.new(5), Minus.new(Num.new(2), Num.new(1))))
    @env[:a] = 5
    p evaluate(Var.new(:a))
    p evaluate(Plus.new(Var.new(:a), Minus.new(Num.new(2), Num.new(1))))
    p evaluate(Call.new(Func.new(:x, Plus.new(Var.new(:x), Num.new(1))), Num.new(2)))
    p evaluate(Call.new(
      Func.new(:f, Plus.new(Num.new(2), Call.new(Var.new(:f), Num.new(8)))), 
      Func.new(:x, Plus.new(Num.new(5), Var.new(:x)))))
    p evaluate(Call.new(
      Func.new(:f, Plus.new(Num.new(2), Call.new(Var.new(:f), Num.new(8)))), 
      Func.new(:f, Plus.new(Num.new(5), Var.new(:f)))))
    
    p evaluate(LetDirect.new(:x, Num.new(28), Var.new(:x))) # 28
    p evaluate(LetByFunc.new(:x, Num.new(18), Var.new(:x))) # 18
    p evaluate(LetByFunc.new(:b, Bool.new(true), Var.new(:b))) # 6
    p evaluate(LetByFunc.new(:b, Bool.new(true), If.new(Var.new(:b), Num.new(6), Num.new(7)))) # 6
    p evaluate(LetByFunc.new(:b, Bool.new(false), If.new(Var.new("b"), Num.new(6), Num.new(7)))) # 7
    

  end

end

inter = Interpreter.new
inter.test
