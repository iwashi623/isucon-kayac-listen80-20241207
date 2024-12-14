# 特訓

## MySQLにつなぐ
```bash
$ sudo mysql -P 13306  -h 127.0.0.1 -pisucon -uisucon
OR
$ sudo mysql -P 13306  -h 127.0.0.1 -proot -uroot
```
hostnameをlocalhostにすると､`/var/run/mysqld/mysqld.sock`を見に行くのでだめ｡`127.0.0.1`として､TCP通信を使うようにする｡
