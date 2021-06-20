---
layout: post
title: Blog pagination support in blogc
date: 2021-02-18
---

After taking quite a break on working on my website I decided to finally add pagination support for the blog on my website, which you are currently reading.  
Since I set up my website on blogc it just made sense to keep using that and even though I had quite a hard time figuring stuff out, again, as there is only documentation to work with, I pulled it off.

As it is now, the blog shows 1 blog entry per site, which I might change in the future once I modify the CSS a bit to make distinguishing between posts easier. Currently the only way to distinguish between them is via the newly added header for every post, which is in orange, being the standard link color.

From anywhere on the site you can get to the blog by clicking the blog entry at the top of my page as usual, which will direct you to the newest entry of the blog. At the bottom of each blog site you can find some navigation, allowing you to navigate to the next and previous blog.  
At the top of each entry you can see the title of the entry, which is a permanent link to the entry it describes. This is needed since you won't be able to point to the same blog entry once new ones are uploaded or old ones are deleted. With the permanent link you can always access the blog entry as long as it's still on the server.

Further things to implement are:

- Index of the blog showing each blog entry
- Jumping to the first/last entry
- RSS feed
- showing the date of publication for a blog entry
- adding some sort of box to each entry
