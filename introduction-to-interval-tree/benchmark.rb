require 'pp'
require 'benchmark'
require_relative './interval_tree'
require_relative './normal'

# Generate random data
size = 50_000
max = 2_000_000_000
command_amount = 100_000
commands = []
array = []
size.times do |index|
  array[index] = rand(0..max)
end
command_amount.times do |index|
  operation = rand(0..1)
  first = rand(0..(size - 1))
  last = rand(0..(size - 1))
  first, last = last, first if first > last
  if operation == 0
    commands[index] = [0, first, last, rand(0..max)]
  else
    commands[index] = [1, first, last]
  end
end

# Compare
def process(tree, commands)
  commands.each do |operation, first, last, value|
    if operation == 0
      tree.update(first..last, value)
    else
      tree.query(first..last)
    end
  end
end
Benchmark.bm do |x|
  x.report("IntervalTree") do
    tree = IntervalTree.new(size, array.dup)
    process(tree, commands)
  end
  x.report("IntervalTree with GC disabled") do
    GC.disable
    tree = IntervalTree.new(size, array.dup)
    process(tree, commands)
  end
  x.report("Normal way") do
    tree = NormalWay.new(size, array.dup)
    process(tree, commands)
  end
end
