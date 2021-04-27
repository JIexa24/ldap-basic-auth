dofile "/lua/creditinals.lua"
dofile "/lua/resolver.lua"

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

lualdap = require "lualdap"
local function ldap_sing_in(username, password)
  local who = login_prefix..username..','..base
  local ld = lualdap.open_simple(ldap_host..':'..ldap_port,
  who, password, ldap_tls)
  local auth = false
  
  if not ld then
    ngx.log(ngx.ERR, "Cannot bind to ldap")
    return auth
  end
  
  search_result = ld:search({ base = base, filter = "("..filter_prefix..username..filter_suffix..")", scope = "subtree"})
  for dn, attribs in search_result do
    auth = true
  end
  return auth
end

local function simple_sing_in(username, password)
  local auth_file = io.open(passwd_file, "r")
  for line in io.lines(passwd_file) do
    if line == username..":"..ngx.md5(password) then
        auth_file:close()
        return true
    end
  end
  auth_file:close()
  return false
end

local function sign_in(username, password)
  -- Authentication order
  local is_auth = false
  is_auth = simple_sing_in(username, password)
  if is_auth then
    return is_auth
  end
  is_auth = ldap_sing_in(username, password)
  if is_auth then
    return is_auth
  end
  return is_auth
end

ngx.req.read_body()
local args, err = ngx.req.get_post_args()
local username
local password
if args then
  for key, val in pairs(args) do
    if key == "username" then
      username = val
    elseif key == "password" then
      password = val
    end
  end
end

local is_auth = sign_in(username, password)
if not is_auth then
  return ngx.redirect(ngx.var.request_uri, 302)
end

if username == nil or username == ngx.null or username == "" or password == nil or password == ngx.null or password == "" then
  return ngx.redirect(ngx.var.request_uri, 302)
end

local redis_addr = redis_host
if resolver_needed then
  redis_addr = resolver(redis_host, dns_server)
end

if redis_addr == nil then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
end

local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(redis_timeout)
local redis_not_connected = true

if resolver_needed then
  for i, ans in ipairs(redis_addr) do
    local ok, err = red:connect(ans.address, redis_port)
    if err == nil then
      redis_not_connected = false
      break
    end
    ngx.log(ngx.ERR, "Redis connect error to "..ans.address)
  end
else
  local ok, err = red:connect(redis_addr, redis_port)
  if err == nil then
    redis_not_connected = false
  end
end

if redis_not_connected then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.log(ngx.ERR, "Redis connect error")
  return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
end

-- Generate UUID for session
local session_key = ""
while true do
  session_key = uuid()
  local data, err = red:get(cookie_key_str.."_"..session_key)
  if err then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
  end

  local key_exist = "true"
  if data == nil or data == ngx.null then
    key_exist = "false"
  end
  if key_exist == "false" then
    break
  end
end

local key = cookie_key_str.."_"..session_key
red:set(key, username)
red:expire(key, session_expire)
ngx.var[user_var] = username 

ngx.header["Set-Cookie"] = {
  cookie_key_str.."="..session_key..";path=/; Expires="..ngx.cookie_time(ngx.time() + session_expire),
  cookie_str.."="..username..";path=/; Expires="..ngx.cookie_time(ngx.time() + session_expire)
}

ngx.redirect("/", 302)