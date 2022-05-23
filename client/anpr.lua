local lastRadar = nil
-- Determines if player is close enough to trigger cam
function HandlespeedCam(speedCam, hasBeenBusted)
	local myPed = PlayerPedId()
	local playerPos = GetEntityCoords(myPed)
	local isInMarker  = false
	
	if #(playerPos - vector3(speedCam.coords.x, speedCam.coords.y, speedCam.coords.z)) < 20.0 then
		isInMarker  = true
		
	end

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
		HasAlreadyEnteredMarker = true
		lastRadar = hasBeenBusted

		local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
		if IsPedInAnyVehicle(myPed, false) then
			if GetPedInVehicleSeat(vehicle, -1) == myPed then		
				if GetVehicleClass(vehicle) ~= 18 then
					local ped = PlayerPedId()
					local veh = GetVehiclePedIsIn(ped, false)
					local speed = math.ceil(GetEntitySpeed(veh) * 3.6)
                    local plate = QBCore.Functions.GetPlate(vehicle)
					local PlayerData = QBCore.Functions.GetPlayerData()
					print (speed)
					print (speedCam.limitspeed)
					if speed > speedCam.limitspeed then 
						if speed > (speedCam.limitspeed * 1.5 ) then
							amount = speedCam.bill2
						else
							amount = speedCam.bill
						end
						Wait (10)
						QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(result)
							retval = result.retval
							vehData = result.vehData
							local coords = GetEntityCoords(PlayerPedId())
							if retval and not vehData then ---  en busqueda sin dueño
								print "pasa retval"
								
								local blipsettings = {
									x = coords.x,
									y = coords.y,
									z = coords.z,
									sprite = 488,
									color = 1,
									scale = 0.9,
									text = "Speed camera #"..hasBeenBusted.." - Marked vehicle"
								}
								local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
								local street1 = GetStreetNameFromHashKey(s1)
								local street2 = GetStreetNameFromHashKey(s2)
								TriggerServerEvent("police:server:FlaggedPlateTriggered", plate, plate, street1, street2, blipsettings)
							elseif retval and vehData then -- en busqueda con dueño
								local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
								local street1 = GetStreetNameFromHashKey(s1)
								local street2 = GetStreetNameFromHashKey(s2)
								TriggerServerEvent("police:server:caramelo", vehData.citizenid, amount,PlayerData.job.name,PlayerData.nameIC,'police')
								ExecuteCommand('veh')
							elseif vehData and not retval then -- con dueño sin busqueda
								local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
								local street1 = GetStreetNameFromHashKey(s1)
								local street2 = GetStreetNameFromHashKey(s2)
								TriggerServerEvent("police:server:caramelo", vehData.citizenid, amount,PlayerData.job.name,PlayerData.nameIC,'police')
							elseif not vehData and not retval then -- sin dueño sin busqueda
								if not PlayerData.job.onduty and PlayerData.job.name ~= 'police' then
									ExecuteCommand('veh')
								end
							end
						

                    	end, plate)
					end
				end
			end
		end
	end

	if not isInMarker and HasAlreadyEnteredMarker and lastRadar == hasBeenBusted then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

CreateThread(function()
	while true do
		Wait(1)
	--	print "espera"
		Player = PlayerPedId()
		if IsPedInAnyVehicle( Player, false) then
		--	print "pass"
			crds = GetEntityCoords(Player, false)
			for key, value in pairs(Config.Radars) do
				v3 = vector3(value.coords.x, value.coords.y, value.coords.z)
				dist = #(crds - v3)
				
				if dist < 30 then
				--	print (dist)
			--	print (key)
				
				--print"speedcam"
				HandlespeedCam(value, key)
				end
			end
			Wait(200)
		else
			Wait(2500)
		end
	end
end)
