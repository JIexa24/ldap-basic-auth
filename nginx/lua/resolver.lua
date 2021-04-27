
function resolver(dnsname, server) 
  local cache = ngx.shared.resolver_cache
  local entry = cache:get(dnsname)
  local expired = cache:get(dnsname.."expired")
  local cache_not_empty = true
  if entry == nil or expire == nil then
    cache_not_empty = false
  end
  if cache_not_empty then
    if expired < ngx.time() then
      return cache
    end
  end
  local resolver = require "resty.dns.resolver"
  local r, err = resolver:new{
    nameservers = {server},
    retrans = 5,  -- 5 retransmissions on receive timeout
    timeout = 2000,  -- 2 sec
  }
  
  if not r then
    ngx.log(ngx.ERR, "DNS: failed to instantiate the resolver")
    return nil
  end
  
  local redis_addr, err, tries = r:query(dnsname, { qtype = r.TYPE_A })
  if not redis_addr then
    ngx.log(ngx.ERR, "DNS: failed to query the DNS server")
    return nil
  end
  cache:set(dnsname, redis_addr)
  cache:set(dnsname.."expired", ngx.time() + resolver_cache_time)
  return redis_addr
end