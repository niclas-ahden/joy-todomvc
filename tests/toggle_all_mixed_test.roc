app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

# Toggle-all from a mixed state completes every todo, it does not invert
# each one
main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	TodoPage.add!(page, "One")?
	TodoPage.add!(page, "Two")?
	TodoPage.add!(page, "Three")?
	Playwright.check!(page, TodoPage.toggle(2))?

	Playwright.check!(page, ".toggle-all")?
	Assert.eq(Playwright.query_count!(page, ".todo-list li.completed")?, 3) ? |e| AllShouldBeCompleted(e)
	Assert.eq(Playwright.text_content!(page, ".todo-count")?, "0 items left") ? |e| NothingShouldBeLeft(e)

	Playwright.close!(browser)
}
