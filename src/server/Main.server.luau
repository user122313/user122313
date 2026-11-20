local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local TreasureService = require(script.Parent.TreasureService)
local StealService = require(script.Parent.StealService)

Remotes.create()
BaseService.start()
TreasureService.start()
StealService.start()

print("Muellbanditen server running")
