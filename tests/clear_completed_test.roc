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
	TodoPage.add!(page, "Third")?

	# The button only exists while something is completed
	Assert.eq(Playwright.query_count!(page, ".clear-completed")?, 0) ? |e| NothingToClearNoButton(e)

	Playwright.check!(page, TodoPage.toggle(1))?
	Playwright.check!(page, TodoPage.toggle(3))?
	Assert.eq(Playwright.query_count!(page, ".clear-completed")?, 1) ? |e| ButtonShouldAppear(e)

	Playwright.click!(page, ".clear-completed")?
	Assert.eq(Playwright.query_count!(page, ".todo-list li")?, 1) ? |e| CompletedShouldBeGone(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Second") ? |e| TheActiveTodoShouldSurvive(e)
	Assert.eq(Playwright.query_count!(page, ".clear-completed")?, 0) ? |e| ButtonShouldGoAway(e)

	Playwright.close!(browser)
}
