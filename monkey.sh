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
        exit 0
    else
        echo "" > $SESSION
    fi
    if (($MODE >= 1 && $MODE <= 5)); then
        echo -e "Automatic Stream Unlock Monitor Monkey 2.1\n"
        Test
    else
        echo "Undefined Mode!"
        exit 0
    fi
}

function Test {
    if [[ $MODE -eq 4 ]]; then
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
        if [[ $MODE -eq 4 ]]; then
            tmpresult=$(curl --interface $WGName -4 -sS -H "Accept-Language: en" "https://www.youtube.com/premium" 2>&1 )
        else
            tmpresult=$(curl -4 -sS -H "Accept-Language: en" "https://www.youtube.com/premium" 2>&1 )
        fi
        isCN=$(echo $tmpresult | grep 'www.google.cn')
            if [ -n "$isCN" ]; then
                Google="CN"
            else	
                Google="US"
            fi
    fi
    echo "Netflix Result: $NetflixResult"
    echo "Google Result: $Google"
    if [[ "$Netflix" == "404" ]] || [[ "$Netflix" == "403" ]] || [[ "$Netflix" == "000" ]] || [[ "$Google" == "CN" ]]; then
        ChangeIP
    else
        if [[ $COUNT -eq 0 ]]; then
            echo "No error found. Exiting..."
            rm -rf /usr/local/bin/.netflix_session
            exit 0
        else
            if [[ $DNSmasq -eq 1 ]]; then
                ChangeDNS
            fi
            SendMsg
            echo "Changing IP successed. Exiting..."
            rm -rf /usr/local/bin/.netflix_session
            exit 0
        fi
    fi
}

function ChangeIP {
    echo "Trying to change IP... Count: $COUNT"
    let COUNT++
    if [[ $MODE -eq 1 ]]; then
        dhclient -r -v >/dev/null 2>&1
        rm -rf /var/lib/dhcp/dhclient*
        ps aux | grep dhclient | grep -v grep | awk -F ' ' '{print $2}' | xargs kill -9 2>/dev/null
        sleep 5s
        dhclient -v >/dev/null 2>&1
        sleep 5s
        Test
    elif [[ $MODE -eq 2 ]]; then
        curl $API > /dev/null 2>&1
        sleep 10s
        Test
    elif [[ $MODE -eq 3 ]]; then
        Cookie=$(curl -ifsSL $'$SYMAPI' 2>&1 | grep -o PHPSESSID=[0-9a-z]*)
        curl $'$SYMAPI' -H 'Cookie: '$Cookie > /dev/null 2>&1
        sleep 10s
        Test
    elif [[ $MODE -eq 4 ]]; then
        wg-quick down $WGName >/dev/null 2>&1
        sleep 5s
        wg-quick up $WGName >/dev/null 2>&1
        Test
    elif [[ $MODE -eq 5 ]]; then
        SendMsg
        curl $API > /dev/null 2>&1
    fi
}
function ChangeDNS {
    PresentIP=$(curl -4 -fsL http://ip.sb)
    sed -ri "s/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/\/$PresentIP/g" /etc/dnsmasq.d/custom_netflix.conf
    systemctl restart dnsmasq
}

function SendMsg {
    echo "Sending Telegram Message..."
    curl -s "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHATID&text=%E3%80%90%E7%8C%B4%E5%AD%90+2.1%E3%80%91$NAME+%E4%B9%8B+Netflix%2FGoogle+%E8%A7%A3%E9%8E%96%E5%B7%B2%E5%A4%B1%E6%95%88%EF%BC%8C%E7%9B%AE%E5%89%8D%E5%B7%B2%E5%AE%8C%E6%88%90%E6%9B%B4%E6%8F%9B+IPv4+%E5%9C%B0%E5%9D%80%28%E5%B0%9D%E8%AF%95%E6%AC%A1%E6%95%B0%EF%BC%9A$COUNT%EF%BC%89" >/dev/null 2>&1
}

Initialize
