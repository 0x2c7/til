In this post, I'll show you some introduction to an advanged data structure
called Interval Tree. Note that the word `advanged` here means that this data
structure is used to solve a too specific kind of computer science problems. It
doesn't do anything with the level of the developers. Don't worry, you don't
need to be a ninja to read. I bet you will be surprised about how simple it is :)

I don't intend to write a science document. This post is just a post I wrote for
myself to read later. I'm trying to explain the concept of Interval tree as
simple as I could, based on what I researched about it. So, you could find tons
of bugs inside. Please report / discuss with me to make it better.

#### Let's get started
Before we jump suddenly into the definition. Let's just start with this simple
problem that all developers solved at the beginning their entire carrers: find
the maxximum element of an array. For example and result:
  ```
  A = [7, 9, 4, 3, 6, 2, 3, 5]
  Max(A) = 9
  ```
It is too easy for you huh? Just a single loop and done. Problem solved. The
time complexity of this problem is `O(n)`.

Continue with something more complicated: find the maximum element of all elements with index from `i` to `j` of a given array. For example and result:
```
A = [7, 9, 4, 3, 6, 2, 3, 5]
Max(A, 3, 5) = Max([3, 6, 2]) = 6
```
Hm... Nothing changes. It's just a little more abstract problem of the above
one. The complexity is still `O(n)`.

Are you now disappointed? Let's the fun begin: given an array `A` with `n`
elements and `m` pairs of number; with each pair of number `i` and `j`, print out the maximum element of all elements with index from `i` to `j` of `A`. Note that `n <= 100` and `m <= 1_000_000`. For example and result:

```
A = [7, 9, 4, 3, 6, 2, 3, 5]
n = 8
m = 3
Max(A, 3, 5) = Max([3, 6, 2]) = 6
Max(A, 1, 2) = Max([9, 4]) = 9
Max(A, 0, 7) = Max(A) = 9
```
This one is totally, different right? You may come up with many solutions for
this. You can think about building a cache 2D array at the beginning to store
all the maximum values. That's a good solution. With some dynamic programming
technique, it becomes `O(n^2)`. But it doesn't work if we
increase the number of `n` to about `100_000`. Before you found a good solution for this. Let's make it more difficult :D

#### Ultimate problem
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
If you want to try the tradition solution that just loop and update the value
and then loop and count, forget about it. With the time complexity `O(n*m)`, it
will cost you `100_000 * 1_000_000 = 10^11` operations. On my Macbook Pro
2015, Core i7, it costs me hours to finish. This solution is unacceptable.

How about caching into 2D array like above? Nah, think about `100_000 x 100_000 x 4` bytes for that giant array. Even the array building at beginning is costly too. In addtion, when you update the elements, the whole 2D array must be updated too. That destroys the whole caching idea of this solution.

Wow, this is tough hah? To archive the problem requirement, we loop too much,
for both query and updating. You must wish that we don't need to loop that much. If you look again at the above example, you will see that range `0..1` which is `[7, 9]` and range `7..9` which is `[5, 4, 0]` don't change at all. So, the query result doesn't change if we process the query on those range. We could cache that. Unfortunately, there is not any operation that match exactly with the range we need to query. Let's find some way to walk around it.

The problem requirement is too find the maximum elments. Recall the some arithmetical nature of maxinum operation. `Max(a, b) = a if a > b` and `Max(a, b) = Max(b, a)`. Hmm... Nothing interesting. We are working on range. How about the maxinum operation on three element? `Max(a, b, c) =  Max(a, Max(b, c))`. For element? `Max(a, b, c, d) =  Max(Max(a, b), Max(c, d))`. Oh hey! We could find the max of a range by spliting the range into two ranges, find the max of each range and compare those partial maxes to get the whole range's max. Let's apply for the above example.
```
Max(A, 3, 9) = Max(Max(A, 3, 6), Max(A, 7, 9))
```
The range `7..9` doesn't change from the beginning to the end. We should cache
that part and find just loop to find the maximum from `3..6`. That seems legit!
Split the entire array into two ranges, each range is splitted into smaller
ranges and so on. Oh wait. Isn't that the concept of **binary tree**? Yup. We
can solve the problem by setting up a special type of binary tree. Each node will manage a range `i..j`. In this context, it is reasonal to choose let two child ranges equal. So, left node manages `i..(i + j) / 2` and right node manages `(i + j) / 2 + 1 .. j`. This new kind of tree is called **Interval Tree** (usually ambiguous with its coursin **Segment Tree**, I'll discuss about this later). Obviously, the way array is splited into half leads to the fact that Interval Tree is a **balanced binary tree**.

#### A little more abstraction (draft)
* People when working in the real life realize that there exists some problems
  which could be categorized into the same class of this problem. For example:
  instead of finding min or max, we need to find the sum of a range in an array;
  or we need to find out how many elements in a range which are bigger than a
  number, etc.
* Step back a little while and think of the similarities of mentioned problems,
  we can easily conduct some abstract natures for the union set of problem:
  * Initially given some array A with pre-defined values for each element
  * We could process two types of operation on the given array: query and update
    operations.
  * The query operation usually require us to find the final processing result
    (usually count, sum, multiply ...) from all the elements satisfying
    condition K (optinal) in a range i..j of the array A.
  * The update operation usually require us to update all elements in range i..j of the array A, usually set value, increase, decrease etc.

* Interval tree was born to solve this kind of problems efficiently.

#### Problem solved (draft)
* Kindly solve the problem with interval tree. Draw a lot of sketches to support
  the idea
* Raise the problem with updating operations: it still update all the elements
  => decrease the time complexity to `O(n*m)`. Quote the example above. Improve the solution by caching
  updating operation: updating go from top to bottom. If the updating range
  match 100% of the current range, no need to go deeper, mark that node
  updating. When query from top to bottom, if 100% match again, return that
  value, no need to gather deeper children. If need its deeper query, update
  that cached node and its children.
* If possible, post some gifs here to illustrate the whole solution
#### Another problems (draft)
* From abstraction part, raise problems with counting (LITES on SPOJ) and describe the solution
* Real life example with calculate reactangle area problem (available on SPOJ)
#### 2D Interval Tree (draft)
* Devide and conquer classic problem => Lead to 2D Interval Tree which has 4
  children and manage a 2D Reactangle instead of a range.
#### Implement Interval Tree with Ruby (draft)
* Something need to be mentioned about implementation
* Interval tree is balanced binary tree. So we can use an array to store instead
  of real referenced structure. Just like heap
#### Interval Tree vs Segment Tree (draft)
* Segment Tree is the basic version of Interval Tree. Mainly used to count
  things.

