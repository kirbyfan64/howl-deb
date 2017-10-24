#!/usr/bin/env perl

use POSIX;


open my $fh, '<', @ARGV[0] or die "could not open @ARGV[0]: $!";
my $changelog = do { local $/; <$fh> };
close $fh;

# join lines together
$changelog =~ s/([^\n])\n([ ]*[^\s-*])/$1 $2/g;

# Grab each version.
while ($changelog =~ /## (.*?) \((.*?)\)((?:.|\n)*?)(?:(?=\n## )|\n+$|$)/g) {
    my $ver = $1, $date = $2, $changes = $3;
    next if $ver eq 'Unreleased';

    # parse the date
    my ($y, $m, $d) = $date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/;
    my $time = strftime("%a, %d %b %Y %T +0000", 0, 0, 0, $d, $m, $y-1900), "\n";

    $changes =~ s/(\n?)\n+?### .*\n+?(\n?(?=[^\n]))/$1$2/g; # remove ###
    $changes =~ s/(?<=\n)([^-])/  $1/g; # proper indentation
    $changes =~ s/(?<=^  )[ ]*//mg; # remove excess indentation
    $changes =~ s/(- [^\n]*\n)(?=-)/$1\n/g; # add some newlines
    $changes =~ s/\*\*([^*]+)\*\*/uc($1)/eg; # un-Markdownify strong text
    $changes =~ s/\[(.*?)\]\((.*?)\)/$1 ($2)/g; # un-Markdownify links
    $changes =~ s/`([^`]+)`/$1/g; # un-Markdownify code
    $changes =~ s/^\s*|\s*$//g; # remove leading and trailing ws

    # special cases
    if ($ver eq '0.2') {
        $changes =~ s/(?<=\n)  (?=In order to streamline)/- /;
    }

    $changes =~ s/^([^-])/- $1/; # make single-item changelogs lists
    $changes =~ s/^-/*/gm; # change - to *
    $changes =~ s/^/  /gm; # indent changes by 2 spaces

    # now dump the release info
    print "howl ($ver) stable; urgency=low", "\n\n", $changes, "\n\n";
    # and the signature
    print " -- Ryan Gonzalez <rymg19\@gmail.com>  $time\n\n";
}
