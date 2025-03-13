use v5.40;
use experimental 'class';

use DBI;
use Readonly;
use strict;
use warnings;
use utf8;
use open IO => qw/ :encoding(utf8) :std /;
require './connect_db.pl';

my $dbh = DBI->connect("dbi:SQLite:dbname=kentyou.db");
my $conn=SqliteDB->new(database =>"kentyou.db");
$conn->command(q{CREATE TABLE IF NOT EXISTS data (id INTEGER PRIMARY KEY, ken_name TEXT,kentyou TEXT,yuubinn TEXT,jyuusho TEXT, dennwa TEXT)});

my $filename = 'k_result.csv';
my $data;
open my $FH, '<', $filename;
for my $line (<$FH>) {
    chomp $line;
    my @field = split /,/, $line;   # カンマ区切りで配列に格納

    my $d=[$field[0],$field[1],$field[2],$field[3],$field[4],$field[5] ];

    push @$data , $d ;
#    $dbh->do("INSERT INTO data (id , ken_name,kentyou ,yuubinn ,jyuusho , dennwa  ) values (" . $field[0] . ",'" . $field[1] . "','" . $field[2]. "','" . $field[3] . "','" . $field[4]. "','" . $field[5] ."');");
}
close $FH;

$conn->command(q{INSERT INTO data (id , ken_name,kentyou ,yuubinn ,jyuusho , dennwa  ) values (?, ?, ?, ?, ?,?)},$data);
$conn->command(q{select * from data where id >5 and id <14});
my $result = $conn->result;

while ( my $row = shift(@$result)){
    foreach ( keys(%$row) ) {
	print "$_ $row->{$_} , ";
    }
    print "\n";
}
$conn->command(q{UPDATE data set kentyou ='さいたま'where  id = 11});
#id 11 , dennwa 048(824)2111 , kentyou さいたま
$conn->command(q{select * from data where id >5 and id <14});
my $result = $conn->result;

while ( my $row = shift(@$result)){
    foreach ( keys(%$row) ) {
	print "$_ $row->{$_} , ";
    }
    print "\n";
}
