use v5.40;
use experimental 'class';
class SqliteDB {
    field $database :param ;
    field $result :reader ;
    ADJUST{
	$result=[];
    }
    method command
    {
	# @_は引数を示す配列である。配列をスカラーコンテキストで評価すると配列のサイズを示す。
	# 引数を単純にスカラー変数に代入しようとすると、スカラーコンテキストで配列を評価した値が代入される。
	# この仕様が組み合わさり、このケースでは直感に反して配列のサイズが代入される。(コンテキストをよく理解していればこの挙動は自明だが、最初はハマりやすい。)
	# sub identity {
	#     my $num = @_;
	#     return $num;
	# }
	# say "identity('foo') => ", identity('foo'); # => 1

	my $args= @_;

	my $sql_stmt;
	my $data;
	if ($args == 1 ){
	    $sql_stmt = shift;
	}elsif( $args == 2 ){
	    ($sql_stmt , $data) = @_;
	}else{
	    exit;
	}
	#sqlite3 *db;
	#sqlite3_stmt *stmt;
	#int rc;

	# int sqlite3_open(const char *filename, sqlite3 **ppDb)
	my $dbh = DBI->connect("dbi:SQLite:dbname=". $database);
	$dbh->{sqlite_unicode} = 1; # important!
	if(!$dbh){
		print("error : database open error\n");
		exit;
	}
	# int sqlite3_prepare_v2(sqlite3 *db, const char *zSql, int nByte,
	#                        sqlite3_stmt **ppStmt, const char **pzTail)
	my $sth = $dbh->prepare($sql_stmt);
	
	if ( $sql_stmt =~ /SELECT/i){
	    @$result=();
	    $sth->execute;
	    while (my $row = $sth->fetchrow_hashref()) {
		push(@$result, $row);
	    }
	}elsif($sql_stmt =~ /INSERT/i){
	    while (my $row = shift(@$data)){
		for my $j (0 .. $#{$row}){
		    $sth->bind_param($j+1, $row->[$j]);
		    $j++;
		}
		$sth->execute;
		my $r = $sth->fetchall_arrayref({});
	    }

	}elsif($sql_stmt =~ /CREATE/i){
	    print "CREATE\n";
	    $sth->execute;
	}elsif($sql_stmt =~ /UPDATE/i){
	    print "UPDATE\n";
	    $sth->execute;
	}
	$sth->finish;

	undef $sth;
	# sqlite3_finalize(sqlite3_stmt *pStmt)

	
	# sqlite3_close(sqlite3*)

	$dbh->disconnect;
	#return $result;
    }
}

1;
