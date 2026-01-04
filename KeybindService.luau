--[[
    File:        | KeybindService.luau
    Author:      | memoriilane
    Description: | thanks nuro
]]--
--------------------------------------------------------------------------------------------------------------------------------

-- # Important stuff

local KeybindService   = {
	IsRecording          = false,
	RecordingConnection  = nil,
	LastKeyPressedObject = nil,
	BindedKeys           = {},
	ReservedKeys         = {
		["/"] 	   = Enum.KeyCode.Slash,
		["Escape"] = Enum.KeyCode.Escape,
		["Up"]     = Enum.KeyCode.Up,
		["Down"]   = Enum.KeyCode.Down,
		["Right"]  = Enum.KeyCode.Right,
		["Left"]   = Enum.KeyCode.Left
	}
}

local UserInputService = game:GetService("UserInputService")
local string_lower     = string.lower
local string_format    = string.format
--------------------------------------------------------------------------------------------------------------------------------

-- >> functions
-- Checks if Key is reserved.
--- @param key any
--- @return boolean
function KeybindService:IsKeyReserved(key): boolean
	for reservedKeycodeName, reservedkeycodeObj in pairs(self.ReservedKeys) do
		local keyCodeString = type(key) == "string" and key
		local keyCodeObject = typeof(key) == "EnumItem"

		-- >> handle string keycode being passed
		if (keyCodeString) and (string_lower(keyCodeString) == string_lower(reservedKeycodeName)) then
			return true
		end

		-- handle keycode EnumItem being passed
		if (keyCodeObject) and (keyCodeString == reservedkeycodeObj) then
			return true
		end

		return false
	end
end


--- Begin recording keys.
--- @param printToConsole boolean
--- @return RBXScriptConnection RecordingConnection
function KeybindService:BeginRecording(printToConsole: boolean)
	self.IsRecording = true
	self.RecordingConnection = UserInputService.InputBegan:Connect(function(input, gameReservedKey)
		--return if the input was processed by the game (example: / for chatbar, Esc for menu, etc.)
		if self:IsKeyReserved(input) then
			(printToConsole and print)(string_format("KeybindService - %s is reserved by the game engine.", tostring(input.KeyCode)))
			return
		end

		if (input.KeyCode == Enum.KeyCode.Unknown) then
			return
		end

		self.LastKeyPressedObject = input;
		(printToConsole and print)("KeybindService - ", input.KeyCode.Name)
		return self.RecordingConnection
	end)
end


--- Bind a function to a key.
--- @param key string | EnumItem
--- @return nil
function KeybindService:BindToKey(key, callback)
	UserInputService.InputBegan:Once(function(input)
		-- // return if the key is reserved by game
		if self:IsKeyReserved(key) then
			warn(string_format("KeybindService - Key %s is reserved by the game engine.", key))
			return
		end

		-- // handle if string character is passed
		if ((typeof(key) == "string" and key) == (string.lower(input.KeyCode))) then
			callback()
			return
		end

		-- // handle if Enum KeyCode object is passed
		if ((typeof(key) == "EnumItem" and key) == input) then
			callback()
			return
		end
	end)
end


---Terminates recording session.
---@return nil
function KeybindService:StopRecording(): nil
	self.RecordingConnection:Disconnect()
end


---Returns whether or not KeybindService is still listening for keys.
---@return boolean isRecording
function KeybindService:IsRecording(): boolean
	return self.IsRecording
end
--------------------------------------------------------------------------------------------------------------------------------

return KeybindService
