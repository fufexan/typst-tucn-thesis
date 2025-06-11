/// Returns whether the current page is one where a chapter begins. This is
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

/// Marks all pagebreaks for empty page detection via. This is called as a show
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

/// Returns whether the current page is empty. This is determined by checking
/// whether the current page is between the start and end of a pagebreak, which may span a whole
/// page when `pagebreak(to: ..)` is used.
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

/// This is intended to be called in a section show rule. It returns whether
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

/// Applies show rules that allow referencing non-numbered headings by name.
///
/// -> function
#let plain-heading-refs() = body => {
  show ref: it => {
    if type(it.element) != content { return it }
    if it.element.func() != heading { return it }
    if it.element.numbering != none { return it }

    link(it.target, it.element.body)
  }
  body
}

/// Applies show rules that set chapter and heading supplements, start each chapter on an odd page,
/// and start the first section in a chapter on a new page.
///
/// -> function
#let chapters-and-sections(
  /// The chapter heading supplement
  /// -> content
  chapter: none,
  /// The section heading supplement
  /// -> content
  section: none,
) = body => {
  assert.ne(chapter, none, message: "Chapter supplement not set")
  assert.ne(section, none, message: "Section supplement not set")

  // Heading supplements are section or chapter, depending on level
  show heading: set heading(supplement: section, numbering: "1.1.")
  show heading.where(level: 1): set heading(supplement: chapter)

  // Chapter starts have numbered headings
  show heading.where(level: 1): it => {
    // Chapters start on new pages, except the first
    if (
      query(
        selector(heading.where(level: 1)).before(
          it.location(),
          inclusive: false,
        ),
      ).len()
        != 0
    ) {
      pagebreak()
    }
    v(30pt)
    set align(center)
    text(it, size: 16pt, weight: "bold")
    // it
    v(24pt)
  }

  show heading.where(level: 2): it => {
    v(24pt)
    text(it, size: 14pt, weight: "bold")
    v(12pt)
  }

  show heading.where(level: 3): it => {
    v(18pt)
    text(it, size: 14pt, weight: "bold")
    v(12pt)
  }

  body
}

/// Applies show rules for the front matter. It's intended that this wraps the _whole_ document;
/// starting the main matter will override the rules applied here.
///
/// -> function
#let front-matter() = body => {
  // front matter headings are not outlined
  set heading(outlined: false)

  body
}

/// Shows the outline and applies show rules for the main matter, overriding the front matter rules.
///
/// -> function
#let main-matter(
  /// The outline title
  /// -> content
  contents: none,
) = body => {
  import "libs.typ": outrageous

  assert.ne(contents, none, message: "Outline title not set")

  {
    show outline.entry: outrageous.show-entry.with(
      ..outrageous.presets.typst,
      font-weight: ("bold", auto),
    )

    heading([Contents], numbering: none)
    outline(title: none)
  }

  set heading(outlined: true, numbering: "1.1.")

  body
}

/// Applies show rules for the references part of the back matter: the glossary, literature, and
/// prompts. These are still outlined.
///
/// -> function
#let back-matter-references() = body => {
  set heading(outlined: true)

  body
}

/// Applies show rules for the list part of the back matter: the lists of figures, tables, and
/// listings. These are not outlined.
///
/// -> function
#let back-matter-lists() = body => {
  body
}
