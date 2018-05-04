#!/usr/bin/env perl

use strict;
use warnings;

while (<>) {
	chomp;
	if ($_ =~ /^(?<word>[^\/]+)\/(?<rep>[^-]+-[^,]+),(?<pos>[1-9][0-9]*),(?<cut>[1-9][0-9]*)$/) {
		my $word = "$+{word}";
		my $rep = "$+{rep}";
		my $pos = "$+{pos}";
		my $cut = "$+{cut}";
		$word =~ s/-/9/g;
		$rep =~ s/-/=/g;
		printf(".%s./%s,%s,%s\n", $word, $rep, $pos, $cut);
	} else {
		die "Wrong pattern: $_";
	}
}
