#!/bin/bash

#export http_proxy="http://localhost:8123/"

MULTIDEB_ROOT="$HOME/.multideb"

ARCHS="\
  amd64\
  i386\
"

SUBS_DEBIAN="\
  main\
  contrib\
  non-free\
"

SUBS_UBUNTU="\
  main\
  multiverse\
  restricted\
  universe\
"

CODENAMES_DEBIAN="\
  sid\
  squeeze\
  wheezy\
"

CODENAMES_UBUNTU="\
  lucid\
  maverick\
  natty\
  oneiric\
  precise\
  quantal\
"

if [ ! -d $MULTIDEB_ROOT ]; then
  echo "[+] Creating $MULTIDEB_ROOT"
  mkdir -p $MULTIDEB_ROOT
fi

for dist in $CODENAMES_UBUNTU; do
  for arch in $ARCHS; do
    APT_ROOT="$MULTIDEB_ROOT/$dist/$arch"
    if [ ! -d $APT_ROOT ]; then
      echo "[+] Creating $APT_ROOT"
      mkdir -p $APT_ROOT
      mkdir -p $APT_ROOT/archives/partial
      for sub in $SUBS_UBUNTU; do
        mkdir -p $APT_ROOT/lists/$sub/partial
      done
      : > $APT_ROOT/sources.list
    fi
    for sub in $SUBS_UBUNTU; do
      URL="http://ftp.ubuntu.com/ubuntu/dists/${dist}/${sub}/binary-${arch}/Packages.bz2"
      FILENAME="$APT_ROOT/lists/$sub/Packages"
      if [ -f $FILENAME ]; then
        echo "[-] $FILENAME already downloaded, skipping."
      else
        wget $URL -O - | bunzip2 > $FILENAME
      fi
      echo "deb file:$APT_ROOT/lists/$sub ./" >> $APT_ROOT/sources.list
    done
    touch $APT_ROOT/status
cat >$APT_ROOT/apt.conf <<EOF
APT::Architecture "${arch}";
APT::Get::List-Cleanup "false";
Dir::Cache ${APT_ROOT};
Dir::State ${APT_ROOT};
Dir::State::status ${APT_ROOT}/status;
Dir::Etc::SourceList ${APT_ROOT}/sources.list;
EOF
    APT_CONFIG=$APT_ROOT/apt.conf apt-get update
  done
done

# Finally, delete the downloaded package files (a copy has been
# created in the process above) and display the size of the multideb tree.
find $MULTIDEB_ROOT -name Packages -delete
du -hs $MULTIDEB_ROOT
