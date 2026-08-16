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
	TodoPage.add!(page, "Walk the dog")?

	TodoPage.edit!(page, 1)?
	Assert.eq(Playwright.query_count!(page, "${TodoPage.row(1)}.editing")?, 1) ? |e| RowShouldEnterEditing(e)
	edit_input = "${TodoPage.row(1)} .edit"
	Assert.eq(Playwright.input_value!(page, edit_input)?, "Buy milk") ? |e| EditShouldStartFromTheTitle(e)

	Playwright.fill!(page, edit_input, "  Buy oat milk  ")?
	Playwright.key_press!(page, edit_input, Enter, [])?
	Assert.eq(Playwright.text_content!(page, TodoPage.label(1))?, "Buy oat milk") ? |e| CommitShouldTrimAndSave(e)
	Assert.eq(Playwright.query_count!(page, ".todo-list li.editing")?, 0) ? |e| EditingShouldEnd(e)
	Assert.eq(Playwright.text_content!(page, TodoPage.label(2))?, "Walk the dog") ? |e| OtherTodosShouldBeUntouched(e)

	Playwright.close!(browser)
}
