require 'minitest/autorun'
require_relative '../lib/multi_dispatch'


class TestSimpleStuff < MiniTest::Unit::TestCase
  
  class JuliaExample
    include MultiDispatch

    def initialize(mul)
      @mltplr = mul
    end

    def_multi :g, Float, Float do |x, y|
      @mltplr*x + @mltplr*y
    end

    def_multi :g, Float, Object do |x, y|
      @mltplr*x + y
    end

    def_multi :g, Object, Float do |x, y|
      x + @mltplr*y
    end
  end

  def test_looking_up_instance_multi_methods_works
    multi_methods = JuliaExample.instance_multi_methods
    
    assert_equal(3, multi_methods.size)
    assert_equal(3, multi_methods.select { |m| m.name == :g }.size)
    
    example = JuliaExample.new(2)
    assert_equal( 
      JuliaExample.instance_multi_methods.select { |m|
        m.patterns.all? { |p| p.eql? Float } 
      }.first, 
      JuliaExample.instance_multi_method(:g, 1.0, 1.0))
  end

  def test_bind_call_to_proc_methods
    unbound = JuliaExample.instance_multi_method(:g, Float, Float)
    bound = unbound.bind(JuliaExample.new(7))
    
    assert_equal(unbound, bound.unbind)
    expected = JuliaExample.new(7).g(133.0, 37.0)
    assert_equal(expected, bound.call(133.0, 37.0))
    assert_equal(expected, bound.to_proc.call(133.0, 37.0))
  end

  def test_dispatch_fails_on_nonexistent_methods
    example = JuliaExample.new(7)
    assert_raises(NoMethodError) { example.f(1) }
    assert_raises(NoMethodError) { 
      JuliaExample.instance_multi_method(:f, 1)
    }
  end

end

class TestDispatchFunctionality < MiniTest::Unit::TestCase

  class Container
    include MultiDispatch
    
    def_multi :reverse, [] { [] }
    def_multi :reverse, Array do |list| 
      [list.pop] + reverse(list) 
    end

    def_multi :map, [], Proc do ; [] end
    def_multi :map, Array, Proc do |list, func|
      [func.call(list.first)] + map(list[1..-1], func)
    end

  end

  def test_multi_methods
    container = Container.new
    container.reverse([1,2,3,4,5])

    assert_equal( [5,4,3,2,1], container.reverse([1,2,3,4,5]))
    assert_equal( [1,4,9,16], 
                  container.map([1,2,3,4], Proc.new { |x| x**2 }))
  end

end
