#!/usr/bin/perl
# ---   *   ---   *   ---
# ELJABR CON
# ROMBLK
#
# LIBRE SOFTWARE
# Licensed under GNU GPL3
# be a bro and inherit
#
# CONTRIBUTORS
# lyeb,

# ---   *   ---   *   ---
# deps

package eljabr::con;

  use v5.36.0;
  use strict;
  use warnings;

  use Readonly;
  use English qw(-no_match_vars);

  use lib $ENV{'ARPATH'}.'/lib/sys/';
  use Style;

  use Arstd::Re;

# ---   *   ---   *   ---
# adds to your namespace

  use Exporter 'import';
  our @EXPORT=qw(

    $PARENS_RE
    $VAR_RE
    $ONETIMES_RE
    $SIGN_RE
    $STOP_RE
    $NSTOP_RE
    $ELEM_RE

  );

# ---   *   ---   *   ---
# info

  our $VERSION = v0.00.2;#b
  our $AUTHOR  = 'IBN-3DILA';

# ---   *   ---   *   ---
# ROM

  Readonly our $PARENS_RE=>re_delim(
    '(',')'

  );

  Readonly our $SIGN_RE  => qr{[\-\+]};

  Readonly our $VAR_RE=>qr{
    (?<mul> \d+)?
    (?<var> [A-Za-z]\d?)
    (?<exp> \^\d)?

  }x;

  Readonly our $ONETIMES_RE=>qr{1\s*$VAR_RE};

  Readonly our $STOP_RE  => qr{(?:$SIGN_RE?\d+)};
  Readonly our $NSTOP_RE => qr{(?:[^\-\+\d]*)};


  Readonly our $ELEM_RE=>qr{
    (?<pre>  $NSTOP_RE)
    (?<stop> $STOP_RE)
    (?<post> $VAR_RE)?

  }x;

# ---   *   ---   *   ---
1; # ret
