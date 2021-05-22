if file.exists("dispsetup.lua") then 
    dofile("dispsetup.lua")
    if file.exists("apconn.lua") then
      dofile("apconn.lua")
    end
    starttmr=tmr.create()
    tcount=6
    _G.gotip=false
    starttmr:register(1000, tmr.ALARM_AUTO,function()
      if tcount==0 then
        starttmr:unregister()
        if file.exists("bmp280.lua") then
          dofile("bmp280.lua")
        end
      else
        tcount=tcount-1
        MsgSystem(string.format("Wait %d second(s)",tcount))
      end
    end)
    starttmr:start()
end
