require_relative '../lib/multi_dispatch.rb'
require 'minitest/autorun'

class TestAmbiguity < MiniTest::Unit::TestCase
  
  class Foo
    include MultiDispatch
    
    def_multi :arg, 1, Numeric do |*a|
      a.first 
    end
    def_multi :arg, Numeric, 2 do |*a|
      a.last
    end

    def_multi :is_one?, 1 do 
      true
    end
    def_multi :is_one?, lambda { |x| x == 1 } do
      true
    end

  end

  def test_ambigous_cases
    f = Foo.new
    
    assert_equal(2, f.arg(1,2))
    assert_equal(1, f.arg(1, 1337))
    assert_equal(2, f.arg(1337, 2))
  end

  def test_values_over_lambdas
    f = Foo.new
    # values have higher priority than lambda functions
      assert_equal( 1,
        f.singleton_class.instance_multi_method(:is_one?, 1).parameters.first)

  end  

end
