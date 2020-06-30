require "../shared/prober"

print("Sentio Rectangular Wafermap Setup Sample");


function main()
  -- open the socket
  local s = open_socket()
  if (s==nil) then
    print("Can't open Socket")
    exit(-1)
  end

  local err, cid, msg
  local rows = 10
  local cols = 20
  
    -- switch to MPI remote command set
  send("*RCS 1")
  
  -- select the wafermap module
  send_cmd("select_module Wafermap")

  -- Create a map with dimension 10x20 [Col x Row]
  send_cmd(string.format("map:create_rect %d,%d", cols, rows))

  -- Set the grid origin columns and rows away from the die at the center of the rectangle
  send_cmd("map:set_grid_origin -10, -5")  

  -- Set the grid origin to the center
  send_cmd("map:set_axis_orient ur")  

  -- I want the home die in the upper right corner of the map, opposite to the grid origin
  send_cmd(string.format("map:set_home_die %d,%d",cols-1,rows-2))  

  -- Take Die Color from bin
  send_cmd("map:set_color_scheme 2")  

  -- select good dies for testing
  send_cmd("map:path:select_dies g")  

  -- set all bins to value 2 (yellow)
  send_cmd("map:bins:set_all 3")  
  
  -- Remove the four corner diese
  send_cmd(string.format("map:die:remove %d, %d",  0,0))  
  send_cmd(string.format("map:die:remove %d, %d",  cols-1,0))  
  send_cmd(string.format("map:die:remove %d, %d",  0,rows-1))  
  send_cmd(string.format("map:die:remove %d, %d",  cols-1,rows-1))  
  
  close_socket(s)
end

main()