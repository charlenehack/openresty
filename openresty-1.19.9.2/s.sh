#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export LANG="en_US.UTF-8"
export LANG="zh_CN.UTF-8"
#nginx资源同步脚本

plain='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cur_dir=`pwd`
ngx_dir='/usr/local/openresty/nginx'
ups_dir='/usr/local/openresty/lualib/resty/upstream'

#exec_scp() {
    #(sshpass -p ${Pass} scp -qr -o "StrictHostKeyChecking no" ${User}@${IP}:/kingdee/www /kingdee && ls -alhtr /kingdee/www) || (echo -e "[${red}Error${plain}] 静态资源www同步失败")
    #(sshpass -p ${Pass} scp -qr -o "StrictHostKeyChecking no" ${User}@${IP}:/kingdee/static /kingdee && ls -alhtr /kingdee/static) || (echo -e "[${red}Error${plain}] 静态资源static同步失败")
    #(sshpass -p ${Pass} scp -qr -o "StrictHostKeyChecking no" ${User}@${IP}:/kingdee/kdinit /kingdee && ls -alhtr /kingdee/kdinit) || (echo -e "[${red}Error${plain}] 脚本资源kdinit同步失败")
    #(sshpass -p ${Pass} scp -qr -o "StrictHostKeyChecking no" ${User}@${IP}:${ngx_dir}/conf ${ngx_dir} && ls -alhtr ${ngx_dir}/conf) || (echo -e "[${red}Error${plain}] nginx配置同步失败")
    #[ -f ${ups_dir}/healthcheck.lua ] && mv ${ups_dir}/healthcheck.lua ${ups_dir}/healthcheck.lua.`date -d "today" +"%Y%m%d%H%M%S"`
    #(sshpass -p ${Pass} scp -qr -o "StrictHostKeyChecking no" ${User}@${IP}:${ups_dir}/healthcheck.lua ${ups_dir} && ls -alhtr ${ups_dir}) || (echo -e "[${red}Error${plain}] healthcheck.lua同步失败")
#}

exec_rsync() {
    (sshpass -p ${Pass} rsync -qarP -e "ssh -l ${User} -p 22 -o StrictHostKeyChecking=no" ${IP}:/kingdee/www /kingdee && ls -alhtr /kingdee/www) || (echo -e "[${red}Error${plain}] 静态资源www同步失败")
    (sshpass -p ${Pass} rsync -qarP -e "ssh -l ${User} -p 22 -o StrictHostKeyChecking=no" ${IP}:/kingdee/static /kingdee && ls -alhtr /kingdee/static) || (echo -e "[${red}Error${plain}] 静态资源static同步失败")
    (sshpass -p ${Pass} rsync -qarP -e "ssh -l ${User} -p 22 -o StrictHostKeyChecking=no" ${IP}:/kingdee/kdinit /kingdee && ls -alhtr /kingdee/kdinit) || (echo -e "[${red}Error${plain}] 脚本资源kdinit同步失败")
    (sshpass -p ${Pass} rsync -qarP -e "ssh -l ${User} -p 22 -o StrictHostKeyChecking=no" ${IP}:${ngx_dir}/conf ${ngx_dir} && ls -alhtr ${ngx_dir}/conf) || (echo -e "[${red}Error${plain}] nginx配置同步失败")
    [ -f ${ups_dir}/healthcheck.lua ] && mv ${ups_dir}/healthcheck.lua ${ups_dir}/healthcheck.lua.`md5sum ${ups_dir}/healthcheck.lua | awk '{print$1}'`
    (sshpass -p ${Pass} rsync -qarP -e "ssh -l ${User} -p 22 -o StrictHostKeyChecking=no" ${IP}:${ups_dir}/healthcheck.lua ${ups_dir} && ls -alhtr ${ups_dir}) || (echo -e "[${red}Error${plain}] healthcheck.lua同步失败")
    md5sum ${ups_dir}/healthcheck.lua
}

restart_nginx() {
    echo -e "[${green}Info${plain}] 即将重启nginx"
    [ -f ${ngx_dir}/conf/ops_conf.d/purge.conf ] && mv ${ngx_dir}/conf/ops_conf.d/purge.conf ${ngx_dir}/conf/ops_conf.d/purge.conf.`date -d "today" +"%Y%m%d%H%M%S"`
    [ -f ${ngx_dir}/conf/vhost.conf/ip_server.conf ] && mv ${ngx_dir}/conf/vhost.conf/ip_server.conf ${ngx_dir}/conf/vhost.conf/ip_server.conf.`date -d "today" +"%Y%m%d%H%M%S"`
    grep -qi '219.133.170.172' ${ngx_dir}/conf/ops_conf.d/ups_status.conf && sed -i "s/219.133.170.172/120.234.7.222/g" ${ngx_dir}/conf/ops_conf.d/ups_status.conf
    grep -qi '172.20.10.36' ${ngx_dir}/conf/ops_conf.d/ups_status.conf && sed -i "s/172.20.10.36/10.247.11.204/g" ${ngx_dir}/conf/ops_conf.d/ups_status.conf && sed -i "/10.247.11.204\;/a\    allow 172.22.31.250\;" ${ngx_dir}/conf/ops_conf.d/ups_status.conf
    grep -C 1 -i '10.247.11.204' -rn ${ngx_dir}/conf/ops_conf.d/ups_status.conf
    #sed -i "s/listen 443 ssl http2\;/listen 443 ssl\;/g" ${ngx_dir}/conf/nginx.conf
    #sed -i "/listen 443 ssl\;/a\         http2 on\;" ${ngx_dir}/conf/nginx.conf
    #grep -C 1 -i 'listen 443 ssl' -rn ${ngx_dir}/conf/nginx.conf
    #sed -i "s/listen 443 ssl http2\;/listen 443 ssl\;/g" ${ngx_dir}/conf/vhost.conf/*.conf
    #sed -i "/listen 443 ssl\;/a\         http2 on\;" ${ngx_dir}/conf/vhost.conf/*.conf
    #sed -i "s/listen 443 ssl http2\;/listen 443 ssl\;/g" ${ngx_dir}/conf/vhost.conf/cdn/*.conf
    #sed -i "/listen 443 ssl\;/a\         http2 on\;" ${ngx_dir}/conf/vhost.conf/cdn/*.conf
    #sed -i "s/listen 443 ssl http2\;/listen 443 ssl\;/g" ${ngx_dir}/conf/vhost.conf/yunzhijia.com/*.conf
    #sed -i "/listen 443 ssl\;/a\         http2 on\;" ${ngx_dir}/conf/vhost.conf/yunzhijia.com/*.conf
    #grep -C 1 -i 'listen 443 ssl' -rn ${ngx_dir}/conf/vhost.conf/*.conf
    #grep -qi 'lua_shared_dict limit 10m' ${ngx_dir}/conf/vhost.conf/lua.conf && sed -i "s/lua_shared_dict limit 10m/lua_shared_dict limit 64m/g" ${ngx_dir}/conf/vhost.conf/lua.conf
    #grep -C 1 -i 'lua_shared_dict' -rn ${ngx_dir}/conf/vhost.conf/lua.conf
    ${ngx_dir}/sbin/nginx -t && (ps -ef | grep nginx | grep -v grep && ${ngx_dir}/sbin/nginx -s stop && sleep 3); ${ngx_dir}/sbin/nginx && sleep 3 && echo -e "\n" && ps -ef | grep nginx
    grep -qi '/kingdee/kdinit/cutnginxlog.sh' /var/spool/cron/root || echo -e "0 0 * * * /bin/bash /kingdee/kdinit/cutnginxlog.sh >> /kingdee/nginxLog/cutnginxlog.log 2>&1" >>/var/spool/cron/root
    grep -Ev "^#" /var/spool/cron/root
    #pgrep nginx && pidof ${ngx_dir}/sbin/nginx
    systemctl stop postfix && systemctl disable postfix
    #systemctl stop rpcbind.socket && systemctl disable rpcbind.socket
}

chmod_755() {
    [[ ! -d /kingdee/nginxLog || ! -d /kingdee/nginxLog/hack ]] && mkdir -p /kingdee/nginxLog/hack
    [ ! -d /kingdee/kdinit ] && mkdir -p /kingdee/kdinit
    [ ! -d /kingdee/www ] && mkdir -p /kingdee/www
    [ ! -d /kingdee/static ] && mkdir -p /kingdee/static
    [[ ! -d /kingdee/cache || ! -d /kingdee/cache/path || ! -d /kingdee/cache/temp ]] && mkdir -p /kingdee/cache/path && mkdir -p /kingdee/cache/temp
	chown -R yzj:yzj /kingdee/nginxLog && chmod -R 755 /kingdee/nginxLog
    chown -R yzj:yzj /kingdee/kdinit && chmod -R 755 /kingdee/kdinit
    chown -R yzj:yzj /kingdee/www && chmod -R 755 /kingdee/www
    chown -R yzj:yzj /kingdee/static && chmod -R 755 /kingdee/static
    chown -R yzj:yzj /kingdee/cache && chmod -R 755 /kingdee/cache
    chown -R yzj:yzj ${ngx_dir}/conf && chmod -R 755 ${ngx_dir}/conf
}

sed_log() {
   sed -i '/XMK/d' /var/loginlog/*/*
   grep XMK -rn /var/loginlog/*
}

rsync_res() {
    #pam_tally2 --user=yzj && pam_tally2 --user=yzj --reset
    [ ! -f /usr/bin/sshpass ] && yum -y -q -e 0 install sshpass
    [ ! -f /usr/bin/rsync ] && yum -y -q -e 0 install rsync
    chmod_755
    exec_rsync
    restart_nginx
    sed_log
    ls -lhtr / | grep kingdee && echo -e "\n" && ls -lhtr /kingdee | sed -n '2,$p' && echo -e "\n" && ls -lhtr ${ngx_dir} | sed -n '2,$p' && echo -e "\n"
}

if [[ -n "$1" && -n "$2" && -n "$3" ]] ;then
    echo -e "[${green}Info${plain}] 开始同步静态资源${plain}"
    if [[ "$1" == "10.247"* && "$2" == "yzj" && -n "$3" ]] ;then
        IP="$1"
        User="$2"
        Pass="XMKuai@2064"
        rsync_res 2>&1 | tee -a rsync_res.log
    fi
else
    echo -e "参数错误，格式为："
    echo -e "$0 IP User Password"
fi

exit 0
