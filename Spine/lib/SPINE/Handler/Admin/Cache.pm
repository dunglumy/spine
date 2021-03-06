package SPINE::Handler::Admin::Cache;

## This module is part of SPINE
## Copyright 2000-2005 Hendrik Van Belleghem
## SPINE is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.

## SPINE is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with Foobar; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## See COPYING and LICENSE for more information on the GPL   
## http://spine.sourceforge.net                  
## beatnik@users.sf.org        

## $Author: beatnik $ - $Date: 2006/03/08 20:48:44 $ - $Revision: 1.18 $

use strict;

use SPINE::DBI::Session;
use SPINE::DBI::User;
use SPINE::DBI::Usergroup;
use SPINE::DBI::Adminaccess;
use SPINE::DBI::Content;
use SPINE::DBI::Attribute;
use SPINE::Base::Attribute;
use SPINE::Constant;

use Data::Dumper;

use SPINE::Transparent::Constant;

use vars qw($VERSION $content_dbi $user_dbi $usergroup_dbi $session_dbi $user $attribute_dbi $adminaccess_dbi $session_dbi $macro_dbi $request $user $adminaccess $adminaccess_dbi $request $error $readperms $writeperms $execperms);

$VERSION = $SPINE::Constant::VERSION;

#Apache::Request Handler
#DB Handler

sub handler 
{ $request = shift; #SPINE::Transparent::Request ; Apache::Request
  my $dbh = shift; #DB Handler
  my @params = ();
  SPINE::Transparent::Constant->new($request);
  my %cookies = $request->cookies;
  my $url = $request->uri;
  my $location = $request->location;

  $url =~ s/^$location\/?//mx;
  ($url,@params) = split("/",$url);
  $attribute_dbi = SPINE::DBI::Attribute->new($dbh);
  my @cache = @{$attribute_dbi->get(attr=>"cache",section=>"content")};
  my $body = "";
  for my $cached (@cache)
  { my %cache = $cached->tohash;
    $body .= "$cache{name}<br>";
  }
  $body = qq(<form method="post" action="<?SPINE_Location?>admin/cache/clear/"><input type="submit" class="button" value="Clear Cache"></form>);
  
  # This part catches the image as button bug in IE.
  shift @params;
  my $action = shift @params;
  if ($request->method eq "POST" && $action eq "clear")
  { for my $cache (@cache)
    { $attribute_dbi->remove($cache); }    
  }
  my $c = SPINE::Base::Content->new({body=>$body,style=>".admin"});
  return $c;
}
1;
__END__

=pod

=head1 NAME

SPINE::Handler::Admin::Attr

=head1 DESCRIPTION

This is the Attribute Admin Handler for SPINE.

SPINE is a perl based content management system. This release uses mod_perl. It should, in time, support all features of the
CGI based version (but it will ofcourse add new things as well). This is a complete rewrite of the engine.

=head1 SYNOPSIS

Most of the installation process takes place in the Apache configuration file.

=head1 VERSION

This is spine 1.3 beta.

=head1 AUTHOR

Hendrik Van Belleghem - hendrik.vanbelleghem@gmail.com

=head1 LICENSE

SPINE is distributed under the GNU General Public License.

Read LICENSE for more information.

=head1 SEE ALSO

SPINE::*

Apache::SPINE::*

Apache::Request

Apache::Cookie

http://spine.sf.net

=cut
