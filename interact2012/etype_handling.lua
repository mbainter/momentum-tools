require("msys.core");
require("msys.extended.message");

local mod = {};

function mod:validate_data_spool(msg,accept,vctx)
  local etype = unpack(msg:header("X-Etype"));
  local jobid = unpack(msg:header("X-JobID"));

  if jobid == nil or jobid == "" then
    print("Missing JobID for " .. tostring(msg.id));
    jobid = "";
  end

  -- Delete it, we no longer need it
  msg:header("X-JobID", "");

  -- If there's no etype we use 0 to stand for 'unknown'
  if(etype == nil) then
    etype = "0"
  end

  msg:context_set(msys.core.ECMESS_CTX_MESS, "etype", etype);
  msg:context_set(msys.core.ECMESS_CTX_MESS, "jobid", jobid);
  
  return msys.core.VALIDATE_CONT;
end

msys.registerModule("etype_handling", mod);
