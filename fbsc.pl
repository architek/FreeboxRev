#!/usr/bin/perl 
#===============================================================================
#
#           FILE: fbsc.pl
#
#  EXAMPLE USAGE: ./fb.pl -pa 'pass!word$' storage.cgi=storage.list fw.cgi=fw.wan_redirs_get
#
#    DESCRIPTION: Allows to get information from the freebox revolution
#
#        VERSION: 0.1
#        CREATED: 13/05/2012 21:49:48
#===============================================================================

use strict;
use warnings;
use Getopt::Long;
use WWW::Mechanize;
use Pod::Usage;
use JSON;
use Data::Dumper;
=head1 NAME

FreeBox Scripter

=cut
my ($passwd,$endpoint,$progress,$verbose)= ("freebox","http://192.168.1.254",0,0);
my $res;

my $mech = WWW::Mechanize->new(
    cookie_jar    => {},
    autocheck     => 1,
    show_progress => $progress,
    timeout       => 10,
) or die("Couldn't build mech");
$mech->add_header( 'Accept-Language' => "fr-fr" );

GetOptions(
    'pass=s'     => \$passwd,
    'endpoint=s' => \$endpoint,
    'progress'   => \$progress,
    'verbose'    => \$verbose,
    help         => sub { pod2usage( verbose => 2 ); },
) or pod2usage( verbose => 2 );


if ($verbose) {
    $|++;
    $mech->add_handler( "request_send", sub { print ">" x 80, "\n", shift->as_string; return } );
    $mech->add_handler( "response_done", sub { print "<" x 80, "\n", shift->as_string; return } );
}

sub do_jsonrpc {
    my ( $url, $content ) = @_;
    my $req = HTTP::Request->new( POST => $endpoint . "/" . $url );
    $req->header( 'Content-type'   => 'application/json' );
    $req->header( 'Content-length' => length($content) );
    $req->content($content);
    $mech->request($req);
    #from_json( $mech->content )->{result}[0];
    from_json( $mech->content );
}

warn "Trying to connect to freebox at $endpoint ...\n";

#Freebox Revolution
$mech->get($endpoint);
$mech->submit_form( with_fields => { login => "freebox", passwd => $passwd } );

while (my $param = shift) {
  my ($uri,$method) = map { m/^(.*?)=(.*)$/ } $param;
  $res = do_jsonrpc(
    $uri,
    to_json(
        {
            jsonrpc => '2.0',
            id      => 0,
            method  => $method,
            #params => ['hello'],
        }
    )
  );
  print Dumper($res);
} 



=head1 SYNOPSIS

This script allows to control the Freebox revolution

=head1 AUTHOR

Laurent KISLAIRE, C<< <teebeenator at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<teebeenator at gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Laurent KISLAIRE.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


