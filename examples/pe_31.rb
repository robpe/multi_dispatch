require_relative '../lib/multi_dispatch.rb'

# PROJECT EULER PROBLEM 31
#
# The example shows that it's possible to simulate pattern matching 
# behavior using anonymous functions to define condition for the pattern.
# It is equivalent to the haskell cade below:
#
# count _ 0      = 1
# count [c] _    = 1
# count (c:cs) s = sum $ map (count cs . (s-)) [0,c..s]


MultiDispatch::def_multi :count, Object, 0 do ;  1 end
MultiDispatch::def_multi :count, 
  lambda { |list| list.size == 1 }, Object do  |a, b| 1 end
MultiDispatch::def_multi :count, Array, Numeric do |list, sum|
  (0..sum).step(list.first).to_a.map { |e| 
    count(list[1..-1], sum-e) 
  }.reduce(:+)
end

p count( [200,100,50,20,10,5,2,1], 200)
