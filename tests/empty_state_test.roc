app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.23.0/7NpDhuqoqGFedmVLvmm1zjq37GCmaFGzwr5sz4ch9wTK.tar.zst",
	playwright: "https://github.com/niclas-ahden/roc-playwright/releases/download/0.7.0/BW5do1pddeCsifMZcgwV4fjYH5mdy9sNA4moigRTvQNg.tar.zst",
	spec: "https://github.com/niclas-ahden/roc-spec/releases/download/0.3.0/2v2CV8CLXRJmQRvfoHtPngAUGgE8jL6DDgXbugZhFVf5.tar.zst",
}

import TodoPage
import playwright.Playwright
import spec.Assert

# The list section and footer only exist while there are todos,
# per the TodoMVC spec
main! = |_args| {
	{ browser, page } = TodoPage.open!({})?

	Assert.eq(Playwright.query_count!(page, ".main")?, 0) ? |e| NoListSectionBeforeTodos(e)
	Assert.eq(Playwright.query_count!(page, ".footer")?, 0) ? |e| NoFooterBeforeTodos(e)

	# Enter on the empty input changes nothing
	Playwright.key_press!(page, ".new-todo", Enter, [])?
	Assert.eq(Playwright.query_count!(page, ".main")?, 0) ? |e| EmptySubmitShouldChangeNothing(e)

	TodoPage.add!(page, "Only todo")?
	Assert.eq(Playwright.query_count!(page, ".main")?, 1) ? |e| ListSectionShouldAppear(e)
	Assert.eq(Playwright.query_count!(page, ".footer")?, 1) ? |e| FooterShouldAppear(e)

	TodoPage.destroy!(page, 1)?
	Assert.eq(Playwright.query_count!(page, ".main")?, 0) ? |e| ListSectionShouldGoAway(e)
	Assert.eq(Playwright.query_count!(page, ".footer")?, 0) ? |e| FooterShouldGoAway(e)

	Playwright.close!(browser)
}
