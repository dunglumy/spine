#!/usr/bin/perl

use strict;
use Test::Simple tests=>9;
use DBI;
use SPINE::DBI::Navbar;
use Data::Dumper;
use Getopt::Long;

my ($dbistr, $username, $psname);

my $result = GetOptions ("dbistr=s"=>\$dbistr,
                         "username=s"=>\$username,
                         "password=s"=>\$psname);


my $dbh = DBI->connect($dbistr||$ENV{'dbistr'}||"dbi:mysql:dbname=test",$username||$ENV{'tusername'}||"spine",$psname||$ENV{'tpass'}||"spine") or die "Could not connect to Database:$!";

my $message_dbi = SPINE::DBI::Navbar->new($dbh);

# Check the objects/pre-requisites

ok(ref($message_dbi) eq "SPINE::DBI::Navbar","Return type: Content DBI object");

# Read

ok(ref($message_dbi->get({name=>"news"})) eq "ARRAY","Return type: get returns array ref");

# Read -- bad

my $mess_content = shift @{$message_dbi->get({'name'=>"somethingnonexistent",count=>1})};

ok ((!$mess_content),"Nothing should be returned with a bad name.");


# Read -- good

$mess_content = shift @{$message_dbi->get({name=>"main"})};

ok (ref($mess_content) eq 'SPINE::Base::Navbar',"This time we have something " . ref($mess_content));

ok ($mess_content->name() eq 'main', "Got a record from Navbar object");

# Create an adminaccess record

$message_dbi->add(SPINE::Base::Navbar->new({
                                                   id=>0,
                                                   name=>'chookie',
                                                   alignment=>'none',
                                                   positioning=>'horizontal',
                                                   font=>'',
                                                   color=>'',
                                                   size=>'',
                                                   style=>'normal',
                                                   sep=>'',
                                                   modified=>'2011-01-01 04:00:00',
                                                   owner=>'admin',
                                                   usergroup=>'users',
                                                   permissions=>'1010'
                                                   }));


# Copy Navbar

$mess_content = shift @{$message_dbi->get({'name'=>"chookie",count=>1})};

$mess_content->name('chookie2');

$message_dbi->add($mess_content);

my $mess_cont1 = shift @{$message_dbi->get({'name'=>"chookie2",count=>1})};

ok ($mess_cont1->name() eq 'chookie2', "New element created.");

# Update Navbar group

my $mess_cont2 = shift @{$message_dbi->get({'name'=>"chookie2",count=>1})};

$mess_cont2->permissions('1011');

$message_dbi->update($mess_cont2);

my $mess_cont3 = shift @{$message_dbi->get({'name'=>"chookie2",count=>1})};

ok ($mess_cont3->permissions() eq '1011', "User setting successfully changed.");

# Delete Navbar group

$message_dbi->remove($mess_content);

my $mess_missing = shift @{$message_dbi->get({'name'=>"chookie",count=>1})};

ok ((!$mess_missing),"Remove worked ok.");

$message_dbi->remove($mess_cont1);

$mess_missing = shift @{$message_dbi->get({'name'=>"chookie2",count=>1})};

ok ((!$mess_missing),"Remove worked ok.");


1;
