elpaaso-plugins-management
================

[![Build Status](https://travis-ci.org/Orange-OpenSource/elpaaso-plugins-management.svg)](https://travis-ci.org/Orange-OpenSource/elpaaso-plugins-management)

maven plugin common configuration for [ElPaaSo](https://github.com/Orange-OpenSource/elpaaso)


build overview
==


![Build overview schema](http://g.gravizo.com/g?
  digraph G {
    size ="4,4";
    github [shape=box];
    github -> travis [weight=8];
    travis -> OJO [label="mvn deploy"]
    travis -> Bintray [style=bold,label="promote"]
    edge [color=blue];
    travis -> github [style=dotted,label="Add release"]
    edge [color=black];
    OJO -> Bintray [style=dotted]
    Bintray -> JCenter
    OJO [label="JFrog (Snapshots)"]
    Bintray [label="Bintray (releases)"]
  }
)
