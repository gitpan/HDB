#############################################################################
## This file was generated automatically by Class::HPLOO/0.17
##
## Original file:    ./lib/HDB/Object.hploo
## Generation date:  2004-10-30 21:26:36
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

  use vars qw(%CLASS_HPLOO @ISA) ;

  @ISA = qw(UNIVERSAL) ;

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
    $sub = 'new' if $sub0 =~ /(?:^|::)$sub\::$sub$/ ;
    $sub = "SUPER::$sub" ;
    $_[0]->$sub(@_[1..$#_]) ;
  }

  use HDB ;
  
  *WITH_HPL = \&HDB::WITH_HPL ;
  *HPL_MAIN = \&HDB::HPL_MAIN ;
  
  sub load { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $CLASS = $this ? ref $this : shift(@_) ;

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
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $CLASS = shift(@_) ;
    my $hdb_obj = shift(@_) ;
    my $sel = shift(@_) ;
    
    my $this = bless({} , $CLASS) ;
    
    &{"$CLASS\::CLASS_HPLOO_TIE_KEYS"}($this) ;
    
    foreach my $Key ( keys %$sel ) {
      if ( $Key =~ /^hdbobj__(\w*?)__(\w+)/ ) {
        my ( $class_obj , $attr , $id ) = ($1,$2 , $$sel{$Key}) ;
        $this->{CLASS_HPLOO_ATTR}{$attr} = $this->_build_ref_obj($class_obj,$id) ;
      }
      elsif ( $Key =~ /^hdbstore__(\w*?)__(\w+)/ ) {
        my ( $class_obj , $attr , $freeze ) = ($1,$2 , $$sel{$Key}) ;
        eval('use Storable qw()') ;
        if ( !$@ ) {
          eval {
            $this->{CLASS_HPLOO_ATTR}{$attr} = Storable::thaw($freeze) ;
          };
        }
      }
      elsif ( exists $this->{CLASS_HPLOO_ATTR}{$Key} ) { $this->{CLASS_HPLOO_ATTR}{$Key} = $$sel{$Key} ;}
    }
    
    $this->{__ID__} = $$sel{id} ;
    $this->{__HDB_OBJ__} = $hdb_obj ;

    
    my @ref_tables = $this->hdb_ref_tables ;
    
    foreach my $ref_tables_i ( @ref_tables ) {
      my ($class_main , $class_obj , $attr) = ( $ref_tables_i =~ /^hdbref__(\w*?)__(\w*?)__(\w+)/ );
      my @sel = $this->hdb->select( $ref_tables_i , "$class_main == $this->{__ID__}" , cols => "$class_obj" , '@$') ;

      $this->{CLASS_HPLOO_ATTR}{$attr} = [] ;
      foreach my $sel_i ( @sel ) {
        push( @{ $this->{CLASS_HPLOO_ATTR}{$attr} } , $this->_build_ref_obj($class_obj,$sel_i) ) ;
      }
    }
    

    return $this ;
  }
  
  sub _build_ref_obj { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $class_obj = shift(@_) ;
    my $id = shift(@_) ;
    
    if ( UNIVERSAL::isa($class_obj,'HDB::Object') ) {
      return $class_obj->load($id) ;
    }
    return ;
  }
  
  sub __ID__ { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return $this->{__ID__} ;
  }
  
  sub hdb_obj_changed { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return 1 if ( exists $this->{CLASS_HPLOO_CHANGED} && $this->{CLASS_HPLOO_CHANGED} && ref $this->{CLASS_HPLOO_CHANGED} eq 'HASH' && %{ $this->{CLASS_HPLOO_CHANGED} }) ;
    return ;
  }
  
  sub hdb { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
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
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    $CLASS = $this ? ref $this : shift(@_) ;
    my $CLASS_HPLOO_HASH = $CLASS->GET_CLASS_HPLOO_HASH ;
    
    return 1 if ( (time - $CLASS_HPLOO_HASH->{HDB_TABLE_CHK}) < 2 ) ;

    my %table_hash = $this ? $this->hdb->tables_hash : $CLASS->hdb->tables_hash ;
    
    if ( $table_hash{ ($this ? $this->__CLASS__ : $CLASS ) } ) {
      $CLASS_HPLOO_HASH->{HDB_TABLE_CHK} = time ;
      return 1 ;
    }
    $CLASS_HPLOO_HASH->{HDB_TABLE_CHK} = undef ;

    return ;
  }
  
  sub hdb_create_table { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $class_hploo = $this->GET_CLASS_HPLOO_HASH ;
    my $CLASS = $this->__CLASS__ ;
    $CLASS =~ s/:+/_/gs ;
      
    my @cols ;
    foreach my $order_i ( @{$class_hploo->{ATTR_ORDER}} ) {
      my $tp = $class_hploo->{ATTR}{$order_i}{tp} ;
      
      my ( $col_name , $tp , $table_ref , @cols_ref ) = $this->_hdb_attr_type($order_i , $tp) ;
            
      if ( $table_ref ) {
        $this->hdb->create( $table_ref , @cols_ref ) ;
        #print $this->hdb->sql . "\n" ;
      }
      else {
        push(@cols , $col_name , $this->_hdb_col_type_hploo_2_hdb($tp) ) ;
      }
    }

    $this->hdb->create( $CLASS , @cols ) ;
    #print $this->hdb->sql . "\n" ;
  }
  
  sub hdb_ref_tables { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $CLASS = $this ? $this->__CLASS__ : shift(@_) ;
    my @tables = $this ? $this->hdb->tables : $CLASS->hdb->tables ;

    $CLASS =~ s/:+/_/gs ;
    my @ref ;
    foreach my $tables_i ( @tables ) {
      push(@ref , $tables_i) if $tables_i =~ /hdbref__$CLASS\__/ ;
    }

    return @ref ;
  }
  
  sub hdb_ref_to_me_tables { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $CLASS = $this ? $this->__CLASS__ : shift(@_) ;
    my @tables = $this ? $this->hdb->tables : $CLASS->hdb->tables ;

    $CLASS =~ s/:+/_/gs ;
    my @ref ;
    foreach my $tables_i ( @tables ) {
      push(@ref , $tables_i) if $tables_i =~ /hdbref__(\w+?)__$CLASS\__/ ;
    }

    return @ref ;
  }
  
  sub hdb_referenced_ids { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $CLASS = $this ? $this->__CLASS__ : shift(@_) ;
    my $this_or_class = $this || $CLASS ;
    
    my $hdb_obj = shift(@_) || $this_or_class->hdb ;

    my $class_obj = $CLASS ;
    $class_obj =~ s/:+/_/gs ;

    my $can_have_ref ;

    my @ref_tables = $this_or_class->hdb_ref_to_me_tables ;
    
    $can_have_ref = 1 if @ref_tables ;

    my %ids_ok ;

    foreach my $ref_tables_i ( @ref_tables ) {
      my @sel = $hdb_obj->select( $ref_tables_i , cols => "$class_obj" , '@$') ;
      @ids_ok{@sel} = (1) x @sel ;
    }
    
    foreach my $tables_i ( $hdb_obj->tables ) {
      foreach my $cols_i ( $hdb_obj->names($class_obj) ) {
        if ( $cols_i =~ /^hdbobj__$class_obj\__/ ) {
          my @sel = $hdb_obj->select( $tables_i , cols => $cols_i , '@$') ;
          @ids_ok{@sel} = (1) x @sel ;
          $can_have_ref = 1 ;
        }
      }
    }
    
    return \%ids_ok if $can_have_ref ;
    return ;
  }
  
  sub hdb_clean_unref { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $CLASS = $this ? $this->__CLASS__ : shift(@_) ;
    my $this_or_class = $this || $CLASS ;
    
    my $hdb_obj = shift(@_) || $this_or_class->hdb ;
    
    my $class_obj = $CLASS ;
    $class_obj =~ s/:+/_/gs ;

    my $ids_ok = $this_or_class->hdb_referenced_ids($hdb_obj) ;
    
    $hdb_obj->delete( $class_obj , ["id != ?", ['AND'] , keys %$ids_ok]) if $ids_ok ;
  }
  
  sub _hdb_attr_type { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my  $attr = shift(@_) ;
    my $tp  = shift(@_) ;
    
    my $CLASS = $this->__CLASS__ ;
        
    $CLASS =~ s/:+/_/gs ;

    my ( $tp1 ,$tp2 ) ;
    
    if ( $tp =~ /(?:ref\s*)?(array\s*|hash\s*)?(&\w+|\w+(?:::\w+)*)/ ) { ( $tp1 ,$tp2 ) = ($1,$2) ;}
    else { $tp2 = $tp ;}
    
    my $is_hdbobj = UNIVERSAL::isa($tp2 , 'HDB::Object') ;
    
    $tp2 =~ s/:+/_/gs ;
    $tp = $tp2 ;
    
    my $is_obj = ($tp =~ /^(?:boolean|integer|floating|string|sub_\w+|any|&\w+)$/ ) ? 0 : 1 ;
    
    my $col_name ;
    
    if ( !$is_hdbobj && $is_obj ) {
      return( "hdbstore__$tp2\__$attr" , '*' ) ;
    }
    elsif ( $is_obj ) {
      $col_name = "hdbobj__$tp2\__$attr" ;
      $tp = 'integer' ;
    }
    else { $col_name = $attr ;}
    
    my ($table_ref , @cols_ref) ;
    if ( $tp1 eq 'array' ) {
      $table_ref = "hdbref__$CLASS\__$tp2\__$attr" ;
      @cols_ref = (
      $CLASS => 'integer' ,
      $tp2 => 'integer' ,
      ) ;
    }
    
    return( $col_name , $tp , $table_ref , @cols_ref ) ;
  }
  
  sub _hdb_col_type_hploo_2_hdb { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my  $hploo_type  = shift(@_) ;
    
    if    ( $hploo_type =~ /(?:any|string)/i ) { return '*' ;}
    elsif ( $hploo_type =~ /bool/i ) { return 'boolean' ;}
    elsif ( $hploo_type =~ /int/i ) { return 'int' ;}
    elsif ( $hploo_type =~ /float/i ) { return 'float' ;}
    else { return '*' ;}
  }
  
  sub hdb_max_id { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    my $max_id = $this->hdb->select( $this->__CLASS__ , cols => '>id' , '$' ) ;
    return $max_id ;
  }
  
  sub hdb_delete { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    
    return if !$this->hdb_table_exists ;
    my $id = $this->{__ID__} ;
    
    return if ( $id eq '' || !$this->hdb->select( $this->__CLASS__ , "id == $id" , cols => 'id' , '$' ) ) ;
    
    $this->hdb->delete( $this->__CLASS__ , "id == $id" ) ;
    
    %$this = () ;
    
    return 1 ;
  }

  sub hdb_save { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my %args = @_ ;
    @_ = () ;
    
    $this->hdb_create_table if !$this->hdb_table_exists ;

    return if !$this->hdb_obj_changed ;
    
    my $class_hploo = $this->GET_CLASS_HPLOO_HASH ;

    my $class_hploo_changed = $this->{CLASS_HPLOO_CHANGED} ;
    $this->{CLASS_HPLOO_CHANGED} = undef ;
    
    my $id = $this->{__ID__} ;
    my $insert ;
    
    if ( $id eq '' || ($id && !$this->hdb->select( $this->__CLASS__ , "id == $id" , cols => 'id' , '$' )) ) {
      $id = $this->hdb_max_id + 1 ;
      $insert = 1 ;
    }
        
    my @del_attr_keys ;
    
    my $saved_classes = $args{saved_classes} || {} ;

    foreach my $order_i ( @{$class_hploo->{ATTR_ORDER}} ) {
      my $tp = $class_hploo->{ATTR}{$order_i}{tp} ;
      my ( $col_name , $tp , $table_ref , @cols_ref ) = $this->_hdb_attr_type($order_i , $tp) ;
            
      if ( $table_ref ) {
        if ( ref $this->{$order_i} eq 'ARRAY' ) {
          my (@ids , %ids , $c) ; 
          
          foreach my $attr_i ( @{$this->{$order_i}} ) {
            if ( UNIVERSAL::isa($attr_i , 'HDB::Object') ) {
              $attr_i->hdb_save( no_auto_clean_unref => 1 , saved_classes => $saved_classes ) ;
              $$saved_classes{ $attr_i->__CLASS__ } = 1 ;
              push(@ids , $attr_i->{__ID__}) ;
              $ids{$attr_i->{__ID__}} = ++$c ;
            }
          }

          my @sel = $this->hdb->select( $table_ref , "$cols_ref[0] == $id" , cols => "$cols_ref[2],id" , '@@') ;
          
          my (@del_ids , %sel_ids , %sel_pos ) ;
          
          #print "IDS[$this]>> @ids\n" ;
          
          $c = 0 ;
          foreach my $sel_i ( @sel ) {
            $sel_ids{$$sel_i[0]} = ++$c ;
            $sel_pos{$c} = $$sel_i[1] ;
            push(@del_ids , $$sel_i[1]) if $ids{$$sel_i[0]} != $c ;
            #print "SEL>> $$sel_i[0] , $$sel_i[1] [$c] >> $ids{$$sel_i[0]}\n" ;
          }
          
          my @dels = @del_ids[($#ids+1)..$#del_ids] ;
          #print "DEL>> @dels\n" ;
          
          $this->hdb->delete( $table_ref , ["$cols_ref[2] == ?" , @dels] ) if @dels ;
          #print $this->hdb->sql . "\n" if @dels ;

          foreach my $ids_i ( @ids ) {
            if ( $ids{$ids_i} != $sel_ids{$ids_i} ) {
              my $pos = $sel_pos{ $ids{$ids_i} } ;
              if ( $pos ) {
                $this->hdb->update( $table_ref , "id == $pos" , {$cols_ref[0] => $id , $cols_ref[2] => $ids_i}) ;
                #print $this->hdb->sql . "\n" ;
              }
              else {
                $this->hdb->insert( $table_ref , {$cols_ref[0] => $id , $cols_ref[2] => $ids_i}) ;
                #print $this->hdb->sql . "\n" ;
              }
            }
          }

        }
        elsif ( UNIVERSAL::isa($this->{$order_i} , 'HDB::Object') ) {
          $this->{$order_i}->hdb_save( no_auto_clean_unref => 1 , , saved_classes => $saved_classes ) ;
          $$saved_classes{ $this->{$order_i}->__CLASS__ } = 1 ;
        }
      }
      elsif ( $col_name =~ /^hdbobj/ ) {
        if ( UNIVERSAL::isa($this->{$order_i} , 'HDB::Object') ) {
          $this->{$order_i}->hdb_save( no_auto_clean_unref => 1 , saved_classes => $saved_classes ) ;
          $$saved_classes{ $this->{$order_i}->__CLASS__ } = 1 ;
          $this->{CLASS_HPLOO_ATTR}{$col_name} = $this->{$order_i}->{__ID__} ;
        }
        push(@del_attr_keys , $col_name) ;
      }
      elsif ( $col_name =~ /^hdbstore/ ) {
        eval('use Storable qw()') ;
        if ( !$@ ) {
          eval {
            $this->{CLASS_HPLOO_ATTR}{$col_name} = Storable::freeze( $this->{$order_i} ) ;
          };
          push(@del_attr_keys , $col_name) ;
        }
      }
    }

    my $ret ;
    if ( $insert ) {
      $this->{CLASS_HPLOO_ATTR}{id} = $this->{__ID__} = $id ;
      push(@del_attr_keys , 'id') ;
      $ret = $this->hdb->insert( $this->__CLASS__ , $this->{CLASS_HPLOO_ATTR} ) ;
    }
    else {
      my %changeds ;
      foreach my $Key ( keys %$class_hploo_changed ) {
        $changeds{$Key} = $this->{CLASS_HPLOO_ATTR}{$Key} ;
      }
      $ret = $this->hdb->update( $this->__CLASS__ , "id == $id" , \%changeds ) ;
    }
    
    foreach my $del_keys_i ( @del_attr_keys ) { delete $this->{CLASS_HPLOO_ATTR}{$del_keys_i} ;}
    
    $$saved_classes{ $this->__CLASS__ } = 1 ;
    
    if ( !$args{no_auto_clean_unref} ) {
      foreach my $Key ( keys %$saved_classes ) {
        if ( defined &{ $Key . '::AUTO_CLEAN_UNREF'} && &{ $Key . '::AUTO_CLEAN_UNREF'}() && (time - $class_hploo->{HDB_TABLE_AUTOCLS}{$Key}) > 2 ) {
          $Key->hdb_clean_unref( $this->hdb ) ;
          $class_hploo->{HDB_TABLE_AUTOCLS}{$Key} = time ;
        }
      }
    }
    
    return $ret ;
  }
  
  sub hdb_dump_table { 
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
    my $CLASS = ref($this) || __PACKAGE__ ;
    my $table = shift(@_) ;
    
    if ( !$this ) {
      $this = $table || $_[0] ;
      $table = $_[0] if $_[0] ;
    }
    
    my $dump ;

    $dump .= "TABLE $table:\n\n" ;
        
    my %cols = $this->hdb->table_columns($table) ;
    my @cols = $this->hdb->names($table) ;
    
    foreach my $Key (@cols) {
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
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
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
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
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
    my $this = ref($_[0]) && UNIVERSAL::isa($_[0],__PACKAGE__) ? shift : undef ;
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

This persistence framework was built by a group of modules that handles specific
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

Create the table for the HDB::Object if it doesn't exists.

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

=head2 hdb_clean_unref

This will automatically clean objects from this table if they doesn't have
references in the database from another object. So, only call this if
you have a colection of objects that are referenced by others or you
will lose all the objects from the table:

  Users::Level->hdb_clean_unref ;

You also can define the constant I<AUTO_CLEAN_UNREF> to automatically clean
unreferenced objects:

  class Users::Level extends HDB::Object {
    use constant AUTO_CLEAN_UNREF => 1 ;
    ...
  }

=head2 hdb_referenced_ids

Return the IDs that have a reference to it.

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

=head1 OBJECT REFERENCES

I<HDB::Object> will try to handle automatically attributes that make references
to other objects or list of objects.

When an atribute make a reference to a object that extends I<HDB::Object>,
only the ID to the object will be saved, making a reference to the ID
of the object table.

If an object doesn't extends I<HDB::Object> it will be serialized, using L<Storable>,
and stored in the coloumn value.

When an attribute have a list of objects a reference table is created automatically:

  attr( array Date::OBject dates )

=head1 SEE ALSO

L<HPL>, L<HDB>, L<Class::HPLOO>.

=head1 AUTHOR

Graciliano M. P. <gm@virtuasites.com.br>

I will appreciate any type of feedback (include your opinions and/or suggestions). ;-P

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

