require_relative '../lib/multi_dispatch.rb'


# reverse for Array
MultiDispatch::def_multi :reverse, [] { [] }
MultiDispatch::def_multi :reverse, Array do |list| 
  [list.pop] + reverse(list) 
end

p reverse [1,2,3,4,5]

# map for Array
MultiDispatch::def_multi :map, [], Proc do ; [] end
MultiDispatch::def_multi :map, Array, Proc do |list, func|
  [func.call(list.first)] + map(list[1..-1], func)
end

p map [1,2,3], lambda { |x| x**2 }

# foldl for Array (equivalent to haskell Data.List implementation)
MultiDispatch::def_multi :foldl, Proc, Object, [] do |f, init, l|
  init
end
MultiDispatch::def_multi :foldl, Proc, Object, Array do |f, init, l|
  foldl(f, f.call(init, l.first), l.drop(1)) 
end

p foldl(lambda { |x, y| x+y }, 0, [1,2,3,4,5])


