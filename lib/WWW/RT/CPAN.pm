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

sub _list_dist_tickets {
    require HTTP::Tiny;
    require HTML::Entities;

    my ($dist, $status) = @_;

    my $url = "https://rt.cpan.org/Public/Dist/Display.html?Status=$status;Name=$dist";
    my $res = HTTP::Tiny->new->get($url);
    unless ($res->{success}) {
        return [$res->{status}, "Can't get $url: $res->{reason}"];
    }
    if ($res->{content} =~ /<title>Unable to find distribution/) {
        return [404, "No such distribution"];
    }
    my @tickets;
    while ($res->{content} =~ m!<tr[^>]*>\s*
                                <td[^>]*><a[^>]+>(\d+)</a></td>\s* # 1) id
                                <td[^>]*><b><a[^>]+>(.+?)</a></b></td>\s* # 2) title
                                <td[^>]*>(.*?)</td>\s* # 3) status
                                <td[^>]*>(.*?)</td>\s* # 4) severity
                                <td[^>]*><small>(.*?)</small></td>\s* # 5) last updated
                                <td[^>]*>(.*?)</td>\s* # 6) broken in
                                <td[^>]*>(.*?)</td>\s* # 7) fixed in
                                #</tr>
                               !gsx) {
        push @tickets, {
            id => $1,
            title => HTML::Entities::decode_entities($2),
            status => $3,
            severity => $4,
            last_updated_raw => $5,
            # last_update => parse $5, but the duration is not accurate e.g. '7 months ago'
            broken_in => [split '<br />', ($6 // '')],
            fixed_in => [split '<br />', ($7 // '')],
        };
    }
    [200, "OK", \@tickets];
}

$SPEC{list_dist_active_tickets} = {
    v => 1.1,
    summary => 'List active tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_active_tickets {
    my %args = @_;
    _list_dist_tickets($args{dist}, 'Active');
}

$SPEC{list_dist_resolved_tickets} = {
    v => 1.1,
    summary => 'List resolved tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_resolved_tickets {
    my %args = @_;
    _list_dist_tickets($args{dist}, 'Resolved');
}

$SPEC{list_dist_rejected_tickets} = {
    v => 1.1,
    summary => 'List rejected tickets for a distribution',
    args => {
        %dist_arg,
    },
};
sub list_dist_rejected_tickets {
    my %args = @_;
    _list_dist_tickets($args{dist}, 'Rejected');
}

1;
# ABSTRACT: Scrape information from https://rt.cpan.org

=head1 SYNOPSIS

 use WWW::RT::CPAN qw(
     list_dist_active_tickets
     list_dist_resolved_tickets
     list_dist_rejected_tickets
 );

 my $res = list_dist_active_tickets(dist => 'Acme-MetaSyntactic');

Sample result:

 [
   200,
   "OK",
   [
     {
       broken_in => [], # e.g. ["0.40", "0.41"]
       fixed_in => [],
       id => 120076,
       last_updated_raw => "8 hours ago",
       severity => "Wishlist",
       status => "new",
       title => "Option to return items in order?",
     },
     {
       broken_in => [],
       fixed_in => [],
       id => 118805,
       last_updated_raw => "3 months ago",
       severity => "Wishlist",
       status => "new",
       title => "Print list of categories of a theme?",
     },
   ],
  ]

Another example (dist not found):

 my $res = list_dist_active_tickets(dist => 'Foo-Bar');

Example result:

 [400, "No such distribution"]


=head1 DESCRIPTION

This module provides some functions to retrieve data from L<https://rt.cpan.org>
by scraping the web pages. Compared to L<RT::Client::REST>, it provides less
functionality but it can get public information without having to log in first.


=head1 SEE ALSO

L<RT::Client::REST>
