#!/usr/bin/perl
# ---   *   ---   *   ---
# ELJABR
# Balance incognita
#
# LIBRE SOFTWARE
# Licensed under GNU GPL3
# be a bro and inherit
#
# CONTRIBUTORS
# lyeb,

# ---   *   ---   *   ---
# deps

package eljabr;

  use v5.36.0;
  use strict;
  use warnings;

  use Readonly;
  use English qw(-no_match_vars);

  use lib $ENV{'ARPATH'}.'/lib/sys/';
  use Style;

  use Arstd::String;

  use lib $ENV{'ARPATH'}.'/lib/';

  use eljabr::con;
  use eljabr::expr;

# ---   *   ---   *   ---
# info

  our $VERSION = v0.00.1;#b
  our $AUTHOR  = 'IBN-3DILA';

# ---   *   ---   *   ---
# cstruc

sub new($class,$src) {

  # clean input
  strip(\$src);

  # ^split at equals
  my @expr=split m[\=],$src;

  # make child icebox
  my $chld="$class\::expr";
  map {$ARG=$chld->new($ARG)} @expr;

  # ^make ice
  return bless {

    expr  => \@expr,

    plug  => [],
    res   => undef,

  },$class;

};

# ---   *   ---   *   ---
# ^expr wraps

sub distribute($self) {

  map {
    $ARG->distribute()

  } @{$self->{expr}};

  return;

};

sub balance($self,$x) {

  map {
    $ARG->balance($x)

  } @{$self->{expr}};

  return;

};

# ---   *   ---   *   ---
# put values

sub plug($self,%O) {

  state $exps=qr{\^};


  # walk expressions
  my @term = @{$self->{term}};
  my $i    = 0;

  for my $t(@term) {

    # filter on have variable
    while($t=~ m[$VAR_RE]smx) {

      # get exponent
      my $key=$+{var};
      my $exp=$+{exp};

      $exp //=  $NULLSTR;
      $exp   =~ s[$exps][**];

      # ^apply
      my $value=$O{$key}.$exp;
      $t=~ s[$VAR_RE][*$value];

    };

  };


  # overwrite
  $self->{plug}=\@term;

};

# ---   *   ---   *   ---
# ^solve with plugged values

sub solve($self) {

  my @out  = (0,0);
  my $plug = $self->{plug};

  map {$out[0]+=eval $ARG} @$plug;


  $out[1]=eval $self->{equ};
  $self->{res}=\@out;

  return $out[0];

};

# ---   *   ---   *   ---
# recalc history

sub update($self) {

  my $class = ref $self;
  my $src   = join '=',@{$self->{expr}};

  %$self=%{$class->new($src)};

};

# ---   *   ---   *   ---
1; # ret
