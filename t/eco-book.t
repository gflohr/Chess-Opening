#! /usr/bin/env perl

# Copyright (C) 2018 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use common::sense;

use Test::More;

use Chess::Opening::Book::ECO;
use Chess::Opening::ECO::Entry;

my $book = Chess::Opening::Book::ECO->new;
ok $book;
ok $book->isa('Chess::Opening::Book');

my @test_cases = (
	{
		fen => 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
		moves => ['a2a3', 'a2a4', 'b1a3', 'b1c3', 'b2b3', 'b2b4', 'c2c3',
		          'c2c4', 'd2d3', 'd2d4', 'e2e3', 'e2e4', 'f2f3', 'f2f4',
				  'g1f3', 'g1h3','g2g3','g2g4','h2h3','h2h4' ],
	},
	{
		fen => 'rnbqr1k1/pp3pbp/3p1np1/2pP4/4P3/2N2N2/PP2BPPP/R1BQ1RK1 w - - 6 10',
		moves => ['d1c2', 'f3d2'],
	},
);

foreach my $tc (@test_cases) {
	my $fen = $tc->{fen};

	my $entry = $book->lookupFEN($fen);
	ok $entry, $fen;
	ok $entry->isa('Chess::Opening::ECO::Entry');

	is $entry->fen, $fen;
	is $entry->count,  @{$tc->{moves}};

	my $moves = $entry->moves;

	foreach my $move (@{$tc->{moves}}) {
		is $moves->{$move}->move, $move;
		is $moves->{$move}->learn, 0;
	}
}

done_testing;
