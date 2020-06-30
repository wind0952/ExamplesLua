require "../shared/prober"

print("Sentio Wafermap Stepping Sample");

function main()
  -- open the socket
  local s = open_socket()
  if (s==nil) then
    print("Can't open Socket")
    exit(-1)
  end

  local err, cid, msg
  
    -- switch to MPI remote command set
  send("*RCS 1")
  
  -- select the wafermap module
  send_cmd("select_module wafermap")

  -- Create a 200 mm wafer map
  send_cmd("map:create 200")

  -- Set up a Flat at 180 Degrees, 10000 µm long
  send_cmd("map:set_flat_params 90, 50000")
  
  -- Set up the grid;  IndexSizeY, IndexSizeY, GridOffsetX, GridOffsetY, EdgeArea
  send_cmd("map:set_grid_params 5000, 5000, 0, 0, 4000")  
  
  
  -- Set the street size to zero
  send_cmd("map:set_street_size 0, 0")  

  -- Set the grid origin to the center
  send_cmd("map:set_grid_origin -20, -20")  
  
    -- Set The Home Die to the lower right Position
  send_cmd("map:set_home_die 20, 20")  
  
  send_cmd("map:set_axis_orient ur")    
  
  send_cmd("map:bins:set_all 0")  
  
  send_cmd("map:path:create_from_bins 0")  
  
  send_cmd("map:bins:load C:\\ProgramData\\MPI Corporation\\Sentio\\config\\defaults\\default_bins.xbt")  
  
  -- Take Die Color from bin
  send_cmd("map:set_color_scheme 1")  

  -- select good dies for testing
  send_cmd("map:path:select_dies g")  

  send_cmd("map:set_routing ur,wc")  
  
  -- Remove some dies from the Map
  for i=21, 24 do
    for j=21,24 do
      send_cmd(string.format("map:die:remove %d, %d",  4+i, 4+j))  
      send_cmd(string.format("map:die:remove %d, %d", -10+i, 4+j))  
    end
  end
  
  for i=-7, 7 do
      if (math.abs(i)>6) then
        send_cmd(string.format("map:die:remove %d, %d",  20+i, 20-8))  
      elseif (math.abs(i)>4) then
        send_cmd(string.format("map:die:remove %d, %d",  20+i, 20-9))  
      else
        send_cmd(string.format("map:die:remove %d, %d",  20+i, 20-10))  
      end
  end

  -- Take Die Color from bin
  send_cmd("map:set_color_scheme 2")  

  print("Stepping to first die")
  send_cmd("map:step_first_die")  

  local running = true
  while running do
    print("Step next die")
    sleep(0.005)
    
    err, stat, cid, msg =  send_cmd(string.format("map:bin_step_next_die %d", math.random()*5))  
    
    if (err~=0) then
      running = false
    end
  end
  
  close_socket(s)
end

main()