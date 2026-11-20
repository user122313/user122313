local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local TreasureService = require(script.Parent.TreasureService)
local StealService = require(script.Parent.StealService)
local TrapService = require(script.Parent.TrapService)

Remotes.create()
BaseService.start()
TreasureService.start()
StealService.start()
TrapService.start()

print("Muellbanditen server running")
