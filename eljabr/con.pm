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

    $EPS
    $NUM_RE

    $PARENS_RE
    $VAR_RE
    $ONETIMES_RE
    $ZEROTIMES_RE
    $SIGN_RE
    $STOP_RE
    $NSTOP_RE
    $ELEM_RE
    $FRAC_RE

  );

# ---   *   ---   *   ---
# info

  our $VERSION = v0.00.5;#b
  our $AUTHOR  = 'IBN-3DILA';

# ---   *   ---   *   ---
# ROM

  Readonly our $EPS=>1e-8;
  Readonly our $NUM_RE=>qr{[\d\.]+};

  Readonly our $PARENS_RE=>re_delim(
    '(',')'

  );

  Readonly our $SIGN_RE  => qr{[\-\+]};

  Readonly our $VAR_RE=>qr{
    (?<mul> $SIGN_RE?[\d\.]+)?
    (?<var> [A-Za-z]\d?)
    (?<exp> \^\d)?

  }x;

  Readonly our $ZEROTIMES_RE=>qr{
    ^$SIGN_RE?0
    (?<! \.)

    $VAR_RE?$

  }x;

  Readonly our $ONETIMES_RE=>qr{1\s*$VAR_RE}x;

  Readonly our $STOP_RE  => qr{(?:$SIGN_RE?[\d\.]+)};
  Readonly our $NSTOP_RE => qr{(?:[^\-\+\d\.]*)};

  Readonly our $FRAC_RE=>qr{
    (?<top> $VAR_RE|$STOP_RE)
    \s* / \s*

    (?<bot> $VAR_RE|$STOP_RE)

  }x;

  Readonly our $ELEM_RE=>qr{
    (?<pre>  $NSTOP_RE)
    (?<stop> $FRAC_RE|$STOP_RE)
    (?<post> $VAR_RE)?

  }x;

# ---   *   ---   *   ---
1; # ret
