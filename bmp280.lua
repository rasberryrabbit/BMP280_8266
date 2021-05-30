sda, scl = 2, 1
id = 0
if i2c.setup(id, sda, scl, i2c.FAST)==0 then -- call i2c.setup() only once
  print("i2c bus init error")
end

function write_reg(id, dev_addr, reg_addr, data)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    c = i2c.write(id, data)
    i2c.stop(id)
    return c
end

local baddr=0x76
local bconfig=0x24 -- bconfig : 24 = pressure, 20 = temp only

bme280.setup()
-- sample x1, forced, not filtered, sleep
if write_reg(id, baddr, 0xF5, 0xe0)==0 then
  baddr=0x77
  write_reg(id, baddr, 0xF5, 0xe0)
  write_reg(id, baddr, 0xF4, bconfig)
else
  write_reg(id, baddr, 0xF4, bconfig)
end

bmptimer=tmr.create()

function stop()
  bmptimer:stop()
end

function start()
  bmptimer:start()
end

local ep
local pt=0
local tt=0
rtctime.set(60)

function doReadData()
  ct=rtctime.get()
  if ct-pt>=60 then
    pt=ct
    ep=true
    bconfig=0x24
  else
    bconfig=0x20
  end
  write_reg(id, baddr, 0xF4, bconfig+1)
  tmr.delay(50000)
  T, P, H, QNH = bme280.read()
  write_reg(id, baddr, 0xF4, bconfig)
  MsgSystem("")
  if ep and P~=nil then
    P = P / 1000
    otext=string.format("%4.2f", P)
    --print(otext)
    DrawText(0,31,otext)
  end
  if ct-tt>=5 and T~=nil then
    tt=ct
    T = T / 100
    otext=string.format("%2.2f", T)
    --print(otext)
    DrawText(0,55,otext)
  end
  ep=false
end

bmptimer:register(5000,tmr.ALARM_AUTO, function()
  doReadData()
end)

print("start bmp280")
bmptimer:start()
DrawXBM(128-20,31-20,20,20,"ihPa.bin")
DrawXBM(128-20,55-20,20,20,"icel.bin")

doReadData()

