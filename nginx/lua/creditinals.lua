-- View parameters.
title = "Test Authentication"
favicon_tag='<link rel="shortcut icon" href="/favicon.ico">'

-- Cookie parameters.
cookie_str = "q_user"
cookie_key_str = cookie_str.."_session"

-- Authentication location.
auth_location = "/auth"

dns_server = "10.96.0.10"
resolver_needed = false
resolver_cache_time = 300

-- Redis parameters.
redis_host = "127.0.0.1"
redis_port = 6379
redis_timeout = 5000

-- Nginx user variable.
user_var = "q_user"

-- Session time
session_expire = 86400*3

-- Ldap parameters.
ldap_host = "ldap.domain.ru"
ldap_port = "389"
ldap_timeout = 5000
ldap_tls = false

-- Authentication prefix - login_prefix..username..','..base
login_prefix = "uid="
base = "ou=people,dc=domain,dc=ru"

-- "("..filter_prefix..username..filter_suffix..")"
filter_prefix = "uid="
filter_suffix = ""

-- Local passwords file.
passwd_file = "/etc/nginx/htpasswd"