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

  our $VERSION = v0.00.5;#b
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

    my %tab=(
      left  => [$lsign,$lhand],
      right => [$rsign,$rhand],

    );

    # ^diff fractions
    push @term,grep {
      ! ($ARG=~ $ZEROTIMES_RE)

    } map {

      my ($sign,$hand)=@{$tab{$ARG}};

#      if($hand=~ $FRAC_RE) {
#        $hand="$sign($hand)";
#
#      } else {
#        $hand="$sign$hand";
#
#      };

"$sign$hand";

#      $hand;

    } qw(left right);

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
  @term=grep {! ($ARG=~ $ZEROTIMES_RE)} @tmp;

  # clean long decimals
  map {

    my @args=();
    while($ARG=~ s[($NUM_RE)][$PL_CUT]) {

      my $x=$1;

      $x=($x=~ m[\.])
        ? sprintf "%.4f",$x
        : $x
        ;

      push @args,$x;

    };

    while(@args) {
      my $x=shift @args;
      $ARG=~ s[$PL_CUT_RE][$x];

    };

  } @term;


  # make ice
  return bless [@term],$class;

};

# ---   *   ---   *   ---
# extract values from term

sub _tex($self,$sref,%O) {

  # defaults
  $O{subst} //= undef;

  # run cmp
  return ()

  if  defined $O{subst}
  &&! ($$sref=~ s[$ELEM_RE][$O{subst}])
  ;

  return ()

  if! defined $O{subst}
  &&! ($$sref=~ $ELEM_RE)
  ;

  # ^get matches and give
  my $pre    = $+{pre};
     $pre    = '+' if ! $pre;

  my $stop   = $+{stop};
  my $post   = $+{post};
     $post //= $NULLSTR;

  return ($pre,$stop,$post);

};

# ---   *   ---   *   ---
# ^same for varterms

sub _texv($self,$sref,%O) {

  # defaults
  $O{subst} //= undef;

  # run cmp
  return ()

  if  defined $O{subst}
  &&! ($$sref=~ s[$VAR_RE][$O{subst}])
  ;

  return ()

  if! defined $O{subst}
  &&! ($$sref=~ $VAR_RE)
  ;


  # ^get matches and give
  my $var   = $+{var};

  my $mul   = $+{mul};
     $mul //= 1;

  my $exp   = $+{exp};
     $exp //= $NULLSTR;

  return ($mul,$var,$exp);

};

# ---   *   ---   *   ---
# ^... fractions

sub _texf($self,$sref,%O) {

  # defaults
  $O{subst} //= undef;

  # run cmp
  return ()

  if  defined $O{subst}
  &&! ($$sref=~ s[$FRAC_RE][$O{subst}])
  ;

  return ()

  if! defined $O{subst}
  &&! ($$sref=~ $FRAC_RE)
  ;


  # ^get matches
  my $top   = $+{top};
  my $bot   = $+{bot};

  my $topv  = $NULLSTR;
  my $botv  = $NULLSTR;

  # ^recurse
  map {

    my ($dst,$dstv)=@$ARG;

    if(my @ar=$self->_texv($dst)) {
      $$dst  = shift @ar;
      $$dstv = join $NULLSTR,@ar;

    };

  } ([\$top,\$topv],[\$bot,\$botv]);

  return ($top,$topv,$bot,$botv);

};

# ---   *   ---   *   ---
# apply distributive

sub distribute($self) {

  state $distr=qr{
    (?<num> $FRAC_RE|$STOP_RE)
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

      # fractions are for losers
      # decimal multiplier goes BRRRRRRRRR
      if($num=~ $FRAC_RE) {
        $num=$+{top}/$+{bot};

      };


      # extract N from <pre>(N+NX)
      # then apply multiplier
      while(my @ar=$self->_tex(
        \$par,
        subst=>$NULLSTR

      )) {

        my ($pre,$stop,$post)=@ar;

        # fractions...
        if(@ar=$self->_texf(\$stop)) {

          my ($top,$topv,$bot,$botv)=@ar;

          $stop=
            ($top*$num).$topv
          . '/'
          . ($bot*$num).$botv
          ;

        } else {
          $stop=$num*$stop;

        };

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

};

# ---   *   ---   *   ---
# add term and combine

sub balance($self,$x) {
  push @$self,$x;
  $self->combine();

};

# ---   *   ---   *   ---
# divide expr by

sub over($self,$x) {

  # extract values
  for my $t(@$self) {

    # terms with V^E
    if(my @ar=$self->_texv(\$t)) {

      my ($mul,$var,$exp)=@ar;

      if($t=~ $FRAC_RE) {
        my $den=$+{bot};
        $mul*=(1/$x) * (1/$den);

      } else {
        $mul /= $x;

      };

      $mul  = $NULLSTR if $mul eq 1;
      $t    = "$mul$var$exp";
      $t    = "+$t" if ! length $mul || $mul >= 0;

    # ^constants
    } else {
      $t=eval "($t)/$x";
      $t="+$t" if $t >= 0;

    };

  };

};

# ---   *   ---   *   ---
# ^modify Nth term

sub modify($self,$i,$x) {
  $self->[$i]=$x;

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
    if(my @ar=$self->_tex(\$t)) {

      my ($pre,$stop,$post)=@ar;

      # terms with V^E
      if(my @ar=$self->_texv(\$t)) {

        my ($mul,$var,$exp)=@ar;
        my $id=$var.$exp;


        # fracs r4 loserz
        if(@ar=$self->_texf(\$t)) {

          my ($top,$topv,$bot,$botv)=@ar;
          $stop="$top/$bot";

        };

        $tab->{V}->{$id} //= 0;

        my $op =  "$tab->{V}->{$id}$pre$stop";
           $op =~ s[\++][+]sxmg;
           $op =~ s[\-+][-]sxmg;

        $tab->{V}->{$id}=eval $op;

      # ^constants
      } else {
        $tab->{C}+=eval $stop;

      };


    } else {

      $t=~ s[($SIGN_RE)][];

      my $sign=(defined $1)
        ? $1
        : '+'
        ;

      $tab->{V}->{$t}//=0;
      $tab->{V}->{$t}+="${sign}1";

    };

  };


  # put '+' in front
  $tab->{C}="+$tab->{C}" if $tab->{C} >= 0;

  # sum and recalc
  @$self=((map {

    my $sign=($tab->{V}->{$ARG} < 0)
      ? '-'
      : '+'
      ;

    (abs($tab->{V}->{$ARG}) eq 1)
      ? $ARG
      : $tab->{V}->{$ARG}.$ARG
      ;

  } keys %{$tab->{V}}),$tab->{C});

};

# ---   *   ---   *   ---
# make copy with values put

sub plug($self,%O) {

  state $exps=qr{\^};


  # make copy
  my @term = @$self;
  my $cpy  = bless [@term],ref $self;

  $cpy->distribute();

  # ^walk
  for my $t(@$cpy) {

    # filter on have variable
    while(my @ar=$self->_texv(\$t)) {

      # get exponent
      my ($mul,$var,$exp)=@ar;
      $exp=~ s[$exps][**];

      # ^apply
      my $value=$O{$var}.$exp;
      $t=~ s[$VAR_RE][$mul*$value];

    };

  };

  return $cpy;

};

# ---   *   ---   *   ---
# ^solve with put values

sub solve($self) {

  my $out=0;
  map {$out+=eval $ARG} @$self;


  return $out;

};

# ---   *   ---   *   ---
# recalc history

sub update($self) {

  my $class =  ref $self;
  my $src   =  join $NULLSTR,grep {
    ! ($ARG=~ $ZEROTIMES_RE)

  } @$self;

  @$self=@{$class->new($src)};


  return $src;

};

# ---   *   ---   *   ---
1; # ret
