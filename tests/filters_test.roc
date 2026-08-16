app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

# The three filter links in footer order
all_filter = ".filters li:nth-child(1) a"
active_filter = ".filters li:nth-child(2) a"
completed_filter = ".filters li:nth-child(3) a"

main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	TodoPage.add!(page, "One")?
	TodoPage.add!(page, "Two")?
	TodoPage.add!(page, "Three")?
	Playwright.check!(page, TodoPage.toggle(2))?

	Assert.eq(Playwright.query_count!(page, "${all_filter}.selected")?, 1) ? |e| AllShouldStartSelected(e)

	Playwright.click!(page, active_filter)?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 2) ? |e| ActiveShouldHideCompleted(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "One") ? |e| FirstActiveTodo(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(2))?, "Three") ? |e| SecondActiveTodo(e)
	Assert.eq(Playwright.query_count!(page, "${active_filter}.selected")?, 1) ? |e| SelectionShouldFollowTheClick(e)
	# The count is over all todos, not the filtered view
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "2 items left") ? |e| CountShouldIgnoreTheFilter(e)

	Playwright.click!(page, completed_filter)?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 1) ? |e| CompletedShouldHideActive(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Two") ? |e| TheCompletedTodo(e)

	Playwright.click!(page, all_filter)?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 3) ? |e| AllShouldShowEverything(e)

	Playwright.close!(browser)
}
