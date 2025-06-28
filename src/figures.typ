/// Applies show rules for regular figure (kind: image) styling.Add commentMore actions
///
/// -> function
#let figure-style(
  /// The figure supplement
  /// -> content
  supplement: none,
) = body => {
  assert.ne(supplement, none, message: "Figure supplement not set")

  show figure.where(kind: image): set figure(supplement: supplement)

  import "libs.typ": codly, codly-languages.codly-languages

  show: codly.codly-init.with()
  codly.codly(languages: codly-languages)

  body
}

/// Applies show rules for table styling.
///
/// -> function
#let table-style(
  /// The table supplement
  /// -> content
  supplement: none,
) = body => {
  assert.ne(supplement, none, message: "Table supplement not set")

  show figure.where(kind: table): set figure(supplement: supplement)

  // table & line styles
  set line(stroke: 0.1mm)
  set table(
    stroke: (x, y) => if y == 0 {
      (bottom: 0.1mm)
    },
  )

  body
}

/// Shows the outlines for the three kinds of figures, if such figures exist.
///
/// -> content
#let outlines(
  /// The figures outline title
  /// -> content
  figures: none,
  /// The tables outline title
  /// -> content
  tables: none,
) = {
  assert.ne(figures, none, message: "List of figures title not set")
  assert.ne(tables, none, message: "List of tables title not set")

  context if query(figure.where(kind: table)).len() != 0 {
    heading(tables, numbering: none)
    outline(
      title: none,
      target: figure.where(kind: table),
    )
  }

  context if (
    query(figure.where(kind: image)).len() != 0
  ) {
    heading(figures, numbering: none)
    outline(
      title: none,
      target: figure.where(kind: image),
    )
  }
}
