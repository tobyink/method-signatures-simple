#
# Toby Inkster hereby assigns copyright on this test case, and the
# accompanying modifications to the Method::Signatures::Simple module
# to Rhesa Rozendaal.
#

=head1 PURPOSE

Check that multiple invocants are supported

=head1 AUTHOR

Toby Inkster (cpan:TOBYINK)

=head1 LICENCE AND COPYRIGHT

Copyright 2013 Rhesa Rozendaal, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

use strict;
use warnings;
use Test::More tests => 6;

{
	package Local::Class;
	
	use Method::Signatures::Simple
		method_keyword => 'handle',
		invocant       => ['$self', '$c'],
	;
	
	sub new { bless {}, shift }
	
	handle m1 {
		return {
			'$self'  => $self,
			'$c'     => $c,
			'@_'     => \@_,
		};
	}

	handle m2 ($p1) {
		return {
			'$self'  => $self,
			'$c'     => $c,
			'$p1'    => $p1,
			'@_'     => \@_,
		};
	}

	# $c is not an invocant here, so the outer variable should
	# be visible within the method
	my $c = 'outer-scope';
	handle m3 ($self: $p1) {
		return {
			'$self'  => $self,
			'$c'     => $c,
			'$p1'    => $p1,
			'@_'     => \@_,
		};
	}

	handle m4 ($this, $k, $j: $p1) {
		return {
			'$this'  => $this,
			'$k'     => $k,
			'$j'     => $j,
			'$p1'    => $p1,
			'$c'     => $c,
			'@_'     => \@_,
		};
	}
}

my $o = "Local::Class"->new;
my $c = ['C'];

is_deeply(
	$o->m1($c),
	{ '$self' => $o, '$c' => $c, '@_' => [] },
	"Fairly normal usage of a method with two invocants",
);

is_deeply(
	$o->m1($c, 1),
	{ '$self' => $o, '$c' => $c, '@_' => [1] },
	"Usage of a method with two invocants, and extra parameter",
);

is_deeply(
	$o->m1(),
	{ '$self' => $o, '$c' => undef, '@_' => [] },
	"Usage of a method with two invocants, forgetting second invocant (doesn't complain, just undef)",
);

is_deeply(
	$o->m2($c, 1),
	{ '$self' => $o, '$c' => $c, '@_' => [1], '$p1' => 1 },
	"Fairly normal usage of a method with two invocants, plus a named parameter",
);

is_deeply(
	$o->m3($c, 1),
	{ '$c' => 'outer-scope', '$self' => $o, '@_' => [$c, 1], '$p1' => $c },
	"Explicit proto invocants override two invocant keyword to take one invocant",
);

is_deeply(
	$o->m4($c, 99, 1),
	{ '$c' => 'outer-scope', '$this' => $o, '$k' => $c, '$j' => 99, '@_' => [1], '$p1' => 1 },
	"Explicit proto invocants override two invocant keyword to take three invocants",
);


