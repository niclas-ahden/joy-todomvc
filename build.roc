#!/usr/bin/env roc
# Run:
#
#   ./build.roc
#
# To build app.roc into `www/app.wasm`. Run from the repo root, or let
# ./watch.roc run it for you on every change.
#
# The Joy platform and joy-html arrive as release bundles through the URLs in
# app.roc's header, prebuilt host and client runtime included, so there is
# nothing to compile but the app itself.
app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
}

import pf.Cmd
import pf.Env
import pf.Path
import pf.Stderr

out_path = "www/app.wasm"

main! = |_args| {
	# roc can exit 0 without writing anything, so drop the outputs up front
	# and check that they came back. Something stale must never reach the
	# page ./watch.roc serves.
	drop!(out_path)?
	drop!("www/runtime.js")?

	build_app!()?

	copy_runtime!()
}

drop! = |file| {
	path = Path.utf8(file)
	if path.is_file!()? {
		path.delete!()
	} else {
		Ok({})
	}
}

# The page's ./runtime.js is Joy's client runtime, shipped inside the
# platform bundle so it always matches the platform. The build above put the
# bundle in roc's package cache, so the runtime is copied out of there next
# to the wasm. Nothing to commit, exactly like the wasm itself.
copy_runtime! = || {
	url = platform_url!()?
	hash = match url.split_last("/") {
		Ok(at_slash) => at_slash.after.drop_suffix(".tar.zst")
		Err(_) => url.drop_suffix(".tar.zst")
	}
	home = Env.var_str!("HOME") ?? ""
	cache = Env.var_str!("XDG_CACHE_HOME") ?? "${home}/.cache"
	src = "${cache}/roc/packages/${hash}/www/runtime.js"
	if Path.utf8(src).is_file!()? {
		run!("cp", [src, "www/runtime.js"])
	} else {
		fail!("no runtime.js at ${src}; is app.roc's platform URL a Joy bundle?")
	}
}

# The platform bundle URL out of app.roc's header.
platform_url! = || {
	source = Str.from_utf8_lossy(Path.utf8("app.roc").read_bytes!()?)
	match source.split_first("platform \"") {
		Ok(at_platform) =>
			match at_platform.after.split_first("\"") {
				Ok(at_quote) => Ok(at_quote.before)
				Err(_) => fail!("could not read the platform URL out of app.roc")
			}

		Err(_) => fail!("could not read the platform URL out of app.roc")
	}
}

# roc exits 2 when it emits warnings but 0 even when it reports errors, so the
# summary line decides, not the exit code. Any warning, an error, or a module
# that never got written fails the build.
build_app! = || {
	output = capture!(
		Cmd.new_str("roc")
			.args_str(["build", "--target=wasm32", "--no-cache", "--output=${out_path}", "app.roc"]),
	)?
	clean = match output.split_on("\n").keep_oks(summary_counts).last() {
		Ok(counts) => counts.errors == 0 and counts.warnings == 0
		Err(_) => Bool.False
	}

	if clean and Path.utf8(out_path).is_file!()? {
		Ok({})
	} else {
		Stderr.line!(output)?
		fail!("roc build failed for app.roc")
	}
}

# Read the counts out of a line like "0 errors and 1 warning found in 704ms".
# Lines that are not a summary fail to parse and are skipped by the caller.
summary_counts = |line| {
	at_error = line.split_first(" error")?
	at_and = at_error.after.split_first(" and ")?
	at_warning = at_and.after.split_first(" warning")?
	errors = U64.from_str(at_error.before.trim()).map_err(|_| NotFound)?
	warnings = U64.from_str(at_warning.before.trim()).map_err(|_| NotFound)?
	Ok({ errors, warnings })
}

# roc spreads its diagnostics across stdout and stderr, and a run that reports
# errors can exit 0, so gather both streams whatever the exit code was.
capture! = |cmd| {
	match cmd.exec_output_bytes!() {
		Ok(streams) => Ok(Str.from_utf8_lossy(streams.stdout_bytes.concat(streams.stderr_bytes)))
		Err(NonZeroExitCodeB(streams)) =>
			Ok(Str.from_utf8_lossy(streams.stdout_bytes.concat(streams.stderr_bytes)))

		Err(FailedToGetExitCodeB(_)) => fail!("could not run ${Cmd.to_str(cmd)}")
	}
}

# Run a command with inherited stdio, exiting with the child's code when it
# fails.
run! = |program, args| {
	match Cmd.new_str(program).args_str(args).exec_exit_code!() {
		Ok(0) => Ok({})
		Ok(code) => Err(Exit(code))
		Err(_) => Err(Exit(1))
	}
}

# Report a message on stderr and exit non-zero.
fail! = |message| {
	Stderr.line!("error: ${message}") ?? {}
	Err(Exit(1))
}
