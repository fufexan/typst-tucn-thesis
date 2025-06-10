#import "../lib.typ": *

#let highlighted-link(..args) = {
  set text(fill: blue.darken(20%))
  link(..args)
}

= Foreword <preface>

A thesis is not an essay! Even though it should be interesting, it is impersonal and written in the passive voice. References are particularly important; they must be selected and referenced appropriately. This template contains two files created for precisely this purpose. The file `bibliography.bib` contains all references and literature used, while `glossaries.typ` contains all definitions of terms and acronyms that are not explained in detail in the thesis itself.

While the majority of this template only demonstrates the structure of a typical thesis, the preface contains information on how to use the template. It is, of course, entirely replaceable. The information here includes template-specific examples as well as examples that refer to functions of Typst or #highlighted-link("https://typst.app/universe/")[available packages] and can be useful for creating theses. It's worth taking a look at `chapters/vorwort.typ` to see how the examples were implemented.

== Sources

Correct citation plays an important role in academic work. Literature management is already included in Typst. The `bibliography.bib` file is predefined, but the Hayagriva format can also be used, as described in the documentation.

As a small example, here is a quote about sound from the first physics textbook by the authors Schweitzer, Svoboda and Trieb.

#quote(attribution: [@physik1[S. 145]], block: true)[
  "Mechanical longitudinal waves are called sound. They are perceptible to the human ear in a frequency range of 16 Hz to 20 kHz. Frequencies below this range are called infrasound, and above this range, ultrasound."
]

In `bibliography.bib` the referenced source is defined as follows:

#figure(
  ```bib
  @book{ physik1,
    title = {Physik 1},
    author = {Christian Schweitzer, Peter Svoboda, Lutz Trieb},
    year = {2011},
    subtitle = {Mechanik, Thermodynamik, Optik},
    edition = {7. Auflage},
    publisher = {Veritas},
    pages = {140, 145-150},
    pagetotal = {296}
  }
  ```,
  caption: [Entry of a book source in BibTeX],
)

The very first thing you see is the ID of this source, `physics1`. This allows you to reference it either with ```type @physics1``` or with additional details such as the page number: #box[```type @physics1[p. 145]```]. It is particularly recommended to include the page number for direct quotations.

After a source is used, it is also listed in the @bibliography, which is located at the end of the document. Sources that are not referenced are not displayed. Therefore, it's not a problem to include sources generously in `bibliography.bib`: it's better to have more literature at hand than to have to search for it later.

Relevant documentation:

- #highlighted-link("https://typst.app/docs/reference/model/bibliography/")[```typc bibliography()```]
- #highlighted-link("https://typst.app/docs/reference/model/cite/")[```typ @key``` or ```typc cite()```]
- #highlighted-link("https://www.bibtex.com/g/bibtex-format/")[the BibTeX file format]
- #highlighted-link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[das Hayagriva file format]

== Glossary

The @glossary contains explanations of terms and abbreviations that don't have space in the main text. This ensures that the reading flow isn't disrupted for experts, while still making the work accessible to a wider audience. In the `glossaries.typ` file, terms—or, in this case, an abbreviation—are defined in the following form:

#figure(
  ```typ
  #glossary-entry(
    "ac:tgm",
    short: "TUCN",
    long: "Technical University of Cluj-Napoca",
  )
  ```,
  caption: [Entry of an abbreviation in `glossaries.typ`],
)

This glossary entry can be used similarly to a source reference by typing @ac:tucn. The first time it is used, the long form is automatically displayed: @ac:tucn. For subsequent uses, however, only the short form is displayed: @ac:tucn.

The _Glossarium_ package, used in the background for the glossary function, also provides additional functions that can be helpful, for example, in adapting to Romanian cases. It can also be used to enforce the long form: _această lucrare a fost creată în cadrul #gls("ac:utcn", display: "Universității Tehnice din Cluj-Napoca"); "#gls("ac:utcn", long: true)" will probably rarely be found in the body text due to the structure of the Romanian language._
Relevante Dokumentation:

- #highlighted-link("https://typst.app/universe/package/glossarium/0.4.1/")[the Glossarium package]

#set-current-authors("Arthur Dent", "Tricia McMillan")

== Authorship within the document

Within a thesis, it is necessary to trace the individual authorship of each section. It is common practice to list the authors in the footer. This template offers two modes: typc current-authors: "highlight" displays all authors in the footer, but prints the current authors in bold; typc current-authors: "only" displays only the current authors in the footer.

Before this section, the authors were set to _Arthur Dent_ and _Tricia McMillan_ (see the source code for this chapter), so they are in bold from this page onwards.

== Figures and equations

Figures, tables, code snippets, and similar independent content are often used to complement the body text. Two _lists_, or code snippets, were already used in the previous sections. Figures should normally be referenced in the body text so that their relevance to the content is explicitly clear. For example, the figure shown in @lst:figure-definition could be referenced using ```typ @fig:picture``. The references in this section use exactly this mechanism; in the PDF version of the work, these references are functioning links. The prefix `fig:` was inserted by the _i-figured_ package and determined based on the type of content, see @tbl:figure-kinds. This package also ensures that figures are numbered by chapter rather than consecutively.

#figure(
```typ
#figure(
  image("../assets/logo.png"),
  caption: [A picture],
) <picture>
```,
  placement: auto,
  caption: [Definition of a figure],
) <figure-definition>

#figure(
  table(
    columns: 4,
    align: (center,) * 3 + (left,),
    table.header(
      [Supplement], [Contents], [Prefix], [Note],
    ),
    [Figure], [```typ image()```], [`fig:`], [Default image type for other content],
[Table], [```typ table()```], [`tbl:`], [],
[Listing], [```typ raw()```], [`lst:`], [```typ raw()``` also has the special syntax ```typ `...` ``` or ```typ ...```],
[Equation], [```typ math.equation()```], [`eqt:`], [```typ math.equation()``` also has the special syntax ```typ $ ... $```],
  ),
  placement: auto,
  caption: [Types of figures and their prefixes in _i-figured_],
) <figure-kinds>

It's also common in academic papers to move figures for better page placement—usually to the top or bottom of a page. In Typst, this can be done using typc figure(.., placement: auto). The figures in this section use this functionality: although this paragraph appears after the figures in the source code, it begins before them and ends on the next page, after them. Whether the results of the automatic placement are satisfactory should, of course, be manually checked again for the final version.

Mathematical equations are represented slightly differently according to conventions and also have their own syntax in Typst. The definition of @eqt:pythagoras can be found in the source code of the preface:

$ a^2 + b^2 = c^2 $ <pythagoras>

Relevant Documentation:

- #highlighted-link("https://typst.app/docs/reference/model/figure/")[```typc figure()```]
- #highlighted-link("https://typst.app/docs/reference/foundations/label/")[```typ <...>``` or ```typc label()```]
- #highlighted-link("https://typst.app/docs/reference/model/table/")[```typc table()```]
- #highlighted-link("https://typst.app/docs/reference/text/raw/")[````typ ```...``` or ```typc raw()```]
- #highlighted-link("https://typst.app/docs/reference/math/equation/")[```typ $ ... $``` or ```typc math.equation()```]
- #highlighted-link("https://typst.app/universe/package/i-figured/0.2.4/")[the i-figured package]

== Internal References <internal-references>

In addition to references to sources, figures, and glossary entries, the ```typ @key`` syntax can also be used to reference chapters and sections. Since this chapter is labeled ```typ <preface>```, it's easy to insert a reference using ```typ @preface```, for example: @preface. A reference to @internal-references, which contains this text, works the same way. In the PDF, these references are also links.

Some parts of the thesis are labeled by the template and can therefore be referenced if necessary:- @declaration

- #text(lang: "ro")[@abstract-ro]
- #text(lang: "en")[@abstract-en]
- @contents
- @bibliography
- (#l10n.list-of-figures -- no link because the template does not contain any "normal" images) // @list-of-figures
- @list-of-tables
- @list-of-listings
- @glossary
Since these headings are not numbered, references to them are shown with the full name.
