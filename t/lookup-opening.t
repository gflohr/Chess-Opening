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
use Data::Dumper;

use Chess::OpeningBook::Polyglot;
use Chess::OpeningBook::Entry;
use Chess::OpeningBook::Move;

sub stringify_key($);

# This opening book comes from a collection of 998 games of Salo Flohr
# with a maximum depth of 4 plies.  It is for testing only!
my $book_file = 't/flohr.bin';

my $book = Chess::OpeningBook::Polyglot->new($book_file);
my ($fen, $entry, $book_entry);

$fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
$entry = $book->lookupFEN($fen);
$book_entry = Chess::OpeningBook::Entry->new($fen);
$book_entry->addMove(move => 'd2d4', count => 612);
$book_entry->addMove(move => 'e2e4', count => 185);
$book_entry->addMove(move => 'g1f3', count => 167);
$book_entry->addMove(move => 'c2c4', count => 103);
is_deeply $entry, $book_entry, Dumper $entry;

done_testing;
