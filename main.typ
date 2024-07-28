#import "@preview/slydst:0.1.1": *

#show: slides.with(
  title: "Insert your title here", // Required
  subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4/3,
  title-color: none,
)

== Outline

#outline()

= First section

== First slide

#figure(image("dist/chad.jpeg", width: 60%), caption: "Caption")

#v(1fr)

#lorem(20)
