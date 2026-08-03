#!/usr/bin/env roc
# Run:
#
#   ./watch.roc
#
# To serve the app at http://localhost:8000. Edit app.roc (or anything else)
# and it rebuilds automatically. Refresh the page to see your changes (there
# is no browser hot-reloading yet). Run from the repo root.
#
# Set the environment variable `JOY_WATCH_PORT` to change the port (default 8000).
app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
}

import pf.Cmd
import pf.Env
import pf.Stdout

main! = |_args| {
	port = Env.var_str!("JOY_WATCH_PORT") ?? "8000"

	# --nocache matters here: a stale app.wasm survives even a hard reload,
	# because runtime.js fetches it rather than the browser loading it.
	server =
		Cmd.new_str("simple-http-server")
			.args_str(["--index", "--nocache", "--silent", "--port", port, "www"])
			.spawn_grouped!()?

	Stdout.line!("=> Serving the app at http://localhost:${port}")?

	# www/runtime.js is ignored because build.roc writes it on every run,
	# which would otherwise retrigger the watch.
	watchexec =
		Cmd.new_str("watchexec")
			.args_str(["--no-global-ignore", "--restart", "--print-events", "--debounce", "500ms", "--exts", "roc,html,css,js", "--ignore", "www/runtime.js", "--", "./build.roc"])
			.exec_exit_code!()
			.ok_or(1)

	server.kill!() ?? {}

	if watchexec == 0 {
		Ok({})
	} else {
		Err(Exit(watchexec))
	}
}
