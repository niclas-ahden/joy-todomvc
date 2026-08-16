app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	TodoPage.add!(page, "First")?
	TodoPage.add!(page, "Second")?

	Playwright.check!(page, TodoPage.toggle(1))?
	Assert.eq(Playwright.query_count!(page, ".todo-list li.completed")?, 1) ? |e| OneTodoShouldBeCompleted(e)
	Assert.eq(Playwright.query_count!(page, "${TodoPage.row(1)}.completed")?, 1) ? |e| TheToggledTodoShouldBeCompleted(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "1 item left") ? |e| CompletedShouldLeaveTheCount(e)

	# Toggling back revives the todo
	Playwright.uncheck!(page, TodoPage.toggle(1))?
	Assert.eq(Playwright.query_count!(page, ".todo-list li.completed")?, 0) ? |e| NoTodoShouldBeCompleted(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "2 items left") ? |e| RevivedShouldRejoinTheCount(e)

	Playwright.close!(browser)
}
