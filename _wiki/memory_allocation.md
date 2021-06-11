---
layout: post
title: Memory Allocation
---

# Memory Allocation

## Basics
In order to use the heap, memory has to be allocated. In the programming language _C_, this memory is usually allocated via a call to a library function.
As explained in the book [_Operating Systems: Three Easy Pieces_](http://ostep.org/), managing this space efficiently is very important, but also very hard. A good memory allocator is supposed to be fast and as space-efficient as possible (avoid fragmentation).

### Strategies
The following strategies are all based on the concept of a _free-list_. The nodes of such a list are pointers to free segments. Usually every segment is preceeded by a _header_, which, among other things, contains the size of the following block of space and if it is used or not.
In the following strategies I will not talk about the concept of a header to focus on how the strategy works...
There are several basic strategies found in the previously named book. These are as follows:

#### Best fit
The _best fit_ strategy goes through the free-list and searches for a block of space that is exactly the size of the requested size or bigger. This strategy can very likely end up searching through the whole free-list, if there is no free block that is exactly as big as the requested size. But, if the free-list is being searched and a block of the exact same size as requested is found, the search can be interrupted as there will not be another block that will fit better.

#### Worst fit
Unlike _best fit_, _worst fit_ searches for the _biggest_ block that can satisfy the request. The motivation behind this allocation strategy is that _best fit_ could potentially have really bad fragmentation if the requested size is just a bit smaller then the found free block (e.g. the user requests 5 bytes and a 6 byte big block is found: the block will be split into a 5 byte big block, which is returned to the user, and a 1 byte big block, which, most likely, wont be allocated). In order to avoid that fragmentation, _worst fit_ just searches for the biggest block so that there wont be a small block left after splitting it to satisfy the request for a specific size.

#### First fit
In contrast to _best fit_ and _worst fit_, _first fit_ does not try to search the whole list for a block that meets specific requirements, but instead returns the first free block that satisfies the size requested by the user. This strategy is faster than the previous two, as it doesnt have to search through the whole list every time an allocation is requested.

#### Next fit
Like _first fit_, _next fit_ returns the first free block that satisfies the requested size. There is a single difference here: instead of searching through the list for the first free block from the beginning, it remembers the last returned block and starts searching from there.
