# Simple lambda calculus interpreter to evaluate arithmetic expressions 
# in the form of abstract syntax trees. Has support for anonymous 
# functions, closures, and let expressions. 
#
# Implemented in functional way, using multi_dispatch gem.

require_relative '../lib/multi_dispatch.rb'

# helpers
module Camelizer
  def camelize
    return self.to_s if self !~ /_/ && self =~ /[A-Z]+.*/
    to_s.split('_').map { |e| e.capitalize }.join
  end
end

Symbol.send(:include, Camelizer)

# Lambda Calculus Interpreter
class LCI
  include MultiDispatch

  attr_accessor :env

  def initialize
    @env = {}
  end

  def self.def_expr(name, *args)
    klass = Object.const_set(name.camelize, Class.new)
    klass.class_eval do
      attr_accessor *args
      define_method :initialize do |*values|
        args.zip(values).each do |var, value|
          instance_variable_set("@#{var}", value)
        end
      end
    end
  end

  def_expr(:var, :name)
  def_expr(:plus, :left, :right)
  def_expr(:minus, :left, :right)
  def_expr(:func, :var_name, :body)
  def_expr(:closure, :var_name, :body)
  def_expr(:call, :func, :param)
  def_expr(:let_direct, :var, :expr, :body)
  def_expr(:let_by_func, :var, :expr, :body)
  def_expr(:if, :cond, :if_true, :if_false)
  
  def_multi :evaluate, Numeric do |num| ; num end
  def_multi :evaluate, true  do ; true  end
  def_multi :evaluate, false do ; false end

  def_multi :evaluate, Plus do |plus|
    evaluate(plus.left) + evaluate(plus.right)
  end

  def_multi :evaluate, Minus do |minus|
    evaluate(minus.left) - evaluate(minus.right)
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

  class << self ; undef :def_expr end

end

# *** TESTS ***
require 'minitest/autorun'

class TestStuff < MiniTest::Unit::TestCase
  
  # helper for tests
  def eval(expr)
    LCI.new.evaluate(expr)
  end
  
  def test_evaluate_to_7
    assert_equal( 7, 
                  eval(7))
  end
  def test_simple_addition
    assert_equal( 8, 
                  eval( Plus.new(3, 5)))
  end
  def test_nested_addition
    assert_equal( 0, 
                  eval( Minus.new(4, 4)))
  end
  def test_addition_and_subtraction
    assert_equal( 6, 
                  eval( Plus.new(5, Minus.new(2, 1))))
  end
  def test_eval_with_env_variable
    i = LCI.new
    i.env[:a] = 5
    assert_equal( 5, 
                  i.evaluate( Var.new(:a) ))
    assert_equal( 6, 
                  i.evaluate(Plus.new(Var.new(:a), Minus.new(2, 1))))
  end
  def test_functions
    assert_equal( 3,
                  eval(Call.new(Func.new(:x, Plus.new(Var.new(:x), 1)), 2)))
  end
  def test_passing_functions_to_functions
    assert_equal( 15,
      eval(Call.new(
                Func.new(:f, Plus.new( 2, Call.new( Var.new(:f), 8))), 
                Func.new( :x, Plus.new(5, Var.new(:x))))))
    assert_equal( 15, 
      eval(Call.new(
                Func.new(:f, Plus.new(2, Call.new(Var.new(:f), 8))), 
                Func.new(:f, Plus.new(5, Var.new(:f))))))
  end
  def test_let_direct
    assert_equal( 28, eval(LetDirect.new(:x, 28, Var.new(:x))))
    assert_equal( 18, eval(LetByFunc.new(:x, 18, Var.new(:x))))
  end
  def test_let_by_func     
    assert_equal( true, eval(LetByFunc.new(:b, true, Var.new(:b))))
    assert_equal( 6, eval(LetByFunc.new(:b, true, If.new(Var.new(:b), 6, 7))))
    assert_equal( 7, eval(LetByFunc.new(:b, false, If.new(Var.new(:b), 6, 7)))) 
  end

end


