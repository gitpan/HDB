#############################################################################
## Name:        sqlite.pm
## Purpose:     HDB::MOD::sqlite -> for DBD::SQLite
## Author:      Graciliano M. P.
## Modified by:
## Created:     14/01/2003
## RCS-ID:      
## Copyright:   (c) 2002 Graciliano M. P.
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

# TESTED WITH DBD::SQLite 0.21 on Win32|Linux

package HDB::MOD::sqlite ;
use DBD::Oracle ;

use strict qw(vars) ;
no warnings ;

our $VERSION = '1.0' ;
our @ISA = qw(HDB::MOD) ;

  my (%OPENED_DBH) ;

  my %SQL = (
  LIKE => 1 ,
  REGEXP => 0 ,
  LOCK_TABLE => 1 ,
  SHOW => 0 ,
  TYPES => [qw(NUMBER VARCHAR VARCHAR2 BOOLEAN)] ,
  TYPES_MASK => {
                'BOOLEAN' => 'NUMBER(1)' ,
                } ,
  ) ;

#######
# NEW #
#######

sub new {
  my $this = shift ;

  $this->{SQL} = \%SQL ;
  $this->{name} = 'HDB::Oracle' ;
  
  bless($this , __PACKAGE__) ;
  return( $this ) ;
}

###########
# CONNECT #
###########

sub MOD_connect {
  my $this = shift ;
  my ( $pass ) = @_ ;
  
  my $db = $this->{db} ;
  my $host = $this->{host} ;
  
  $this->{dbh} = DBI->connect("DBI:Oracle:database=$db;host=$host", $this->{user} , $pass , { RaiseError => 0 , PrintError => 1 , AutoCommit => 1 }) ;
  
  if (! $this->{dbh} ) { return $this->Error("Can't connect to db $db\@$host!") ;}
  
  return( $this->{dbh} ) ;
}

##############
# PRIMARYKEY #
##############

sub PRIMARYKEY { return "UNIQUE" ;}

#################
# AUTOINCREMENT #
#################

sub AUTOINCREMENT { return "INTEGER UNIQUE NOT NULL" ;}

#############
# TYPE_TEXT #
#############

sub Type_TEXT {
  my ( $sz ) = @_ ;
  $sz = 65535 if $sz <= 0 ;
  return( $sz <= 4000 ? "VARCHAR($sz)" : "VARCHAR2($sz)" ) ;
}

################
# TYPE_INTEGER #
################

sub Type_INTEGER {
  my ( $sz ) = @_ ;
  
  $sz =~ s/\D+//g ;
  $sz = 38 if $sz > 38 ;
  
  return "NUMBER($sz)" ;
}

##############
# TYPE_FLOAT #
##############

sub Type_FLOAT {
  my ( $type , $args ) = @_ ;
  
  if ( $args !~ /\d/ ) { return "NUMBER(38)" ;}
  
  my $tp_arg ;
  if    ( $args =~ /(\d+)\D+(\d+)/ ) { $tp_arg = "($1,$2)" ;}
  elsif ( $args =~ /(\d+)/ ) { $tp_arg = "($1)" ;}
  
  return "NUMBER$tp_arg" ;
}

##############
# LOCK_TABLE #
##############

sub lock_table { $_[0]->dbh->do("LOCK TABLE $_[1] IN EXCLUSIVE") ;}

################
# UNLOCK_TABLE #
################

sub unlock_table { $_[0]->dbh->do("UNLOCK TABLES") ;}

#######
# END #
#######

1;


