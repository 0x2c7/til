class Node
  attr_reader :range
  attr_accessor :cache, :max, :left, :right

  def initialize(range)
    @range = range
    @cache = nil
  end

  def belong_to?(input_range)
    range.first <= input_range.first && input_range.last <= range.last
  end

  def leaf?
    left.nil? && right.nil?
  end

  def migrate_cache
    return if @cache.nil?
    @left.assign_cache(@cache) unless @left.nil?
    @right.assign_cache(@cache) unless @right.nil?
    @cache = nil
  end

  def assign_cache(cache)
    @cache = cache
    @max = cache
  end
end

class IntervalTree
  attr_reader :root, :array

  def initialize(size, array)
    @root = build(0..(size - 1), array)
    @array = array
  end

  def build(range, array)
    node = Node.new(range)
    if range.count == 1
      node.max = array[range.first]
      return node
    end
    mid = (range.first + range.last) / 2
    node.left = build(range.first..mid, array)
    node.right = build((mid + 1)..range.last, array)
    node.max = max(node.left.max, node.right.max)
    node
  end

  def query(range)
    do_query(@root, range)
  end

  def update(range, value)
    do_update(@root, range, value)
  end

  private

  def do_query(current_node, query_range)
    if invalid_range?(query_range) || !current_node.belong_to?(query_range)
      return -Float::INFINITY
    end

    return current_node.max if query_range == current_node.range
    current_node.migrate_cache

    max_left = do_query(
      current_node.left,
      query_range.first..left_bound(query_range, current_node)
    )
    max_right = do_query(
      current_node.right,
      right_bound(query_range, current_node)..query_range.last
    )

    max(max_left, max_right)
  end

  def do_update(current_node, update_range, value)
    if invalid_range?(update_range) || !current_node.belong_to?(update_range)
      return
    end

    if update_range == current_node.range
      current_node.assign_cache(value)
      return
    end
    current_node.migrate_cache

    do_update(
      current_node.left,
      update_range.first..left_bound(update_range, current_node),
      value
    )
    do_update(
      current_node.right,
      right_bound(update_range, current_node)..update_range.last,
      value
    )
    current_node.max = max(
      current_node.left.max,
      current_node.right.max
    )
  end

  def invalid_range?(range)
    range.first > range.last
  end

  def left_bound(range, current_node)
    min(range.last, current_node.left.range.last)
  end

  def right_bound(range, current_node)
    max(current_node.right.range.first, range.first)
  end

  def min(a, b)
    a < b ? a : b
  end

  def max(a, b)
    a > b ? a : b
  end
end
