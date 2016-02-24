---
title:  "Ignore Rails public/assets in development"
date:   2013-05-15
tags: [Ruby, Rails]
---

While building a Rails app, I decided to run

```bash
rake assets:precompile
```

on my local machine before uploading the app to production, in order to avoid installing gem I'll never use on my production server. However, after doing this, the behavior of links using `data-confirm` such as

```html
<a href="foobar" data-confirm="really?">foo</a>
```

became kind of weird. After searching a little, I found [this issue](https://github.com/rails/rails/issues/6421), and as explained there, adding

```ruby
config.serve_static_assets = false
```

to my `development.rb` filed solved the problem.
