# Сквозная LDAP + Local аутентификация

Структура репозитория:

Следующие папки являются универсальными и общими для всех ЭМ:
- nginx - Содержит докерфайл и nginx.conf для сборки веб сервера nginx с модулем lua (Используется для LDAP + Local аутентификации).

Приоритеты:
1. Local auth
2. LDAP auth

Работает в докере со следующими компонентами:
- Nginx + lua module  
  Сервер со сквозной проверкой на предмет аутентификации
- redis (может быть и вне докера)  
  Используется для хранения соответствия id сессии и имени пользователя

Список основных конфигурационных параметров для аутентификации находится в уникальном для проекта файле creditinals.lua.
Если локальная аутентификация не подтверждается, делается запрос в ldap по фильтру из переменной filter.
Если аутентификация успешна, ставится две cookie - одна с именем пользователя, другая с id сессии.
Вместе с cookie устанавливается ключ в redis с именем пользователя как значением.
Ключ состоит из имени сессионной cookie и id сессии.

При запросе через nginx, запрашивается ключ по id из сессионной cookie и если пользователь в значении совпадает с именем в cookie, показывается контент.
Если сессии в редисе нет/не совпадает имя пользователя или имя unknown - происходит редирект на страницу аутентификации.  
За аутентификацию отвечает скрипт auth.lua.  
За доступ к защищаемому контенту отвечает скрипт access.lua  

Что уникально для каждого приложения:
1. Конфигурация nginx
1. Файл для локальной аутентификации (passwd_file)
3. Файл creditinals.lua  

Основные параметры creditinals.lua скрипта:  
При доступе к redis по домену, необходимо установить параметры dns_server, resolver_needed  

```shell
-- View parameters.
title = "Test Authentication" -- Заголовок на странице аутентификации
favicon_tag='<link rel="shortcut icon" href="/favicon.ico">' -- тег для favicon, вставляется в title

-- Cookie parameters.
cookie_str = "q_user" -- Имя основной куки, содержит имя пользователя
cookie_key_str = cookie_str.."_session" -- Имя куки для сессии

-- Authentication location.
auth_location = "/auth" -- Локейшн страницы аутентификации

dns_server = "10.96.0.10" -- Адрес DNS сервера
resolver_needed = false -- Использовать DNS сервер
resolver_cache_time = 300 -- Кэш DNS запросов (Используется при повторном вызове резолвера)

-- Redis parameters.
redis_host = "127.0.0.1" -- Адрес redis сервера
redis_port = 6379 -- Порт redis сервера
redis_timeout = 5000 -- Таймаут подключения

-- Nginx user variable.
user_var = "cookie_str" -- Переменная с именем пользователя в конфиге Nginx 

-- Session time
session_expire = 86400*3 -- Время жизни сессии

-- Ldap parameters.
ldap_host = "ldap.domain.ru" -- Адрес ldap сервера
ldap_port = "389" -- Порт ldap сервера
ldap_timeout = 5000 -- Таймаут подключения
ldap_tls = false

-- Authentication prefix - login_prefix..username..','..base
login_prefix = "uid=" -- Префикс запроса на аутентификацию
base = "ou=people,dc=domain,dc=ru" -- Base запроса на аутентификацию

-- "("..filter_prefix..username..filter_suffix..")"
filter_prefix = "uid=" -- Префикс фильтра
filter_suffix = "" -- Суффикс фильтра

-- Local passwords file.
passwd_file = "/etc/nginx/htpasswd" -- Локальный файл с паролями (Пароль в виде хэша md5)
```