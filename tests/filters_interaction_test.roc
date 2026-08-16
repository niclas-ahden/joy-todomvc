app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

active_filter = ".filters li:nth-child(2) a"
completed_filter = ".filters li:nth-child(3) a"
all_filter = ".filters li:nth-child(1) a"

# Changing todos while a filter is on: the view updates right away, and
# every selector is positional, so the rows below shift up
main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	TodoPage.add!(page, "One")?
	TodoPage.add!(page, "Two")?
	TodoPage.add!(page, "Three")?
	Playwright.check!(page, TodoPage.toggle(2))?

	# Completing a todo under Active drops it from the view
	Playwright.click!(page, active_filter)?
	Playwright.check!(page, TodoPage.toggle(1))?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 1) ? |e| CompletedShouldLeaveTheActiveView(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Three") ? |e| TheRemainingActiveTodo(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "1 item left") ? |e| CountShouldFollow(e)

	# Editing under a filter edits the todo the view shows, not the
	# todo that happens to sit at that index in the full list
	Playwright.click!(page, completed_filter)?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "One") ? |e| CompletedShouldShowBoth(e)
	TodoPage.edit!(page, 1)?
	edit_input = "${TodoPage.row(1)} .edit"
	Playwright.fill!(page, edit_input, "One edited")?
	Playwright.key_press!(page, edit_input, Enter, [])?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "One edited") ? |e| TheShownTodoShouldBeEdited(e)

	# Back on All everything is still there, in order, with the edit applied
	Playwright.click!(page, all_filter)?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 3) ? |e| AllShouldShowEverything(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "One edited") ? |e| TheEditShouldStick(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(2))?, "Two") ? |e| SecondShouldBeUntouched(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(3))?, "Three") ? |e| ThirdShouldBeUntouched(e)

	Playwright.close!(browser)
}
