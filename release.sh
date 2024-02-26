#!/bin/bash -e
# You need to have GITHUB_TOKEN exported to use the script.
# This script is a bit rough but allows us to release very simply

USER=hotdoc
PROJECT=hotdoc_lumen_theme

gh --version

if [ -z ${1+x} ]; then
	echo "Need to pass new version as argument"
	exit 1
else echo "Releasing $1"; fi

version=$1
meson_projline="project('$PROJECT', 'c', version: '$version')"

sed -i "1s/.*/$meson_projline/" meson.build
git add meson.build
git commit -m "Release $version"
git tag $version -m "Release $version"

echo "Pushing $PROJECT"
git push origin master
git push origin $version

cd subprojects/hotdoc_bootstrap_theme
git fetch && git checkout origin/master
bootstrap_theme_commit=$(git rev-list --format=%B --max-count=1 HEAD)
cd -

echo "Producing new release tarball"
rm -Rf build/
mkdir build/
meson build/
ninja -C build tar
sha=$(sha256sum $PROJECT-$1.tar.xz | cut -d ' ' -f 1)

TXT="Update $PROJECT

To use the theme, pass to hotdoc:

\`\`\`
--html-theme=https://github.com/$USER/$PROJECT/releases/download/$1/$PROJECT-$1.tar.xz?sha256=$sha
\`\`\`

Hotdoc bootstrap theme commit:

\`\`\`
$bootstrap_theme_commit
\`\`\`
"

gh release create $version \
	--title "Release $version" \
	--notes "$TXT"

gh release upload $version $PROJECT-$1.tar.xz
