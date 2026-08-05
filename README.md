# Joy TodoMVC example

[TodoMVC](https://todomvc.com) written in [Joy](https://github.com/niclas-ahden/joy), a framework for building web apps in [Roc](https://www.roc-lang.org).

## Run it

```sh
$ git clone https://github.com/niclas-ahden/joy-todomvc
$ cd joy-todomvc
$ nix develop
$ ./watch.roc
```

The app is now available at [`http://localhost:8000`](http://localhost:8000). Edit `app.roc` and it recompiles on save. Refresh the browser to see your changes (there is no hot-reloading yet). Set `JOY_WATCH_PORT` to serve on another port.

The first `nix develop` builds the pinned Roc compiler from source, which takes a while. After that it comes from the Nix cache.

If you don't want to use Nix then please install:

* [`roc`](https://www.roc-lang.org/install)
* [`caddy`](https://caddyserver.com/docs/install)

## Structure

```
app.roc        The TodoMVC app. This is the file to play with.
build.roc      Builds app.roc into www/app.wasm and copies Joy's runtime.js
               out of the platform bundle next to it.
watch.roc      Serves www/ with caddy and recompiles app.roc on change,
               using roc's own `--watch`.
Caddyfile      The dev server: serves www/ with revalidation forced, so a
               rebuilt wasm is never shadowed by the last one.
www/           The page: index.html and style.css. The wasm and runtime.js
               land here on build (both gitignored).
```

Play around with it, it's a great starting point for a web app!
