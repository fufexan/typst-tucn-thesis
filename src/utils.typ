/// *Internal function.* Returns whether the current page is one where a chapter begins. This is
/// used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-chapter-page() = {
  // all chapter headings
  let chapters = query(heading.where(level: 1))
  // return whether one of the chapter headings is on the current page
  chapters.any(c => c.location().page() == here().page())
}

// this is an imperfect workaround, see
// - https://github.com/typst/typst/issues/2722
// - https://github.com/typst/typst/issues/4438

#let _empty_page_start = <thesis-empty-page-start>
#let _empty_page_end = <thesis-empty-page-end>

/// *Internal function.* Marks all pagebreaks for empty page detection via. This is called as a show
/// rule (```typ #show: mark-empty-pages()```) by the main template.
///
/// -> function
#let mark-empty-pages() = doc => {
  show pagebreak: it => {
    [#metadata(none)#_empty_page_start]
    it
    [#metadata(none)#_empty_page_end]
  }
  doc
}

/// *Internal function.* Returns whether the current page is empty. This is determined by checking
/// whether the current page is between the start and end of a pagebreak, which may span a whole
/// page when `pagebreak(to: ...)` is used.
/// This is used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-empty-page() = {
  let page-num = here().page()
  query(selector.or(_empty_page_start, _empty_page_end))
    .chunks(2)
    .any(((start, end)) => {
      start.location().page() < page-num and page-num < end.location().page()
    })
}

/// *Internal function.* Checks whether all chapters and chapter ends are placed properly. The
/// document should contain an alternating sequence of chapters and chapter ends; if a chapter
/// doesn't have an end or vice-versa, this can lead to wrongly displayed/hidden headers and footers.
///
/// The result of this function is invisible if it succeeds.
///
/// -> content
#let enforce-chapter-end-placement() = context {
  let ch-sel = heading.where(level: 1)
  let end-sel = selector(_chapter_end)

  let chapters-and-ends = query(ch-sel.or(end-sel))

  let at-page(item) = "on page " + str(item.location().page())
  let ch-end-assert(check, message) = {
    if not check {
      panic(
        message()
          + " (hint: set `strict-chapter-end: false` to build anyway and inspect the document)",
      )
    }
  }

  for chunk in chapters-and-ends.chunks(2) {
    // the first of each pair must be a chapter
    let ch = chunk.first()
    ch-end-assert(
      ch.func() == heading,
      () => "extra chapter-end() found " + at-page(ch),
    )

    // each chapter must come in a pair
    ch-end-assert(
      chunk.len() == 2,
      () => "no chapter-end() for chapter " + at-page(ch),
    )

    // the second item in the pair must be a chapter end
    let end = chunk.last()
    ch-end-assert(
      end.func() == metadata,
      () => (
        "new chapter "
          + at-page(end)
          + " before the chapter "
          + at-page(ch)
          + " ended"
      ),
    )
  }
}

/// *Internal function.* This is intended to be called in a section show rule. It returns whether
/// that section is the first in the current chapter
///
/// This function is contextual.
///
/// -> bool
#let is-first-section() = {
  // all previous headings
  let prev = query(selector(heading).before(here(), inclusive: false))
  // returns whether the previous heading is a chapter heading
  prev.len() != 0 and prev.last().level == 1
}
