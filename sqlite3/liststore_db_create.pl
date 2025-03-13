#
# create liststore.db from array @data ;
#
use v5.40;
use experimental 'class';

use DBI;
use Readonly;
use strict;
use warnings;
use utf8;

use open IO => qw/ :encoding(utf8) :std /;
use Glib 'TRUE', 'FALSE';

binmode STDOUT, ":utf8";

Readonly my $COLUMN_FIXED       => 0;
Readonly my $COLUMN_NUMBER      => 1;
Readonly my $COLUMN_SEVERITY    => 2;
Readonly my $COLUMN_DESCRIPTION => 3;
Readonly my $TRUE  => 1 ;
Readonly my $FALSE => 0;
require "./connect_db.pl";

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


my $d=[];
for my $i ( 0 .. $#data ) {
    my $item = $data[$i];
    my $tmp=[$item->{fixed} , $item->{number}, $item->{severity} ,$item->{description}];
    push @$d,$tmp;
}
for my $item (@$d){
    foreach (@$item){
	print $_ . " , " ;
    }print "\n";
}
my $dbh = SqliteDB->new(database=>"liststore.db");

$dbh->command(q{CREATE TABLE IF NOT EXISTS data (id INTEGER PRIMARY KEY, fixed INT,number INT,severity TEXT,description TEXT)});
$dbh->command(q{INSERT INTO data (fixed ,number ,severity ,description  ) values (?,?,?,?)},$d);
