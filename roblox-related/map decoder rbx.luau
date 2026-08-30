-- LocalScript: decode_parts_local.lua
local HttpService = game:GetService("HttpService")

local function tableToVec3(t)
	return Vector3.new(t[1], t[2], t[3])
end

local function tableToColor3(t)
	return Color3.new(t[1], t[2], t[3])
end

local function buildCFrame(cfdata)
	local p = cfdata.pos
	local r = cfdata.rot
	local pos = Vector3.new(p[1], p[2], p[3])
	local rx, ry, rz = r[1], r[2], r[3]
	return CFrame.new(pos) * CFrame.Angles(rx, ry, rz)
end

local function ensureParent(rootName, relativePath)
	-- try to find/create the path under the corresponding root
	local root = (rootName == "Workspace") and workspace or game:GetService("ReplicatedStorage")
	if relativePath == "" or relativePath == nil then
		return root
	end
	local segments = {}
	for seg in string.gmatch(relativePath, "[^/]+") do
		table.insert(segments, seg)
	end
	-- final segment is the part name; we want parent folder path
	if #segments <= 1 then
		return root
	end
	-- create folders as needed
	local parent = root
	for i = 1, #segments-1 do
		local name = segments[i]
		local found = parent:FindFirstChild(name)
		if not found then
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = parent
			parent = folder
		else
			parent = found
		end
	end
	return parent
end

local function decodePartsFromJSON(jsonString)
	local success, data = pcall(function() return HttpService:JSONDecode(jsonString) end)
	if not success then
		warn("Invalid JSON")
		return
	end
	for _, entry in ipairs(data) do
		-- create appropriate part type
		local cls = entry.ClassName or "Part"
		local part = Instance.new(cls)
		part.Name = entry.Name or "Part"
		part.Size = tableToVec3(entry.Size)
		part.CFrame = buildCFrame(entry.CFrame)
		part.Anchored = entry.Anchored
		part.CanCollide = entry.CanCollide
		part.Transparency = entry.Transparency
		pcall(function() part.Material = Enum.Material[entry.Material] end)
		part.Color = tableToColor3(entry.Color)
		if cls == "MeshPart" then
			part.MeshId = entry.MeshId or ""
			part.TextureID = entry.TextureID or ""
		end
		local parent = ensureParent(entry.Root, entry.RelativePath)
		part.Parent = parent
	end
end

-- Example: decode immediately from a saved jsonString variable (from previous script)
-- decodePartsFromJSON(jsonString)
