#import "template.typ" as template: *
#import "/src/lib.typ" as tgm-hit-sew-lecture

#let fake-template() = doc => {
  import tgm-hit-sew-lecture: *

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
  doc
}

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: [TGM-HIT SEW Lecture],
  date: none,
  // date: datetime(year: ..., month: ..., day: ...),

  // logo: rect(width: 5cm, height: 5cm),
  // abstract: [
  //   A PACKAGE for something
  // ],

  scope: (
    tgm-hit-sew-lecture: tgm-hit-sew-lecture,
    fake-template: fake-template,
    simple-example: simple-example,
  ),
)

= Introduction

This template is aimed at teachers of the information technology department at the TGM technical secondary school in Vienna, specifically those teaching software engineering.
It can be used both in the Typst app and using the CLI:

Using the Typst web app, you can create a project by e.g. using the "Create new project in app" button on the package's Universe page:
#context link("https://typst.app/universe/package/" + package-meta().name).

To work locally, use the following command:

#context raw(
  block: true,
  lang: "bash",
  "typst init @preview/" + package-meta().name
)

To get started, you will likely be better off looking into the document created by the template:
it contains instruction and examples on the most important features of this template.
If you have not yet initialized the template, a rendered version is linked in the README, but it is recommended to view the source code along with the rendered form.
If you are new to Typst, also check out the Typst documentation: https://typst.app/docs/.

The rest of this manual documents the individual functions offered by this package.
This is useful if you want to know what customization options are available, or you're not sure what parts of the template package do.

As a school-specific template, this package is fairly opinionated and may not offer enough configurability to fit your needs. However, if you like this template, feel free to adapt the code (MIT-licensed) to your needs, or open a Github issue to request making this template more general.

= Module reference

#module(
  read("/src/lib.typ"),
  name: "tgm-hit-sew-lecture",
  label-prefix: none,
)
