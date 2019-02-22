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
	my $fen = $pos->get_fen;

        my @san;
	foreach my $move (@moves) {
		my $move_info = $pos->go_move($move) or die;
		my $move = lc "$move_info->{from}$move_info->{to}$move_info->{promote}";
		push @san, $move_info->{san};
		my $parent = $fen;
		$fen = $pos->get_fen;
		$positions{$parent}->{moves}->{$move} = $fen;
		$positions{$fen}->{parent} = $parent;
	}
	$positions{$fen}->{eco} = $eco;
	$positions{$fen}->{variation} = $variation;
	$positions{$fen}->{history} = \@san;
}

# FIXME! Sort by ECO code and the length of the line.  That will make it a lot
# easier to translate.
foreach my $fen (sort keys %positions) {
	my $position = $positions{$fen};
	my $moves = $position->{moves};
	my $parent = $position->{parent};
	my $naming_position = $position;
	while ($naming_position && !exists $naming_position->{eco}) {
		$naming_position = $positions{$naming_position->{parent}};
	}
	my $eco = $naming_position->{eco};
	my $variation = $naming_position->{variation};
	$variation =~ s{([\\'])}{\\$1}g;

	my $comment = '# TRANSLATORS:';
	for (my $i = 0; $i < @{$position->{history}}; ++$i) {
			if (!($i & 1)) {
					my $moveno = 1 + ($i >> 1);
					$comment .= " $moveno.";
			}
			$comment .= " $position->{history}->[$i]";
	}
	$comment .= "\n";
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
