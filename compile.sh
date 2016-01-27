#!/bin/bash

echo "Cleaning up"
find -name "*.html" -print0 | xargs -0 rm

echo "Generating /"
tpage index.tt > index.html
tpage 3e642cfac747.tt > 3e642cfac747.html
tpage google51787ae736da833c.tt > google51787ae736da833c.html

echo "Generating /css"
lessc css/style.less > css/style.css
lessc css/mobile.less > css/mobile.css

echo "Formatting"
find \( -name "*.html" -o -name "*.css" \) -print0 | xargs -0 perl -i -pe 's/\n/ /g'
find \( -name "*.html" -o -name "*.css" \) -print0 | xargs -0 perl -i -pe 's/\s+/ /g'

count=$(find -name "*.html" | wc -l)
echo "Generated $count pages"
