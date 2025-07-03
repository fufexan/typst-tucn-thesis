#import "bib.typ" as bib: bibliography
#import "l10n.typ"
#import "glossary.typ" as glossary: (
  glossary-entry, gls, glspl, register-glossary,
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
  /// The language in which the thesis is written. `"ro"` and `"en"` are supported. The choice of language influences certain texts on the title page and in headings, as well as the date format used on the title page.
  /// -> string
  language: "ro",
  /// The mode used to show the current authors in the footer; see @@set-current-authors(). This can be `highlight` (all authors are shown, some *strong*) or `only` (only the current authors are shown).
  /// -> string
  current-authors: "highlight",
  /// Changes the paper format of the thesis. Use this option with care, as it will shift various contents around.
  /// -> string
  paper: "a4",
) = body => {
  import "libs.typ": *
  import hydra: anchor, hydra

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
  set text(lang: language, font: "Times New Roman", size: 12pt)
  set block(spacing: 1em)
  set par(
    justify: true,
    spacing: 1em,
    leading: 0.5em,
    // first-line-indent: 1.75em,
  )

  // title page settings - must come before the first content (e.g. state update)
  set page(margin: (x: 2.2cm, y: 2cm))

  // make properties accessible as state
  _authors.set-authors(authors)

  // setup linguify
  l10n.set-database()

  // setup glossarium
  show: glossary.make-glossary

  // setup Alexandria
  show: bib.alexandria.alexandria(prefix: "cite:", read: read)

  // general styles

  // figure caption separator
  set figure.caption(separator: [. ])

  // combine code and images into Figures to share the same counter
  show figure.where(kind: raw): set figure(kind: image)

  // figure supplements
  show: figures.figure-style(supplement: l10n.figure)
  show: figures.table-style(supplement: l10n.table)

  show quote.where(block: false): it => {
    it
    if it.attribution != none [ #it.attribution]
  }

  // Number equations
  set math.equation(numbering: "(1)", supplement: l10n.equation)

  // references to non-numbered headings
  show: structure.plain-heading-refs()

  // regular page setup

  // header & footer
  set page(
    margin: (x: 2.2cm, y: 2cm),
    header-ascent: 15%,
    footer-descent: 15%,
    header: context {
      if structure.is-empty-page() {
        // no header
      } else {
        hydra(1, use-last: true, display: (ctx, candidate) => {
          stack(
            spacing: 5pt,
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              align: (left + top, right + top),
              {
                set par(justify: false)
                candidate.body
              },
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
                    panic(
                      "unreachable: current-authors not 'highlight' or 'only'",
                    )
                  }
                }
                emph(authors.map(box).join[, ])
              },
            ),
            line(length: 100%, stroke: 0.5pt + black),
          )
        })
        anchor()
      }
    },
    footer: context {
      if structure.is-empty-page() {
        // no footer
      } else {
        hydra(1, display: (ctx, candidate) => {
          stack(spacing: 5pt, line(length: 100%, stroke: 0.5pt + black), grid(
            columns: (5fr, 1fr),
            align: (left + bottom, right + bottom),
            "", counter(page).display("1"),
          ))
        })
      }
    },
  )

  show: structure.chapters-and-sections(
    chapter: l10n.chapter,
    section: l10n.section,
  )

  show: structure.main-matter(contents: l10n.contents)

  // List of {Figures, Tables, Listings}
  {
    show: structure.back-matter-lists()

    figures.outlines(
      figures: l10n.list-of-figures,
      tables: l10n.list-of-tables,
    )
  }

  // Glossary
  {
    glossary.print-glossary(
      title: [#heading(l10n.glossary, numbering: none) <glossary>],
      disable-back-references: true,
      // look through glossarium's code if you want to change this
      user-print-glossary: (entries, groups, ..) => {
        table(
          columns: 2,
          stroke: 0pt,
          inset: (x: 1em, y: 0.4em),
          ..for group in groups {
            (
              table.cell(group, colspan: 2),
              ..for entry in entries
                .filter(x => x.group == group)
                .sorted(key: it => (lower(it.short), lower(it.long))) {
                (
                  entry.short,
                  [
                    #figure(
                      entry.long,
                      kind: "glossarium_entry",
                      numbering: none,
                      supplement: "",
                    )#label(entry.key)
                    // The line below adds a ref shorthand for plural form, e.g., "@term:pl"
                    #figure(
                      kind: "glossarium_entry",
                      supplement: "",
                    )[]#label(entry.key + ":pl")
                    // Same as above, but for capitalized form, e.g., "@Term"
                    // Skip if key is already capitalized
                    #if upper(entry.key.at(0)) != entry.key.at(0) {
                      [
                        #figure(
                          kind: "glossarium_entry",
                          supplement: "",
                        )[]#label(glossary.__capitalize(entry.key))
                        #figure(
                          kind: "glossarium_entry",
                          supplement: "",
                        )[]#label(glossary.__capitalize(entry.key) + ":pl")
                      ]
                    }
                  ],
                )
              },
            )
          }
        )
      },
    )
  }

  body

  if bibliography != none {
    bibliography

    context {
      let bibl = bib.alexandria.get-bibliography(auto)
      [= #l10n.bibliography <bibliography>]
      bib.alexandria.render-bibliography(
        bibl,
        title: none,
      )
    }
  }
}

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

/// An abstract section. This should appear once in the thesis in Romanian if the thesis was written in an international language, or in English if the thesis was written in Romanian.
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

  #heading(l10n.abstract, numbering: none)

  #body
]

