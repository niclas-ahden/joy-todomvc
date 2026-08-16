app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

# Clicking away from an edit commits it, like Enter would
main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	TodoPage.add!(page, "Original")?

	TodoPage.edit!(page, 1)?
	Playwright.fill!(page, "${TodoPage.row(1)} .edit", "Committed by blur")?
	Playwright.click!(page, "h1")?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Committed by blur") ? |e| BlurShouldCommit(e)
	Assert.eq(Playwright.query_count!(page, ".todo-list li.editing")?, 0) ? |e| EditingShouldEnd(e)

	Playwright.close!(browser)
}
