now = $(shell date "+%Y%m%d%H%M%S")
app = isucondition
service = isucondition.go

# TODO: webapp dirが欲しい？isucariが特殊？

.PHONY: bn
bn:
	ssh isucon@bn 'cd /home/isucon/bench && ./bench -all-addresses 172.31.28.37 -target 172.31.28.37:443 -tls -jia-service-url http://172.31.17.147:4999'

# アプリ､nginx､mysqlの再起動
.PHONY: re
re:
	make arestart
	make nrestart
	make mrestart
	docker compose up -d --build

# アプリ､nginx､mysqlの再起動
.PHONY: re-ssh
re-ssh-db:
	make arestart
	make nrestart
	make mrestart
# DBを分割した時このコメントアウトをとる。 リフレッシュしたいDBのPrivate IPを指定
# ssh 192.168.0.12 -A "cd webapp && make mrestart"

# アプリの再起動
.PHONY: arestart
arestart:
	# sudo systemctl daemon-reload
	# sudo systemctl restart ${service}
	# sudo systemctl status ${service}

# nginxの再起動
.PHONY: nrestart
nrestart:
	# sudo touch /var/log/nginx/access.log
	# sudo rm /var/log/nginx/access.log
	# sudo systemctl reload nginx
	# sudo systemctl status nginx

# mysqlの再起動
.PHONY: mrestart
mrestart:
	sudo touch /home/isucon/webapp/mysql/logs/slow.log
	sudo rm /home/isucon/webapp/mysql/logs/slow.log
	docker compose restart mysql
	# echo "set global slow_query_log = 1;" |  mysql -h 127.0.0.1 -P 13306 -u root -proot
	# echo "set global slow_query_log_file = '/var/log/mysql/slow.log';" | mysql -h 127.0.0.1 -P 13306 -u root -proot
	# echo "set global long_query_time = 0;" | mysql -h 127.0.0.1 -P 13306 -u root -proot

# 分割後のMysqlの再起動(二代目でmrestartを実行する)
# .PHONY: mrestart
# mrestart:
# 	ssh 192.168.0.12 -A "cd webapp && make mrestart"

# アプリのログを見る
.PHONY: nalp
nalp:
	sudo cat /var/log/nginx/access.log | alp ltsv --sort=sum --reverse -m "^/api/condition/[-0-9a-f]+$$","^/api/isu/[-0-9a-f]+$$","^/api/isu/[-0-9a-f]+/icon$$","^/api/isu/[-0-9a-f]+/graph$$","^/isu/[-0-9a-f]+$$","^/isu/[-0-9a-f]+/graph$$","^/isu/[-0-9a-f]+/condition$$"

# mysqlのslowlogを見る
.PHONY: pt
pt:
	sudo pt-query-digest /home/isucon/webapp/mysql/logs/slow.log > ~/pt.log

# pprofを実行する
.PHONY: pprof
pprof:
	curl -o /home/isucon/cpu-profile.prof http://localhost:6060/debug/pprof/profile?seconds=45
	go tool pprof /home/isucon/cpu-profile.prof

# Goのビルド
.PHONY: build
build: go/main.go go/go.mod go/go.sum
	cd go && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ${app}

# Goのビルドと1台目へのGoのバイナリアップロード
.PHONY: upload1
upload1: build
	ssh isucon@i1 'sudo systemctl daemon-reload'
	ssh isucon@i1 'sudo systemctl stop ${service}'
	scp ./go/${app} isucon@i1:/home/isucon/webapp/go/${app}
	ssh isucon@i1 'sudo systemctl restart ${service}'
	ssh isucon@i1 'sudo systemctl status ${service}'

# Goのビルドと2台目へのGoのバイナリアップロード
.PHONY: upload2
upload2: build
	ssh isucon@i2 'sudo systemctl daemon-reload'
	ssh isucon@i2 'sudo systemctl stop ${service}'
	scp ./go/${app} isucon@i2:/home/isucon/webapp/go/${app}
	ssh isucon@i2 'sudo systemctl restart ${service}'
	ssh isucon@i2 'sudo systemctl status ${service}'

# Goのビルドと3台目へのGoのバイナリアップロード
.PHONY: upload3
upload3: build
	ssh isucon@i3 'sudo systemctl daemon-reload'
	ssh isucon@i3 'sudo systemctl stop ${service}'
	scp ./go/${app} isucon@i3:/home/isucon/webapp/go/${app}
	ssh isucon@i3 'sudo systemctl restart ${service}'
	ssh isucon@i3 'sudo systemctl status ${service}'

# 1台目､2台目､3台目へのGoのバイナリアップロード
.PHONY:
all:
	make upload1
	make upload2
	make upload3

.PHONY: zenbu
zenbu:
	make all
	ssh isucon@i1 -A 'cd webapp && make re'
	ssh isucon@i2 -A 'cd webapp && make re'
	ssh isucon@i3 -A 'cd webapp && make re'

.PHONY: pbnalp1
pbnalp1:
	ssh isucon@i1 -A "cd webapp && make nalp" | pbcopy

.PHONY: pbnalp2
pbnalp2:
	ssh isucon@i2 -A "cd webapp && make nalp" | pbcopy

.PHONY: pbnalp3
pbnalp3:
	ssh isucon@i3 -A "cd webapp && make nalp" | pbcopy

.PHONY: pbpt1
pbpt1:
	ssh isucon@i1 -A "cd webapp && make pt && cat ~/pt.log" | pbcopy

.PHONY: pbpt2
pbpt2:
	ssh isucon@i2 -A "cd webapp && make pt && cat ~/pt.log" | pbcopy

.PHONY: pbpt3
pbpt3:
	ssh isucon@i3 -A "cd webapp && make pt && cat ~/pt.log" | pbcopy

.PHONY: getpprof
getpprof:
	scp i1:/home/isucon/webapp/cpu-profile.prof ./
	go tool pprof -http 127.0.0.1:9092 ./cpu-profile.prof

.PHONY: upmakefile1
upmakefile1:
	scp ./Makefile isucon@i1:/home/isucon/webapp/Makefile

.PHONY: upmakefile2
upmakefile2:
	scp ./Makefile isucon@i2:/home/isucon/webapp/Makefile

.PHONY: upmakefile3
upmakefile3:
	scp ./Makefile isucon@i3:/home/isucon/webapp/Makefile

.PHONY: gp1
gp1:
	ssh isucon@i1 -A "cd webapp && git pull"
