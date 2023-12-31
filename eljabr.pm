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

  our $VERSION = v0.00.7;#b
  our $AUTHOR  = 'IBN-3DILA';

# ---   *   ---   *   ---
# crux

sub import($class,%O) {

  # defaults
  $O{eps}   //= undef;
  $O{fpres} //= 4;

  # ^apply settings
  $FPRES = $O{fpres};
  $EPS   = (defined $O{eps})
    ? $O{eps}
    : eval "1e-$FPRES"
    ;

};

# ---   *   ---   *   ---
# cstruc

sub new($class,$src,$hist=[]) {

  # split at equals
  my @expr=$class->mkexpr($src);

  # make ice
  my $self=bless {

    expr  => \@expr,

    plug  => [],
    res   => undef,

    hist  => $hist,

  },$class;


  # record first entry
  $self->get_hist('beg')
  if ! @{$self->{hist}};

  return $self;

};

# ---   *   ---   *   ---
# ^make child icebox

sub mkexpr($class,$src) {

  # clean input
  strip(\$src);

  # split at equals
  my @out  = split m[\=],$src;
  my $chld = "$class\::expr";

  # split terms
  map {$ARG=$chld->new($ARG)} @out;


  return @out;

};

# ---   *   ---   *   ---
# ^expr wraps

sub distribute($self) {
  map {
    $ARG->distribute()

  } @{$self->{expr}};

  $self->update('distribute');
  return;

};

sub balance($self,$x) {

  map {
    $ARG->balance($x)

  } @{$self->{expr}};

  $self->update("balance ($x)");
  return;

};

sub over($self,$x) {

  map {
    $ARG->over($x)

  } @{$self->{expr}};

  $self->update("over ($x)");
  return;

};

sub combine($self) {

  map {
    $ARG->combine()

  } @{$self->{expr}};

  $self->update("combine liketerms");
  return;

};

sub modify($self,$i,$j,$x) {
  $self->{expr}->[$i]->modify($j,$x);
  $self->update();

};

# ---   *   ---   *   ---
# put values

sub plug($self,%O) {

  my $src   = $self->{hist}->[0];
     $src   = join '=',@{$src}[1..@$src-1];


  my $class = ref $self;
  my @expr  = $class->mkexpr($src);

  my @plug=map {
    $ARG->plug(%O)

  } @expr;

  # overwrite and calc
  $self->{plug}=\@plug;

};

# ---   *   ---   *   ---
# ^solve with plugged values

sub solve($self) {

  my @out  = map {
    $ARG->solve();

  } @{$self->{plug}};

  return int(grep {
     $ARG >= $out[0]-$EPS
  && $ARG <= $out[0]+$EPS

  } @out)==@out;

};

# ---   *   ---   *   ---
# ^both at once

sub check($self,%O) {

  $self->plug(%O);

  if($self->solve()) {
    say "\n\e[32;1mOK\e[0m\n";

  } else {
    say "\n\e[31;22mNO\e[0m\n";

  };

};

# ---   *   ---   *   ---
# recalc history

sub update($self,$note=undef) {

  my $class = ref $self;
  my $src   = join '=',$self->get_hist($note);

  %$self=%{$class->new($src,$self->{hist})};

};

# ---   *   ---   *   ---
# ^stringify

sub get_hist($self,$note=undef) {

  $note//='wtf?';
  my $pre=(@{$self->{hist}})
    ? '^'
    : $NULLSTR
    ;

  push @{$self->{hist}},["# $pre$note",map {
    $ARG->update()

  } @{$self->{expr}}];

  my @expr=map {
    join $NULLSTR,@$ARG

  } @{$self->{expr}};


  return @expr;

};

# ---   *   ---   *   ---
# ^prich history, colored

sub histc($self,$com=1) {

  state $arg_re=qr{
    (?<! \%)
    ((?:[\d][\d\.]*[a-zA-Z]+|[\d][\d\.]*))

  }x;

  map {

    say "\e[32;22m\n$ARG->[0]\e[0m" if $com;

    my $body=join '=',@{$ARG}[1..@$ARG-1];
    my @args=();

    while($body=~ s[$arg_re][$PL_CUT]) {

      my $arg=$1;
      my $col=$NULLSTR;

      if($arg=~ m[[\d\.]+$]) {

        $arg=($arg=~ m[\.])
          ? sprintf "%.${FPRES}f",$arg
          : $arg
          ;

        $col='$';

      } else {

        if($arg=~ s[($NUM_RE)][$PL_CUT]) {

          my $n=$1;

          $n=($n=~ m[\.])
            ? sprintf "%.${FPRES}f",$n
            : $n
            ;

          $arg=~ s[$PL_CUT_RE][$n];

        };

        $col='&';

      };


      $col  =  "[$col]:%s";
      $body =~ s[$PL_CUT_RE][$col];

      push @args,$arg;

    };

    $body =~ s[\$][num]sxmg;
    $body =~ s[\&][good]sxmg;

    $body =  fsansi($body);
    $body =  sprintf $body,@args;

    say $body;

  } @{$self->{hist}};

  return;

};

# ---   *   ---   *   ---
# ^no colors! :c

sub hist($self,$com=1) {

  map {
    say "\e[32;22m\n$ARG->[0]\e[0m" if $com;
    say join '=',@{$ARG}[1..@$ARG-1];

  } @{$self->{hist}};

};

# ---   *   ---   *   ---
1; # ret
