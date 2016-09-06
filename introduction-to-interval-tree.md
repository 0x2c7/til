# Introduction to Interval Tree

In this post, I'll show you some introduction to an advanged data structure called Interval Tree. Note that the word `advanged` here means that this data structure is used to solve a too specific kind of computer science problems. It doesn't do anything with the level of the developers. Don't worry, you don't need to be a ninja to read. I bet you will be surprised about how simple it is :)

I don't intend to write a science document. This post is just a post I wrote for myself to read later. I'm trying to explain the concept of Interval tree as simple as I could, based on what I researched about it. So, you could find tons of bugs inside. Please report / discuss with me to make it better.

## Let's get started
Before we jump suddenly into the definition. Let's just start with this simple problem that all developers solved at the beginning their entire carrers: find the maxximum element of an array. For example and result:
```
A = [7, 9, 4, 3, 6, 2, 3, 5]
Max(A) = 9
```
It is too easy for you huh? Just a single loop and done. Problem solved. The time complexity of this problem is `O(n)`.

Continue with something more complicated: find the maximum element of all elements with index from `i` to `j` of a given array. For example and result:
```
A = [7, 9, 4, 3, 6, 2, 3, 5]
Max(A, 3, 5) = Max([3, 6, 2]) = 6
```
Hm... Nothing changes. It's just a little more abstract problem of the above one. The complexity is still `O(n)`.

Are you now disappointed? Let's the fun begin: given an array `A` with `n` elements and `m` pairs of number; with each pair of number `i` and `j`, print out the maximum element of all elements with index from `i` to `j` of `A`. Note that `n <= 100` and `m <= 1_000_000`. For example and result:

```
A = [7, 9, 4, 3, 6, 2, 3, 5]
n = 8
m = 3
Max(A, 3, 5) = Max([3, 6, 2]) = 6
Max(A, 1, 2) = Max([9, 4]) = 9
Max(A, 0, 7) = Max(A) = 9
```
This one is totally, different right? You may come up with many solutions for this. You can think about building a cache 2D array at the beginning to store all the maximum values. That's a good solution. With some dynamic programming technique, it becomes `O(n^2)`. But it doesn't work if we increase the number of `n` to about `100_000`. Before you found a good solution for this. Let's make it more difficult :D

## Ultimate problem
Given an array `A` with `n` elements and `m` set of number (`n <= 100_000`, `m <= 1_000_000`). Each set of number has two format:
* `0 i j`: print out the maximum elements with index from `i` to `j`
* `1 i j k`: set all elements with index from `i` to `j` to the value `k`

For example:
```
A = [7, 9, 4, 3, 6, 2, 3, 5, 4, 0]
n = 10
m = 7
Max(A, 3, 5) = 6

Update(A, 3, 4, 10)
=> A = [7, 9, 4, 10, 10, 2, 3, 5, 4, 0]

Max(A, 1, 4) = 10
Max(A, 3, 9) = 10

Update(A, 2, 6, 1)
=> A = [7, 9, 1, 1, 1, 1, 1, 5, 4, 0]

Max(A, 1, 4) = 9
Max(A, 3, 9) = 5
```
If you want to try the tradition solution that just loop and update the value and then loop and count, forget about it. With the time complexity `O(n*m)`, it will cost you `100_000 * 1_000_000 = 10^11` operations. On my Macbook Pro 2015, Core i7, it costs me hours to finish. This solution is unacceptable.

How about caching into 2D array like above? Nah, think about `100_000 x 100_000 x 4` bytes for that giant array. Even the array building at beginning is costly too. In addtion, when you update the elements, the whole 2D array must be updated too. That destroys the whole caching idea of this solution.

Wow, this is tough hah? To archive the problem requirement, we loop too much, for both query and updating. You must wish that we don't need to loop that much. If you look again at the above example, you will see that range `0..1` which is `[7, 9]` and range `7..9` which is `[5, 4, 0]` don't change at all. So, the query result doesn't change if we process the query on those range. We could cache that. Unfortunately, there is not any operation that match exactly with the range we need to query. Let's find some way to walk around it.

The problem requirement is too find the maximum elments. Recall the some arithmetical nature of maxinum operation. `Max(a, b) = a if a > b` and `Max(a, b) = Max(b, a)`. Hmm... Nothing interesting. We are working on range. How about the maxinum operation on three element? `Max(a, b, c) =  Max(a, Max(b, c))`. For element? `Max(a, b, c, d) =  Max(Max(a, b), Max(c, d))`. Oh hey! We could find the max of a range by spliting the range into two ranges, find the max of each range and compare those partial maxes to get the whole range's max. Let's apply for the above example.
```
Max(A, 3, 9) = Max(Max(A, 3, 6), Max(A, 7, 9))
```
The range `7..9` doesn't change from the beginning to the end. We should cache that part and find just loop to find the maximum from `3..6`. That seems legit!  Split the entire array into two ranges, each range is splitted into smaller ranges and so on. Oh wait. Isn't that the concept of **binary tree**? Yup. We can solve the problem by setting up a special type of binary tree. Each node will manage a range `i..j`. In this context, it is reasonal to choose let two child ranges equal. So, left node manages `i..(i + j) / 2` and right node manages `(i + j) / 2 + 1 .. j`. This new kind of tree is called **Interval Tree** (usually ambiguous with its coursin **Segment Tree**, I'll discuss about this later). Obviously, the way array is splited into half leads to the fact that Interval Tree is a **balanced binary tree**. Each node has no children (leaf node) or two children (normal node).

## A little more abstraction
In fact, when working with pure computer science problems, people realize there are many ones which could be categorized into the same class of this problem. For example: instead of finding min or max, we need to find the sum of a range in an array; or we need to find out how many elements in a range which are bigger than a number, etc.
Step back a little while and think of the similarities of mentioned problems, we can easily conduct some abstract natures for the union set of problem:
* Initially given some array A with pre-defined values for each element
* We could process two types of operation on the given array: query and update operations.
* The update operation usually require us to update all elements in range i..j of the array A, usually set value, increase, decrease etc.
* The query operation usually require us to find the final processing result (usually count, sum, multiply ...) from all the elements satisfying condition K (optinal) in a range i..j of the array A.

Interval tree was born to solve this kind of problems efficiently. Although each problem could have better exclusive optimised solution, the Interval Tree is more abstract, reuseable and doesn't require further research time. Subsequently, if you don't need a specially strict solution for those problems, I think interval tree is great enough for most of the cases.

## Problem solved

### Building the tree
It's time to go back to our problem. From the array `A = [7, 9, 4, 3, 6, 2, 3, 5, 4, 0]`, we build the Interval Tree in which the root node is the whole array. Left node is the segment `[7, 9, 4, 3, 6]` and the right node is `[2, 3, 5, 4, 0]`. Apply the same rule for those nodes until we reach leaf node, which contains only one element. Beside the managed range, each node contains one more attribute called `Range Max`, which is the maximum element of the managed range. Initally, only the leaf node has range max value which is the only value of the managed range. Recursively building the tree from the root node to the leaf node, we got this tree:

![Interval Tree Building](./introduction-to-interval-tree/tree1.jpg)

*Upper yellow part is the range that node manage and bottom green part is the range max*

Obviously, we find the range max of non-leaf node easily by its two children: `node.range_max = Max(node.left.range_max, node.right.max_max)`. The tree building process could be subscribed by the following ruby code:
```ruby
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
```
Each node of an Interval Tree must have 0 children node (leaf node) or 2 children node (normal node). Subsequently, we don't have to be worried about out of range case of the building process. Using above algorithm, we got the whole tree:

![Interval Tree Building Full](./introduction-to-interval-tree/tree2.jpg)

The time complexity of the building tree operator is `O(n * log n)`

### Query operation
To solve the query operation, for example: `Max(A, 3, 5)`, we follow the basic idea: starting with the root, if the node range match 100% with the query range, return the range max as the querying result, otherwise, continue to browse left and right node and return maximum values between left and right querying result. Go back to our current example, we illustrate it by the following figure. The red line is the query result we want to find. It starts at the beginning of the query range and ends at corresponding one.

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query1.jpg)

At the root node, we only have the information of the range max from index 0 to 9. The query result `Q` we want to query is index 3 to 5. We could not conduct a right result from this information. Applying above idea, we need to find the query result `Q1` upon the left node and `Q2` upon the right node. Then, `Q = Max(Q1, Q2)`. Since the left node manage the range from 0 to 4, we only need to find `Q1` from 3 to 4. Similarly, we only need to find `Q2` from range index 5 to 5 upon the right node.

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query2.jpg)

After spliting, we approach the result, but we are still not there yet. Continue spliting the range of `Q1` into `Q3` and `Q4`, and the range of `Q2` into `Q5` and `Q6`. The final result will be `Q = Max( Max(Q3, Q4), Max(Q5, Q6) )`.

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query3.jpg)

Oh wait a minute! Some thing is wrong with `Q3`. The node contains `Q3` manages the range from index 0 to 3, while `Q1` is the result from ... index `3` to index `2`. Hm... I got it. The `Q1` is 100% belongs to the left child node of the node it belongs. So, we don't need to browse the right child node. The sam fact happens with `Q6`. Subsequently, `Q3` and `Q6` is redundant. Let's rename and change the fomula a little bit: `Q = Max( Max(Q3), Max(Q4) ) = Max(Q3, Q4)`

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query4.jpg)

Finally, we got a 100% match. The `Q3` match 100% with its node. So, `Q3` is equal to the range max of its node. In this case, `Q3 = 6`, and `Q1 = Q3 = 6` too. We stop browsing `Q3`'s children nodes from now. In the oposite, `Q4` is still a mysterious, keep spliting deeper until we reach the 100% match, we got the full query tree. Obviously, `Q6 = 2`, `Q5 = 2`, `Q4 = 2` and `Q2 = 2`. Subsequently, `Q = Max(Q1, Q2) = Max(6, 2) = 6`. The full query operator is describe below:

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query5.jpg)

You must be thinking that what the hell, the traditional loop cost only 3 steps. While this algorithm cost nearly at least 7 steps. Yeah, you are right. In micro queries, interval tree is slow comparing to traditional way. Usually, people overcome this weakness by applying traditional searching for micro queries (such as queries with the range under 10 for example) and apply interval-tree-way query for larger queries. If you try another example: `Max(0, 7)`, the interval tree is remarkable faster than traditional way:

![Interval Tree Query Operation](./introduction-to-interval-tree/tree-query6.jpg)

Yup, 4 steps vs 8 steps. Interval Tree wins! The bigger the data is, the more the Interval Tree saves you. After the example, we can easily implement the query operation with following persuade code. To make our code simpler, instead of checking redundant browsing path, we check the out of range condition and return negative infinity if vilolated. It won't affect the result of `Max` operation.

```ruby
  def query(current_node, query_range)
    if invalid_range?(query_range) || !current_node.belong_to?(query_range)
      return -Float::INFINITY
    end

    return current_node.max if query_range == current_node.range

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
```

The time complexity of the query operator is `O(log n)`

### Update operator
Wow, finally we reach the final piece of the puzzlee: update operator. Through the above query operator explanation, perhaps, the first solution popping up in your head is that starting with the root, if the node is leaf node, update the real value of the array and the range max of the node, otherwise, continue to browse left and right node right? Let's follow that solution. The blue line is the range we need to update all elements. With the operator `Update(A, 3, 4, 10)`, starting with the root node, it is not leaf node, browse left and right, go back later. After reaching the leaf node, at each back-recursive step, we update the range max of each node just like when building the tree. Finally, we got the updated Interval tree.

![Interval Tree Update Operation](./introduction-to-interval-tree/tree-update1.jpg)

But wait, it seems like the operator costs too much. We only want to update 2 element, but it costs us 5 steps. Unlike above query operator, this operator's time complexity is `O(n * n)`. It means the more the data is, the more it costs to process this operator. If all the operators are update ones, we are doomed. We must find out a way to go through this challenge. Well, if you don't have any idea yet, just process all the operators in the example by hand first to see whether we could find something interesting or not.
```
Update(A, 3, 4, 10)
Max(A, 1, 4)
Max(A, 3, 9)
Update(A, 2, 6, 1)
Max(A, 1, 4)
Max(A, 3, 9)
```
![Interval Tree Update Operation](./introduction-to-interval-tree/tree-update2.jpg)

Wow, it is so complicated, especially the update operators. It costs half of all while there are only 2 operators! Research the tree, you will find something really interesting. Look at this section of the tree:

![Interval Tree Update Operation](./introduction-to-interval-tree/tree-update3.jpg)


There are 4 query operators and 2 update operators reaching the range `[3, 6]`. There are only two update operators reaching its child nodes. Is it a waste when we update its both left node and child node? The final result of the problem is to print out all the query operators' results. The update operators, in oposite, don't require any evidences to show that the array is updated. So, if the query operators only care about the range `[3, 6]`, not its children node, we could have a shortcut so that we both ensure the query results and save the update cost as much as we could by not updating non-query nodes. Go back to the example, the range `[3, 6]` is updated to value `10`. Two query operators match the range and return the query results. That range is updated to value `1`. Again, two query operators get the query results by 100% match. We come up with an idea: when updating, if the update range match 100% with the node range, cache that update value without browsing the children nodes, otherwise, continue browsing left and right child node of that node; in the recursive tree, update the range max of each node. To match with that idea, the query idea must be audited: starting with the root, if the node range match 100% with the query range, return the range max as the querying result, otherwise, migrate the current node's cache to its children, clear currnt node cache and continue to browse left and right node and return maximum values between left and right querying result. Hm.. It becomes more complicated now. The node of the tree is expanded with an extra attribute (pink rectangle in the figures). By default, the cache attribute is null. Let's make it easier by returning to our example:

![Interval Tree full](./introduction-to-interval-tree/tree-full.jpg)

With update operator `Update(A, 3, 4, 10)`, we browse until we reach range `[3, 6]`, then update the range max and the cache of that node. That's it. We don't even need to update the array.

![Interval Tree full](./introduction-to-interval-tree/tree-update-full1.jpg)

With query operator `Max(A, 1, 4)` and `Max(A, 3, 9)`, we process like above normal way, nothing changes. Query operator `Update(A, 2, 6, 1)` is the same. The next two query operators have nothing special too.

![Interval Tree full](./introduction-to-interval-tree/tree-update-full2.jpg)

Let's add some more examples: `Update(A, 0, 7, 4); Max(A, 3, 9)`. The `Update(A, 0, 7, 4)` is processed just like above, nothing special.

![Interval Tree full](./introduction-to-interval-tree/tree-update-full3.jpg)

When process query operator `Max(A, 3, 9)`, something fun happens. Following the traditional way, we soon reach the following situation. This situation is described above that the query range is inside the node range and the node has an update cache.

![Interval Tree full](./introduction-to-interval-tree/tree-update-full4.jpg)

The update cache is now useless because we want the inside result. So, we clear this cache and update all the elements inside. However, because update action is costly and we are not sure we need all the elements between this range, we choose a smarter approach. Look at that node, we are sure that all the elements inside the range in the left node and the right node have the same value with the cache. Subsequently, we create the cache for both left node and right node. The value of those caches are the same as the value of the cache in parent node. This action is temperarily called cache migration. After this action, we continue the querying operator.

![Interval Tree full](./introduction-to-interval-tree/tree-update-full5.jpg)

Soon, we get the query result, which is `4`. This is the whole update query process we need :) This process could be described by the following persuade code:

```ruby
  def update(current_node, update_range, value)
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
```
The time complexity of the update operator is `O(log n)`

## Implementation
I implemented full problem with available source code at [Interval Tree implementation in ruby](./introduction-to-interval-tree/interval_tree.rb). Note: honestly, this code is for demonstration only because Ruby is not a good language for competitive programming. If you submit this source code to online judgement websites such as codeforces, it could not be compared to compiled static typed language like C++/Java.

Benchmark (array size = 50000, number of commands = 100000)
```
.................|user......|system......|total......|real
Normal way.......|105.520000|0.430000....|105.950000.|(106.561576)
IntervalTree.....|5.060000..|0.040000....|5.100000...|(5.154039)
IntervalTree.....|4.860000..|0.190000....|5.050000...|(5.078880)
with GC disabled
```
Yup. Interval Tree is 20 times faster than normal way. Fair enough right? Let's try bigger test

Benchmark (array size = 100000, number of commands = 500000)
```
.................|user......|system......|total......|real
Normal way.......|1011.97000|2.580000....|1014.55000.|(1020.275318)
IntervalTree.....|25.240000.|0.110000....|25.350000..|(25.506603)
IntervalTree.....|26.59000..|0.860000....|27.450000..|(27.779953)
with GC disabled
```
Now 40 times faster. Impressive! And perhaps GC disable doesn't help in decreasing the running time :D

If you find something wrong or want to discuss more about this. Please don't hesitate to leave a comment. I really appreciate for your feedbacks :)
