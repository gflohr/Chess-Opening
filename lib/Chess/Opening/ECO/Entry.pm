#! /bin/false

# Copyright (C) 2018 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Chess::Opening::ECO::Entry;

use common::sense;

use Locale::TextDomain 'com.cantanea.Chess-Opening';

use base 'Chess::Opening::Book::Entry';

sub new {
	my ($class, $fen, %args) = @_;

	my $self = $class->SUPER::new($fen);

	return $self;
}

sub fen { shift->{__fen} }
sub moves { shift->{__moves} }
sub count { shift->{__count} }

1;
