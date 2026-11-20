-- Starts the client HUD, theft controls and screen effects once per player session.
-- Connects the existing remotes without changing gameplay state on the client.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local Hud = require(script.Parent:WaitForChild("Hud"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local StealController = require(script.Parent:WaitForChild("StealController"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local buyBanana = Remotes.get("RequestBuyBanana")
local placeBanana = Remotes.get("RequestPlaceBanana")
local upgradeBase = Remotes.get("RequestUpgradeBase")
local stealStart = Remotes.get("RequestStealStart")
local stealCommit = Remotes.get("RequestStealCommit")

local hud = Hud.new(player, playerGui, function()
	buyBanana:FireServer()
end, function()
	placeBanana:FireServer()
end, function()
	upgradeBase:FireServer()
end)
local effects = Effects.new(hud.gui)

local connections = {
	Remotes.get("HudUpdate").OnClientEvent:Connect(hud.setMoney),
	Remotes.get("Announce").OnClientEvent:Connect(hud.announce),
	Remotes.get("StealAlarm").OnClientEvent:Connect(function(thiefName)
		effects:showStealAlarm(thiefName)
	end),
	Remotes.get("Slipped").OnClientEvent:Connect(function(seconds)
		effects:showSlip(seconds)
	end),
}

local stopSteal = StealController.start(hud.stealButton, hud.setStealProgress, function(treasureId)
	stealStart:FireServer(treasureId)
end, function(treasureId)
	stealCommit:FireServer(treasureId)
end, hud.setKeyboardHint)

script.Destroying:Once(function()
	stopSteal()
	for _, connection in connections do
		connection:Disconnect()
	end
	effects:destroy()
	hud.destroy()
end)
