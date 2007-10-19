package FCGI::IIS;

use 5.005;
use strict;
#use warnings;
use FCGI;
use vars qw($VERSION $count);
$VERSION = '0.04';

sub import {
    my $pkg = shift;
    my $runmode = shift;
    &_worker($runmode);
}#sub

sub _worker {
    my $runmode = shift;
    $runmode = "do" unless ($runmode);
    my $request = FCGI::Request();

    while($request->Accept() >= 0) {
        if ($runmode eq "test") {
            print("Content-type: text/html\r\n\r\n", ++$count, "<br>\nMode:$runmode<br>\nScript: $ENV{'SCRIPT_FILENAME'}");
            next;
        }#if
        if ($runmode eq "carp") {
            require CGI::Carp;
            CGI::Carp->import("fatalsToBrowser");
        }#if
        if ($runmode eq "eval") {
            if ($ENV{'SCRIPT_FILENAME'}) {
                open(INF, "$ENV{'SCRIPT_FILENAME'}");
                    undef $/;
                    my $scriptcode = <INF>;
                close(INF);
                $/ = "\n";
                package main;
                eval $scriptcode;
                print ("Content-type: text/html\r\n\r\n", "Error! $@") if $@;
                package FCGI::IIS;
            }#if
            next;
        }#if
        package main;
        do ($ENV{'SCRIPT_FILENAME'}) if ($ENV{'SCRIPT_FILENAME'});
        package FCGI::IIS;
    }#while
}#sub


1;

__END__

=head1 NAME

FCGI::IIS - FCGI wrapper for MS IIS FastCGI

=head1 

SYNOPSIS

  perl -MFCGI::IIS=test
  perl -MFCGI::IIS=carp
  perl -MFCGI::IIS=eval
  perl -MFCGI::IIS=do

=head1 ABSTRACT

  This module provides easy access to Microsoft's FastCGI implementation for IIS 5.1, 6 & 7. 
  Allowing you to easily run your perl scripts as FastCGI. Module usage is described below. 
  If you would details of how to implement this with your IIS visit 
  http://www.cosmicscripts.com/servers/fastcgi.html#iis
  ActivePerl ppm is available from:-
  http://www.cosmicscripts.com/modules
  from a windows command prompt type:-
  "ppm install http://www.cosmicscripts.com/modules/perl/FCGI-IIS.ppd"


=head1 DESCRIPTION

The module has 4 different modes it can be run in.

=over

=item perl -MFCGI::IIS=test

This is a simple test routine, that displays a counter that increments by 1 each time 
the script is called as a FastCGI.

=item perl -MFCGI::IIS=carp

In this mode, CGI::Carp qw(fatalsToBrowser) is invoked before running the do method.

=item perl -MFCGI::IIS=eval

With this mode eval is used instead of the do operator. Slower run time, but allows 
you to trap errors.

=item perl -MFCGI::IIS=do

This is the default mode, and will be called if no arguments are given, i.e. 
perl -MFCGI::IIS. The calling script is loaded into the FastCGI using the do operator.

=back

=head1 SEE ALSO

FCGI
http://www.cosmicscripts.com/servers/fastcgi.html#iis

=head1 AUTHOR

Lyle Hopkins, leader of bristol.pm and bath.pm

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Lyle Hopkins

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
