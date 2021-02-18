wiredspace.de
-------------

# Dependencies

- GNU make
- blogc

# Build
Build this with `make clean all`.

# Adding blog posts
To add a blog post, write one in simple markdown (which flavour exactly is described in [blogc-source(7)](https://blogc.rgm.io/man/blogc-source.7.html)) and put it in the `content/blog/` directory. You then need to add the file name without the file ending to the `POSTS` variable in the Makefile.
