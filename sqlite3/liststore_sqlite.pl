# The GtkListStore is used to store data in list form, to be used
# later on by a GtkTreeView to display it. This demo builds a
# simple GtkListStore and displays it. See the Stock Browser
# demo for a more advanced example.
#
# Perl version by Dave M <dave.nerd@gmail.com>
# https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/liststore.pl


use v5.40;
use experimental 'class';

use DBI;
use Readonly;
use strict;
use warnings;
use utf8;
use Encode;
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

binmode STDOUT, ":utf8";
use open IO => qw/ :encoding(utf8) :std /;


Readonly my $COLUMN_ID          => 0;
Readonly my $COLUMN_FIXED       => 1;
Readonly my $COLUMN_NUMBER      => 2;
Readonly my $COLUMN_SEVERITY    => 3;
Readonly my $COLUMN_DESCRIPTION => 4;
Readonly my $TRUE  =>TRUE;
Readonly my $FALSE =>FALSE;

#CREATE TABLE IF NOT EXISTS data (id INTEGER PRIMARY KEY, fixed INT,number INT,severity TEXT,description TEXT
my $COL_ID          ={'col' => 0,'db'=>'id'};
my $COL_FIXED       ={'col' => 1,'db'=>'fixed'};
my $COL_NUMBER      ={'col' => 2,'db'=>'number'};
my $COL_SEVERITY    ={'col' => 3,'db'=>'severity'};
my $COL_DESCRIPTION ={'col' => 4,'db'=>'description'};


require './connect_db.pl';

my $conn=SqliteDB->new(database =>"liststore.db");

$conn->command("select * from data ;");
my $data = $conn->result;

class Create_Treeview {
    field  $treeview   :reader;
    field $lstore=Gtk3::ListStore->new( 'Glib::Uint','Glib::Boolean', 'Glib::Uint', 'Glib::String','Glib::String', );
    ADJUST{
	my $model = Create_model->new(lstore=>$lstore)->lstore;

	$treeview = Gtk3::TreeView->new($model);
	$treeview->set_rules_hint($TRUE);
	$treeview->set_search_column($COL_DESCRIPTION->{'col'});
	
	Add_columns->new(treeview=>$treeview);
    }


    method remove_row {
	my $sel=$treeview->get_selection;
	my ( $model, $iter ) = $sel->get_selected;
	print " remove_row " .$model->get($iter,1). " " . $model->get($iter,2) . " " . $model->get($iter,3) ."\n";
	$model->remove($iter);
    }


    class Create_model{
	field  $lstore :param :reader;
	ADJUST {
	    
	    foreach (@$data) {
		my $iter = $lstore->append();
		$lstore->set(
		    $iter,
		    $COL_ID->{'col'}          => $_->{id},
		    $COL_FIXED->{'col'}       => $_->{fixed},
		    $COL_NUMBER->{'col'}      => $_->{number},
		    $COL_SEVERITY->{'col'}    => $_->{severity},
		    $COL_DESCRIPTION->{'col'} => $_->{description}
		    );
	    }
	}
    }
    
    class Add_model{
	field  $lstore :param :reader;
	ADJUST {
	    
	    for my $item (@$data) {
		my $iter = $lstore->append();
		$lstore->set(
		    $iter,
		    $COL_ID->{'col'}         ,    "",
		    $COL_FIXED->{'col'}      ,    $TRUE,
		    $COL_NUMBER->{'col'}     ,    0,
		    $COL_SEVERITY->{'col'}   ,    "",
		    $COL_DESCRIPTION->{'col'},    "" );
	    }
	}
    }    

# Gtk.CellRendererText
# Gtk.CellRendererToggle renderer_radio = Gtk.CellRendererToggle()
#                        renderer_radio.set_radio(True)
# Gtk.CellRendererPixbuf
# Gtk.CellRendererCombo
# Gtk.CellRendererProgress
# Gtk.CellRendererSpinner
# Gtk.CellRendererSpin
# Gtk.CellRendererAccel
    class Add_columns {
	field  $treeview :param ;#:reader ;
	ADJUST{
	    my $model    = $treeview->get_model();
	    
	    # Column for ID
	    my $renderer = Gtk3::CellRendererText->new;
	    my $column = Gtk3::TreeViewColumn->new_with_attributes( 'Id', $renderer,text => $COL_ID->{'col'} );
	    $column->set_sort_column_id($COL_ID->{'col'});
	    $treeview->append_column($column);

	    # Column for fixed toggles
	    $renderer = Gtk3::CellRendererToggle->new;
	    $renderer->signal_connect(toggled => \&fixed_toggled, $model);
	    $column = Gtk3::TreeViewColumn->new_with_attributes( 'Fixed', $renderer,active => $COL_FIXED->{'col'} );
	    
	    #      Set this column to a fixed sizing (of 50 pixels)
	    $column->set_sizing('fixed');
	    $column->set_fixed_width(50);
	    $treeview->append_column($column);
	    
	    # Column for bug numbers
	    $renderer = Gtk3::CellRendererText->new;
	    $column = Gtk3::TreeViewColumn->new_with_attributes( 'Bug number', $renderer,text => $COL_NUMBER->{'col'} );
	    $column->set_sort_column_id($COL_NUMBER->{'col'});
	    $treeview->append_column($column);
	    
	    # Column for severities
	    $column = Gtk3::TreeViewColumn->new_with_attributes( 'Severity', $renderer,text => $COL_SEVERITY->{'col'} );
	    $column->set_sort_column_id($COL_SEVERITY->{'col'});
	    $treeview->append_column($column);
	
	    # Column for description
	    $column =Gtk3::TreeViewColumn->new_with_attributes( 'Description', $renderer,text => $COL_DESCRIPTION->{'col'} );
	    $column->set_sort_column_id($COL_DESCRIPTION->{'col'});
	    $treeview->append_column($column);
	}
	sub fixed_toggled {
	    my ( $cell, $path_str, $model ) = @_;
	    
	    my $path = Gtk3::TreePath->new($path_str);
	    
	    # Get toggled iter
	    my $iter = $model->get_iter($path);
	    my $fixed = $model->get_value( $iter, $COL_FIXED->{'col'} );
	
	    # Do something with value
	    $fixed ^= 1;
	    
	    # Set new value
	    $model->set( $iter, $COL_FIXED->{'col'}, $fixed );
	}
	
    }
}


my $window = Gtk3::Window->new;
$window->set_title('ListStore demo');
$window->signal_connect( destroy => sub { Gtk3->main_quit } );
$window->set_border_width(8);
$window->set_default_size( 300, 250 );

my $icon = 'gtk-logo-rgb.gif';
if ( -e $icon ) {
    my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($icon);
    my $transparent = $pixbuf->add_alpha( $TRUE, 0xff, 0xff, 0xff );
    $window->set_icon($transparent);
}

# This VBox will be handy to organize objects
my $box = Gtk3::Box->new( 'vertical', 8 );
$box->set_homogeneous($FALSE);
$window->add($box);

$box->pack_start(
    Gtk3::Label->new(
              'This is the bug list (note: not based on real data, '
            . 'it would be nice to have a nice ODBC interface to '
            . 'bugzilla or so, though).'
            ),
    $FALSE, $FALSE, 0
    );

my $sw = Gtk3::ScrolledWindow->new( undef, undef );
$sw->set_shadow_type('etched-in');
$sw->set_policy( 'never', 'automatic' );
$box->pack_start( $sw, $TRUE, $TRUE, 5 );



# Create a TreeView
my $new_treeview = Create_Treeview->new;
my $treeview = $new_treeview->treeview;

$sw->add($treeview);

my $bbox = Gtk3::ButtonBox->new('horizontal');
$bbox->set_layout('spread');
$box->pack_start( $bbox, $FALSE, $FALSE, 0 );

my $button = Gtk3::Button->new_from_stock('gtk-delete');
$bbox->add($button);
$button->signal_connect( clicked => \&activate, $new_treeview );

my $buttonc = Gtk3::Button->new_from_stock('gtk-close');
$bbox->add($buttonc);
$buttonc->signal_connect( clicked => sub { Gtk3->main_quit } );

$window->show_all;

Gtk3->main();



sub activate {
    my ( undef, $tree ) = @_;
    $tree->remove_row();
    # my $sel = $tree->get_selection;

    # my ( $model, $iter ) = $sel->get_selected;

    # print $model->get($iter,1). " " . $model->get($iter,2) . " " . $model->get($iter,3) ."\n";

    # return unless $iter;
    # print "remove\n";
    # $tree->remove($iter);
    # return $TRUE;
}

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public License
# as published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
