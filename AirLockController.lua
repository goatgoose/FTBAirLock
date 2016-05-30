DOOR_CLOSE_DELAY = 4 -- seconds
COUNTDOWN_TIME = 15 -- seconds

monitor = peripheral.wrap("top")

in_use = false

computer1_id = -1
computer2_id = -1

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

function clearMonitor()
	monitor.clear()
	monitor.setCursorPos(1,1)
end

function sendId()
	rednet.broadcast("brain_id")
	return "ID SENT"
end

function registerId(id)
	if computer1_id == -1 then
		computer1_id = id
	else
		if computer2_id == -1 then
			computer2_id = id
		end
	end
end

function otherId(id)
	if computer1_id == id then
		return computer2_id
	else
		return computer1_id
	end
end

function activate(id)
	rednet.broadcast("activated") -- disable activation until finished

	-- phase 1 - avtivation door
	rednet.send(id, "open_door")
	sleep(DOOR_CLOSE_DELAY)
	rednet.send(id, "close_door")

	-- phase 2 - preperation countdown
	for second = COUNTDOWN_TIME, 0, -1 do
		clearMonitor()
		if second >= 10 then
			monitor.setTextScale(3)
			monitor.setCursorPos(1,2)
		else
			monitor.setTextScale(5)
		end
		monitor.write(tostring(second))
		sleep(1)
	end
	clearMonitor()

	-- phase 3 - other door
	rednet.send(otherId(id), "open_door")
	sleep(DOOR_CLOSE_DELAY)
	rednet.send(otherId(id), "close_door")

	rednet.broadcast("finished")
end

function rednetListen()
	rednet.open("back")
	while true do
		local id, message = rednet.receive()
		if message == "register" then
			registerId(id)
		elseif message == "activate" then
			activate(id)
		end
	end
end

function getInput()
	while true do
		clear()
		print("PRESS ENTER TO ENABLE STARTED COMPUTERS")
		local kEvent, param = os.pullEvent("key")
		if kEvent == "key" then
			if param == 28 then -- enter - http://computercraft.info/wiki/index.php?title=Raw_key_events
				clear()
				print(sendId())
				sleep(1)
			end
		end

	end
end

clearMonitor()
sendId()

parallel.waitForAny(rednetListen, getInput)






