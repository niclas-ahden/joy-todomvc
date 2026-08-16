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

	TodoPage.add!(page, "Buy milk")?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Buy milk") ? |e| TodoShouldBeListed(e)
	Assert.eq(Playwright.input_value!(page, ".new-todo")?, "") ? |e| InputShouldClearForTheNextTodo(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "1 item left") ? |e| CountShouldBeSingular(e)

	TodoPage.add!(page, "Walk the dog")?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 2) ? |e| BothTodosShouldBeListed(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(2))?, "Walk the dog") ? |e| NewestTodoShouldBeLast(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "2 items left") ? |e| CountShouldBePlural(e)

	Playwright.close!(browser)
}
