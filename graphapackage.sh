#!/bin/bash 

MULTIDEB_ROOT=$HOME/.multideb
ARCH=amd64
DISTS="\
  lucid\
  maverick\
  natty\
  oneiric\
  precise\
  quantal\
"

PKG_NAME=$1

# pdfunite won't work with just one input file; however, it happens
# often that only one gets created. So we add all successfully created
# PDF names to an array, count the mebers in the end, and if there is
# only one member in the array, we simply mv that file to become the
# end product.
pdfs=( )

for dist in $DISTS; do
  echo -n "[+] Processing $dist ..."
  APT_ROOT="$MULTIDEB_ROOT/$dist/$ARCH"

  DOT_FILE=$dist-$ARCH-$PKG_NAME.dot
  PDF_FILE=$dist-$ARCH-$PKG_NAME.pdf
  APT_CONFIG=$APT_ROOT/apt.conf debtree \
    --no-conflicts \
    --no-alternatives \
    --no-recommends \
    --no-provides \
    --condense \
    $PKG_NAME \
  2>/dev/null > $DOT_FILE
  if [ "$?" -eq "0" ]; then
    echo " found."
    pdfs=( "${pdfs[@]}" "$PDF_FILE" )
    sed "2i label=\"$PKG_NAME ($dist)\";" -i $DOT_FILE
    sed "3i labelloc=t;" -i $DOT_FILE
    dot -Tpdf -o $PDF_FILE $DOT_FILE
  else
    echo " not found."
  fi
done

if [ "${#pdfs[*]}" -eq "0" ]; then
  echo "[-] No output was produced; was the package name correct?"
elif [ "${#pdfs[*]}" -gt "1" ]; then
  pdfunite *-$PKG_NAME.pdf $PKG_NAME.pdf
else
  mv ${pdfs[0]} $PKG_NAME.pdf
fi
echo "[+] Removing leftovers ..."
make clean
