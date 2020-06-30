print("TRex Test");

-- Change this to the IP of the probe station
local ip = "127.0.0.1"
local port = 35555


function open_socket()
  local s = socket.tcp()
  print("Opening Probe Station Connection: "..ip..":"..port)  
  s:setoption("tcp-nodelay", true)
  s:connect(ip, port);
  s:settimeout(200)
  return s
end


-- Close the socket again
function close_socket(s)
  print("Closing Probe Station Connection")
  if (s~=nil) then
    s:close()
  end
end


function get_resp(s)
  local str = s:receive()
  local n
  
  n   = string.find(str, ",")
  local serr = string.sub(str, 0, n-1)
   
  str = string.sub(str, n+1)
  n   = string.find(str, ",")
  local scid = string.sub(str, 0, n-1)
   
  local sremainder = string.sub(str, n+1)
  
  local err = tonumber(serr)
  local cid = tonumber(scid)
  local msg = sremainder
  
  print(serr.." : "..scid.." : "..msg)
  
  return err, cid, msg
end



function main()
  -- open the socket
  local s = open_socket()
  if (s==nil) then
    print("Can't open Socket")
    exit(-1)
  end

  local err, cid, msg
  
  --
  -- A simple script for stepping over all dies of a wafer 
  --
  -- Please  Note:
  --
  -- Stepping is only possible once you have set a chuck home position. This is something that has to be done 
  -- on the probe station and in the Demo mode. The demo mode is behaving exactly like a real machine. It will 
  -- not let you step without a chuck home position!
  -- 
  -- To set a home position for DEMO purposes (SENTIO 3.1):
  --   * Go to the vision module
  --   * open the Navigation Tab
  --   * In the side Panel press "Set Home" on the topmost element of the side panel (labelled "Set Contact")
  
  -- switch to MPI remote command set (Sentio may be set to a different command set)
  s:send("*RCS 1\r\n")
  
  -- select the wafermap module
  s:send("select_module map\r\n")
  err, cid, msg = get_resp(s)

  -- setup a wafer map
  s:send("map:create 200\r\n")
  err, cid, msg = get_resp(s)

  -- Set up the grid;  IndexSizeY, IndexSizeY, GridOffsetX, GridOffsetY, EdgeArea
  s:send("map:set_grid_params 5000, 5000, 0, 0, 4000\r\n")
  err, cid, msg = get_resp(s)
  
  -- Set the grid origin to lower left edge (coordinates relative to center die)
  s:send("map:set_grid_origin -20, -20\r\n")
  err, cid, msg = get_resp(s)
  
    -- Set The Home Die to center (relative to grid origin)
  s:send("map:set_home_die 20, 20\r\n")
  err, cid, msg = get_resp(s)
  
  s:send("map:set_axis_orient ur\r\n")
  err, cid, msg = get_resp(s)
  
  -- select good dies for testing
  s:send("map:path:select_dies g\r\n")  
  err, cid, msg = get_resp(s)

  s:send("map:step_first_die\r\n")  
  err, cid, msg = get_resp(s)

  local running = true
  while running do
    print("Step next die")
    s:send(string.format("map:bin_step_next_die %d\r\n", math.random()*5))  
    err, cid, msg = get_resp(s)
    if (err~=0) then
      running = false
    end
  end

  close_socket(s)
end

main()