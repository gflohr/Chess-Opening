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
		moves => [
			{
				move => 'a2a3',
			},
			{
				move => 'a2a4',
			},
			{
				move => 'b1a3',
			},
			{
				move => 'b1c3',
			},
			{
				move => 'b2b3',
			},
			{
				move => 'b2b4',
			},
			{
				move => 'c2c3',
			},
			{
				move => 'c2c4',
			},
			{
				move => 'd2d3',
			},
			{
				move => 'd2d4',
			},
			{
				move => 'e2e3',
			},
			{
				move => 'e2e4',
			},
			{
				move => 'f2f3',
			},
			{
				move => 'f2f4',
			},
			{
				move => 'g1f3',
			},
			{
				move => 'g1h3',
			},
			{
				move => 'g2g3',
			},
			{
				move => 'g2g4',
			},
			{
				move => 'h2h3',
			},
			{
				move => 'h2h4',
			},
		],
	},
	{
		fen => 'rnbqr1k1/pp3pbp/3p1np1/2pP4/4P3/2N2N2/PP2BPPP/R1BQ1RK1 w - - 6 10',
		moves => [
			{
				move => 'd1c2',
			},
			{
				move => 'f3d2',
			},
		],
	},
);

foreach my $tc (@test_cases) {
	my $fen = $tc->{fen};
	my $book_entry = Chess::Opening::ECO::Entry->new($fen);

	foreach my $move (@{$tc->{moves}}) {
		$book_entry->addMove(%$move);
	}

	my $entry = $book->lookupFEN($fen);
	ok $entry, $fen;
	ok $entry->isa('Chess::Opening::ECO::Entry');
	$tc->{got} = $entry;
	$tc->{wanted} = $book_entry;
	is_deeply $entry, $book_entry, $fen;
}

done_testing;
