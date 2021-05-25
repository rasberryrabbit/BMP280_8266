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

bme280.setup()
-- sample x1, forced, not filtered
if write_reg(0, 0x76, 0xF5, 0xe0)==0 then
  write_reg(0, 0x77, 0xF5, 0xe0)
  write_reg(0, 0x77, 0xF4, 0x25)
else
  write_reg(0, 0x76, 0xF4, 0x25)
end

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
