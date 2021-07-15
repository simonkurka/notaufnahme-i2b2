#!/bin/bash
set -e
VERSION=$1

# Directory this script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBUILD="$DIR/build/aktin-notaufnahme-i2b2_$VERSION"

# Load common linux files
source $(dirname "$DIR")/build.sh "$DBUILD" "$VERSION"

mkdir -p $DBUILD/DEBIAN
sed -e "s/__PACKAGE__/$PACKAGE/g" -e "s/__VERSION__/$VERSION/g" $DIR/control > $DBUILD/DEBIAN/control
cp $DIR/templates $DBUILD/DEBIAN/
cp $DIR/config $DBUILD/DEBIAN/
cp $DIR/postinst $DBUILD/DEBIAN/
cp $DIR/prerm $DBUILD/DEBIAN/
sed -e "/^__I2B2_DROP__/{r $DRESOURCES/database/i2b2_postgres_drop.sql" -e 'd;}' $DIR/postrm > $DBUILD/DEBIAN/postrm && chmod 0755 $DBUILD/DEBIAN/postrm

dpkg-deb --build $DBUILD

