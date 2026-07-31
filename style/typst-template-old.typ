// Customized Typst Template for Quarto Books

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "Arial",
  fontsize: 11pt,
  title-size: 2em,
  subtitle-size: 1.5em,
  heading-family: "Arial",
  heading-weight: "bold",
  heading-style: "normal",
  // --- COVER & STYLING PARAMETERS ---
  cover-image: "images/cover1.jpeg", // Main book cover image
  heading-color: rgb("#1a365d"),     // Font and line color (Navy Blue)
  chapter-size: 1.3em,               // Font size for Chapter / TOC / Ref titles
  section-size: 1.2em,
  subsection-size: 1.15em,
  subsubsection-size: 1.1em,
  line-thickness: 1pt,               // Thickness of horizontal rule
  line-offset: -0.65em,              // Offset for line under standard headings
  content-margin: 1.5em,             // Space under heading before content
  sectionnumbering: "1.",            // Enables chapter numbers ("1.", "1.1", etc.)
  pagenumbering: "1",
  toc: false,
  toc_title: "Table of Contents",
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Page Setup
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    columns: cols,
  )
  set par(justify: true)
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize
  )
  
  // Set automatic heading numbering
  set heading(numbering: sectionnumbering)

  let has-title-page = (title != none or authors != none or date != none or abstract != none)

  // --- DYNAMIC TITLE SPLITTING ---
  // Format title to automatically insert a line break before '('
  let formatted-title = if type(title) == str and title.contains("(") {
    let parts = title.split("(")
    [#parts.at(0).trim() \ (#parts.slice(1).join("(")]
  } else {
    title
  }

  // --- 1. FULL-BLEED BOOK COVER PAGE ---
  if has-title-page {
    if cover-image != none {
      place(
        top + left,
        dx: -margin.x,
        dy: -margin.y,
        image(
          cover-image, 
          width: 100% + 2 * margin.x, 
          height: 100% + 2 * margin.y, 
          fit: "cover"
        )
      )
    }

    align(center + horizon)[
      #block(inset: 2em, fill: rgb(255, 255, 255, 200), radius: 8pt)[
        // Automatically insert a line break before '(' in the title
        #show " (": [ \ (]
        #show "(": [ \ (]
        
        // Tighten the spacing between title lines (default is ~0.65em)
        #set par(leading: 0em)
        
        #text(font: heading-family, weight: "bold", size: title-size, fill: heading-color)[#title]
        #if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      ]
    ]

    pagebreak()
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[#date]]
  }

  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  // --- 2. LEVEL 1 HEADING SHOW RULE (AUTOMATIC PAGEBREAKS) ---
  show heading.where(level: 1): it => {
    pagebreak(weak: true) // Ensures every chapter & main section starts on a new page
    
    block(width: 100%)[
      #set text(
        font: heading-family,
        size: chapter-size,
        weight: heading-weight,
        fill: heading-color,
      )
      #if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.3em)
      }
      #it.body
      #v(line-offset)
      #line(length: 100%, stroke: line-thickness + heading-color)
    ]
    
    v(content-margin)
  }

  // --- SECTION HEADINGS (Level 2) ---
  show heading.where(level: 2): it => [
    #set text(size: section-size, weight: "bold", fill: heading-color)
    #v(0.8em)
    #it
    #v(0.4em)
  ]

  // --- SUBSECTION HEADINGS (Level 3) ---
  show heading.where(level: 3): it => [
    #set text(size: subsection-size, weight: "bold", fill: heading-color)
    #v(0.6em)
    #it
    #v(0.3em)
  ]

  // --- SUBSECTION HEADINGS (Level 4) ---
  show heading.where(level: 4): it => [
    #set text(size: subsubsection-size, weight: "bold", fill: heading-color)
    #v(0.6em)
    #it
    #v(0.3em)
  ]

  // --- 3. BOLD CHAPTER ENTRIES IN TOC ---
  show outline.entry.where(level: 1): it => {
    v(0.5em)
    strong(it)
  }

  // --- 4. TABLE OF CONTENTS ---
  if toc {
    let t_title = if toc_title == none { "Table of Contents" } else { toc_title }
    
    heading(level: 1, numbering: none, outlined: false)[#t_title]
    
    outline(
      title: none,
      depth: toc_depth,
      indent: toc_indent
    )
    pagebreak()
  }

  // --- 5. RENDER BODY CONTENT ---
  doc
}

#set table(
  inset: 6pt,
  stroke: none
)