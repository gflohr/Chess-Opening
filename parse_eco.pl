#! /usr/bin/env perl

# Copyright (C) 2019 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# This script parses a PGN file containing an ECO (Encyclopedia of Chess
# Openings) database.  Such a PGN file can be created with the chess tool
# Scid.  The source tarball contains a file "scid.eco" that can be converted
# to PGN with the Python script "scripts/eco2pgn.py".

use common::sense;

use Chess::PGN::Parse;
use Chess::Rep;

sub by_eco;
sub significant;

my $filename;

my $filename = shift @ARGV;
die "Usage: $0 ECO-PGN-FILE" if !defined $filename;

my $pgn = Chess::PGN::Parse->new($filename);
if (!($pgn && $pgn->{fh})) {
	if ($!) {
		die __x("error opening '{filename}': {error}!\n",
				filename => $filename, error => $!);
	} else {
		die __x("error parsing '{filename}'.\n");
	}
}

my %positions;

while ($pgn->read_game) {
	$pgn->parse_game;
	my $tags = $pgn->tags;
	my $eco = $tags->{ECO};
	my $variation = $tags->{Variation};

	# Insert spaces after the periods.
	$variation =~ s{([0-9])\.\.\.([KQBNR]?[a-h][1-8])}{$1... $2}g;
	$variation =~ s{([0-9])\.([KQBNR]?[a-h][1-8])}{$1. $2}g;

	my @moves = @{$pgn->moves};
	my $pos = Chess::Rep->new;
	my $fen = significant $pos->get_fen;

	my @san;
	my @history;
	foreach my $move (@moves) {
		my $move_info = $pos->go_move($move) or die;
		my $move = lc "$move_info->{from}$move_info->{to}$move_info->{promote}";
		push @history, $move;
		push @san, $move_info->{san};
		my $parent = $fen;
		$fen = significant $pos->get_fen;
		$positions{$parent}->{moves}->{$move} = $fen;
		$positions{$fen}->{parent} = $parent;
		$positions{$fen}->{san} = [@san];
		$positions{$fen}->{history} = [@history];
	}
	$positions{$fen}->{eco} = $eco;
	$positions{$fen}->{variation} = $variation;
	$positions{$fen}->{san} = [@san];
	$positions{$fen}->{history} = [@history];
	$positions{$fen}->{significant} = @san;
}

# Fill ECO code and variation for intermediate positions.
foreach my $fen (sort keys %positions) {
	my $position = $positions{$fen};
	my $naming_position = $position;
	while ($naming_position && !exists $naming_position->{significant}) {
		$naming_position = $positions{$naming_position->{parent}};
	}
	$position->{eco} = $naming_position->{eco};
	$position->{variation} = $naming_position->{variation};
	$position->{significant} = $naming_position->{significant};
}

foreach my $fen (sort by_eco keys %positions) {
	my $position = $positions{$fen};
	my $moves = $position->{moves};
	my $eco = $position->{eco};
	my $variation = $position->{variation};
	$variation =~ s{([\\'])}{\\$1}g;

	my $comment = "# TRANSLATORS: $eco:";
	for (my $i = 0; $i < @{$position->{san}}; ++$i) {
			if (!($i & 1)) {
					my $moveno = 1 + ($i >> 1);
					$comment .= " $moveno.";
			}
			$comment .= " $position->{san}->[$i]";
	}

	print <<EOF;
		'$fen' => {
			eco => '$eco',
			$comment
			variation => N__('$variation'),
			moves => {
EOF

	foreach my $move (sort keys %{$position->{moves}}) {
		print <<EOF;
				'$move' => 1,
EOF
	}

	print <<EOF;
			},
		},
EOF
}

sub by_eco {
	return $positions{$a}->{eco} cmp $positions{$b}->{eco}
		if $positions{$a}->{eco} cmp $positions{$b}->{eco};

	my $history_a = join '', @{$positions{$a}->{history}};
	my $history_b = join '', @{$positions{$b}->{history}};
	return $history_a cmp $history_b;
}

sub significant {
	my ($fen) = @_;

	$fen =~ s/[ \011-\015]+[0-9]+[ \011-\015]+[0-9]+[ \011-\015]*$//;

	return $fen;
}
