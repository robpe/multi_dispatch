require_relative '../lib/multi_dispatch.rb'

class ListPatternMatching
  include MultiDispatch

  # (match '(1 2 3)
  #    [(list a b c) (list c b a)]) => '(3 2 1)
  #
  def_multi :ex1, lambda { |l| l.size == 3 } do |list|
    a,b,c = list
    [c, b, a]
  end

  # (match '(1 2 3)
  #    [(list 1 a ...) a]) => '(2 3)
  #
  def_multi :ex2, lambda { |l| l.first == 1 } do |list|
    list[1..-1]
  end

  # (match '(1 2 3 4)
  #    [(list 1 a ..3) a]
  #    [_ 'else]) => '(2 3 4)
  #
  def_multi :ex3, 
            lambda { |l| l.first == 1 && l[1..-1].size >= 3 } do |list|
    list[1..3]
  end

  # (match '(1 2 3 4 5)
  #    [(list 1 a ..3 5) a]
  #    [_ 'else]) => '(2 3 4)
  #
  def_multi :ex4, 
            lambda { |l| l.first == 1 && l.size == 5 && l.last == 5 } do |list|
    list[1..3]
  end

  # (match '(1 (2) (2) (2) 5)
  #    [(list 1 (list a) ..3 5) a]
  #    [_ 'else]) => '(2 2 2)
  #
  ptr = lambda do |list|
    list.first == 1 && list.size == 5 && list.last == 5 &&
    list[1..-2].all? { |e| e.size == 1}
  end
  def_multi :ex5, ptr do |list|
    list[1..3].map(&:first)
  end

  # (match '(1 2 3)
  #   [(list-no-order 3 2 x) x]) => 1
  #
  ptr = lambda do |list|
    list.size == 3 && list.include?(2) && list.include?(3)
  end
  def_multi :ex6, ptr do |list|
    list.delete_if { |x| [2,3].include? x }.first
  end

  # (match '(1 (2 3) 4)
  #   [(list _ (and a (list _ ...)) _) a]) => '(2 3)
  #
  ptr = lambda do |list|
    list.size == 3 && list[1].size >= 1
  end
  def_multi :ex7, ptr do |list|
    list[1]
  end

end

class RegexPatternMatching
  include MultiDispatch
  
  animals_ptr = /dog|cat|cow|ox/ 
  def_multi :classify, lambda { |s| s =~ animals_ptr } do |s|
    s =~ animals_ptr ; [$&, :animal]
  end

  def_multi :classify, lambda { |s| s =~ /-?\d+/ } do |s|
    s =~ /-?\d*/ ; [$&, :integer]
  end

  food_ptr = /burger|pizza|falafel|burrito|pasta/
  def_multi :classify, lambda { |s| s =~ food_ptr } do |s|
    s =~ food_ptr ; [$&, :food]
  end

  os_ptr = /windows|linux|freebsd|solaris|plan b/
  def_multi :classify, lambda { |s| s =~ os_ptr } do |s|
    s =~ os_ptr ; [$&, :os]
  end

end

# *** TESTS ***
require 'minitest/autorun'

class TestStuff < MiniTest::Unit::TestCase

  def test_list_pattern_matching
    pm = ListPatternMatching.new
    assert_equal([3,2,1], pm.ex1([1, 2, 3]))
    assert_equal([2,3],   pm.ex2([1, 2, 3]))
    assert_equal([2,3,4], pm.ex3([1, 2, 3, 4]))
    assert_equal([2,3,4], pm.ex4([1, 2, 3, 4, 5])) 
    assert_equal([2,2,2], pm.ex5([1, [2], [2], [2], 5]))
    assert_equal(1,       pm.ex6([1, 2, 3]))
    assert_equal([2, 3],  pm.ex7([1, [2, 3], 4]))

  end
  
  def test_regexp_pattern_matching
    pm = RegexPatternMatching.new
    assert_equal(['dog', :animal],    pm.classify('some dog'))
    assert_equal(['-1337', :integer], pm.classify('-1337 or 31337'))
    assert_equal(['freebsd', :os],    pm.classify('freebsd is great!'))
    assert_equal(['pasta', :food],    pm.classify('I love italian pasta')) 
  end

end
