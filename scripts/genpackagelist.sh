#!/bin/sh
# script to generate packages.json

PORTSDIR="$(dirname $(dirname $(realpath $0)))"
SCRIPTDIR="$(dirname $(realpath $0))"

repo="core multilib nonfree testing"

echo -ne "[" > packages.json

for r in $repo; do
	for p in $PORTSDIR/$r/*; do
		[ -f $p/spkgbuild ] || continue
		. $p/spkgbuild
		homepage=$(grep "^# homepage[[:blank:]]*:" $p/spkgbuild | sed 's/^# homepage[[:blank:]]*:[[:blank:]]*//')
		if [ ! "$homepage" ]; then
			s=$(echo $source | awk '{print $1}')
			case $s in
				*::*) s=${s#*::};;
			esac
			case $s in
				*//*) ;;
				*) continue;;
			esac
			case $s in
				*x.org*|*gnu.org*|*gnome.org*|*github.com*) homepage=$(echo $s | cut -d / -f1-4);;
				*) homepage=$(echo $s | cut -d / -f1-3);;
			esac
		fi
		jsonformat="{\"name\": "\"$name"\",\"version\": "\"$version"\",\"release\": "\"$release"\",\"repo\": "\"$r"\",\"homepage\": "\"$homepage"\"},"
		echo -ne $jsonformat >> packages.json
	done
done

sed 's/.$//' -i packages.json # remove last comma (,)
echo -ne "]" >> packages.json

exit 0
