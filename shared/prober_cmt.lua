-- Change this to the IP of the probe station
local ip = "127.0.0.1"
local port = 35555
local _socket = nil

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function open_socket()
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

function send_cmd(cmd)
  _socket:send(cmd .. "\r\n")
  return get_resp(_socket)
end

function get_resp(s)
  local str = s:receive();
  print("received: \""..str.."\"")
  
  return str
end