require "../shared/vector_prober"

print("Sentio Wafer Stepping Sample for Vector Probestations");

function main()
  -- open the socket
  local s = open_socket()
  if (s==nil) then
    print("Can't open Socket")
    exit(-1)
  end

  -- prerequisites:  A Waferma must be defined
  --                 vector remote command set must be open
  
  local resp;
  
  -- switch to vector remote command set
  send("*RCS 2")
  
  -- Step First Die
  r = send_cmd("G")
  print(r);
  
  local running = true
  local ct = 1
  while running do
    
    r = send_cmd("J")
    print("executing \"J\": "..r);
    
    if (r=="L" or r=="J") then
      running = false
    end
    
    r = send_cmd("MRp"..ct)
    print("executing \"MRp\": "..r);
    
    ct=ct+1
    if (ct==5) then 
      ct=1
    end
    
    if (r=="L" or r=="J") then
      running = false
    end

  end
  
  close_socket(s)
end

main()