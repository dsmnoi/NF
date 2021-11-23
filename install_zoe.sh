#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo -e "ZoeCloud 定制版流媒体猴子 2.2 一键安装"
echo -e "官网 https://zoecloud.cc"
echo -e "频道 https://t.me/zoecloud"
echo -e "群组 https://t.me/zoeclouds\n"

localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -o "10.[0-9]\{1,3\}\.[0-9]\{1,3\}\.")

wget -O /usr/local/bin/netflix.sh https://raw.githubusercontent.com/yxkumad/streammonkeylite/main/zoe_hinet.sh>/dev/null 2>&1 && chmod +x /usr/local/bin/netflix.sh

echo -e "请输入服务器名称"
read -erp "(默认: ZoeCloud):" zoecloudname
[[ -z "$zoecloudname" ]] && zoecloudname="ZoeCloud"

echo -e "请输入 Telegram Bot Token"
read -erp "(默认: null):" zoecloudbottoken
[[ -z "$zoecloudbottoken" ]] && zoecloudbottoken="null"

echo -e "请输入 Telegram Chat ID"
read -erp "(默认: null):" zoecloudbotchatid
[[ -z "$zoecloudbotchatid" ]] && zoecloudbotchatid="null"

echo -e "请输入检测频率"
read -erp "(默认: 5):" crontime
[[ -z "$crontime" ]] && crontime="5"

zoecloudapi="http:\/\/${localIP}10\/changeip\/changeip.aspx"

sed -i "s/zoecloudname/$zoecloudname/g" /usr/local/bin/netflix.sh
sed -i "s/zoecloudapi/$zoecloudapi/g" /usr/local/bin/netflix.sh
sed -i "s/zoecloudbottoken/$zoecloudbottoken/g" /usr/local/bin/netflix.sh
sed -i "s/zoecloudbotchatid/$zoecloudbotchatid/g" /usr/local/bin/netflix.sh

crontab -l | { cat; echo "*/$crontime * * * * /usr/local/bin/netflix.sh >/dev/null 2>&1"; } | crontab -
