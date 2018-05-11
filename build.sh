#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exit_cmd=""
defer() { exit_cmd="$@; $exit_cmd"; }
trap 'bash -c "$exit_cmd"' EXIT

PACKAGES=${@:-pkg/*}
CHROOT="$PWD/root"

REPO_PATH=x86_64
REPO_NAME=raysl

mkdir -p "$CHROOT"
[[ -d "$CHROOT/root" ]] || mkarchroot -C /etc/pacman.conf $CHROOT/root base base-devel

for package in $PACKAGES; do
    cd "$package"
    rm -f *.pkg.tar.xz
		updpkgsums
    makechrootpkg -cur $CHROOT
    cd -
done

repo="/home/ray/code/arch-repo/x86_64"

rsync --ignore-existing pkg/*/*.pkg.tar.xz "$repo"
repose --verbose --xz --root="$repo" "$REPO_NAME"

for package in $PACKAGES; do
    cd "$package"
    rm -f *.pkg.tar.xz *.log
		rm -rf "$(basename $package)"
    cd -
done
