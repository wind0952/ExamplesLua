require "../shared/prober"

print("Sentio Wafermap SubSites Sample");


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
  send_cmd("map:set_flat_params 90, 50000")
  
  -- Set up the grid;  IndexSizeY, IndexSizeY, GridOffsetX, GridOffsetY, EdgeArea
  send_cmd("map:set_grid_params 5000, 5000, 0, 0, 4000")  
  
  -- Set the street size to zero
  send_cmd("map:set_street_size 0, 0")  

  -- Set the Grid Origin to the center
  send_cmd("map:set_grid_origin 20, 20")  
  
  -- Set The Home Die to the lower right Position
  send_cmd("map:set_home_die -2, -19")  
  
  send_cmd("map:bins:load C:\\ProgramData\\MPI Corporation\\Sentio\\config\\defaults\\default_bins.xbt")  
  
  -- Use the "Color from Bin" color scheme
  send_cmd("map:set_color_scheme 2")  
  
    -- select good dies for testing
  send_cmd("map:path:select_dies g")  
  
  --[[ 
  --
  --    Binning 
  --
  ]]--
  
  -- bin all dies with 2 
  send_cmd("map:bins:set_all 1,D")  

  -- bin all subdies dies with 4 
  send_cmd("map:bins:set_all 3,S")  
  
  -- get number of sub sites
  print("Querying number of sub sites")  
  err, stat, cid, msg = send_cmd("map:subsite:get_num")  

  local n = tonumber(msg);
  print(string.format("Number of subsite: %d", n))
  
  -- delete all subsites, including the default subsite. If no new sites are created probing will 
  -- not work!
  print("resetting sub sites")
  send_cmd("map:subsite:reset")  
  
  -- get number of sub sites (should be 0 after reset)
  add_site(s, "site1", 1000, 1000)
  add_site(s, "site2", 2000, 1000)
  add_site(s, "site3", 2000, 2000)
  add_site(s, "site4", 1000, 2000)
  
  -- get number of subdies
  close_socket(s)
end

main()