monitor = peripheral.wrap("top")

in_use = false

brain_id = -1

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

function clearMonitor()
	monitor.clear()
	monitor.setCursorPos(1,1)
end

function openDoor()
	redstone.setOutput("bottom", true)
end

function closeDoor()
	redstone.setOutput("bottom", false)
end

function activate()
	if not in_use then
		if brain_id ~= -1 then
			rednet.send(brain_id, "activate")
			return "AIRLOCK ACTIVATED"
		else
			return "COMPUTER NOT CONNECTED TO BRAIN: ACTIVATION DISABLED"
		end
	else
		return "AIR LOCK CURRENTLY IN USE: ACTIVATION DISABLED"
	end
end

function rednetListen()
	rednet.open("back")
	while true do
		local id, message = rednet.receive()
		if message == "brain_id" then
			brain_id = id
			rednet.send(brain_id, "register")

		elseif message == "activated" then
			in_use = true

			clearMonitor()
			monitor.setTextScale(2)
			monitor.write("IN")
			monitor.setCursorPos(1,2)
			monitor.write("USE")

		elseif message == "finished" then
			in_use = false

			clearMonitor()
			monitor.setTextScale(1.5)
			monitor.setCursorPos(1,2)
			monitor.write("READY")

		elseif message == "open_door" then
			openDoor()

		elseif message == "close_door" then
			closeDoor()

		end
	end
end

function getInput()
	while true do
		clear()
		print("PRESS ENTER TO ACTIAVTE AIR LOCK")
		local kEvent, param = os.pullEvent("key")
		if kEvent == "key" then
			if param == 28 then -- enter - http://computercraft.info/wiki/index.php?title=Raw_key_events
				clear()
				print(activate())
				sleep(2)
			elseif param == 14 then
				clear()
				print("MANUAL DOOR OPEN")
				openDoor()
				sleep(4)
				closeDoor()
			end
		end

	end
end

clearMonitor()
monitor.setTextScale(1.5)
monitor.setCursorPos(1,2)
monitor.write("READY")

parallel.waitForAny(rednetListen, getInput)





