local ADDON, Private = ...
local Core = Wheel("LibModule"):GetModule(ADDON)
if (not Core) then 
	return 
end
for moduleName,list in pairs({
	[ADDON] = {
		--["AzeriteUI"] = true,
		["DiabolicUI"] = true,
		["ElvUI"] = true,
		["GoldieSix"] = true,
		["GoldpawUI"] = true,
		["GoldpawUI7"] = true,
		["KkthnxUI"] = true,
		["SpartanUI"] = true,
		["TukUI"] = true
	},
	BlizzardChatFrames = {
		["Glass"] = true,
		["Prat-3.0"] = true
	},
	BlizzardGameMenu = {
		["ConsolePort"] = true
	},
	BlizzardObjectivesTracker = {
		["!KalielsTracker"] = true
	},
	BlizzardTooltips = {
		["TinyTip"] = true,
		["TinyTooltip"] = true,
		["TipTac"] = true
	},
	BlizzardWorldMap = {
		["ClassicWorldMapEnhanced"] = true,
		["Leatrix_Maps"] = true
	},
	Bindings = {
		["ConsolePort"] = true
	},
	ChatBubbles = {
		["Prat-3.0"] = true
	},
	NamePlates = {
		["Kui_Nameplates"] = true,
		["NeatPlates"] = true,
		["Plater"] = true,
		["SimplePlates"] = true,
		["TidyPlates"] = true,
		["TidyPlates_ThreatPlates"] = true,
		["TidyPlatesContinued"] = true
	},
	UnitFrameArena = {
		["Gladius"] = true,
		["GladiusEx"] = true,
		["sArena"] = true
	}
}) do
	local module = (moduleName == ADDON) and Core or Core:GetModule(moduleName)
	if (module) then
		for addonName,isIncompatible in pairs(list) do
			if (isIncompatible) then
				module:SetIncompatible(addonName)
			end
		end
	end
end
