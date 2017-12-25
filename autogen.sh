#!/bin/sh
# Run this to generate configure, the initial makefiles, etc.
#
# Source (non-SVN) distributions should come with a "configure" script
# already generated--people simply compiling the program shouldn't
# need autoconf and friends installed.
#
# SVN only contains the source files: Makefile.am, configure.ac, and
# so on.


srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="stepmania"

AUTOHEADER=autoheader
ACLOCAL_OPTIONS="-I autoconf/m4/"
AUTOMAKE_OPTIONS=-a

AUTOCONF=autoconf

(test -f $srcdir/configure.ac \
  && test -d $srcdir/src) || {
    echo -n "**Error**: Directory \"$srcdir\" does not look like the"
    echo " top-level $PKG_NAME directory"

    exit 1
}

DIE=0

($AUTOCONF --version) > /dev/null 2>&1 || {
  echo
  echo "**Error**: You must have \`autoconf' installed to compile $PKG_NAME."
  echo "Download the appropriate package for your distribution,"
  echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/autoconf/"
  DIE=1
}

if test -z "$AUTOMAKE" && automake --version > /dev/null 2>&1; then
	version=`automake --version | head -1 | awk '{print $4}'`

	IFS=.
	set $version
	if test $1 -eq 1 -a $2 -ge 7; then
		ACLOCAL=aclocal-$1.$2
		AUTOMAKE=automake-$1.$2
	elif test -z "$version"; then
		echo "\`automake' appears to be installed, but the version string could not"
		echo "be parsed.  Proceeding anyway ..."
	elif test $1 -lt 1 -o $2 -lt 7; then
		echo "\`automake' appears to be installed, but is not recent enough.  Automake"
		echo "1.7 or newer is required."
		exit 1
	fi
	unset IFS
	ACLOCAL=aclocal
	AUTOMAKE=automake
fi

if test -z "$AUTOMAKE"; then
  echo
  echo "**Error**: You must have \`automake' installed to compile $PKG_NAME."
  DIE=1
  NO_AUTOMAKE=yes
fi


# if no automake, don't bother testing for aclocal
test -n "$NO_AUTOMAKE" || ($ACLOCAL --version) < /dev/null > /dev/null 2>&1 || {
  echo
  echo "**Error**: Missing \`aclocal'.  The version of \`automake'"
  echo "installed doesn't appear recent enough."
  DIE=1
}

if test "$DIE" -eq 1; then
  exit 1
fi

$ACLOCAL $ACLOCAL_OPTIONS
$AUTOCONF
$AUTOHEADER
$AUTOMAKE $AUTOMAKE_OPTIONS
