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

  our $VERSION = v0.00.2;#b
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

sub over($self,$x) {

  map {
    $ARG->over($x)

  } @{$self->{expr}};

  return;

};

sub combine($self) {

  map {
    $ARG->combine()

  } @{$self->{expr}};

  return;

};

sub modify($self,$i,$j,$x) {
  $self->{expr}->[$i]->modify($j,$x);

};

# ---   *   ---   *   ---
# put values

sub plug($self,%O) {

  my @plug=map {
    $ARG->plug(%O)

  } @{$self->{expr}};

  # overwrite
  $self->{plug}=\@plug;

};

# ---   *   ---   *   ---
# ^solve with plugged values

sub solve($self) {

  my @out  = map {
    $ARG->solve()

  } @{$self->{plug}};

  $self->{res}=\@out;

  return int(grep {$ARG==$out[0]} @out)==@out;

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
