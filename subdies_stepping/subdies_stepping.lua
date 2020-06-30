require "../shared/prober"

print("Sentio Wafermap Subsite Stepping Sample");

function add_site(s, id, x, y)
  print("Querying number of sub sites")  
  err, stat, cid, msg = send_cmd("map:subsite:get_num")  
  local n = tonumber(msg);
  
  print(string.format("Number of subdies: %d", n))
  err, stat, cid, msg = send_cmd(string.format("map:subsite:add %s,%d,%d", id, x, y))  
  
  print("Querying number of sub sites")  
  err, stat, cid, msg = send_cmd("map:subsite:get_num")  
  local n = tonumber(msg);
  
  print(string.format("Number of subdies: %d", n))
end


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
  send_cmd("select_module map")

  -- Create a 200 mm wafer map
  send_cmd("map:create 200")

  -- Set up a Flat at 180 Degrees, 10000 µm long
  send_cmd("map:set_flat_params 90, 10000")
  
  -- Set up the grid;  IndexSizeY, IndexSizeY, GridOffsetX, GridOffsetY, EdgeArea
  send_cmd("map:set_grid_params 10000, 10000, 0, 0, 4000")  
  
  -- Set the grid origin to the center
  send_cmd("map:set_grid_origin 0, 0")  

  -- Set The Home Die to the lower right Position
  send_cmd("map:set_home_die 0, 0")  
  
  send_cmd("map:bins:load C:\\ProgramData\\MPI Corporation\\Sentio\\config\\defaults\\default_bins.xbt")  
  
    -- Take Die Color from bin
  send_cmd("map:set_color_scheme 2")  

  -- set all bins to 0
  send_cmd("map:bins:set_all 0")  

  -- select good dies for testing
  send_cmd("map:path:select_dies g")  
  
  send_cmd("map:step_first_die")  

  -- delete all subsites, including the default subsite. If no new sites are created probing will 
  -- not work!
  print("resetting sub sites")
  send_cmd("map:subsite:reset")  
  
  -- get number of sub sites (should be 0 after reset)
  add_site(s, "site1", 2000, 2000)
  add_site(s, "site2", 4000, 2000)
  add_site(s, "site3", 4000, 4000)
  add_site(s, "site4", 2000, 4000)
  
  send_cmd("map:step_first_die")  
  
  -- send_cmd("map:step_die 1, -9")  

  local running = true
  local die_eval = 0
  local ct = 0
  while running do
    print("Step next die")
    sleep(0.05)
    
    local site_bin = math.random()*5
    err, stat, cid, msg = send_cmd(string.format(string.format("map:subsite:bin_step_next %d", site_bin))) 
    
    ct = ct + site_bin    
    
    -- If the LastSite Flag is set check whether the sum of all sitebins is larger than 10. If so bin the die
    -- as good otherwise bin the die as bad
    if (bit.band(stat, 2)~=0) then
      if ct>10 then
        err, stat, cid, msg = send_cmd("map:bins:set_bin 3") 
      else
        err, stat, cid, msg = send_cmd("map:bins:set_bin 4") 
      end
      
      ct = 0      
    end
    
    err, stat, cid, msg = send_cmd(string.format("map:view:show_current_die"))  
    
    if (err~=0) then
      running = false
    end
  end
  
  close_socket(s)
end

main()