#import "template.typ" as template: *
#import "/src/lib.typ" as tgm-hit-sew-lecture

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: [TGM-HIT SEW Lecture],
  date: none,
  // date: datetime(year: ..., month: ..., day: ...),

  // logo: rect(width: 5cm, height: 5cm),
  // abstract: [
  //   A PACKAGE for something
  // ],

  scope: (tgm-hit-sew-lecture: tgm-hit-sew-lecture),
)

= Introduction

This is a PACKAGE for something.

= Module reference

#module(
  read("/src/lib.typ"),
  name: "tgm-hit-sew-lecture",
  label-prefix: none,
)
