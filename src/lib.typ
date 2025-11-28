#import "libs.typ": ccicons, showybox.showybox, zebraw.zebraw, zebraw.zebraw-init, meander, pinit

#let no-zebra(body) = zebraw(
  background-color: luma(255).transparentize(100%),
  inset: (top: 0.34em, bottom: 0.34em),
  numbering: false,
  body,
)

#let zebraw = (..args, body) => {
  show: zebraw.with(
    // smart-skip: true,
    // skip-text: [#"    ..."],
    ..args
  )
  show raw.where(block: true): block.with(
    stroke: luma(245) + 2pt,
    radius: 4pt,
  )
  show raw.where(block: true): it => {
    show regex("PIN\d+"): it => pinit.pin(eval(it.text.slice(3)))
    it
  }
  body
}

#let lines(spec) = {
  assert("," not in spec, message: "separate ranges are not yet supported")
  spec.split(",").map(part => {
    let bounds = part.split("-").map(str.trim)
    if bounds.len() == 1 and bounds.first() != "" {
      // a single page
      let page = int(bounds.first())
      (page, page + 1)
    } else if bounds.len() == 2 {
      // a page range
      let (lower, upper) = bounds
      lower = if lower != "" { int(lower) }
      upper = if upper != "" { int(upper) }
      (lower, upper + 1)
    } else {
      panic("invalid page range: " + spec)
    }
  })
  .first()
}

#let licenses = {
  let cc-link(category, name, version, body) = link(
    "https://creativecommons.org/" + category + "/" + name + "/" + version + "/",
    text(black, body),
  )
  let publicdomain = ("zero",)
  (:
    ..for l in ("by", "by-nc", "by-nc-nd", "by-nc-sa", "by-nd", "by-sa") {
      let icon = dictionary(ccicons).at("cc-" + l)
      ("cc-" + l + "-4-0": cc-link("licenses", l, "4.0", icon))
    },
    ..for l in ("zero",) {
      let icon = dictionary(ccicons).at("cc-" + l)
      ("cc-" + l + "-1-0": cc-link("publicdomain", l, "1.0", icon))
    },
  )
}

#let template(
  license: none,
  header-left: auto,
  header-center: auto,
  header-right: auto,
  footer-left: auto,
  footer-center: auto,
  footer-right: auto,
) = doc => {
  show: zebraw
  show: zebraw-init.with(
    extend: false,  // hide empty headers and footers
    lang: false,  // hide language tag, I don't like the style
    background-color: (luma(255), luma(245)),
    inset: (top: 0.48em, bottom: 0.48em),
    // highlight-color: blue.lighten(90%),
    // comment-color: blue.lighten(93%),
  )

  show raw.where(block: true): set text(0.9em)

  set text(font: "Noto Sans", hyphenate: true)
  set par(justify: true)
  show link: it => {
    if type(it.dest) == str {
      set text(blue.darken(20%))
      show: underline
      it
    } else {
      show: underline.with(stroke: text.fill.transparentize(50%))
      it
    }
  }
  // show link: underline

  let resolve-auto(value, default) = {
    if value != auto { value }
    else if type(default) == function { default() }
    else { default }
  }
  set page(
    header: {
      set text(0.9em)
      grid(
        columns: 3*(1fr,),
        align: (left, center, right),
        resolve-auto(header-left, none),
        resolve-auto(header-center, context document.title),
        resolve-auto(header-right, context [v#document.date.display().slice(2)]),
      )
    },
    footer: {
      set text(0.9em)
      grid(
        columns: 3*(1fr,),
        align: (left, center, right),
        resolve-auto(footer-left)[
          #sym.copyright
          #context document.author.join[, ],
          #context document.date.year()
          #license
        ],
        resolve-auto(footer-center, context counter(page).display("1 / 1", both: true)),
        resolve-auto(footer-right, none),
      )
    },
  )

  set bibliography(style: "chicago-notes")
  show bibliography: none

  show quote.where(block: true): set block(spacing: 1.2em)

  show list: pad.with(left: 0.5em)

  show figure.caption: set text(0.9em)

  doc
}

#let colorbox(body, color: green, ..args) = {
  set align(center)
  showybox(
    frame: (
      border-color: color,
      title-color: color.lighten(30%),
      body-color: color.lighten(95%),
      footer-color: color.lighten(80%)
    ),
    width: 95%,
    ..args,
    body,
  )
}

#let pin = pinit.pin

#let pinit-code-from(
  color: blue,
  pin: (0.5, 0),
  offset: (5, 0),
  body: (0.5, 0),
  ..args,
  bod,
) = {
  let scale = (4.7pt, 13.7pt)
  let resolve(name, scale, offset, value) = {
    let (dx, dy) = array.zip(scale, offset, value).map(((scale, offset, value)) => value * scale + offset)
    (name + "-dx": dx, name + "-dy": dy)
  }


  pinit.pinit-point-from(
    ..resolve("pin", scale, (0pt, -3pt), pin),
    ..resolve("offset", scale, (1pt, -3pt), offset),
    ..resolve("body", scale, (1pt, -4pt), body),
    fill: color,
    thickness: 0.8pt,
    ..args,
    {
      set text(0.85em, color)
      set par(leading: 0.75em)
      bod
    }
  )
}