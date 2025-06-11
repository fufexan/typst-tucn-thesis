#import "lib.typ": *

#show: thesis(
  title: [TUCN Thesis],
  subtitle: [Diploma thesis written in Typst],
  authors: (
    (
      name: "Mihai Fufezan",
      class: [Communications],
      subtitle: [Subtitle of the subject area by Mihai Fufezan],
    ),
  ),
  supervisor-label: [Coordinator:in],
  supervisor: [As.Drd.Ing. Supervisor],
  date: datetime(year: 2025, month: 7, day: 1),
  year: [2024/25],
  division: [Communications],
  // logo: assets.logo(width: 3cm),
  read: path => read(path),
  bibliography: bibliography("bibliography.bib"),

  language: "en",
  // current-authors: "only",
)

#include "glossaries.typ"

#show: main-matter()

#include "chapters/abstract.typ"

#include "chapters/work_planning.typ"

#include "chapters/state_of_the_art.typ"

#include "chapters/theoretical_fundamentals.typ"

#include "chapters/implementation.typ"

#include "chapters/experimental_results.typ"

#include "chapters/conclusions.typ"
