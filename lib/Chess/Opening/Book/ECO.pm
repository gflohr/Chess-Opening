#! /bin/false

# Copyright (C) 2019 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# Make Dist::Zilla happy.
# ABSTRACT: Read chess opening books in polyglot format

package Chess::Opening::Book::ECO;

use common::sense;

use Fcntl qw(:seek);

use Chess::Opening::ECO::Entry;

use base 'Chess::Opening::Book';

sub new {
	my $self = '';

	require Chess::Opening::ECO;

	bless \$self, shift;
}

sub lookupFEN {
	my ($self, $fen) = @_;

	my $positions = Chess::Opening::ECO->positions;

	return if !exists $positions->{$fen};

	my $position = $positions->{$fen};
$DB::single = 1;
	my $entry = Chess::Opening::ECO::Entry->new(
		$fen,
		length => $position->{length},
		significant => $position->{significant},
		history => $position->{history},
		eco => $position->{eco},
		variation => $position->{variation});

	foreach my $move (keys %{$position->{moves}}) {
		$entry->addMove(move => $move);
	}

	return $entry;
}

1;
