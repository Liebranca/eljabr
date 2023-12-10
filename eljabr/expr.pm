#!/usr/bin/perl
# ---   *   ---   *   ---
# ELJABR EXPR
# You don't know my pain
#
# LIBRE SOFTWARE
# Licensed under GNU GPL3
# be a bro and inherit
#
# CONTRIBUTORS
# lyeb,

# ---   *   ---   *   ---
# deps

package eljabr::expr;

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

# ---   *   ---   *   ---
# info

  our $VERSION = v0.00.1;#b
  our $AUTHOR  = 'IBN-3DILA';

# ---   *   ---   *   ---
# cstruc

sub new($class,$src) {

  state $term_re=qr{(?:

    (?:[^\-\+])
  | (?:$PARENS_RE)

  )+}x;

  state $expr_re=qr{

    (?<lsign> \-|\+)?
    (?<lhand> $term_re)

    (?<rsign> \-|\+)?
    (?<rhand> $term_re)?

  }x;

  state $parbeg = qr{\(};
  state $parend = qr{\)};
  state $rm     = qr{^\+0$};


  # clean input
  strip(\$src);
  my @term=();

  # ^proc expressions
  while($src=~ s[$expr_re][]) {

    my $lsign   = $+{lsign};
       $lsign //= '+';

    my $lhand   = $+{lhand};
       $lhand //= 0;

    my $rsign   = $+{rsign};
       $rsign //= '+';

    my $rhand   = $+{rhand};
       $rhand //= 0;

    # clean and push
    map {
      $ARG=~ s[$NSPACE_RE][]sxmg

    } $lhand,$rhand;

    push @term,"$lsign$lhand","$rsign$rhand";

  };


  # cat parens
  my @tmp    = ();
  my $anchor = undef;
  my $i      = 0;

  while(@term) {

    my $t=shift @term;

    # have dst string
    if(defined $anchor) {

      # ^end of
      if($t=~ $parend) {
        $tmp[-1] .= $t;
        $anchor   = undef;

      # ^middle
      } else {
        $tmp[-1] .= $t;

      };

    # push next
    } else {
      $anchor=$i if $t=~ $parbeg;
      push @tmp,$t;

    };


    $i++;

  };


  # clean "+0"
  @term=grep {! ($ARG=~ $rm)} @tmp;

  # make ice
  return bless [@term],$class;

};

# ---   *   ---   *   ---
# apply distributive

sub distribute($self) {

  state $distr=qr{
    (?<num> $STOP_RE)
    (?<par> $PARENS_RE)

  }x;

  state $rm=qr{(?:\(|\))};


  # walk terms
  for my $t(@$self) {

    # ^filter on distributive possible
    while($t=~ $distr) {

      my $num=$+{num};
      my $par=$+{par};
      my $sim=$NULLSTR;

      # extract N from <pre>(N+NX)
      # then apply multiplier
      while($par=~ s[$ELEM_RE][]) {

        my $pre    = $+{pre};
           $pre    = '+' if ! $pre;

        my $stop   = $+{stop};
           $stop   = $num*$stop;

        my $post   = $+{post};
           $post //= $NULLSTR;

        # remove parens
        $pre  =~ s[$rm][]sxmg;
        $stop =~ s[$rm][]sxmg;
        $post =~ s[$rm][]sxmg;

        # ^compose final
        $sim.="$pre$stop$post";

      };

      # ^repl expr with final
      $t=~ s[$distr][$sim];

    };

  };


  # recalc
  $self->update();

};

# ---   *   ---   *   ---
# add term and combine

sub balance($self,$x) {
  push @$self,$x;
  $self->combine();

};

# ---   *   ---   *   ---
# ^modify Nth term

sub modify($self,$i,$x) {
  $self->[$i]=$x;
  $self->update();

};

# ---   *   ---   *   ---
# add liketerms

sub combine($self) {

  # write to
  my $tab = {
    C=>0,
    V=>{},

  };


  # walk expressions
  for my $t(@$self) {

    # extract values
    if($t=~ $ELEM_RE) {

      my $pre    = $+{pre};
         $pre    = '+' if ! $pre;

      my $stop   = $+{stop};
      my $post   = $+{post};
         $post //= $NULLSTR;


      # terms with V^E
      if($t=~ $VAR_RE) {

        my $var   = $+{var};
        my $exp   = $+{exp};
           $exp //= $NULLSTR;

        my $id    = $var.$exp;

        $tab->{V}->{$id} //= 0;

        my $op=  "$tab->{V}->{$id}$pre$stop";
           $op=~ s[\++][+]sxmg;
           $op=~ s[\-+][-]sxmg;

        $tab->{V}->{$id}=eval $op;

      # ^constants
      } else {
        $tab->{C}+=$stop;

      };

    };

  };


  # put '+' in front
  $tab->{C}="+$tab->{C}" if $tab->{C} >= 0;

  # sum and recalc
  @$self=((map {
    $tab->{V}->{$ARG}.$ARG;

  } keys %{$tab->{V}}),$tab->{C});

  $self->update();

};

# ---   *   ---   *   ---
# recalc history

sub update($self) {

  my $class = ref $self;
  my $src   = join $NULLSTR,@$self;

  @$self=@{$class->new($src)};

};

# ---   *   ---   *   ---
1; # ret
