#!/usr/bin/perl

my %pin = (
block => "Bl",
core => "Cr",
double => "Do",
file => "Fi",
memory => "Me",
float => "Fl",
string => "St",
tools => "To",
facility => "Fa",
search => "Wl",
);

my %ppre = (
embedded => "Emb",
freestanding => "Frs",
);

my %psuf = (
O0 => "O0",
O1 => "O1",
O2 => "O2",
);

my @infix = ();

my @prefix = ();
my @suffix = ();

foreach my $i (@ARGV) {
    if (defined $pin{$i}) {
        push @infix, $pin{$i};
    }
    if (defined $ppre{$i}) {
        push @prefix, $ppre{$i};
    }
    if (defined $psuf{$i}) {
        push @suffix, $psuf{$i};
    }
}
my $r = join('', sort(@infix));
my $pr = join('', sort(@prefix));
my $sr = join('', sort(@suffix));
print "$pr$r$sr\n";
