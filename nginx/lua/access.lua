dofile "/lua/creditinals.lua"
dofile "/lua/resolver.lua"

local redis_addr = redis_host
if resolver_needed then
  redis_addr = resolver(redis_host, dns_server)
end

if redis_addr == nil then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.exit(ngx.OK)
end

local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(redis_timeout) -- 5 sec
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
  ngx.exit(ngx.OK)
end

local session_key = ngx.var['cookie_'..cookie_key_str]
if session_key == nil then
  ngx.log(ngx.ERR, "Nil session key")
  return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
end

local key = cookie_key_str.."_"..session_key
local username, err = red:get(key)
if err then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.log(ngx.ERR, "Redis error: Cannot get session by key")
  ngx.exit(ngx.OK)
end

local name_not_equal = true
if ngx.var[user_var] == username then
  name_not_equal = false
end

if name_not_equal then
  ngx.log(ngx.ERR, "Name does not match with session")
  -- ngx.log(ngx.ERR, "Username: "..username.." uservar: "..ngx.var[user_var])
  return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
end

if username == nil or username == ngx.null or username == "" or ngx.var[user_var] == "unknown" then
  -- ngx.log(ngx.ERR, "Username: "..username.." uservar: "..ngx.var[user_var])
  ngx.log(ngx.ERR, "Username possible is nil")
  return ngx.redirect(auth_location.."?uri="..ngx.var.request_uri, 302)
end

red:expire(key, session_expire)

ngx.header["Set-Cookie"] = {
  cookie_key_str.."="..session_key..";path=/; Expires="..ngx.cookie_time(ngx.time() + session_expire),
  cookie_str.."="..username..";path=/; Expires="..ngx.cookie_time(ngx.time() + session_expire)
}

return