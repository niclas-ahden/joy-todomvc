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

	TodoPage.destroy!(page, 1)?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 1) ? |e| OneTodoShouldRemain(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Second") ? |e| TheOtherTodoShouldRemain(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "1 item left") ? |e| CountShouldFollow(e)

	Playwright.close!(browser)
}
