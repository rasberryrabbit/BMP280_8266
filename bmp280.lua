sda, scl = 2, 1
id = 0
if i2c.setup(id, sda, scl, i2c.FAST)==0 then -- call i2c.setup() only once
  print("i2c bus init error")
end
bme280.setup(0x76) -- bmp280 module, 0x77 for bme280

bmptimer=tmr.create()

function stop()
  bmptimer:stop()
end

function start()
  bmptimer:start()
end

function doReadData()
  P, T = bme280.baro()
  MsgSystem("")
  if P~=nil then
    P = P / 1000
    otext=string.format("%4.1f hPa", P)
    --print(otext)
    DrawText(0,31,otext)
  end
  if T~=nil then
    T = T / 100
    otext=string.format("%2.2f %sC", T, string.char(176))
    --print(otext)
    DrawText(0,55,otext)
  end
end

bmptimer:register(5000,tmr.ALARM_AUTO, function()
  doReadData()
end)

MsgSystem("start bmp280")
bmptimer:start()
doReadData()
