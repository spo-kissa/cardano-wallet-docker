#!/usr/bin/env bash

echo
echo
echo カレントディレクトリにhd1ディレクトリがあると上書きされます！
echo
echo
read -r _

echo
echo Dockerfileをビルドします...
docker build -t address:1.0 .

echo Dockerを起動します...
docker run --rm -dit --init -v ./:/root/share --name spokissa-address address:1.0

echo ウォレットを作成します...
docker exec -it spokissa-address bash create.sh

echo
echo Dockerを停止します...
docker stop spokissa-address

echo
echo DockerImageを削除します...
docker image rm address:1.0

echo
echo ○ ウォレットhd1ディレクトリを作成しました！

echo

