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
  cover-image: "images/cover1.jpeg",
  heading-color: rgb("#1a365d"),
  chapter-size: 1.3em,
  section-size: 1.2em,
  subsection-size: 1.15em,
  subsubsection-size: 1.1em,
  line-thickness: 1pt,
  line-offset: -0.65em,
  content-margin: 1.5em,
  sectionnumbering: "1.1",             // <--- CHANGED FROM "1." TO "1.1" FOR NUMERIC LEVELS (2.1.1)
  pagenumbering: "i",
  toc: false,
  toc_title: "Table of Contents",
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // --- INITIAL PAGE SETUP ---
  set page(
    paper: paper,
    margin: margin,
    columns: cols,
    footer: none
  )
  
  set par(justify: true)
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize
  )
  
  // Set automatic heading numbering (uses "1.1" so 3rd level becomes 2.1.1)
  set heading(numbering: sectionnumbering)

  // Force figure numbering to format as Chapter.Figure (e.g. 2.1)
  set figure(numbering: "1.1")

  let has-title-page = (title != none or authors != none or date != none or abstract != none)

  // --- FULL-BLEED BOOK COVER PAGE ---
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
        #show " (": [ \ (]
        #show "(": [ \ (]
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

  // --- LEVEL 1 HEADING SHOW RULE (CHAPTERS) ---
  show heading.where(level: 1): it => {
    // Reset figure count per chapter
    counter(figure.where(kind: image)).update(0)

    pagebreak(weak: true)
    
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

  // --- FIGURE SHOW RULE (FORMATS "Figure 2.1: Caption") ---
  show figure.where(kind: image): it => {
    let ch = counter(heading).get().first()
    let fig = counter(figure.where(kind: image)).at(it.location()).first()
    
    block(width: 100%, breakable: false)[
      #align(center)[#it.body]
      #if it.has("caption") [
        #v(0.5em)
        #align(center)[
          #text(weight: "bold")[Figure #ch.#fig]
          #if it.caption.body != none [: #it.caption.body]
        ]
      ]
    ]
  }

  // --- SECTION HEADINGS ---
  show heading.where(level: 2): it => [
    #set text(size: section-size, weight: "bold", fill: heading-color)
    #v(0.8em)
    #it
    #v(0.4em)
  ]

  show heading.where(level: 3): it => [
    #set text(size: subsection-size, weight: "bold", fill: heading-color)
    #v(0.6em)
    #it
    #v(0.3em)
  ]

  show heading.where(level: 4): it => [
    #set text(size: subsubsection-size, weight: "bold", fill: heading-color)
    #v(0.6em)
    #it
    #v(0.3em)
  ]

  // --- TOC STYLING ---
  show outline.entry.where(level: 1): it => {
    v(0.5em)
    strong(it)
  }

  // --- TABLE OF CONTENTS ---
  if toc {
    counter(page).update(1)
    set page(
      numbering: "i",
      footer: context {
        let i = counter(page).get().first()
        let page_num = numbering(page.numbering, i)
        if calc.even(here().page()) {
          align(left)[#page_num]
        } else {
          align(right)[#page_num]
        }
      }
    )

    let t_title = if toc_title == none { "Table of Contents" } else { toc_title }
    heading(level: 1, numbering: none, outlined: false)[#t_title]
    
    outline(
      title: none,
      depth: toc_depth,
      indent: toc_indent
    )
    
    pagebreak()
  }

  // --- MAIN MATTER SETUP ---
  if toc {
    counter(page).update(1)
  }
  
  set page(
    numbering: "1",
    footer: context {
      let i = counter(page).get().first()
      let page_num = numbering(page.numbering, i)
      if calc.even(here().page()) {
        align(left)[#page_num]
      } else {
        align(right)[#page_num]
      }
    }
  )

  // --- RENDER BODY ---
  doc
}

#set table(
  inset: 6pt,
  stroke: none
)