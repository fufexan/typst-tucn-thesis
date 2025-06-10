#import "bib.typ" as bib: bibliography
#import "l10n.typ"
#import "glossary.typ" as glossary: (
  register-glossary,
  glossary-entry,
  gls,
  glspl,
)

/// The main template function. Your document will generally start with ```typ #show: thesis(...)```,
/// which it already does after initializing the template. Although all parameters are named, most
/// of them are really mandatory. Parameters that are not given may result in missing content in
/// places where it is not actually optional.
///
/// -> function
#let thesis(
  /// The title of the thesis, displayed on the title page and used for PDF metadata.
  /// -> content | string
  title: none,
  /// A descriptive one-liner that gives the reader an immediate idea about the thesis' topic.
  /// -> content | string
  subtitle: none,
  /// The thesis authors. Each array entry is a `dict` of the form `(name: ..., class: ..., subtitle: ...)` stating their name, class, and the title of their part of the whole thesis project. The names must be regular strings, for the PDF metadata.
  /// -> array
  authors: (),
  /// The term with which to label the supervisor name; if not given or `auto`, this defaults to a language-dependent text. In German, this text is gender-specific and can be overridden with this parameter.
  /// -> content | string | auto
  supervisor-label: auto,
  /// The name of the thesis' supervisor.
  /// -> content | string
  supervisor: none,
  /// The date of submission of the thesis.
  /// -> datetime
  date: none,
  /// The school year in which the thesis was produced.
  /// -> content | string
  year: none,
  /// The division inside the HIT department (i.e. usually "Medientechnik" or "Systemtechnik").
  /// -> content | string
  division: none,
  /// The image (```typc image()```) to use as the document's logo on the title page.
  /// -> content
  logo: none,
  /// pass ```typc path => read(path)``` into this parameter so that Alexandria can read your bibliography files.
  /// -> function
  read: none,
  /// The (Alexandria) bibliography (```typc bibliography()```) to use for the thesis.  /// The bibliography (```typc bibliography()```) to use for the thesis.
  /// -> content
  bibliography: none,
  /// The language in which the thesis is written. `"de"` and `"en"` are supported. The choice of language influences certain texts on the title page and in headings, as well as the date format used on the title page.
  /// -> string
  language: "de",
  /// The mode used to show the current authors in the footer; see @@set-current-authors(). This can be `highlight` (all authors are shown, some *strong*) or `only` (only the current authors are shown).
  /// -> string
  current-authors: "highlight",
  /// Changes the paper format of the thesis. Use this option with care, as it will shift various contents around.
  /// -> string
  paper: "a4",
) = body => {
  import "libs.typ": *
  import hydra: hydra, anchor

  import "authors.typ" as _authors
  import "figures.typ"
  import "structure.typ"

  _authors.check-current-authors(current-authors)

  // basic document & typesetting setup
  set document(
    title: title,
    author: authors.map(author => author.name).join(", "),
    date: date,
  )
  set page(paper: paper)
  set text(lang: language)
  set par(justify: true)

  // title page settings - must come before the first content (e.g. state update)
  set page(margin: (x: 2.5cm, y: 2cm))

  // make properties accessible as state
  _authors.set-authors(authors)

  // setup linguify
  l10n.set-database()

  // setup glossarium
  show: glossary.make-glossary

  // setup Alexandria
  show: bib.alexandria.alexandria(prefix: "cite:", read: read)

  // outline style
  show outline.where(target: selector(heading)): it => {
    show outline.entry: outrageous.show-entry.with(font: (auto,))
    it
  }
  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presents.outrageous-figures,
  )

  // general styles

  // figure supplements
  show: figures.figure-style(supplement: l10n.figure)
  show: figures.figure-style(supplement: l10n.table)
  show: figures.figure-style(supplement: l10n.listing)

  show quote.where(block: false): it => {
    it
    if it.attribution != none [ #it.attribution]
  }

  // references to non-numbered headings
  show: structure.plain-heading-refs()

  // title page not included as it is a separate PDF you have to complete

  // regular page setup

  // show header & footer on "content" pages, show only page number in chapter title pages
  set page(
    margin: (x: 2.5cm, y: 2cm),
    header-ascent: 15%,
    footer-descent: 15%,
    header: context {
      if structure.is-chapter-page() {
        // no header
      } else if structure.is-empty-page() {
        // no header
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => (
            candidates.primary.prev.outlined == true
          ),
          display: (ctx, candidate) => {
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              align: (left + top, right + top),
              title,
              {
                set par(justify: false)
                if candidate.has("numbering") and candidate.numbering != none {
                  l10n.chapter
                  [ ]
                  numbering(
                    candidate.numbering,
                    ..counter(heading).at(candidate.location()),
                  )
                  [. ]
                }
                candidate.body
              },
            )
            line(length: 100%)
          },
        )
        anchor()
      }
    },
    footer: context {
      if structure.is-chapter-page() {
        align(center)[
          #counter(page).display("1")
        ]
      } else if structure.is-empty-page() {
        // no footer
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => (
            candidates.primary.prev.outlined == true
          ),
          display: (ctx, candidate) => {
            line(length: 100%)
            grid(
              columns: (5fr, 1fr),
              align: (left + bottom, right + bottom),
              {
                let authors = _authors.get-names-and-current()
                let authors = {
                  if current-authors == "highlight" {
                    authors.map(((author, is-current)) => {
                      if is-current {
                        author = strong(author)
                      }
                      author
                    })
                  } else if current-authors == "only" {
                    authors
                      .filter(((author, is-current)) => is-current)
                      .map(((author, is-current)) => author)
                  } else {
                    panic("unreachable: current-authors not 'highlight' or 'only'")
                  }
                }
                authors.map(box).join[, ]
              },
              counter(page).display("1 / 1", both: true),
            )
          },
        )
      }
    },
  )

  show: structure.mark-empty-pages()
  show: structure.chapters-and-sections(
    chapter: l10n.chapter,
    section: l10n.section,
  )

  show: structure.front-matter()

  // main body
  {
    // scope i-figured to not interact with Glossarium
    show: figures.numbering

    body
  }

  // back matter: references
  {
    show: structure.back-matter-references()

    glossary.print-glossary(title: [= #l10n.glossary <glossary>])
  }

  if bibliography != none {
    bibliography

    context {
      let (references, ..rest) = bib.alexandria.get-bibliography(auto)
      if references.len() != 0 {
        [= #l10n.bibliography <bibliography>]
        bib.alexandria.render-bibliography(
          title: none,
          (references: references, ..rest),
        )
      }
    }
  }

  // List of {Figures, Tables, Listings}
  {
    show: structure.back-matter-lists()

    figures.outlines(
      figures: [= #l10n.list-of-figures <list-of-figures>],
      tables: [= #l10n.list-of-tables <list-of-tables>],
      listings: [= #l10n.list-of-listings <list-of-listings>],
    )
  }
}

/// The statutory declaration that the thesis was written without improper help. The text is not
/// part of the template so that it can be adapted according to one's needs. Example texts are given
/// in the template. Heading and signature lines for each author are inserted automatically.
///
/// -> content
#let declaration(
  /// The height of the signature line. The default should be able to fit up to seven authors on one page; for larger teams, the height can be decreased.
  /// -> length
  signature-height: 1.1cm,
  /// The actual declaration.
  /// -> content
  body,
) = [
  #import "authors.typ" as _authors

  #let caption-spacing = -0.2cm

  = #l10n.declaration-title <declaration>

  #body

  #v(0.2cm)

  #context (
    _authors
      .get-authors()
      .map(author => {
        show: block.with(breakable: false)
        set text(0.9em)
        grid(
          columns: (4fr, 6fr),
          align: center,
          [
            #v(signature-height)
            #line(length: 80%)
            #v(caption-spacing)
            #l10n.location-date
          ],
          [
            #v(signature-height)
            #line(length: 80%)
            #v(caption-spacing)
            #author.name
          ],
        )
      })
      .join()
  )
]

/// Set the authors writing the current part of the thesis. The footer will highlight the names of
/// the given authors until a new list of authors is given with this function.
///
/// -> content
#let set-current-authors(
  /// The names of the authors to highlight
  /// -> arguments
  ..authors,
) = {
  import "authors.typ" as _authors

  _authors.set-current-authors(authors)
}

/// An abstract section. This should appear twice in the thesis regardless of language; first for
/// the Romanian abstract, then for the English abstract.
///
#let abstract(
  /// The language of this abstract. Although it defaults to ```typc auto```, in which case the document's language is used, it's preferable to always set the language explicitly.
  /// -> string
  lang: auto,
  /// The abstract text.
  /// -> content
  body,
) = [
  #set text(lang: lang) if lang != auto

  #context [
    #[= #l10n.abstract] #label("abstract-" + text.lang)
  ]

  #body
]

/// Starts the main matter of the thesis. This should be called as a show rule (```typ #show: main-matter()```) after the abstracts and will insert
/// the table of contents. All subsequent top level headings will be treated as chapters and thus be
/// numbered and outlined.
///
/// -> function
#let main-matter() = body => {
  import "structure.typ"

  show: structure.main-matter(contents: l10n.contents)

  body
}
