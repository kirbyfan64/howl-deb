: ${HOWL_VER:=0.5.3}
TGZ=howl-$HOWL_VER.tgz
URL=https://github.com/howl-editor/howl/releases/download/$HOWL_VER/howl-$HOWL_VER.tgz
DIR=howl_$HOWL_VER
DEFAULT_DISTROS='xenial zesty artful'

[ -f local.sh ] && . local.sh


parse_distros() {
  if [[ -n "$@" ]]; then
    distros="`echo "$@" | sed 's/-//g'`"
  else
    distros=$DEFAULT_DISTROS
  fi
}


task_changelog() {
  ./format-changelog.pl $DIR/Changelog.md > $DIR/debian/changelog
}


task_download() {
  aria2c -x16 $URL
  tar xvf $TGZ
  mv howl-$HOWL_VER $DIR
  bask_depends update
}


task_update() {
  rm -rf $DIR/debian
  cp -r debian $DIR/debian
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


task_push() {
  parse_distros "$@"

  echo "$distros"

  if [ -z "$REPREPRO_BASE_DIR" ]; then
    bask_log_error "Set \$REPREPRO_BASE_DIR in 'local.sh'."
    return 1
  fi

  export REPREPRO_BASE_DIR

  for distro in $distros; do
    bask_run reprepro -C $distro includedeb $distro out/$distro/*.deb || return
  done
}
