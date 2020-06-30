require "bit"

-- Change this to the IP of the probe station
local _defaultIp = "127.0.0.1"
local _defaultPort = 35555
local _socket = nil

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function open_socket(ip, port)
  if (ip==nil) then
    ip = _defaultIp
  end
  
  if (port==nil) then
    port = _defaultPort
  end
  
  local s = socket.tcp()
  print("Opening Probe Station Connection: "..ip..":"..port)  
  s:setoption("tcp-nodelay", true)
  s:connect(ip, port);
  s:settimeout(200)
  
  _socket = s
  
  return s
end

-- Close the socket again
function close_socket(s)
  print("Closing Probe Station Connection")
  if (s~=nil) then
    s:close()
  end
end

function send(cmd)
  _socket:send(cmd .. "\r\n")
end

function send_cmd(cmd, verbose)
  if (verbose) then
    print(cmd);
  end
  
  _socket:send(cmd .. "\r\n")
  return get_resp(_socket, verbose)
end

function vsend_cmd(cmd, abort) 
  _socket:send(cmd .. "\r\n")
  
  err, stat, cid, msg = get_resp(_socket, verbose)
  if (err~=0 and err~=11) then
      print(string.format("\"%s\" execution failed. (Code=%d; Message=%s)",cmd, err, msg))
      if (abort~=nil and abort==true) then
        os.exit(-1)
      end  
  end
  
  return err, stat, cid, msg
end

function receive()
  return _socket:receive();
end

function get_resp(s, verbose)
  local str = s:receive();
  if (verbose) then
    print("received: "..str)
  end
  
  local resp, cdi, msg;
  resp, cid, msg = str:match('(%d+)[%s]*,[%s]*(%d+)[%s]*,[%s]*(.*)')
  
  -- extract status flags from the response
  local err  = bit.band(resp, 1023)          -- isolate the lowermost 10 bits
  local stat = bit.band(resp, bit.bnot(1023)) -- isolate the status bits
  
  -- print Status messages:
  local statmsg = "";
  if (stat~=0) then
    stat = bit.rshift(stat,10)
    if (bit.band(stat, 1)~=0) then
      statmsg = statmsg.."LastDie"
    end
  
    if (bit.band(stat, 2)~=0) then
      statmsg = statmsg.." LastSubSite"
    end
    
--    print("> status: "..statmsg);    
  end
  
  -- 0 is no error, 11 is end of route
  if (err~=0 and err~=11) then
    print("> errc="..err.."; status="..stat.."; cid="..cid..";  "..msg);
--    print("> Aborting script execution due to an error");  
--    os.exit(0);
  else
    if (verbose) then
      print("> errc="..err.."; status="..stat.."; cid="..cid..";  "..msg);
    end
  end
  
  return err, stat, cid, msg
end

function send_cmd_n(cmd)
  _socket:send(cmd .. "\r\n")
  return get_resp_nucleus(_socket)
end

function get_resp_nucleus(s) 
  local str = s:receive();
  
  local resp;
  resp = str 
  print("errc="..str);
  return resp
end


function vsend_cmd2(cmd, abort) 
  _socket:send(cmd .. "\r\n")
  
  msg = get_resp2(_socket, verbose)
  
  return msg
end
function get_resp2(s, verbose)
  local str = s:receive();
  if (verbose) then
    print("received: "..str)
  end
  
  
  return str
end