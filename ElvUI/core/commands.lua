local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

function E:EnableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		EnableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end	
end

function E:DisableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		DisableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end
end

function E:ResetGold()
	ElvData.gold = nil;
	ReloadUI();
end

function FarmMode()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT); return; end
	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		UIFrameFadeIn(FarmModeMap, 0.3) 
		Minimap.fadeInfo.finishedFunc = function() Minimap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = true
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		UIFrameFadeIn(Minimap, 0.3) 
		FarmModeMap.fadeInfo.finishedFunc = function() FarmModeMap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = false
	end
end

function E:FarmMode(msg)
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 500 and tonumber(msg) >= 20 and not InCombatLockdown() then
		E.db.farmSize = tonumber(msg)
		FarmModeMap:Size(tonumber(msg))
	end
	
	FarmMode()
end

local channel = 'PARTY'
local target = nil;
function E:ElvSaysChannel(chnl)
	channel = chnl
	E:Print(string.format('ElvSays channel has been changed to %s.', chnl))
end

function E:ElvSaysTarget(tgt)
	target = tgt
	E:Print(string.format('ElvSays target has been changed to %s.', tgt))
end

function E:ElvSays(msg)
	if channel == 'WHISPER' and target == nil then
		E:Print('You need to set a whisper target.')
		return
	end
	SendAddonMessage('ElvSays', msg, channel, target)
end

function E:Grid(msg)
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 256 and tonumber(msg) >= 4 then
		E.db.gridSize = msg
		E:Grid_Show()
	else 
		if EGrid then		
			E:Grid_Hide()
		else 
			E:Grid_Show()
		end
	end
end

function E:LuaError(msg)
	msg = string.lower(msg)
	if (msg == 'on') then
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif (msg == 'off') then
		SetCVar("scriptErrors", 0)
		E:Print("Lua errors off.")
	else
		E:Print("/luaerror on - /luaerror off")
	end
end

function E:FoolsHowTo()
	E:Print('Thank you for using ElvUI and participating in this years april fools day joke. Type "/aprilfools" in chat without quotes to fix your UI back to normal. If you liked this years joke please let us know about it at tukui.org.')
end

function E:DisableAprilFools()
	E.global.aprilFools = true;
	ReloadUI();
end

function E:BGStats()
	local DT = E:GetModule('DataTexts')
	DT.ForceHideBGStats = nil;
	DT:LoadDataTexts()
	
	E:Print(L['Battleground datatexts will now show again if you are inside a battleground.'])
end

local function OnCallback(command)
	MacroEditBox:GetScript("OnEvent")(MacroEditBox, "EXECUTE_CHAT_LINE", command)
end

function E:DelayScriptCall(msg)
	local secs, command = msg:match("^([^%s]+)%s+(.*)$")
	secs = tonumber(secs)
	if (not secs) or (#command == 0) then
		self:Print("usage: /in <seconds> <command>")
		self:Print("example: /in 1.5 /say hi")
	else
		E:ScheduleTimer(OnCallback, secs, command)
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("in", "DelayScriptCall")
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	
	self:RegisterChatCommand('bgstats', 'BGStats')
	self:RegisterChatCommand('moreinfo', 'FoolsHowTo')
	self:RegisterChatCommand('aprilfools', 'DisableAprilFools')
	self:RegisterChatCommand('luaerror', 'LuaError')
	self:RegisterChatCommand('egrid', 'Grid')
	self:RegisterChatCommand("moveui", "MoveUI")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand("enable", "EnableAddon")
	self:RegisterChatCommand("disable", "DisableAddon")
	self:RegisterChatCommand('resetgold', 'ResetGold')
	self:RegisterChatCommand('farmmode', 'FarmMode')
	self:RegisterChatCommand('elvsays', 'ElvSays')
	self:RegisterChatCommand('elvsayschannel', 'ElvSaysChannel')
	self:RegisterChatCommand('elvsaystarget', 'ElvSaysTarget')
	if E.ActionBars then
		self:RegisterChatCommand('kb', E.ActionBars.ActivateBindMode)
	end
end

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
			ElvUF_Arena1:Show(); ElvUF_Arena1.Hide = function() end; ElvUF_Arena1.unit = "player"
			ElvUF_Arena2:Show(); ElvUF_Arena2.Hide = function() end; ElvUF_Arena2.unit = "player"
			ElvUF_Arena3:Show(); ElvUF_Arena3.Hide = function() end; ElvUF_Arena3.unit = "player"
			ElvUF_Arena4:Show(); ElvUF_Arena4.Hide = function() end; ElvUF_Arena4.unit = "player"
	elseif msg == "boss" or msg == "b" then
			ElvUF_Boss1:Show(); ElvUF_Boss1.Hide = function() end; ElvUF_Boss1.unit = "player"
			ElvUF_Boss2:Show(); ElvUF_Boss2.Hide = function() end; ElvUF_Boss2.unit = "player"
			ElvUF_Boss3:Show(); ElvUF_Boss3.Hide = function() end; ElvUF_Boss3.unit = "player"
			ElvUF_Boss4:Show(); ElvUF_Boss4.Hide = function() end; ElvUF_Boss4.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"
