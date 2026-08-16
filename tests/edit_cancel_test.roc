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

	TodoPage.add!(page, "Keep me")?
	edit_input = "${TodoPage.row(1)} .edit"

	TodoPage.edit!(page, 1)?
	Playwright.fill!(page, edit_input, "Throw this away")?
	Playwright.key_press!(page, edit_input, Escape, [])?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Keep me") ? |e| EscapeShouldKeepTheTitle(e)
	Assert.eq(Playwright.query_count!(page, ".todo-list li.editing")?, 0) ? |e| EditingShouldEnd(e)

	# The thrown-away draft must not leak into the next edit
	TodoPage.edit!(page, 1)?
	Assert.eq(Playwright.input_value!(page, edit_input)?, "Keep me") ? |e| NextEditShouldStartFresh(e)

	Playwright.close!(browser)
}
