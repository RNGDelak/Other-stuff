-- LocalScript: CompactJSONExporter.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

------------------------------------------------
-- SETTINGS
------------------------------------------------
local CHUNK_LIMIT = 199999 -- safe under Roblox's 200k cap
local ROUND = 2 -- decimal places for numbers
------------------------------------------------

-- Helpers
local function round(num, places)
	local mult = 10 ^ places
	return math.floor(num * mult + 0.5) / mult
end

local function vec3ToArray(v)
	return {round(v.X, ROUND), round(v.Y, ROUND), round(v.Z, ROUND)}
end

local function color3ToRGB(c)
	return {
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5),
	}
end

-- Compact serialization
local function serializePart(part)
	return {
		T = part.Transparency,             -- Transparency
		R = part.Reflectance,              -- Reflectance
		P = vec3ToArray(part.Position),    -- Position
		O = vec3ToArray(part.Orientation), -- Orientation
		S = vec3ToArray(part.Size),        -- Size
		C = color3ToRGB(part.Color),       -- Color (RGB 0–255)
		M = tostring(part.Material),       -- Material
		CC = part.CanCollide,              -- CanCollide
		Sh = (part:IsA("Part") and tostring(part.Shape)) or nil, -- Shape
		Cl = part.ClassName,               -- ClassName
	}
end

local function collectParts()
	local out = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("BasePart") then
			table.insert(out, serializePart(inst))
		end
	end
	return out
end

-- Encode all parts to one JSON
local function encodeAll()
	local data = collectParts()
	return HttpService:JSONEncode(data, false) -- compact JSON, no spaces
end

-- Split into safe chunks
local function splitString(str, chunkSize)
	local chunks = {}
	for i = 1, #str, chunkSize do
		table.insert(chunks, str:sub(i, i + chunkSize - 1))
	end
	return chunks
end

------------------------------------------------
-- UI
------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompactExporter"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main text box
local mainBox = Instance.new("TextBox")
mainBox.Size = UDim2.new(1, -20, 1, -80) -- leave space at bottom
mainBox.Position = UDim2.new(0, 10, 0, 10)
mainBox.MultiLine = true
mainBox.TextWrapped = false
mainBox.ClearTextOnFocus = false
mainBox.Font = Enum.Font.Code
mainBox.TextSize = 14
mainBox.TextXAlignment = Enum.TextXAlignment.Left
mainBox.TextYAlignment = Enum.TextYAlignment.Top
mainBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainBox.TextColor3 = Color3.new(1,1,1)
mainBox.TextEditable = false
mainBox.Parent = screenGui

-- Page identifier
local pageBox = Instance.new("TextBox")
pageBox.Size = UDim2.new(0, 200, 0, 30)
pageBox.Position = UDim2.new(0.5, -100, 1, -35)
pageBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
pageBox.TextColor3 = Color3.new(1, 1, 1)
pageBox.Font = Enum.Font.SourceSansBold
pageBox.TextSize = 18
pageBox.ClearTextOnFocus = false
pageBox.TextWrapped = true
pageBox.Text = "Page 0 / 0"
pageBox.TextEditable = false
pageBox.ZIndex = 10
pageBox.Parent = screenGui

------------------------------------------------
-- PAGING
------------------------------------------------
local chunks = {}
local currentPage = 1

local function showPage(n)
	if n < 1 or n > #chunks then return end
	currentPage = n
	mainBox.Text = chunks[currentPage]
	pageBox.Text = ("Page %d / %d"):format(currentPage, #chunks)
end

local function exportNow()
	local bigJSON = encodeAll()
	chunks = splitString(bigJSON, CHUNK_LIMIT)
	if #chunks == 0 then chunks = {"(no parts)"} end
	showPage(1)
end

-- Arrow key navigation
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.T then
		showPage(currentPage + 1)
	elseif input.KeyCode == Enum.KeyCode.R then
		showPage(currentPage - 1)
	end
end)

------------------------------------------------
-- RUN
------------------------------------------------
exportNow()
