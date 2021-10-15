# 全自动流媒体解锁监控猴子


## 特点
- 7x24 全天候自动检测
- 支持多种 IP 更换方式
- 支持 Telegram 推送通知
- 支持自动更换 DNS 解锁 IP

## 如何使用
1. 下载脚本到服务器，建议路径为 `/usr/local/bin/netflix.sh`

2. 按照下列可配置选项名单编辑文件，推荐使用 nano 或 vim

3. 命令行输入 `/usr/local/bin/netflix.sh` 测试，如需要测试更换 IP 地址可输入 `/usr/local/bin/netflix.sh 1`

4. 新增 crontab 任务，命令行输入 `crontab -e` 后输入 `*/1 * * * * /usr/local/bin/netflix.sh >/dev/null 2>&1` （每分钟检测一次）

## 可配置选项

### NAME（名称）
自定义服务器名称，Telegram 推送信息用

### MODE（模式）
1: 以 DHCP 更换 IP

2: 以 API 更换 IP

3: 以 API 更换 IP（SYM Host 服务器专用）

4: 为 Cloudflare Warp（Wireguard 版本）更换 IP（Lite 版不适用）

5: 以 API 更换 IP（无重试）（Lite 版不适用）

### TEST（测试项目，Lite 版不适用）
0: 测试 Google 和 Netflix

1: 仅测试 Google

2: 仅测试 Netflix

### DNSmasq（DNS 解锁）
0: 禁用自动更新 DNSmasq 配置

1: 启用自动更新 DNSmasq 配置

### WGName（仅供模式 4 使用）
Cloudflare Warp Wireguard 版本的配置名

### API（仅供模式 2/5 使用）
更换 IP API 地址，请在使用前配置

### SYMAPI（仅供模式 2/5 使用）
更换 IP API 地址，请在使用前配置

### TG_BOT_TOKEN（Telegram 机器人密钥）
请使用 @BotFather 创建新机器人

### TG_CHATID（Telegram 推送接收者 ID）
您可以发送 /me 给 @luxiaoxun_bot 来获取个人 Telegram ID

## 最后更新
版本：2.2（Lite 版仅提供 2.1 Lite）

日期：2021年10月15日

## 联系
Telegram: https://t.me/AS56040

Telegram 频道: https://t.me/gangzai
