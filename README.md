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

* [`roc nightly-2026-08-18-e9be50a`](https://github.com/roc-lang/nightlies/releases/tag/nightly-2026-08-18-e9be50a)
* [`caddy`](https://caddyserver.com/docs/install)
* [`playwright 1.61`](https://playwright.dev) (only needed for ./tests.roc)

## Test it

```sh
$ nix develop
$ ./tests.roc
```

Builds the app and drives it through a real Chromium. Every `tests/*_test.roc`
is a standalone Roc program that steers the browser with
[roc-playwright](https://github.com/niclas-ahden/roc-playwright), and
[roc-spec](https://github.com/niclas-ahden/roc-spec) runs them in parallel,
each worker against its own server. `./tests.roc edit` runs only the tests
whose name contains "edit", and `--fail-fast` stops at the first failure.

## Structure

```
app.roc        The TodoMVC app. This is the file to play with.
build.roc      Builds app.roc into www/app.wasm and copies Joy's runtime.js
               out of the platform bundle next to it.
watch.roc      Serves www/ with caddy and recompiles app.roc on change,
               using roc's own `--watch`.
tests.roc      Builds the app and runs the browser tests.
tests/         The tests, their runner (run.roc) and shared helpers
               (TodoPage.roc).
Caddyfile      The dev server: serves www/ with revalidation forced, so a
               rebuilt wasm is never shadowed by the last one. The test
               servers use it too, one per worker.
www/           The page: index.html and style.css. The wasm and runtime.js
               land here on build (both gitignored).
```

Play around with it, it's a great starting point for a web app!
