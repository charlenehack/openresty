#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export LANG="en_US.UTF-8"
export LANG="zh_CN.UTF-8"
#openresty安装脚本

plain='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cur_dir=`pwd`
ngx_dir='/usr/local/openresty/nginx'
ups_dir='/usr/local/openresty/lualib/resty/upstream'
cpu=`cat /proc/cpuinfo | grep processor | wc -l`
zlibv='1.3.1'
pcrev='8.45'
sslv='w'
jitv='2.0.5'
restyv='1.27.1.1'
nginxv='1.27.1'

function yum_install() {
    echo -e "当前路径${cur_dir}"
    #yum -y -q -e 0 update
    yum -y -q -e 0 install tar wget curl zlib zlib-devel pcre pcre-devel openssl openssl-devel nss nss-devel gcc gcc-c++ make lua lua-devel luajit luarocks
}

function res_zlib() {
    [ ! -f zlib-${zlibv}.tar.gz ] && wget -q --no-check-certificate https://zlib.net/zlib-${zlibv}.tar.gz -O zlib-${zlibv}.tar.gz > /dev/null
    [ -f zlib-${zlibv}.tar.gz ] && tar zxf zlib-${zlibv}.tar.gz
}
function res_pcre() {
    [ ! -f pcre-${pcrev}.tar.gz ] && wget -q --no-check-certificate https://cfhcable.dl.sourceforge.net/project/pcre/pcre/${pcrev}/pcre-${pcrev}.tar.gz -O pcre-${pcrev}.tar.gz >/dev/null
    [ -f pcre-${pcrev}.tar.gz ] && tar zxf pcre-${pcrev}.tar.gz
}
function res_openssl() {
    #https://openssl.org/source/old/1.1.1/openssl-1.1.1w.tar.gz
    #https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
    #https://kkgithub.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
    #https://cdn.jsdelivr.net/gh/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
    #https://gcore.jsdelivr.net/gh/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
    #https://fastly.jsdelivr.net/gh/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
    [ ! -f openssl-1.1.1${sslv}.tar.gz ] && wget -q --no-check-certificate https://kkgithub.com/openssl/openssl/releases/download/OpenSSL_1_1_1${sslv}/openssl-1.1.1${sslv}.tar.gz -O openssl-1.1.1${sslv}.tar.gz > /dev/null
    [ -f openssl-1.1.1${sslv}.tar.gz ] && tar zxf openssl-1.1.1${sslv}.tar.gz
}

function openresty_install() {
    [ ! -f openresty-${restyv}.tar.gz ] && wget -q --no-check-certificate https://openresty.org/download/openresty-${restyv}.tar.gz -O openresty-${restyv}.tar.gz >/dev/null ###2>&1
    [ -f openresty-${restyv}.tar.gz ] && tar zxf openresty-${restyv}.tar.gz && cd openresty-${restyv}
    if [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *CentOS*Linux* ]] ;then
	    echo -e "CentOS openresty configure"
        ./configure --prefix=/usr/local/openresty --with-debug --with-threads --with-luajit --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-select_module --with-http_v2_module --with-http_sub_module --with-http_stub_status_module --with-http_realip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_ssl_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-openssl=../openssl-1.1.1${sslv} --with-zlib=../zlib-${zlibv} --with-pcre=../pcre-${pcrev} --with-pcre-jit >/dev/null
    fi
    if [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *openEuler* ]] ;then
	    echo -e "OpenEuler openresty configure"
        ./configure --prefix=/usr/local/openresty --with-debug --with-threads --with-luajit --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-select_module --with-http_v2_module --with-http_sub_module --with-http_stub_status_module --with-http_realip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_ssl_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-pcre-jit >/dev/null
    fi

    sed -i '0,/512/s/512/40960/' bundle/nginx-${nginxv}/src/os/unix/ngx_process_cycle.c
    grep 40960 bundle/nginx-${nginxv}/src/os/unix/ngx_process_cycle.c
    sed -i '0,/NGX_LISTEN_BACKLOG/s/511/65535/' bundle/nginx-${nginxv}/src/os/unix/ngx_linux_config.h
    sed -i '0,/NGX_LISTEN_BACKLOG/s/511/65535/' bundle/nginx-${nginxv}/src/os/unix/ngx_posix_config.h
    sed -i '0,/NGX_LISTEN_BACKLOG/s/511/65535/' bundle/nginx-${nginxv}/src/os/unix/ngx_solaris_config.h
    grep 65535 bundle/nginx-${nginxv}/src/os/unix/ngx_*_config.h

    if [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *CentOS*Linux* ]] ;then
	    echo -e "CentOS openresty make"
        make >/dev/null
        make install >/dev/null
    fi
    if [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *openEuler* ]] ;then
	    echo -e "OpenEuler openresty make"
        make -j${cpu}>/dev/null
        make install >/dev/null
    fi

    /usr/local/openresty/nginx/sbin/nginx -V
}

function luarocks_install() {
    cd ..
    luarocks install luasec > /dev/null
    luarocks install lrexlib-pcre > /dev/null
    luarocks install lua-cjson > /dev/null
    luarocks install lua-resty-http > /dev/null
    luarocks install luafilesystem > /dev/null
    luarocks install luasocket > /dev/null
    luarocks list
}

function remove_res() {
    cd ${cur_dir}
    echo -e "当前路径${cur_dir}"
    [ -d zlib-${zlibv} ] && rm -rf zlib-${zlibv}
    [ -d pcre-${pcrev} ] && rm -rf pcre-${pcrev}
    [ -d openssl-1.1.1${sslv} ] && rm -rf openssl-1.1.1${sslv}
    [ -d openresty-${restyv} ] && rm -f openresty-${restyv}
    [ -f zlib-${zlibv}.tar.gz ] && rm -f zlib-${zlibv}.tar.gz
    [ -f pcre-${pcrev}.tar.gz ] && rm -f pcre-${pcrev}.tar.gz
    [ -f openssl-1.1.1${sslv}.tar.gz ] && rm -f openssl-1.1.1${sslv}.tar.gz
    [ -f openresty-${restyv}.tar.gz ] && rm -f openresty-${restyv}.tar.gz
}

function ngdir_chmod() {
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
    chown -R yzj:yzj /usr/local/openresty/nginx/conf && chmod -R 755 /usr/local/openresty/nginx/conf
}

function run_install() {
    yum_install
    if [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *CentOS*Linux* ]] ;then
	    echo -e "CentOS Install"
        res_zlib
        res_pcre
        res_openssl
    elif [[ "$(cat /etc/os-release | grep -i 'NAME=')" == *openEuler* ]] ;then
	    echo -e "OpenEuler Install"
	fi
    openresty_install
    luarocks_install
    remove_res
    ngdir_chmod
    ls -lhtr / | grep kingdee && echo -e "\n" && ls -lhtr /kingdee | sed -n '2,$p' && echo -e "\n" && ls -lhtr /usr/local/openresty/nginx | sed -n '2,$p' && echo -e "\n"
}

run_install 2>&1 | tee -a install_openresty.log

exit 0
