# The GtkListStore is used to store data in list form, to be used
# later on by a GtkTreeView to display it. This demo builds a
# simple GtkListStore and displays it. See the Stock Browser
# demo for a more advanced example.
#
# https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/liststore.pl
# 2025-03-13 
use v5.40;
use experimental 'class';


use Readonly;
use strict;
use warnings;
use utf8;

use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';

binmode STDOUT, ":utf8";
# 
Readonly my $COLUMN_FIXED       => 0;
Readonly my $COLUMN_NUMBER      => 1;
Readonly my $COLUMN_SEVERITY    => 2;
Readonly my $COLUMN_DESCRIPTION => 3;
Readonly my $TRUE  =>TRUE;
Readonly my $FALSE =>FALSE;

my @data = (
    {
        fixed       => $FALSE,
        number      => 60482,
        severity    => "Normal",
        description => "scrollable notebooks and hidden tabs"
    },
    {   fixed    => $FALSE,
	number   => 60620,
        severity => "Critical",
        description =>
            "gdk_window_clear_area (gdkwindow-win32.c) is not thread-safe"
    },
    {   fixed       => $FALSE,
        number      => 50214,
        severity    => "Major",
        description => "Xft support does not clean up correctly"
    },
    {   fixed       => $TRUE,
        number      => 52877,
        severity    => "Major",
        description => "GtkFileSelection needs a refresh method. "
        },
    {   fixed       => $FALSE,
        number      => 56070,
        severity    => "Normal",
        description => "Can't click button after setting in sensitive"
        },
    {   fixed       => $TRUE,
        number      => 56355,
        severity    => "Normal",
        description => "GtkLabel - Not all changes propagate correctly"
        },
    {   fixed       => $FALSE,
        number      => 50055,
        severity    => "Normal",
        description => "Rework width/height computations for TreeView"
        },
    {   fixed       => $FALSE,
        number      => 58278,
        severity    => "Normal",
        description => "gtk_dialog_set_response_sensitive () doesn't work"
        },
    {   fixed       => $FALSE,
        number      => 55767,
        severity    => "Normal",
        description => "Getters for all setters"
        },
    {   fixed       => $FALSE,
        number      => 56925,
        severity    => "Normal",
        description => "Gtkcalender size"
        },
    {   fixed       => $FALSE,
        number      => 56221,
        severity    => "Normal",
        description => "Selectable label needs right-click copy menu"
        },
    {   fixed       => $TRUE,
        number      => 50939,
        severity    => "Normal",
        description => "Add shift clicking to GtkTextView"
        },
    {   fixed       => $FALSE,
        number      => 6112,
        severity    => "Enhancement",
        description => "netscape-like collapsable toolbars"
        },
    {   fixed       => $FALSE,
        number      => 1,
        severity    => "Normal",
        description => "First bug :=)"
        },
    );

class Create_Treeview {
    field  $treeview   :reader;
    field $lstore=Gtk3::ListStore->new( 'Glib::Boolean', 'Glib::Uint', 'Glib::String','Glib::String', );
    ADJUST{
	my $model = Create_model->new(lstore=>$lstore)->lstore;
	
	$treeview = Gtk3::TreeView->new($model);
	$treeview->set_rules_hint($TRUE);
	$treeview->set_search_column($COLUMN_DESCRIPTION);
	
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
	    
	    for my $item (@data) {
		my $iter = $lstore->append();
		$lstore->set(
		    $iter,
		    $COLUMN_FIXED       => $item->{fixed},
		    $COLUMN_NUMBER      => $item->{number},
		    $COLUMN_SEVERITY    => $item->{severity},
		    $COLUMN_DESCRIPTION => $item->{description}
		    );
	    }
	}
    }
    
    class Add_model{
	field  $lstore :param :reader;
	ADJUST {
	    
	    for my $item (@data) {
		my $iter = $lstore->append();
		$lstore->set(
		    $iter,             $COLUMN_FIXED,
		    $TRUE,    $COLUMN_NUMBER,
		    0,   $COLUMN_SEVERITY,
		    "", $COLUMN_DESCRIPTION,
		    "" );
	    }
	}
    }    

    class Add_columns {
	field  $treeview :param ;#:reader ;
	ADJUST{
	    my $model    = $treeview->get_model();
	    
	    # Column for fixed toggles
	    my $renderer = Gtk3::CellRendererToggle->new;
	    $renderer->signal_connect(toggled => \&fixed_toggled, $model);
	    
	    my $column = Gtk3::TreeViewColumn->new_with_attributes( 'Fixed', $renderer,active => $COLUMN_FIXED );
	    
	    # Set this column to a fixed sizing (of 50 pixels)
	    $column->set_sizing('fixed');
	    $column->set_fixed_width(50);
	    $treeview->append_column($column);
	    
	    # Column for bug numbers
	    $renderer = Gtk3::CellRendererText->new;
	    $column = Gtk3::TreeViewColumn->new_with_attributes( 'Bug number', $renderer,text => $COLUMN_NUMBER );
	    $column->set_sort_column_id($COLUMN_NUMBER);
	    $treeview->append_column($column);
	    
	    # Column for severities
	    $column = Gtk3::TreeViewColumn->new_with_attributes( 'Severity', $renderer,text => $COLUMN_SEVERITY );
	    $column->set_sort_column_id($COLUMN_SEVERITY);
	    $treeview->append_column($column);
	
	    # Column for description
	    $column =Gtk3::TreeViewColumn->new_with_attributes( 'Description', $renderer,text => $COLUMN_DESCRIPTION );
	    $column->set_sort_column_id($COLUMN_DESCRIPTION);
	    $treeview->append_column($column);
	}
	sub fixed_toggled {
	    my ( $cell, $path_str, $model ) = @_;
	    
	    my $path = Gtk3::TreePath->new($path_str);
	    
	    # Get toggled iter
	    my $iter = $model->get_iter($path);
	    my $fixed = $model->get_value( $iter, $COLUMN_FIXED );
	
	    # Do something with value
	    $fixed ^= 1;
	    
	    # Set new value
	    $model->set( $iter, $COLUMN_FIXED, $fixed );
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
#print $TRUE ." False  " . $FALSE . "  , " . $COLUMN_FIXED  . " , " . undef ." EnD\n";
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
