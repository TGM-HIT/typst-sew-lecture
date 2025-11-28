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
  pin: (0, 0, right),
  offset: (5, 0, left),
  body: (0.3, 0),
  looseness: 3pt,
  width: auto,
  ..args,
  bod,
) = {
  // Computes a linear combination of the form `a*A+b*B+c*C`.
  // All a, b, c must be numbers or arrays and all A, B, C arrays where the arrays all have the same length.
  // When the first ("lowercase") parameter in a pair is an array, it is pairwise multiplied with the second array.
  // The return value is an array of the same length.
  // For example, to compute `A-B`, use `lin(1, A, -1, B)`
  let lin(..args) = {
    assert.eq(args.named(), (:), message: "no named arguments allowed")
    assert(
      args.pos().len() > 0 and calc.even(args.pos().len()),
      message: "number of arguments must be even and nonzero",
    )
    let pairs = args.pos().chunks(2)
    assert(
      pairs.all(((a, b)) => type(a) in (int, float, array) and type(b) == array),
      message: "all pairs must contain a number or array, and an array",
    )
    let len = pairs.first().last().len()
    assert(
      pairs.all(((a, b)) => (type(a) != array or a.len() == len) and b.len() == len),
      message: "all arrays must match in length",
    )

    range(len).map(i => pairs.map(((a, b)) => if type(a) == array { a.at(i) } else { a } * b.at(i)).sum())
  }

  let dx-dy(name, values) = {
    let (dx, dy) = values
    (name + "-dx": dx, name + "-dy": dy)
  }

  let align-offset(def) = {
    let value = def.at(2, default: center)
    let values = (-looseness, 0pt, 0pt, looseness)
    (
      values.at((left, none, center, right).position(x => x == value.x)),
      values.at((top, none, horizon, bottom).position(x => x == value.y)),
    )
  }

  let dims = (
    // how much to move from pinit's pin coordinate to arrive at the center of the anchoring monospace letter
    // how much to shift to get from one monospace character to the next
    grid-cell: (4.77pt, 13.62pt),
    // how big a character actually is;
    // pinit's pin coordinate needs to be offset by -character/2 to find the center of the character,
    // and arrows are drawn around bounds defined by these dimensions
    character: (4.77pt, 5.8pt),
  )

  pinit.pinit-point-from(
    ..dx-dy("pin", lin(
      -1/2, dims.character,
      pin.slice(0, 2), dims.grid-cell,
      1, align-offset(pin),
    )),
    ..dx-dy("offset", lin(
      -1/2, dims.character,
      offset.slice(0, 2), dims.grid-cell,
      1, align-offset(offset),
    )),
    ..dx-dy("body", lin(
      -1/2, dims.character,
      body, dims.grid-cell,
      -1, align-offset(offset),
    )),
    fill: color,
    thickness: 0.8pt,
    ..args,
    block(width: width, {
      set text(0.85em, color)
      set par(leading: 0.75em)
      bod
    })
  )
}
