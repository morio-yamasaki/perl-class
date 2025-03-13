# perl-class sqlite3
perl 3.8から使えるようになったクラスで書いたプログラム  

connect_db.pl   :       sqlite3 class  

k_result.csv    :       県庁所在地のデータ  

kentyou.pl      :       require "connect_db.pl" ; k_result.csv をデーターベースに書き換え  

liststore.pl    :       https://github.com/dave-theunsub/gtk3-perl-demos/blob/master/liststore.plをclassを使って書き換えた  

liststore_db_create.pl : liststore.pl @data をデーターベースに置き換え liststore.db  

liststore_sqlite.pl  :  liststore.pl を liststore.db を使う用に書き換え  
