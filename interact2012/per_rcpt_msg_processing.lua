require("msys.core");
require("msys.extended.message");

local mod = {};

function split_address(addr)
  local t = {};

  for part in addr:gmatch("([^@]+)") do
    table.insert(t, part); 
  end

  return t;
end

function mod:validate_data_spool_each_rcpt(msg,accept,vctx)
  local etype = msg:context_get(msys.core.ECMESS_CTX_MESS, "etype");
  local hval = unpack(msg:header("list-unsubscribe"));
  local rcpt = "";
  local t = {};

  t = split_address(msg:rcptto());
  rcpt = t[1] .. "=" .. t[2];
  
  t = split_address(msg:mailfrom());

  msg:context_set(msys.core.ECMESS_CTX_MESS, "mailfrom_localpart", t[1] .. "-" .. rcpt);

  msg:mailfrom(t[1] .. "-" .. rcpt .. "@" .. t[2]);
  msg:header("Return-Path", "<" .. t[1] .. "-" .. rcpt .. "@" .. t[2] .. ">");

  if hval == nil then
    local unsub = "<mailto:unsub-" .. etype .. "-" .. rcpt ..
            "@unsub.acme.com?subject=Unsubscribe>";
    msg:header("list-unsubscribe", unsub);
  end

  return msys.core.VALIDATE_CONT;
end

msys.registerModule("per_rcpt_msg_processing", mod);
