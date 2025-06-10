#import "lib.typ": *

#show: thesis(
  title: [TUCN Thesis],
  subtitle: [Diploma thesis written in Typst],
  authors: (
    (
      name: "Mihai Fufezan",
      class: [5xHIT],
      subtitle: [Subtitle of the subject area by Mihai Fufezan],
    ),
  ),
  supervisor-label: [Coordinator:in],
  supervisor: [As.Drd.Ing. Supervisor],
  date: datetime(year: 2025, month: 7, day: 1),
  year: [2024/25],
  division: [Communications],
  // logo: assets.logo(width: 3cm),
  bibliography: bibliography("bibliography.bib"),

  language: "en",
  current-authors: "only",
  strict-chapter-end: true,
)

#include "glossaries.typ"

#declaration(context if text.lang == "de" [
  Declar că am scris această lucrare independent, că nu am folosit alte surse decât cele declarate și că am marcat explicit tot materialul care a fost citat, ori literal, ori prin conținut din sursele folosite.
  De asemenea, am folosit următoarele unelte IA generative (de exemplu ChatGPT, Grammarly Go, Midjourney) pentru următoarele scopuri:

  - ChatGPT: practic pentru tot
] else if text.lang == "en" [
  I declare that I have authored this thesis independently, that I have not used other than the declared sources and that I have explicitly marked all material which has been quoted either literally or by content from the used sources.
  I also used the following generative AI tools [e.g. ChatGPT, Grammarly Go, Midjourney] for the following purpose:

  - ChatGPT: for basically everything
] else {
  panic("no statutory declaration for that language!")
})

#include "chapters/1_abstract.typ"

#show: main-matter()

#include "chapters/2_work_planning.typ"
// in the main-matter, currently all chapters need to have an explicit `#chapter-end()` to ensure
// correct headers and footers. This can hopefully be removed in the future
// (see https://github.com/typst/typst/issues/2722, https://github.com/typst/typst/issues/4438)
#chapter-end()

#include "chapters/3_state_of_the_art.typ"
#chapter-end()

#include "chapters/4_theoretical_fundamentals.typ"
#chapter-end()

#include "chapters/5_implementation.typ"
#chapter-end()

#include "chapters/6_experimental_results.typ"
#chapter-end()

#include "chapters/7_conclusions.typ"
#chapter-end()
