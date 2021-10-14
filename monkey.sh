
#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

NAME="localhost"
MODE=1
DNSmasq=0
WGName="wgcf"
API="http://10.192.93.10/changeip/changeip.aspx"
SYMAPI="https://sym.moe/ddns/ip.php?apikey=apikey&hostname=vmid"
TG_BOT_TOKEN=1145141919:xxxxxxxxxxxxxxxxxxxxxxxxxxxx
TG_CHATID=-1145141919810

COUNT=0
SESSION=/usr/local/bin/.netflix_session
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Initialize {
    if [ -f $SESSION ]; then
        echo "Session file found. Terminating..."
        break
    else
        echo "" > $SESSION
    fi
    if (($MODE >= 1 && $MODE <= 5)); then
        echo -e "Automatic Stream Unlock Monitor Monkey 2.1\n"
        Test
    else
        echo "Undefined Mode!"
        break
    fi
}

function Test {
    if [ $MODE -eq 4]; then
        echo "Detecting Netflix Unlock..."        
        Netflix=$(curl --interface $WGName --user-agent "${UA_Browser}" -4 -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://www.netflix.com/title/70143836" 2>&1)
        echo "Detecting Google Location..."
        Google=$(curl --interface $WGName --user-agent "${UA_Browser}" -4 -sL --max-time 10 "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4)
    else
        echo "Detecting Netflix Unlock..."        
        Netflix=$(curl --user-agent "${UA_Browser}" -4 -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://www.netflix.com/title/70143836" 2>&1)
        echo "Detecting Google Location..."
        Google=$(curl --user-agent "${UA_Browser}" -4 -sL --max-time 10 "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4)
    fi
    Analyse
}

function Analyse {
    if [[ "$Netflix" == "404" ]]; then
        NetflixResult="Originals Only"
    elif [[ "$Netflix" == "403" ]]; then
        NetflixResult="Banned"
    elif [[ "$Netflix" == "000" ]]; then
        NetflixResult="Network Error"
    elif [[ "$Netflix" == "200" ]]; then
        NetflixResult="Normal"
    else
        NetflixResult="Error"
    fi
    if [[ "$Google" == "" ]]; then
        Google="CN"
    fi
    echo "Netflix Result: $NetflixResult"
    echo "Google Result: $Google"
    if [[ "$Netflix" == "404" ]] || [[ "$Netflix" == "403" ]] || [[ "$Netflix" == "000" ]] || [[ "$Google" == "CN" ]]; then
        ChangeIP
    else
        if [[ $COUNT == 0 ]]; then
            echo "No error found. Exiting..."
            rm -rf /usr/local/bin/.netflix_session
        else
            if [ $DNSmasq -eq 1 ]; then
                ChangeDNS
            fi
            SendMsg
            rm -rf /usr/local/bin/.netflix_session
            echo "Changing IP successed. Exiting..."
        fi
    fi
}

function ChangeIP {
    echo "Trying to change IP..."
    let COUNT++
    if [ $MODE -eq 1 ]; then
        dhclient -r -v >/dev/null 2>&1
        rm -rf /var/lib/dhcp/dhclient*
        ps aux | grep dhclient | grep -v grep | awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
        sleep 5s
        dhclient -v >/dev/null 2>&1
        sleep 5s
        Test
    elif [ $MODE -eq 2 ]; then
        curl $API > /dev/null 2>&1
        sleep 10s
        Test
    elif [ $MODE -eq 3 ]; then
        Cookie=$(curl -ifsSL $'$SYMAPI' 2>&1 | grep -o PHPSESSID=[0-9a-z]*)
        curl $'$SYMAPI' -H 'Cookie: '$Cookie > /dev/null 2>&1
        sleep 10s
        Test
    elif [ $MODE -eq 4 ]; then
        wg-quick down $WGName >/dev/null 2>&1
        sleep 5s
        wg-quick up $WGName >/dev/null 2>&1
        Test
    elif [ $MODE -eq 5 ]; then
        SendMsg
        curl $API > /dev/null 2>&1
}
function ChangeDNS {
    sed -ri "s/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/\/$PresentIP/g" /etc/dnsmasq.d/custom_netflix.conf
    systemctl restart dnsmasq
}

function SendMsg {
    echo "Sending Telegram Message..."
    curl -s "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHATID&text=%E3%80%90%E7%8C%B4%E5%AD%90+2.0%E3%80%91$NAME+%E4%B9%8B+Netflix%2FGoogle+%E8%A7%A3%E9%8E%96%E5%B7%B2%E5%A4%B1%E6%95%88%EF%BC%8C%E7%9B%AE%E5%89%8D%E5%B7%B2%E5%AE%8C%E6%88%90%E6%9B%B4%E6%8F%9B+IPv4+%E5%9C%B0%E5%9D%80" >/dev/null 2>&1
}

Initialize
