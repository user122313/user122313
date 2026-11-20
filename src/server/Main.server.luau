local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local BaseService = require(script.Parent.BaseService)
local TreasureService = require(script.Parent.TreasureService)

Remotes.create()
BaseService.start()
TreasureService.start()

print("Muellbanditen server running")
