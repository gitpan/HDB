#############################################################################
## This file was generated automatically by Class::HPLOO/0.16
##
## Original file:    ./lib/HDB/Object.hploo
## Generation date:  2004-10-16 19:02:55
##
## ** Do not change this file, use the original HPLOO source! **
#############################################################################

#############################################################################
## Name:        Object.pm
## Purpose:     HDB::Object - Base class for persistent Class::HPLOO objects.
## Author:      Graciliano M. P.
## Modified by:
## Created:     21/09/2004
## RCS-ID:      
## Copyright:   (c) 2004 Graciliano M. P.
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################


{ package HDB::Object ;

  use strict qw(vars) ; no warnings ;

  use vars qw(@ISA) ; @ISA = qw(UNIVERSAL) ;

  my (%CLASS_HPLOO) ;

  my $CLASS = 'HDB::Object' ; sub __CLASS__ { 'HDB::Object' } ;
 
  sub new { 
    if ( !defined &Object && @ISA > 1 ) {
    foreach my $ISA_i ( @ISA ) {
    return &{"$ISA_i\::new"}(@_) if defined &{"$ISA_i\::new"} ;
    } }  my $class = shift ;
    my $this = bless({} , $class) ;
    no warnings ;
    my $undef = \'' ;
    sub UNDEF {$undef} ;
    my $ret_this = defined &Object ? $this->Object(@_) : undef ;
    if ( ref($ret_this) && UNIVERSAL::isa($ret_this,$class) ) {
    $this = $ret_this } elsif ( $ret_this == $undef ) {
    $this = undef }  return $this ;
    }  sub CLASS_HPLOO_TIE_KEYS ;
    sub SUPER {
    my ($pack , undef , undef , $sub0) = caller(1) ;
    unshift(@_ , $pack) if ( (!ref($_[0]) && $_[0] ne $pack) || (ref($_[0]) && !UNIVERSAL::isa($_[0] , $pack)) ) ;
    my $sub = $sub0 ;
    $sub =~ s/.*?(\w+)$/$1/ ;
    $sub = 'new' if $sub0 =~ /(?:^|::)$sub::$sub$/ ;
    $sub = "SUPER::$sub" ;
    $_[0]->$sub(@_[1..$#_]) ;
  }

  use HDB ;
  
  *WITH_HPL = \&HDB::WITH_HPL ;
  *HPL_MAIN = \&HDB::HPL_MAIN ;
  
  sub load { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $CLASS = shift if !$this ;

    my @where ;
    
    foreach my $i ( @_ ) {
      if ( $i =~ /^\d+$/s ) { push(@where , "id == $i") ;}
      else { push(@where , $i) ;}
    }
    
    return if !$CLASS->hdb_table_exists() ;
    
    my $hdb_obj = $CLASS->hdb ;
    
    my @sel = $hdb_obj->select( $CLASS , (@where ? ['?',@where] : ()) , (!wantarray ? (limit => '1') : () ) , '@%' ) ;
    return if !@sel ;
    
    my @obj ;
    foreach my $sel_i ( @sel ) {
      push(@obj , _build_obj($CLASS , $hdb_obj , $sel_i) ) if $sel_i ;
    }
    
    return if !@obj ;
    
    return @obj if wantarray ;
    return $obj[0] ;
  }
  
  sub _build_obj { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $CLASS = shift(@_) ;
    my $hdb_obj = shift(@_) ;
    my $sel = shift(@_) ;
    
    my $this = bless({} , $CLASS) ;
    
    my $class_hploo = $CLASS->GET_CLASS_HPLOO_HASH ;    
    
    if ( $class_hploo->{ATTR} ) {
      foreach my $Key ( keys %{$class_hploo->{ATTR}} ) {
        tie( $this->{$Key} => "$CLASS\::HPLOO_TIESCALAR" , $this , $Key , $class_hploo->{ATTR}{$Key}{tp} , $class_hploo->{ATTR}{$Key}{pr} , \$this->{CLASS_HPLOO_ATTR}{$Key} , \$this->{CLASS_HPLOO_CHANGED} , $CLASS ) if !exists $this->{$Key} ;
      }
    }
    
    foreach my $Key ( keys %$sel ) {
      $this->{CLASS_HPLOO_ATTR}{$Key} = $$sel{$Key} if exists $this->{CLASS_HPLOO_ATTR}{$Key} ;
    }
    
    $this->{__ID__} = $$sel{id} ;
    $this->{__HDB_OBJ__} = $hdb_obj ;

    return $this ;
  }
  
  sub __ID__ { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return $this->{__ID__} ;
  }
  
  sub hdb_obj_changed { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return 1 if ( exists $this->{CLASS_HPLOO_CHANGED} && $this->{CLASS_HPLOO_CHANGED} && ref $this->{CLASS_HPLOO_CHANGED} eq 'HASH' && %{ $this->{CLASS_HPLOO_CHANGED} }) ;
    return ;
  }
  
  sub hdb { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $dbobj = UNIVERSAL::isa($this , 'HASH') ? $this->{__HDB_OBJ__} : undef ;
    
    if ( !$dbobj ) { $dbobj = HDB->HPLOO ;}
    
    if ( !$dbobj && WITH_HPL() ) {
      my $hpl = HPL_MAIN() ;
      if ( defined $hpl->env->{DOCUMENT_ROOT} ) {
        my $db_dir = $hpl->env->{DOCUMENT_ROOT} . '/db' ;
        my $db_file = "$db_dir/hploo.db" ;
        $dbobj = HDB->new(
        type => 'sqlite' ,
        db   => $db_file ,
        ) if -d $db_dir && -w $db_dir && (!-e $db_file || -w $db_file) ;
      }
    }
    
    if ( !$dbobj ) {
      warn("Can't find the predefined HPLOO database connection!") ;
      return ;
    }
    
    if ( UNIVERSAL::isa($this , 'HASH') && !$this->{__HDB_OBJ__} ) {
      $this->{__HDB_OBJ__} = $dbobj ;
    }
    
    return $dbobj ;
  }
  
  sub hdb_table_exists { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $CLASS = shift if !$this ;
    my %table_hash = $this ? $this->hdb->tables_hash : $CLASS->hdb->tables_hash ;
    return 1 if $table_hash{ ($this ? $this->__CLASS__ : $CLASS ) } ;
    return ;
  }
  
  sub hdb_create_table { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $class_hploo = $this->GET_CLASS_HPLOO_HASH ;

    my @cols ;
    foreach my $order_i ( @{$class_hploo->{ATTR_ORDER}} ) {
      push(@cols , $order_i , $this->_hdb_col_type_hploo_2_hdb( $class_hploo->{ATTR}{$order_i}{tp} ) ) ;
    }
    
    $this->hdb->create( $this->__CLASS__ , @cols ) ;
  }
  
  sub _hdb_col_type_hploo_2_hdb { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my  $hploo_type  = shift(@_) ;
    
    if    ( $hploo_type =~ /(?:any|string)/i ) { return '*' ;}
    elsif ( $hploo_type =~ /int/i ) { return 'int' ;}
    elsif ( $hploo_type =~ /float/i ) { return 'float' ;}
    else { return '*' ;}
  }
  
  sub hdb_max_id { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $max_id = $this->hdb->select( $this->__CLASS__ , cols => '>id' , '$' ) ;
    return $max_id ;
  }
  
  sub hdb_delete { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return if !$this->hdb_table_exists ;
    my $id = $this->__ID__ ;
    
    return if ( $id eq '' || !$this->hdb->select( $this->__CLASS__ , "id == $id" , cols => 'id' , '$' ) ) ;
    
    $this->hdb->delete( $this->__CLASS__ , "id == $id" ) ;
    
    %$this = () ;
    
    return 1 ;
  }

  sub hdb_save { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $this->hdb_create_table if !$this->hdb_table_exists ;
    
    return if !$this->hdb_obj_changed ;

    my $class_hploo_changed = $this->{CLASS_HPLOO_CHANGED} ;
    $this->{CLASS_HPLOO_CHANGED} = undef ;
    
    my $id = $this->__ID__ ;
    
    if ( $id eq '' || ($id && !$this->hdb->select( $this->__CLASS__ , "id == $id" , cols => 'id' , '$' )) ) {
      if ( $id eq '' ) {
        $this->{CLASS_HPLOO_ATTR}{id} = $id = $this->{__ID__} = $this->hdb_max_id + 1 ;
      }
      else {
        $this->{CLASS_HPLOO_ATTR}{id} = $this->{__ID__} = $id ;
      }
      my $ret = $this->hdb->insert( $this->__CLASS__ , $this->{CLASS_HPLOO_ATTR} ) ;
      delete $this->{CLASS_HPLOO_ATTR}{id} ;
      return $ret ;
    }
    else {
      my %changeds ;
      foreach my $Key ( keys %$class_hploo_changed ) {
        $changeds{$Key} = $this->{CLASS_HPLOO_ATTR}{$Key} ;
      }
    
      return $this->hdb->update( $this->__CLASS__ , "id == $id" , \%changeds ) ;
    }
  }
  
  sub hdb_dump_table { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $this ||= shift ;
    
    my $table = $this->__CLASS__ ;
    
    my $dump ;

    $dump .= "TABLE $table:\n\n" ;
        
    my %cols = $this->hdb->table_columns($table) ;
    foreach my $Key (sort keys %cols ) {
      $dump .= "  $Key = $cols{$Key}\n" ;
    }
    
    $dump .= "\nROWS:\n\n" ;
    
    my @sel = $this->hdb->select( $table , '@$' ) ;
    foreach my $sel_i ( @sel ) {
      $dump .= "$sel_i\n" ;
    }
    
    return $dump ;
  }
  
  sub STORABLE_freeze { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $cloning = shift(@_) ;
    
    return(
      $this ,
      {
        (ref $this->{CLASS_HPLOO_ATTR} eq 'HASH' ? %{$this->{CLASS_HPLOO_ATTR}} : ()) ,
        id => $this->{__ID__} ,
      }
    ) ;
  }
  
  sub STORABLE_thaw { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $cloning = shift(@_) ;
    my $serial = shift(@_) ;
    my $attrs = shift(@_) ;
    
    my $class = ref $this ;
    
    $this->{__ID__} = delete $attrs->{id} ;

    $this->{CLASS_HPLOO_ATTR} = {} ;
    %{ $this->{CLASS_HPLOO_ATTR} } = %$attrs ;
    
    &{"$class\::CLASS_HPLOO_TIE_KEYS"}($this) ;
    
    $this->hdb ;
    return ;
  }

  sub DESTROY { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],'UNIVERSAL') ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return if !%$this ;
    $this->hdb_save ;
  }


}


1;

__END__

=head1 NAME

HDB::Object - Base class for persistent Class::HPLOO objects.

=head1 DESCRIPTION

This is the base class for persistent Class::HPLOO objects.

This will automaticallt make Class::HPLOO classes persistent in any DB
handled by L<HDB>.

This persistence framework was built by a group of modules that handle specific
parts of the problem:

=over 4

=item L<Class::HPLOO>

The class declaration and attribute handler.

=item L<HDB::Object>

The object persistence and class proxy.

=item L<HDB>

The DB connection and SQL communication for each DB type.

=back

All of this will create a very automatic way to create persistent objects over a
relational DB, what is perfect for fast and easy creation of good systems.
For Web Systems this framework is automatically embeded into L<HPL>,
where you can count with a lot of resources for fast and powerful creations for
the Web.

=head1 USAGE

Here's an example of a class built with HDB::Object persistence.

  use Class::HPLOO ;
  
  class User extends HDB::Object {
  
    use HDB::Object ;
  
    attr( user , pass , name , int age ) ;
    
    sub User( $user , $pass , $name , $age ) {
      $this->{user} = $user ;
      $this->{pass} = $pass ;
      $this->{name} = $name ;
      $this->{age} = time ;
    }
  
  }

B<You can see that is completly automatic and you don't need to care about the
serialization or even about the DB connection, tables and column types.>

=head1 METHODS

=head2 load (CONDITIONS)

Loads an object that exists in the database.

I<CONDITIONS> can be a sequence of WHERE conditions for HDB:

  my $users_x = load User('id == 123') ;
  
  my @users = load User('id <= 10' , 'id == 123' , 'name eq "joe"') ;

If I<CONDITIONS> is NOT paste, if wantarray it will return all the objects in the table, or it will return only the 1st:

  my $user1 = load User() ;
  
  my @all_users = load User() ;

=head2 hdb

Return the HDB object that handles the DB connection.

=head2 hdb_dump_table

Dump all the table content, returning that as a string.

=head2 hdb_table_exists

Retrun TRUE if the table for the HDB::Object was already created.

=head2 hdb_create_table

Create the table for the HDB::Object.

=head2 hdb_obj_changed

Return TRUE when the object was changed and need to be updated in the DB.

=head2 hdb_max_id

Return the max id in the object table.

=head2 hdb_delete

Delete the object from the database.

=head2 hdb_save

Save the object in the database.

I<** Note that you don't need to call this method directly, since when
the object is destroied from the memory it will be saved automatically.>

=head1 DESTROY and AUTO SAVE OBJECT

The object will be automatically saved when the object is destroied.

So if you want to use this automatically save resource you can't overload the
sub DESTROY, or at least should call the super method:

  class User extends HDB::Object {
    ...
    
    sub DESTROY {
      $this->SUPER::DESTROY ;
      ... # your destroy stuffs.
    }
  }

=head1 SEE ALSO

L<HPL>, L<HDB>, L<Class::HPLOO>.

=head1 AUTHOR

Graciliano M. P. <gm@virtuasites.com.br>

I will appreciate any type of feedback (include your opinions and/or suggestions). ;-P

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

