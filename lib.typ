#import "@preview/subpar:0.1.1"
#import "@preview/physica:0.9.3": *

#let stroke-color = luma(200)
#let fill-color = luma(250)
#let std-bibliography = bibliography

#let isappendix = state("isappendix", false)
#let subfigure = {
  subpar.grid.with(
    numbering: n => if isappendix.get() {numbering("A.1", counter(heading).get().first(), n)
      } else {
        numbering("1.1", counter(heading).get().first(), n)
      },
    numbering-sub-ref: (m, n) => if isappendix.get() {numbering("A.1a", counter(heading).get().first(), m, n)
      } else {
        numbering("a", m, n)
      }
  )
}

#let ntnu-thesis(
  title: [Title],
  author: "Author",
  paper-size: "a4",
  date: datetime.today(),
  date-format: "[day padding:zero]/[month repr:numerical]/[year repr:full]",
  abstract: none,
  preface: none,
  table-of-contents: outline(),
  bibliography: none,
  chapter-pagebreak: true,
  figure-index: (
    enabled: false,
    title: "",
  ),
  table-index: (
    enabled: false,
    title: "",
  ),
  listing-index: (
    enabled: false,
    title: "",
  ),
  body,
) =  {
  set document(title: title, author: author)
  // Set text fonts and sizes
  set text(font: "Charter", size: 11pt)
  show raw: set text(font: "DejaVu Sans Mono", size: 9pt)
  //Paper setup
  set page(
    paper: paper-size,
    margin: (bottom: 4.5cm, top:4cm, left:4cm, right: 4cm),
    numbering: "1"
  )
  
  // Cover page
  page(align(center + horizon, block(width: 90%)[
      #let v-space = v(2em, weak: true)
      #text(2em)[*#title*]

      #v-space
      #text(1.1em, author)
      
      #if date != none {
        v-space
        // Display date as MMMM DD, YYYY  
        text(1.1em, date.display(date-format))
      }
  ]))
  //Paragraph properties
  set par(leading: 0.7em, justify: true, linebreaks: "optimized")
  show par: set block(spacing: 1.35em)

  //Properties for all headings (incl. subheadings)
  set heading(numbering: "1.1")
  show heading: set text(hyphenate: false)
  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }
  
  // Properties for main headings (i.e "Chapters")
  show heading.where(level: 1): it => {
    //Show chapters on new page
    if chapter-pagebreak { colbreak(weak: true) }
    //Display heading as two lines, a "Chapter # \n heading"
    v(10%)
    if it.numbering != none {
      set text(size: 20pt)
      text("Chapter ")
      numbering("1.1", ..counter(heading).at(it.location()))
    }
    v(1.4em, weak: true)
    set text(size: 24pt)
    block(it.body)
    v(1.8em, weak: true)
  }
  
  //Show preface
  if preface != none {
      page(preface)
  } 

  // Display table of contents.
  if table-of-contents != none {
    set par(leading: 10pt, justify: true, linebreaks: "optimized")

    show outline.entry.where(level: 1): it => {
      strong(it)
    }
    set outline(indent: true, depth: 3)
    table-of-contents
  }
  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt, 
  )

  // Display block code with padding.
  show raw.where(block: true): block.with(
    inset: (x: 5pt, y: 10pt),
    stroke: stroke-color,
    width: 100%,
  )
  show raw.where(block: true): set align(start)
  show figure.where(
    kind: raw
  ): set figure.caption(position: top)

  // Configure proper numbering.
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("1.1", h1, n)
  }
  show figure: set figure(numbering: numbering-fig)
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(1.1)", h1, n)
  }
  set math.equation(numbering: numbering-eq)

  //Set table caption on top
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  
   // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled and has-fig(image)
      let tbls = table-index.enabled and has-fig(table)
      let lsts = listing-index.enabled and has-fig(raw)
      if imgs or tbls or lsts {
        // Note that we pagebreak only once instead of each each
        // individual index. This is because for documents that only have a couple of
        // figures, starting each index on new page would result in superfluous
        // whitespace.
        pagebreak()
      }

      if imgs { outline(title: figure-index.at("title", default: "Index of Figures"), target: fig-t(image)) }
      if tbls { outline(title: table-index.at("title", default: "Index of Tables"), target: fig-t(table)) }
      if lsts { outline(title: listing-index.at("title", default: "Index of Listings"), target: fig-t(raw)) }
    }
  }
  
  //Body in brackets to style alone
  {
    // Properties for main headings (Chapters)
    
    body
  }
  
  //Style bibliography
  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(0.95em)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }
}
//Style appendix
#let appendix(body) = {
  show heading: it => {
    colbreak(weak: true)
    v(10%)
    if it.numbering != none {
      set text(size: 20pt)
      text("Appendix ")
      numbering("A.1", ..counter(heading).at(it.location()))
    }
    v(1.4em, weak: true)
    set text(size: 24pt)
    block(it.body)
    v(1.8em, weak: true)
  }
  // Reset heading counter
  counter(heading).update(0)
  
  // Equation numbering
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(A.1)", h1, n)
  }
  set math.equation(numbering: numbering-eq)
  
  // Figure and Table numbering
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("A.1", h1, n)
  }
  show figure.where(kind: image): set figure(numbering: numbering-fig)
  show figure.where(kind: table): set figure(numbering: numbering-fig)
  
  isappendix.update(true)
    
  body
}
