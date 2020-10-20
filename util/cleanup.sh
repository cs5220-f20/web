#!/bin/bash

pandoc -s --mathjax -i -t revealjs $1.md -o $1-a.html

cat <<EOF > $1-b.html
---
title: $2
layout: slides
audio: $1
---

<section>
  <h1><a href="https://www.cs.cornell.edu/courses/cs5220/2020fa/">CS 5220</a></h1>
  <h2>Applications of Parallel Computers</h2>
  <h3>$2</h3>
  <p>
    <small>Prof <a href="http://www.cs.cornell.edu/~bindel">David Bindel</a></small>
  </p>
  <p>Please click the play button below.</p>
</section>
EOF

awk '
BEGIN { flag = 0 }
/<section id="title-slide">/ { flag = 1 }
/^    <\/div>/ { flag = 0 }
/<section/ { $0 = "<section>" }
/ class="fragment"/ { gsub(/ class="fragment"/, ""); }
flag == 2 { print }
flag == 2 && /<\/section>/ { print "" }
flag == 1 && /<\/section>/ { flag = 2 }
/<div class="slides">/ { flag = 1}
' $1-a.html >> $1-b.html

rm $1-a.html
mv $1-b.html $1.html
