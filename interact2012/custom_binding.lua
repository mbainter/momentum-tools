require("msys.core");
require("msys.db");
require("msys.datasource");
require("msys.extended.message");

local mod = {};

function mod:validate_set_binding(msg,accept,vctx)
  local xbind = msg:context_get(msys.core.ECMESS_CTX_MESS, "binding_group");
  local domain = msg:context_get(msys.core.ECMESS_CTX_MESS, "mailfrom_domain");

  if xbind == nil or xbind == "" then
    xbind = unpack(msg:header("X-Binding"));
    if xbind ~= nil then
      msg:context_set(msys.core.ECMESS_CTX_MESS, "binding_group", xbind);
    else
      local etype = msg:context_get(msys.core.ECMESS_CTX_MESS, "etype");
      local result, err = msys.db.query("bindingsdb", 
        "SELECT binding_group from bindingmap WHERE etype=? AND sender LIKE ?", 
        {etype, "%@" .. domain}, 
        {raise_error = false});

      if result ~= nil then
        for row in result do
          if msg:binding_group(row.binding_group) ~= nil then
            msg:context_set(msys.core.ECMESS_CTX_MESS, "binding_group", row.binding_group);
            return msys.core.VALIDATE_CONT
          end
        end
      elseif err ~= nil then
        print("CustomBinding: Query Failed for " .. tostring(msg.id) .. "with: " .. err);
      end
    end
  end


  if xbind ~= nil then
    msg:binding_group(xbind)
  end
  
  return msys.core.VALIDATE_CONT;
end

msys.registerModule("custom_binding.lua", mod);
