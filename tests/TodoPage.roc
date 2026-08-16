# Shared helpers for the browser tests. Not a test itself: roc-spec only
# runs files ending in _test.roc, so this module can sit in tests/.
import pf.Cmd
import pf.Env
import playwright.Playwright
import spec.TestEnvironment

TodoPage :: [].{

	# roc-playwright drives a Playwright process through the platform's Cmd
	# API. Every launch takes the same record, so it lives here.
	hooks = {
		new: Cmd.new_str,
		args: Cmd.args_str,
		spawn_grouped!: Cmd.spawn_grouped!,
		write_stdin!: Cmd.Child.write_stdin!,
		read_stdout!: Cmd.Child.read_stdout!,
		kill!: Cmd.Child.kill!,
	}

	## Launch a browser on the app and wait for it to boot. The new-todo
	## input only exists once the wasm has rendered, so waiting for it
	## means every test starts against a running app.
	open! = |{}| {
		{ browser, page } = Playwright.launch_page!(hooks, Chromium(DefaultChannel))?
		Playwright.navigate!(page, base_url!({}))?
		Playwright.wait_for!(page, ".new-todo", Visible)?
		Ok({ browser, page })
	}

	## The URL under test: this worker's own server when run through
	## ./tests.roc, or the ./watch.roc dev server when a test file is run
	## on its own (`roc tests/add_todo_test.roc`).
	base_url! = |{}|
		match TestEnvironment.worker_url!({ env_var!: Env.var_str! }) {
			Ok(url) => url
			Err(_) => {
				port = Env.var_str!("JOY_WATCH_PORT") ?? "8000"
				"http://localhost:${port}"
			}
		}

	## Type a title into the new-todo input and press Enter.
	add! = |page, title| {
		Playwright.fill!(page, ".new-todo", title)?
		Playwright.key_press!(page, ".new-todo", Enter, [])
	}

	## Destroy the nth todo. The destroy button is display:none until the
	## row is hovered, so hover first like a user would.
	destroy! = |page, n| {
		Playwright.hover!(page, row(n))?
		Playwright.click!(page, "${row(n)} .destroy")
	}

	## Double-click the nth todo's label to start editing it. Dispatched
	## via JS because roc-playwright has no double-click yet. Joy binds the
	## handler on the label itself, so the synthetic event lands exactly
	## where a real double-click would.
	edit! = |page, n| {
		js =
			\\(() => {
			\\    const el = document.querySelector('${label(n)}');
			\\    if (!el) return 'ElementNotFound';
			\\    el.dispatchEvent(new MouseEvent('dblclick', {bubbles: true}));
			\\    return 'ok';
			\\})()
		result = Playwright.evaluate!(page, js)?
		if result == "ok" {
			Ok({})
		} else {
			Err(NoTodoToEdit(n))
		}
	}

	## Whether the checkbox at the given selector is checked. Read through
	## the DOM because roc-playwright has no checked-state query yet.
	is_checked! = |page, selector| {
		js =
			\\(() => {
			\\    const el = document.querySelector('${selector}');
			\\    if (!el) return 'ElementNotFound';
			\\    return el.checked ? 'true' : 'false';
			\\})()
		result = Playwright.evaluate!(page, js)?
		if result == "true" {
			Ok(Bool.True)
		} else if result == "false" {
			Ok(Bool.False)
		} else {
			Err(CheckboxNotFound(selector))
		}
	}

	## Selectors for the nth (1-based) todo in the list.
	row : U64 -> Str
	row = |n| ".todo-list li:nth-child(${n.to_str()})"

	label : U64 -> Str
	label = |n| "${row(n)} label"

	toggle : U64 -> Str
	toggle = |n| "${row(n)} .toggle"
}
