local LibSwitcherTool = Wheel:Set("LibSwitcherTool", 7)
if (not LibSwitcherTool) then
	return
end

local LibModule = Wheel("LibModule")
assert(LibModule, "LibSwitcherTool requires LibModule to be loaded.")

local LibSlash = Wheel("LibSlash")
assert(LibSlash, "LibSwitcherTool requires LibSlash to be loaded.")

-- We want this embedded
LibSlash:Embed(LibSwitcherTool)

-- Lua API
local _G = _G
local assert = assert
local date = date
local debugstack = debugstack
local error = error
local pairs = pairs
local select = select
local string_format = string.format
local string_join = string.join
local string_match = string.match
local table_insert = table.insert
local tonumber = tonumber
local type = type

-- WoW API
local DisableAddOn = DisableAddOn
local EnableAddOn = EnableAddOn
local ReloadUI = ReloadUI

-- Library registries
LibSwitcherTool.embeds = LibSwitcherTool.embeds or {}
LibSwitcherTool.switches = LibSwitcherTool.switches or { Addons = {}, Cmds = {} }

-- Keep the actual list of available UIs local.
local CurrentProjects = { Addons = {}, Cmds = {} }

-- List of known user interfaces. 
local KnownProjects = {
	["AzeriteUI"] = {
		azeriteui2 = true,
		azeriteui = true,
		azerite2 = true,
		azerite = true,
		azui2 = true,
		azui = true,
		az2 = true,
		az = true
	},
	["DiabolicUI"] = { 
		diabolicui2 = true, 
		diabolicui = true, 
		diabolic2 = true, 
		diabolic = true, 
		diabloui2 = true, 
		diabloui = true, 
		diablo = true,
		dio2 = true,
		dio = true,
		dui2 = true, 
		dui = true
	},
	["ElvUI"] = {},
	["GoldieSix"] = {},
	["GoldpawUI"] = {},
	["GoldpawUI7"] = { 
		goldpawui7 = true,
		goldpawui = true,
		goldpaw7 = true,
		goldpaw = true,
		goldui7 = true,
		goldui = true,
		gui7 = true,
		gui = true 
	},
	["KkthnxUI"] = {},
	["SpartanUI"] = {},
	["TukUI"] = {}
}

-- Shortcuts for quality of life.
local Switches = LibSwitcherTool.switches
local Addons = LibSwitcherTool.switches.Addons
local Cmds = LibSwitcherTool.switches.Cmds

----------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------
-- Syntax check 
local check = function(value, num, ...)
	assert(type(num) == "number", ("Bad argument #%.0f to '%s': %s expected, got %s"):format(2, "Check", "number", type(num)))
	for i = 1,select("#", ...) do
		if type(value) == select(i, ...) then 
			return 
		end
	end
	local types = string_join(", ", ...)
	local name = string_match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	error(string_format("Bad argument #%.0f to '%s': %s expected, got %s", num, name, types, type(value)), 3)
end

----------------------------------------------------------------
-- Private Callbacks
----------------------------------------------------------------
local OnChatCommand = function(editBox, ...)
	local cmd = ...
	if ((not cmd) or (cmd == "")) then 
		return 
	end 
	local targetAddon = CurrentProjects.Cmds[cmd]
	if targetAddon then 
		LibSwitcherTool:SwitchToInterface(targetAddon)
	end 
end 

-- Internal method to update the stored switches
local UpdateInterfaceSwitches = function()
	-- Clean out the list of current ones. 
	for i in pairs(CurrentProjects) do 
		for v in pairs(CurrentProjects[i]) do 
			CurrentProjects[i][v] = nil
		end 
	end 
	-- Add in the currently available from our own lists.
	local counter = 0
	for addon,list in pairs(KnownProjects) do 
		if (LibModule:IsAddOnAvailable(addon)) then 
			counter = counter + 1
			CurrentProjects.Addons[addon] = list
			for cmd in pairs(list) do 
				CurrentProjects.Cmds[cmd] = addon
			end 
		end 
	end 
	-- Add in the currently available from the user lists.
	for addon,list in pairs(Addons) do 
		if (LibModule:IsAddOnAvailable(addon)) then 
			counter = counter + 1
			CurrentProjects.Addons[addon] = list
			for cmd in pairs(list) do 
				CurrentProjects.Cmds[cmd] = addon
			end 
		end 
	end 
	-- Register the commands. 
	if (counter > 0) then 
		LibSwitcherTool:RegisterChatCommand("go", OnChatCommand, true)
		LibSwitcherTool:RegisterChatCommand("goto", OnChatCommand, true)
	else
		LibSwitcherTool:UnregisterChatCommand("go")
		LibSwitcherTool:UnregisterChatCommand("goto")
	end 
end

----------------------------------------------------------------
-- Public API
----------------------------------------------------------------
LibSwitcherTool.AddInterfaceSwitch = function(self, addon, ...)
	check(addon, 1, "string")
	-- Silently fail if the addon already has been registered
	if Addons[addon] then 
		return 
	end 
	-- Add the command to our globally available cache
	local numCmds = select("#", ...)
	if (numCmds > 0) then 
		Addons[addon] = {}
		for i = 1, numCmds do 
			local cmd = select(i, ...)
			check(cmd, i+1, "string")
			Addons[addon][i] = cmd
			Cmds[cmd] = addon
		end 
		-- Update the available switches
		UpdateInterfaceSwitches()
	end 
end

LibSwitcherTool.SwitchToInterface = function(self, targetAddon)
	check(targetAddon, 1, "string")
	-- Silently fail if an unavailable project is requested
	if (not CurrentProjects.Addons[targetAddon]) then 
		return 
	end 
	-- Iterate the currently available addons.
	for addon in pairs(CurrentProjects.Addons) do 
		if (addon == targetAddon) then 
			EnableAddOn(addon, true) -- enable the target addon
		else
			DisableAddOn(addon, true) -- disable all other addons in the lists
		end
	end 
	ReloadUI() -- instantly reload to apply the operations
end

-- Return a list of available interface addon names. 
LibSwitcherTool.GetInterfaceList = function(self)
	-- Generate a new list each time this is called, 
	-- as we don't want to provide any access to our own tables. 
	local listCopy = {}
	for addon in pairs(KnownProjects) do 
		if LibModule:IsAddOnAvailable(addon) then 
			table_insert(listCopy, addon)
		end 
	end 
	return unpack(listCopy)
end

-- Return an iterator of available interface addon names.
-- The key is the addon name, the value is whether its currently enabled. 
LibSwitcherTool.GetInterfaceIterator = function(self)
	-- Generate a new list each time this is called, 
	-- as we don't want to provide any access to our own tables. 
	local listCopy = {}
	for addon in pairs(KnownProjects) do 
		if LibModule:IsAddOnAvailable(addon) then 
			listCopy[addon] = LibModule:IsAddOnEnabled(addon) or false -- can't have nil here
		end 
	end
	return pairs(listCopy)
end

-- Run this once to initialize the database. 
UpdateInterfaceSwitches()

local embedMethods = {
	AddInterfaceSwitch = true, 
	GetInterfaceIterator = true, 
	GetInterfaceList = true, 
	SwitchToInterface = true
}

LibSwitcherTool.Embed = function(self, target)
	for method in pairs(embedMethods) do
		target[method] = self[method]
	end
	self.embeds[target] = true
	return target
end

-- Upgrade existing embeds, if any
for target in pairs(LibSwitcherTool.embeds) do
	LibSwitcherTool:Embed(target)
end