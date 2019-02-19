#! /bin/false

# Copyright (C) 2018 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Chess::Opening::BookEntry;

use common::sense;

use Locale::TextDomain 'com.cantanea.Chess-Opening';

use Chess::Opening::BookMove;

sub new {
	my ($class, $fen) = @_;

	bless {
		__fen => $fen,
		__moves => [],
		__count => 0,
	}, $class;
}

sub addMove {
	my ($self, %args) = @_;

	if (!exists $args{move}) {
		require Carp;
		Carp::croak(__x("the named argument '{arg}' is required",
		                arg => 'move'));
	}
	if ($args{move} !~ /^[a-h][1-8][a-h][1-8][qrbn]?$/) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'",
		                move => '$args{move}'));
	}
	if (exists $args{count} && $args{count}
	    && $args{count} !~ /^[1-9][0-9]*$/) {
		require Carp;
		Carp::croak(__"count must be a positive intenger");
	}

	my $move = Chess::Opening::BookMove->new(%args);
	push @{$self->{__moves}}, $move;
	$self->{__count} += $move->count;

	return $self;
}

sub fen { shift->{__fen} }
sub moves { shift->{__moves} }
sub count { shift->{__count} }

1;
