function responseHeader(code, type)      
     return "HTTP/1.1 " .. code .. "\r\nServer: vix-LUA\r\nContent-Type: " .. type .. "\r\nConnection: close\r\n\r\n";   
end

function setdirection(io1, io2, dir)
    local v1, v2
    if(dir == "O") then
        v1, v2 = 0, 0        
    elseif(dir == "P") then
        v1, v2 = 1, 0
    elseif(dir == "N") then
        v1, v2 = 0, 1
    else
        print("Wrong direction - \'" .. dir .. "\'")
    end
    if(v1 ~= nil) then gpio.write(io1, v1) end
    if(v2 ~= nil) then gpio.write(io2, v2) end
end

function draw_ssid_ip()
    if(AP_pars ~= nil) then
        disp:drawRFrame(0, 0, 127, 15, 4)
        disp:drawStr(5, 3, "SSID: " .. AP_pars.SSID .. " ["..AP_pars.channel.. "]")
    end
    if(my_IP ~= nil) then
        disp:drawRFrame(0, 17, 127, 37, 4)
        disp:drawStr(5, 20, "IP  : " .. my_IP.IP)
        disp:drawStr(5, 30, "mask: " .. my_IP.netmask)
        disp:drawStr(5, 40, "gate: " .. my_IP.gateway)
    end
end

function draw_try_connect()
    disp:drawRFrame(35, 19, 52, 26, 4)
    disp:drawRFrame(33, 17, 56, 30, 6)
    disp:drawStr(43, 22, "Try to")    
    disp:drawStr(40, 32, "connect")
end

function disp_routine(draw_func)
    if(disp ~= nil) then
        disp:firstPage()    
        repeat
            draw_func()
        until disp:nextPage() == false
    end
end

function print_AP_pars(T)
    print("\tConnected to:\n\tSSID  = "..T.SSID.."\n\tBSSID = "..T.BSSID.."\n\tChnl  = "..T.channel)
    AP_pars = T
    disp_routine(draw_ssid_ip)    
end

function print_my_IP(T)
    print("\n\tStation IP = "..T.IP.."\n\tSubnet msk = "..T.netmask.."\n\tGateway IP = "..T.gateway)
    my_IP = T
    disp_routine(draw_ssid_ip)    
end

function init_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     sda = 1 -- GPIO14
     scl = 2 -- GPIO12
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end


print("\r\n\r\nHTTP robocar remote control module.\r\nSet 'log' variable (log=1) for debug messages, or unset (log=nil) to disable it.")


-- init GPIO
pins = {0, 5, 6, 7, 12, 4} -- 1..2 = left; 3..4 = right; 5 = PWM, 6 = LED
for key, val in pairs(pins) do 
    gpio.write(val, (key == 6) and 1 or 0)
    gpio.mode(val,  gpio.OUTPUT)    
end
-- init PWM
pwm.setup(pins[5], 200, 100)
pwm.start(pins[5])

if(disp == nil) then init_display() end
disp_routine(draw_try_connect)

-- init WiFi as Station
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, print_AP_pars)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, print_my_IP)
station_cfg={}
station_cfg.ssid="SSID"
station_cfg.pwd="PASSWORD"
station_cfg.save=false
wifi.setmode(wifi.STATION)
wifi.sta.sethostname("robocar")
wifi.sta.config(station_cfg)
wifi.sta.connect()

-- init WiFi as Access Point
--wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T) print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID) end)
--wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T) print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID) end)
--wifi.ap.config({ssid="NODE-07", pwd="22222222", channel=10})
--wifi.ap.setip({ip="192.168.1.2",netmask="255.255.255.0",gateway="192.168.1.2"})
--wifi.setmode(wifi.SOFTAP)

-- make HTTP server
if(srv == nil) then
    srv=net.createServer(net.TCP)
    srv:listen(80, function(conn)
    	conn:on("receive", function(client,request)
            gpio.write(pins[6], 0) -- led on
    		local buff = "";
    		if(log) then print(request) end
    		local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
    		if(method == nil)then _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP") end
    
    		local type="text/html"
    		if(vars == nil) then  -- no variables
    			local fname = string.sub(path, 2)
    			if(fname == "") then   fname = "index.htm" end
    			
    			if file.open(fname, "r") then
    				local _, _, _, ext = string.find(fname, "([_%a]+).([_%a]+)")
    				if(ext == "svg") then type = "image/svg+xml" end
    				if(ext == "js") then type = "application/javascript" end
    				
    				buff = responseHeader("200 OK", type)
    				print("sending \'" .. fname .. "\' type = \'" .. type .."\'") -- .. "\' ext = \'" .. ext .. "\'")
    				repeat
    					local line=file.readline()
    					if line then buff = buff .. line end
    				until not line
    				file.close();
    			else
    				buff = responseHeader("404 Not Found","text/html") .. "Page not found"
    			end
    		else --some variables received
    			buff = responseHeader("200 OK", type)
    			local arg = {}
    			for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
    				arg[k] = v
    				print("Arg '" .. k .. "' = '" .. v .. "'")
    			end
    
    			if(arg.dir) then
    				setdirection(pins[1], pins[2], string.sub(arg.dir, 1, 1))
    				setdirection(pins[3], pins[4], string.sub(arg.dir, 2, 2))
    			elseif(arg.spd) then
    				pwm.setduty(pins[5], arg.spd)
    			end
    		end
    		if(log) then print(buff) end
    		client:send(buff)
    		client:close()
            gpio.write(pins[6], 1) -- led off
    	end)
    	collectgarbage()    
    end)
end -- (srv == nil)

