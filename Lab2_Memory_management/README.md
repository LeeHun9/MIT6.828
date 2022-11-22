# Lab2: Memory Management
[guide link](https://pdos.csail.mit.edu/6.828/2018/labs/lab2/)
## Introduction
Writing memory management code for our OS, memory management have two components:
1. physical memory allocator for kernel, so that the kernel can allocate memory and later free it.
2. virtual memory, which maps the virtual address used by kernel and user software to address in physical memory.

## Getting started
```sh
cd lab 
git checkout -b lab2 origin/lab2
```
## Part 1: Physical Page Management

JOS manages the PC's physical memory with `page` granularity, and use the MMU to map and protect each piece of allocated memory.



Now need to write **physical page allocator**, which keeps track of which pages are free with a linked list of `struct Pageinfo` objects(`memlayout.h` line 175). A object corresponding to a physical page.

### Exercise 1
> In the file kern/pmap.c, you must implement code for the following functions (probably in the order given).
> 
> boot_alloc()
> 
> mem_init() (only up to the call to check_page_free_list(1))
> 
> page_init()
> 
> page_alloc()
> 
> page_free()
> 
> check_page_free_list() and check_page_alloc() test your physical page allocator. 

d