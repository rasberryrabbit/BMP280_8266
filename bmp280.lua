sda, scl = 2, 1
id = 0
if i2c.setup(id, sda, scl, i2c.FAST)==0 then -- call i2c.setup() only once
  print("i2c bus init error")
end
bme280.setup(2) -- 2 for bmp280?

bmptimer=tmr.create()

function stop()
  bmptimer:stop()
end

function start()
  bmptimer:start()
end

function doReadData()
  T, P, H, QNH = bme280.read()
  MsgSystem("")
  if P~=nil then
    P = P / 1000
    otext=string.format("%4.2f", P)
    --print(otext)
    DrawText(0,31,otext)
  end
  if T~=nil then
    T = T / 100
    otext=string.format("%2.2f", T)
    --print(otext)
    DrawText(0,55,otext)
  end
end

bmptimer:register(1000,tmr.ALARM_AUTO, function()
  doReadData()
end)

MsgSystem("start bmp280")
bmptimer:start()
DrawXBM(128-20,31-20,20,20,"ihPa.bin")
DrawXBM(128-20,55-20,20,20,"icel.bin")
doReadData()
