MultiDispatch
====================

multiple-dispatch is a library extending Ruby objects with multiple dispatch generic functions.

Install
-------
```
gem install multi_dispatch
```

or add `gem 'multi_dispatch'` to Gemfile and use `bundle`.


Usage
-----

Look for examples in the examples/ directory and in test cases test/. Here are simple examples:

Functional style
----------------

```ruby

# reverse for Array
def_multi :reverse, [] { [] }
def_multi :reverse, Array do |list| 
  [list.pop] + reverse(list) 
end

# map for Array
def_multi :map, [], Proc do ; [] end
def_multi :map, Array, Proc do |list, func|
  [func.call(list.first)] + map(list[1..-1], func)
end

# foldl for Array (equivalent to haskell implementation in Data.List module)
def_multi :foldl, Proc, Object, [] do |f, init, l|
  init
end
def_multi :foldl, Proc, Object, Array do |f, init, l|
  foldl(f, f.call(init, l.first), l.drop(1)) 
end
```


Pattern Matching
----------------

It allows to do hacky pattern matching using annonymous functions for defining parameters. The example below shows equivalent Ruby code for Racket examples of list pattern matching:


```ruby
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
```

Method Ambiguities
------------------

It is possible to define a set of methods such that there is no unique most specific method applicable to some combinations of arguments:

```ruby
def_multi :arg, 1, Numeric do |*a|
  a.first 
end
def_multi :arg, Numeric, 2 do |*a|
  a.last
end

# is_one?(1) matches to the method with argument defined by value
def_multi :is_one?, 1 do 
  true
end
def_multi :is_one?, lambda { |x| x == 1 } do
  true
end

1.9.3-p374 :001 > arg(1,2)
2

1.9.3-p374 :001 > arg(1, 1337)
1

1.9.3-p374 :001 > arg(1337, 2)
2

```



