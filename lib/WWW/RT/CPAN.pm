package WWW::RT::CPAN;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(
                       list_dist_active_tickets
                       list_dist_resolved_tickets
                       list_dist_rejected_tickets
               );

our %SPEC;

my %dist_arg = (
    dist => {
        schema => 'perl::distname*',
        req => 1,
        pos => 0,
    },
);

$SPEC{list_dist_active_tickets} = {
    v => 1.1,
    summary => 'List active tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_active_tickets {
}

$SPEC{list_dist_resolved_tickets} = {
    v => 1.1,
    summary => 'List resolved tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_resolved_tickets {
}

$SPEC{list_dist_rejected_tickets} = {
    v => 1.1,
    summary => 'List rejected tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_rejected_tickets {
}

1;
# ABSTRACT: Scrape information from https://rt.cpan.org

=head1 DESCRIPTION

This module provides some functions to retrieve data from L<https://rt.cpan.org>
by scraping the web pages. Compared to L<RT::Client::REST>, it provides less
functionality but it can get public information without having to log in first.


=head1 SEE ALSO

L<RT::Client::REST>
