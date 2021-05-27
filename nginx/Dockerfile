FROM alpine as builder

LABEL Author="Alexey Romanuta"

ENV LANG=en_US.UTF-8 \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    NGINX_VERSION=1.20.1 \
    NGINX_VTS_MODULE_VERSION=0.1.18 \
    NGX_DEVEL_KIT_VERSION=0.3.1 \
    LUA_NGINX_MODULE_VERSION=0.10.19 \
    RESTY_CORE_VERSION=0.1.21  \
    LUAJIT_VERSION=2.1-20210510 \
    RESTY_LRUCACHE_VERSION=0.10 \
    RESTY_REDIS_VERSION=0.29 \
    RESTY_DNS_VERSION=0.21 \
    LUA_LDAP_VERSION=1.2.6 \
    LUA_VERSION=5.1
    
RUN addgroup -S nginx \
	  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
		mkdir -p /var/lib/nginx && chown nginx:nginx /var/lib/nginx

RUN CONFIG="\
    #  --with-cc-opt='-g -O2 -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
     --with-ld-opt='-Wl,-rpath,/usr/lib' \
     --prefix=/usr/share/nginx \
     --conf-path=/etc/nginx/nginx.conf \
     --http-log-path=/var/log/nginx/access.log \
     --error-log-path=/var/log/nginx/error.log \
     --lock-path=/var/lock/nginx.lock \
     --pid-path=/run/nginx.pid \
     --modules-path=/usr/share/nginx/modules \
     --http-client-body-temp-path=/var/lib/nginx/body \
     --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
     --http-proxy-temp-path=/var/lib/nginx/proxy \
     --http-scgi-temp-path=/var/lib/nginx/scgi \
     --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
     --with-debug \
     --with-pcre-jit \
     --with-http_ssl_module \
     --with-http_stub_status_module \
     --with-http_realip_module \
     --with-http_auth_request_module \
     --with-http_v2_module \
     --with-http_dav_module \
     --with-http_slice_module \
     --with-threads \
     --with-http_addition_module \
     --with-http_geoip_module=dynamic \
     --with-http_gunzip_module \
     --with-http_gzip_static_module \
     --with-http_image_filter_module=dynamic \
     --with-http_sub_module \
     --with-http_xslt_module=dynamic \
     --with-stream=dynamic \
     --with-stream_ssl_module \
     --with-stream_ssl_preread_module \
     --with-mail=dynamic \
     --with-mail_ssl_module \
	   --add-module=/tmp/nginx-module-vts-${NGINX_VTS_MODULE_VERSION} \
	   --add-dynamic-module=/tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
    " && \
	apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		geoip-dev \
		gd-dev \
		libxslt-dev \
		# luajit-dev \
	&& curl -fSL https://github.com/openresty/luajit2/archive/v${LUAJIT_VERSION}.tar.gz -o /tmp/luajt.tar.gz \
	&& tar -xvf /tmp/luajt.tar.gz -C /tmp \
	&& cd /tmp/luajit2-${LUAJIT_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& curl -fSL https://github.com/openresty/lua-resty-core/archive/v${RESTY_CORE_VERSION}.tar.gz -o /tmp/lua-resty-core.tar.gz \
	&& tar -xvf /tmp/lua-resty-core.tar.gz -C /tmp \
	&& cd /tmp/lua-resty-core-${RESTY_CORE_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& curl -fSL https://github.com/openresty/lua-resty-lrucache/archive/v${RESTY_LRUCACHE_VERSION}.tar.gz -o /tmp/lua-resty-lrucache.tar.gz \
	&& tar -xvf /tmp/lua-resty-lrucache.tar.gz -C /tmp \
	&& cd /tmp/lua-resty-lrucache-${RESTY_LRUCACHE_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& curl -fSL https://github.com/openresty/lua-resty-redis/archive/v${RESTY_REDIS_VERSION}.tar.gz -o /tmp/lua-resty-redis.tar.gz \
	&& tar -xvf /tmp/lua-resty-redis.tar.gz -C /tmp \
	&& cd /tmp/lua-resty-redis-${RESTY_REDIS_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& ln -s /usr/local/include/luajit-2.1/lua.h /usr/include/ \
	&& ln -s /usr/local/include/luajit-2.1/lualib.h /usr/include/ \
	&& ln -s /usr/local/include/luajit-2.1/lauxlib.h /usr/include/ \
	&& ln -s /usr/local/include/luajit-2.1/luaconf.h /usr/include/ \
	&& ln -s /usr/local/include/luajit-2.1/lua.hpp /usr/include/ \
	&& ln -s /usr/local/include/luajit-2.1/luajit.h /usr/include/ \
	&& apk add --no-cache libldap openldap-dev \ 
	&& curl -fSL https://github.com/lualdap/lualdap/archive/refs/tags/v${LUA_LDAP_VERSION}.tar.gz -o /tmp/lualdap.tar.gz \
	&& tar -xvf /tmp/lualdap.tar.gz -C /tmp \
	&& cd /tmp/lualdap-${LUA_LDAP_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& curl -fSL https://github.com/openresty/lua-resty-dns/archive/v${RESTY_DNS_VERSION}.tar.gz -o /tmp/lua-resty-dns.tar.gz \
	&& tar -xvf /tmp/lua-resty-dns.tar.gz -C /tmp \
	&& cd /tmp/lua-resty-dns-${RESTY_DNS_VERSION} \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& curl -fSL https://github.com/vozlt/nginx-module-vts/archive/v${NGINX_VTS_MODULE_VERSION}.tar.gz -o /tmp/nginx-module-vts.tar.gz \
	&& tar -xvf /tmp/nginx-module-vts.tar.gz -C /tmp \
	&& cd /tmp/nginx-module-vts-${NGINX_VTS_MODULE_VERSION} \
	# && ldconfig \
	&& export LUAJIT_LIB=/usr/local/lib \
	&& export LUAJIT_INC=/usr/local/include/luajit-2.1 \
	&& curl -fSL https://github.com/vision5/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz -o /tmp/ndk.tar.gz \
	&& tar -xvf /tmp/ndk.tar.gz -C /tmp \
	&& curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz -o /tmp/lua-nginx.tar.gz \
	&& tar -xvf /tmp/lua-nginx.tar.gz -C /tmp \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc \
	# && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -rf nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& rm nginx.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx /usr/sbin/nginx \
	&& ln -s /usr/share/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/share/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	&& rm -f /tmp/ndk.tar.gz \
	&& rm -rf /tmp/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
	&& rm -f /tmp/lua-nginx.tar.gz \
	&& rm -rf /tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
	&& rm -f /tmp/luajt.tar.gz \
	&& rm -rf /tmp/luajt2-${LUAJIT_VERSION} \
	&& rm -f /tmp/lua-resty-core.tar.gz \
	&& rm -rf /tmp/lua-resty-core-${RESTY_CORE_VERSION} \
	&& rm -f /tmp/lua-resty-lrucache.tar.gz \
	&& rm -rf /tmp/lua-resty-lrucache-${RESTY_LRUCACHE_VERSION} \
	&& rm -f /tmp/lua-resty-redis.tar.gz \
	&& rm -rf /tmp/lua-resty-redis-${RESTY_REDIS_VERSION} \
	&& rm -f /tmp/lua-resty-dns.tar.gz \
	&& rm -rf /tmp/lua-resty-dns-${RESTY_DNS_VERSION} \
	&& rm -f /tmp/lualdap.tar.gz \
	&& rm -rf /tmp/lualdap-${LUA_LDAP_VERSION} \
	&& rm -f /tmp/nginx-module-vts.tar.gz \
	&& rm -rf /tmp/nginx-module-vts-${NGINX_VTS_MODULE_VERSION} \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps libgcc $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
  && ln -s /usr/lib/lua/lualdap.so /usr/local/lib/lua/${LUA_VERSION}/

EXPOSE 80 443

ADD nginx.conf /etc/nginx/nginx.conf
ADD lua /lua

CMD ["nginx", "-g", "daemon off;"]