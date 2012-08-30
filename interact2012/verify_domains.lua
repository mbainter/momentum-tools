require("msys.core");
require("msys.threadpool");
require("msys.extended.message");

local mod = {};

function mod:validate_rcptto(msg, rcptto_string, ac, vctx)
  local domain = msg:context_get(msys.core.ECMESS_CTX_MESS, "rcptto_domain");
  local status, result = msys.runInPool("DNS", 
           function()
             local results, err = msys.dnsLookup(domain, "MX");
             if !results and err == "NXDOMAIN" then
               return false;
             end

             return true;
           end);

  if status and !result then
    msg:context_set(msys.core.ECMESS_CTX_MESS, "bad_domain_" .. domain, "true");
  end

  return msys.core.VALIDATE_CONT;
end

msys.registerModule("verify_domains", mod);
