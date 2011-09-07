Parched
=======

Description
-----------

Parched is a minimal wiki designed to be run from a backing Git repository. Parched's features are limited to rendering pages found in the repository, and all editing and collaboration is expected to be done via Git and collaborative tools that support it such as GitHub.

Parched supports some nice features like support for a huge variety of markup formats through Tilt, code highlighting, TeX rendering, in-wiki linking, and partial page inclusion. It's designed to be customizable without manipulating any core source files so that updates to the system are a simple `git pull` away.

### Who Should Use Parched?

A more fully featured wiki is probably a better option for most people in most cases. The remaining subset of people who Parched may be useful for are:

* Those who know Rails well, and want to work with a Rails 3.1 project with minimal cruft and complete specs
* Those looking for a very minimalist wiki solution and who have good familiarity deploying Rails apps

Installation
------------

Clone the repository from GitHub:

    git clone https://github.com/brandur/parched.git

Install Gem dependencies:

    bundle install

Open `config/app.rb` and `config/app/<ENV>.rb` where `ENV` is the environment where you'd like to deploy. Override default options from `app.rb` in the environment-specific file. Overriding keys in environment files is the preferred configuration method to avoid conflicts when new Parched code is pulled in the future, as Parched may modify `app.rb` but will endeavor to never modify any of the environment files.

The most important configuration key to change is `config.repo` which will point the backing Git repository for this Parched installation.

Deploy a new secret token with:

    rake secret_deploy

If you're deploying for production, make sure to precompile the application's assets:

    rake assets:precompile

Now boot the application up on your favorite Rack server (mine is Phusion Passenger) and you're all set to go!

Cache Expiry
------------

Parched uses full page caching while in production to ensure that wiki resources can be accessed quickly and by a large number of visitors. Rails full page caching stores a rendered version of a page and allows the frontend web server to serve it without going through Rails at all. The downside is that these cached pages must be expired when a change is made to their source file.

A few Rake tasks are provided to help with cache expiry when a backing repository gets new commits in production.

Firstly, `rake expire` expires the cache for all files that were part of a single commit.

    rake expire                    # Expire for the last commit (HEAD)
    rake expire revision="HEAD^"   # Expire for the commit at HEAD - 1
    rake expire revision="11be2a"  # Git-style partial match identifying a commit

Another task is provided that will expire the cache for every file in the repository:

    rake expire_all

Usage
-----

Parched is intended as a minimalist viewer for pages in a backing Git repository, and as such has no edit/user/discussion/etc. functionality at all. Changes should be commited to the backing repository via terminal, other Git client software, or pulled socially on a site like GitHub.

### Page Files

Parched is designed to make the entire tree of its backing repository available through pretty and concise web URLs that represent the same structure. A document in the repository's root called `hello.md` is accessible at `/hello`. Directories work as expected, so 'languages/functional/haskell.md` maps to `/languages/functional/haskell`. **Only committed versions of repository files are served by Parched**.

An important thing to note is that a file's extension should be dropped to access its rendered counterpart on Parched (i.e. `.md` in the case of `hello.md` to get `/hello`). If a full filename is is requested like `/hello.md`, Parched will serve that file up in its raw format. This is useful behavior for binaries that are stored in the repository: if `avatar.jpg` is requested, Parched will make no attempt to render it.

When the main page of the wiki is requested (i.e. the root at `/`), Parched looks for a file called `index` in any format that it knows how to process.

Any file in the repository is publicly available except those files whose names start with an underscore (i.e. `_`). The underscore is normally reserved for partial pages (see below for more information on partials).

### Page Links

Inter-wiki links can be created in any file using the syntax:

    [[Page]]

Where `Page` is a repository path. A full link might look like `[[languages/functional/haskell]]` (an extension can be included or omitted). A display name can also be assigned by placing text after a pipe:

    [[Page|Display title]]

Inter-wiki links of this kind are rendered _before_ a file is formatted according to its extension.

### External Links

External links take the same format as inter-wiki links such as `[[http://example.com]]` or `[[http://example.com|A link example]]`.

### Partials

Partial pages can be rendered inside another page using double curly braces:

    {{Partial}}

Here `Partial` is just a reference to another repository file like `{{languages/functional/_index}}`. It's common practice to include an underscore (i.e. `_`) as a prefix to any partial file so that Parched won't attempt to render them as their own page.

### Syntax Highlighting

Syntax highlighting is provided through [Google's Prettify](http://code.google.com/p/google-code-prettify/), a JavaScript-based syntax highlighter. Code that should be highlighted is wrapped inside a GitHub-style code fence:

    ```
    def square(x)
      x * x
    end
    ```

A language hint can also be provided:

    ``` ruby
    def square(x)
      x * x
    end
    ```

### Mathematical Equations

Typesetting for mathematical equations is provided by MathJax. A block style equation should be wrapped with `\[` and `\]`:

    \[ P(E) = {n \choose k} p^k (1-p)^{ n-k} \]

Inline equations are also possible with `\(` and `\)`:

    The Pythagorean theorem is \( a^2 + b^2 = c^2 \).

Note that math is **disabled by default** due to the heavy library dependencies. Override `config.enable_math` in the appropriate environment configuration file.

### Escaping

Links and partials will not be rendered if escaped by prefixing them with a single quote:

    '[[languages/functional/haskell]]
    '{{languages/functional/_index}}

Customization
-------------

There are a few mechanisms available to enable customization of your Parched install. They are specifically designed not to interfere with changes from future pulls from the master repository.

### Layout

A new sublayout can be created and added to `app/views/layouts`. See the default `miniml.html.slim` for the sections where new content can be added. Name your new layout something different, and override `config.layout` with that name in the appropriate environment configuration file for it to take effect.

A header and/or footer can be added directly into your custom layout file, through the use of standard Rails partial helpers (e.g. `== render :partial => 'shared/header'`, or by using Parched's `partial_page` helper to render a page from the backing repository. The following example renders both a header and a footer in an overridden layout:

``` slim
- content_for(:content) do
  == partial_page('internal/_header.md')
  = yield
  == partial_page('internal/_footer.md')
```

### Styling

Copy `app/assets/stylesheets/miniml.css.sass` to your own stylesheet in the same directory and remove `miniml.css.sass`. The name of the new stylesheet isn't important, Rails will bundle everything in that directory. If Rails is in production, `rake assets:precompile` may need to be re-run.
