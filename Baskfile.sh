: ${HOWL_VER:=0.5.2}
TGZ=howl-$HOWL_VER.tgz
URL=https://github.com/howl-editor/howl/releases/download/$HOWL_VER/howl-$HOWL_VER.tgz
DIR=howl_$HOWL_VER
DEFAULT_DISTROS='xenial zesty artful'



task_changelog() {
  ./format-changelog.pl > $DIR/debian/changelog
}


task_download() {
  aria2c -x16 $UR
  tar xvf $TGZ
  mv howl-$HOWL_VER $DIR
  bask_depends update
}


task_update() {
  rm -rf $DIR/debian
  cp -r debian $DIR/debain
}


task_build() {
  if [[ -n "$@" ]]; then
    distros="`echo "$@" | sed 's/-//g'`"
  else
    distros=$DEFAULT_DISTROS
  fi

  for distro in $distros; do
    mkdir -p out/$distro
    bask_run ddb build ubuntu:$distro out/$distro $DIR || return
    bask_run ddb build ubuntu:$distro out/$distro $DIR -a x86 || return
  done
}
