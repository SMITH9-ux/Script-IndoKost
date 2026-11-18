--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                 ⚡ INDO-KOST ULTRA HUB v2.5 ⚡                 ║
    ║                    👑 SMITH GANTENG 👑                        ║
    ║       Modern Cyber Dark Edition - All-In-One Automation       ║
    ║  - Auto Plant: Multi-Plot Selection + Auto TP ke Plot         ║
    ║  - Auto Clean: Remote Signal + Auto Prompt + TP Jarak Jauh    ║
    ║  - Anti-AFK: Cegah Kick Idle 20 Menit (Tombol Terpisah)       ║
    ║  - Alur Clean: Bersih > Tunggu Sampah > Ambil > Buang         ║
    ║  - Kompatibel multi-executor (fallback otomatis)              ║
    ║  - Auto Acc Penyewa + Spin Gratis saat 10 Penyewa (Terpisah)  ║
    ║  - High-End Glassmorphism UI with UIGradient & Micro-Tweens   ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local okCoreGui, CoreGui = pcall(function() return game:GetService("CoreGui") end)
if not okCoreGui then CoreGui = nil end

local okVirtualUser, VirtualUser = pcall(function() return game:GetService("VirtualUser") end)
if not okVirtualUser then VirtualUser = nil end

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========================================================
-- CONFIGURATION & STATE
-- ========================================================
local isScriptRunning = true
local Connections = {}

-- 1. Auto Plant Configuration
local PlantConfig = {
    CROP_NAME = "Cabai",
    BUY_COUNT = 100,
    INTER_ACTION_DELAY = 0.15,
    CYCLE_COOLDOWN = 0.10,
    DEFAULT_LAHAN = "Semua Lahan",
    USE_TELEPORT = true, -- Auto TP: teleport ke tiap plot sebelum menanam
    TP_SETTLE_DELAY = 0.05, -- jeda singkat setelah teleport sebelum tanam
    PLOT4_RADIUS = 1000 -- radius (studs) auto plant khusus Plot 4; plot di luar radius dilewati
}

local LAHAN_LIST = {
    ["Plot 4 Kanan 1"] = {
        Vector3.new(-524.1873168945312, 15.5, -308.36993408203125),
        Vector3.new(-539.720703125, 15.5, -309.0425720214844),
        Vector3.new(-557.5257568359375, 15.5, -310.53521728515625),
        Vector3.new(-575.1414794921875, 15.5, -312.2712097167969),
        Vector3.new(-594.4540405273438, 15.5, -311.93402099609375),
        Vector3.new(-627.4417114257812, 15.499998092651367, -313.681640625),
        Vector3.new(-610.0003662109375, 15.5, -309.58355712890625),
    },
    ["Plot 4 Kanan 2"] = {
        Vector3.new(-481.1759033203125, 15.5, -312.5938720703125),
        Vector3.new(-447.9565734863281, 15.500000953674316, -313.7166748046875),
        Vector3.new(-429.1582946777344, 15.500000953674316, -313.7612609863281),
        Vector3.new(-413.0259094238281, 15.5, -314.4434814453125),
        Vector3.new(-395.03643798828125, 15.5, -314.36480712890625),
        Vector3.new(-378.6339111328125, 15.500000953674316, -315.72528076171875),
    },
    ["Plot 4 Kiri A"] = {
        Vector3.new(-376.51953125, 15.499998092651367, -238.30813598632812),
        Vector3.new(-395.7886657714844, 15.5, -238.7544403076172),
        Vector3.new(-411.9199523925781, 15.5, -238.71746826171875),
        Vector3.new(-430.12469482421875, 15.5, -238.633544921875),
        Vector3.new(-446.92437744140625, 15.5, -238.82785034179688),
        Vector3.new(-464.1773986816406, 15.5, -238.52267456054688),
        Vector3.new(-479.4200439453125, 15.5, -237.79177856445312),
    },
    ["Plot 4 Kiri B"] = {
        Vector3.new(-626.8344116210938, 15.5, -230.7158660888672),
        Vector3.new(-523.2505493164062, 15.5, -229.5054931640625),
        Vector3.new(-540.0543823242188, 15.5, -229.42343139648438),
        Vector3.new(-558.4065551757812, 15.5, -228.7265167236328),
        Vector3.new(-574.9323120117188, 15.5, -229.35032653808594),
        Vector3.new(-592.9701538085938, 15.5, -228.72628784179688),
        Vector3.new(-609.5208740234375, 15.5, -228.6973114013672),
    },
    ["Lahan Kanan 1"] = {
        Vector3.new(-618.5881958007812, 15.499999046325684, -252.45172119140625),
        Vector3.new(-632.3125, 15.499999046325684, -253.161865234375),
        Vector3.new(-590.6769409179688, 15.500000953674316, -247.18519592285156),
        Vector3.new(-603.5460815429688, 15.500000953674316, -251.08877563476562),
    },
    ["Lahan Kanan 2"] = {
        Vector3.new(-517.0890502929688, 15.5, -250.7201690673828),
        Vector3.new(-531.0599975585938, 15.500000953674316, -252.03182983398438),
        Vector3.new(-544.1796264648438, 15.5, -251.0286407470703),
        Vector3.new(-556.2644653320312, 15.5, -244.6540069580078),
    },
    ["Lahan Kanan 3"] = {
        Vector3.new(-482.7235107421875, 15.499999046325684, -248.57882690429688),
        Vector3.new(-470.6371765136719, 15.5, -249.12124633789062),
        Vector3.new(-456.2996520996094, 15.5, -248.90750122070312),
        Vector3.new(-443.5169982910156, 15.5, -249.10556030273438),
    },
    ["Lahan Kanan 4"] = {
        Vector3.new(-408.9349060058594, 15.5, -252.46971130371094),
        Vector3.new(-397.1911315917969, 15.5, -249.8361358642578),
        Vector3.new(-382.33148193359375, 15.5, -242.9317626953125),
        Vector3.new(-370.10791015625, 15.5, -239.33607482910156),
    },
    ["Lahan Kiri 1"] = {
        Vector3.new(-630.9166259765625, 15.5, -321.91656494140625),
        Vector3.new(-618.759521484375, 15.5, -324.889892578125),
        Vector3.new(-604.3545532226562, 15.5, -323.1783752441406),
        Vector3.new(-590.7984619140625, 15.5, -320.9075012207031),
    },
    ["Lahan Kiri 2"] = {
        Vector3.new(-557.5001831054688, 15.5, -314.1703186035156),
        Vector3.new(-544.183837890625, 15.5, -316.4648132324219),
        Vector3.new(-530.4700927734375, 15.5, -317.07122802734375),
        Vector3.new(-516.580322265625, 15.500000953674316, -316.50634765625),
    },
    ["Lahan Kiri 3"] = {
        Vector3.new(-516.580322265625, 15.500000953674316, -316.50634765625),
        Vector3.new(-470.6393127441406, 15.5, -326.2953186035156),
        Vector3.new(-456.388916015625, 15.500000953674316, -322.6510925292969),
        Vector3.new(-443.1785888671875, 15.5, -319.5091247558594),
    },
    ["Lahan Kiri 4"] = {
        Vector3.new(-410.2164306640625, 15.5, -298.1622619628906),
        Vector3.new(-396.0249938964844, 15.499999046325684, -300.63201904296875),
        Vector3.new(-382.8375244140625, 15.5, -301.8544006347656),
        Vector3.new(-368.1260070800781, 15.5, -305.3680419921875),
    },
}

local function mergePlotGroups(names)
    local combined = {}
    for _, name in ipairs(names) do
        local plots = LAHAN_LIST[name]
        if plots then
            for _, pos in ipairs(plots) do
                table.insert(combined, pos)
            end
        end
    end
    return combined
end

local LAHAN_CATEGORIES = {
    "Semua Lahan",
    "Semua Kanan",
    "Semua Kiri",
    "Lahan Kanan 1",
    "Lahan Kanan 2",
    "Lahan Kanan 3",
    "Lahan Kanan 4",
    "Lahan Kiri 1",
    "Lahan Kiri 2",
    "Lahan Kiri 3",
    "Lahan Kiri 4",
    "Semua Plot 4",
    "Plot 4 Kanan 1",
    "Plot 4 Kanan 2",
    "Plot 4 Kiri A",
    "Plot 4 Kiri B"
}

local LAHAN_PRESETS = {
    ["Semua Lahan"] = mergePlotGroups({
        "Lahan Kanan 1", "Lahan Kanan 2", "Lahan Kanan 3", "Lahan Kanan 4",
        "Lahan Kiri 1", "Lahan Kiri 2", "Lahan Kiri 3", "Lahan Kiri 4"
    }),
    ["Semua Kanan"] = mergePlotGroups({"Lahan Kanan 1", "Lahan Kanan 2", "Lahan Kanan 3", "Lahan Kanan 4"}),
    ["Semua Kiri"]  = mergePlotGroups({"Lahan Kiri 1", "Lahan Kiri 2", "Lahan Kiri 3", "Lahan Kiri 4"}),
    ["Lahan Kanan 1"] = LAHAN_LIST["Lahan Kanan 1"],
    ["Lahan Kanan 2"] = LAHAN_LIST["Lahan Kanan 2"],
    ["Lahan Kanan 3"] = LAHAN_LIST["Lahan Kanan 3"],
    ["Lahan Kanan 4"] = LAHAN_LIST["Lahan Kanan 4"],
    ["Lahan Kiri 1"]  = LAHAN_LIST["Lahan Kiri 1"],
    ["Lahan Kiri 2"]  = LAHAN_LIST["Lahan Kiri 2"],
    ["Lahan Kiri 3"]  = LAHAN_LIST["Lahan Kiri 3"],
    ["Lahan Kiri 4"]  = LAHAN_LIST["Lahan Kiri 4"],
    -- Plot 4: terpisah, tidak masuk "Semua Lahan"
    ["Semua Plot 4"]  = mergePlotGroups({"Plot 4 Kanan 1", "Plot 4 Kanan 2", "Plot 4 Kiri A", "Plot 4 Kiri B"}),
    ["Plot 4 Kanan 1"] = LAHAN_LIST["Plot 4 Kanan 1"],
    ["Plot 4 Kanan 2"] = LAHAN_LIST["Plot 4 Kanan 2"],
    ["Plot 4 Kiri A"]  = LAHAN_LIST["Plot 4 Kiri A"],
    ["Plot 4 Kiri B"]  = LAHAN_LIST["Plot 4 Kiri B"],
}

local currentLahanIndex = 1
for idx, name in ipairs(LAHAN_CATEGORIES) do
    if name == PlantConfig.DEFAULT_LAHAN then
        currentLahanIndex = idx
        break
    end
end

local function getActivePlots()
    local name = LAHAN_CATEGORIES[currentLahanIndex]
    return LAHAN_PRESETS[name] or {}
end

-- 2. Auto Clean Configuration
local CleanConfig = {
    TargetName = "kotoran",
    TargetMaterial = Enum.Material.Plastic,
    DefaultKosanID = "8833771934_19",
    DefaultRadius = 9999, -- Default Jarak Jauh (9999 studs untuk jangkauan global)
    DefaultLoop = 0.5,
    MinLoopInterval = 0.05,
}

local CleanState = {
    CurrentKosanID = CleanConfig.DefaultKosanID,
    KosanOwner = "",
    RoomNumber = "",
    Radius = CleanConfig.DefaultRadius,
    LoopInterval = CleanConfig.DefaultLoop,
    USE_TELEPORT = true -- Mode Jarak Jauh (Auto TP ke kotoran)
}

local function parseKosanID(idString)
    local parts = string.split(tostring(idString), "_")
    return parts[1] or "-", parts[2] or "-"
end
CleanState.KosanOwner, CleanState.RoomNumber = parseKosanID(CleanState.CurrentKosanID)

-- ========================================================
-- HELPER: SAFE TELEPORT (JARAK JAUH)
-- ========================================================
local function safeTeleport(targetPos: Vector3)
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum and hum.Sit then
        hum.Sit = false
    end

    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    end
end

-- ========================================================
-- COMPAT LAYER (MULTI-EXECUTOR)
-- ========================================================
-- Menekan ProximityPrompt: pakai fireproximityprompt bila ada,
-- jika tidak ada pakai simulasi tahan tombol (InputHoldBegin/End)
local function firePrompt(prompt)
    if typeof(fireproximityprompt) == "function" then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end

    local ok = pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration or 0) + 0.05)
        prompt:InputHoldEnd()
    end)
    return ok
end

local function getExecutorName()
    if typeof(identifyexecutor) == "function" then
        local ok, name, version = pcall(identifyexecutor)
        if ok and name then
            return tostring(name) .. (version and (" " .. tostring(version)) or "")
        end
    end
    return "Unknown"
end

print(string.format("[IndoKost] Executor: %s | fireproximityprompt: %s | firesignal: %s | gethui: %s",
    getExecutorName(),
    typeof(fireproximityprompt) == "function" and "ya" or "fallback",
    typeof(firesignal) == "function" and "ya" or "fallback",
    typeof(gethui) == "function" and "ya" or "CoreGui/PlayerGui"))

-- ========================================================
-- NETWORK RESOLVERS
-- ========================================================
-- Knit Tanam Service
local function resolvePlantRemote(remoteName: string)
    local success, remote = pcall(function()
        return ReplicatedStorage
            :WaitForChild("NKSystem", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("TanamService", 5)
            :WaitForChild("RF", 5)
            :WaitForChild(remoteName, 5)
    end)
    return if success then remote else nil
end

local beliBibitRF = resolvePlantRemote("BeliBibit")
local tanamRF = resolvePlantRemote("Tanam")

-- Kosan Clean Remote
local CleanEvent = nil
pcall(function()
    CleanEvent = ReplicatedStorage
        :WaitForChild("NKSystem", 5)
        :WaitForChild("Packages", 5)
        :WaitForChild("Knit", 5)
        :WaitForChild("Services", 5)
        :WaitForChild("KosanStateService", 5)
        :WaitForChild("RE", 5)
        :WaitForChild("CleanProgress", 5)
end)

local function fireCleanSignal(targetId)
    if not CleanEvent then return end
    if typeof(firesignal) == "function" then
        firesignal(CleanEvent.OnClientEvent, targetId, "Kotor", true)
    else
        pcall(function() CleanEvent:FireServer(targetId, "Kotor", true) end)
    end
end

local function findNearestDirt()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local rootPos = char.HumanoidRootPart.Position

    local nearest, minDist = nil, CleanState.Radius
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower() == CleanConfig.TargetName:lower() then
            if obj.Material == CleanConfig.TargetMaterial then
                local dist = (obj.Position - rootPos).Magnitude
                if dist <= minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- ========================================================
-- AUTO SAMPAH (BAGIAN DARI AUTO CLEAN): AMBIL + BUANG
-- ========================================================
local TrashConfig = {
    -- Kata kunci (huruf kecil). Dicocokkan dengan nama/teks ProximityPrompt
    -- dan nama 3 parent di atasnya. Sesuaikan dengan nama objek di game.
    PickupKeywords  = { "sampah", "trash", "garbage", "litter" },
    DisposeKeywords = { "tong sampah", "tempat sampah", "trashcan", "trash can", "trash bin", "dustbin", "buang", "dispose" },
    CleanDoneStreak = 3, -- berapa kali cek berturut-turut tanpa kotoran sebelum cek persen kebersihan

    -- Tunggu kebersihan rumah 100% sebelum lanjut ke sampah
    RequireFullClean = true,
    CleanPercentKeywords = { "bersih", "clean", "kebersihan", "kotor" }, -- teks/nama UI persen kebersihan
    CleanPercentTimeout = 0, -- detik. 0 = tunggu 100% tanpa batas waktu; isi mis. 120 agar tidak macet

    -- Deteksi "penuh" (mode gabungan: ambil sampai penuh dulu, baru buang)
    MaxCarry = 5, -- kapasitas bawa sampah. SESUAIKAN dengan game
    FullKeywords = { "penuh", "inventory full", "backpack full", "bag full" },
    NoPromptLimit = 3,        -- berapa kali berturut-turut tidak ada target sebelum ganti fase
    DisposePhaseTimeout = 20, -- detik, batas maksimal fase buang sebelum balik ambil

    -- Kecepatan buang sampah (burst: 1x cari tong + 1x TP, lalu tembak berturut-turut)
    DisposeSettleDelay = 0.03,  -- jeda setelah TP ke tong sebelum mulai buang
    DisposeFireDelay = 0.04,    -- jeda antar buang sampah di tong yang sama
    DisposeLoopInterval = 0.1,  -- jeda antar loop selama fase BUANG (menggantikan LoopInterval)

    -- Buang hanya ke tong milik kosan sendiri
    OwnBinOnly = true,          -- true = hanya tong yang cocok dengan ID kosan / owner kita
    DisposeFallbackRadius = 150 -- studs. Bila tidak ada tong yang cocok owner, pakai tong terdekat
                                -- dari lokasi ambil sampah dalam radius ini. 0 = tanpa fallback
}

local TrashState = {
    Enabled = true,         -- ikut alur sampah setelah rumah bersih
    Phase = "BERSIH",       -- "BERSIH" > "TUNGGU" > "AMBIL" > "BUANG"
    PickupCount = 0,
    DisposeCount = 0,
    PickedSinceDispose = 0,
    DisposedThisPhase = 0,
    ToolDetected = false,   -- true bila sampah terdeteksi sebagai Tool di Backpack
    NoticeCached = false,
    HomePos = nil,          -- lokasi terakhir ambil sampah (jangkar kosan sendiri)
    LastBinLogged = nil
}

local onTrashUpdate = function() end -- diisi oleh GUI

local function hasKeyword(text, list)
    for _, kw in ipairs(list) do
        if string.find(text, kw, 1, true) then
            return true
        end
    end
    return false
end

local function promptSignature(prompt)
    local parts = { prompt.Name, prompt.ActionText, prompt.ObjectText }
    local inst = prompt.Parent
    for _ = 1, 3 do
        if not inst or inst == Workspace then break end
        table.insert(parts, inst.Name)
        inst = inst.Parent
    end
    return string.lower(table.concat(parts, " "))
end

local function promptPosition(prompt)
    local parent = prompt.Parent
    if not parent then return nil end
    if parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent:IsA("Model") then
        local ok, pivot = pcall(function() return parent:GetPivot() end)
        if ok then return pivot.Position end
    end
    return nil
end

-- Token identitas kosan sendiri (huruf kecil, minimal 4 karakter agar tidak salah cocok)
local function ownerTokens()
    local tokens = {}
    local function add(v)
        v = string.lower(tostring(v or ""))
        if #v >= 4 and v ~= "-" then table.insert(tokens, v) end
    end
    add(CleanState.CurrentKosanID) -- UserID_RoomID lengkap
    add(CleanState.KosanOwner)     -- UserID pemilik
    add(LocalPlayer.UserId)
    add(LocalPlayer.Name)
    add(LocalPlayer.DisplayName)
    return tokens
end

-- Apakah objek (atau salah satu parent-nya sampai Workspace) milik kosan kita?
-- Dicek lewat nama dan Attribute (mis. Owner / UserId / KosanID).
local function isOwnedByMe(inst, tokens)
    local node = inst
    while node and node ~= Workspace and node ~= game do
        local lname = string.lower(node.Name)
        for _, tk in ipairs(tokens) do
            if string.find(lname, tk, 1, true) then return true end
        end

        local okAttr, attrs = pcall(function() return node:GetAttributes() end)
        if okAttr and attrs then
            for _, value in pairs(attrs) do
                local sv = string.lower(tostring(value))
                for _, tk in ipairs(tokens) do
                    if sv == tk or string.find(sv, tk, 1, true) then return true end
                end
            end
        end

        node = node.Parent
    end
    return false
end

local function logBinChoice(prompt, owned)
    if prompt == TrashState.LastBinLogged then return end
    TrashState.LastBinLogged = prompt
    if prompt then
        print(string.format("[IndoKost] Tong dipilih (%s): %s",
            owned and "cocok owner" or "fallback terdekat", prompt:GetFullName()))
    else
        warn("[IndoKost] Tidak ada tong milik kosan sendiri yang ditemukan (cek ID kosan / DisposeFallbackRadius)")
    end
end

local function findNearestTrashPrompt(isDispose)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local ownOnly = isDispose and TrashConfig.OwnBinOnly
    local tokens = ownOnly and ownerTokens() or nil
    local anchor = TrashState.HomePos or hrp.Position

    local best, bestDist = nil, math.huge   -- terdekat (atau terdekat milik sendiri)
    local fb, fbDist = nil, math.huge       -- cadangan: terdekat dari jangkar kosan

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local sig = promptSignature(obj)
            local isBin = hasKeyword(sig, TrashConfig.DisposeKeywords)
            local match
            if isDispose then
                match = isBin
            else
                -- Pick up: cocok "sampah" tapi BUKAN tempat sampah
                match = (not isBin) and hasKeyword(sig, TrashConfig.PickupKeywords)
            end

            if match then
                local pos = promptPosition(obj)
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if ownOnly then
                        if isOwnedByMe(obj, tokens) then
                            if dist < bestDist then
                                bestDist = dist
                                best = obj
                            end
                        elseif TrashConfig.DisposeFallbackRadius > 0 then
                            local d2 = (pos - anchor).Magnitude
                            if d2 <= TrashConfig.DisposeFallbackRadius and d2 < fbDist then
                                fbDist = d2
                                fb = obj
                            end
                        end
                    elseif dist < bestDist then
                        bestDist = dist
                        best = obj
                    end
                end
            end
        end
    end

    if ownOnly then
        local chosen = best or fb
        logBinChoice(chosen, best ~= nil)
        return chosen
    end
    return best
end

-- Hitung sampah yang sedang dibawa (Tool di Backpack / Character)
local function getCarriedTrash()
    local n = 0
    local function scan(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and hasKeyword(string.lower(item.Name), TrashConfig.PickupKeywords) then
                n += 1
            end
        end
    end
    scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
    scan(LocalPlayer.Character)
    return n
end

-- Cek notifikasi "penuh" yang tampil di layar
local function guiShown(obj)
    local inst = obj
    while inst and inst ~= PlayerGui do
        if inst.Name == "IndoKostUltraHub" then return false end
        if inst:IsA("GuiObject") and not inst.Visible then return false end
        if inst:IsA("ScreenGui") and not inst.Enabled then return false end
        inst = inst.Parent
    end
    return true
end

local lastNoticeScan = 0
local function fullNoticeVisible()
    if os.clock() - lastNoticeScan < 1 then
        return TrashState.NoticeCached
    end
    lastNoticeScan = os.clock()

    local found = false
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text ~= "" and obj.TextTransparency < 1 and guiShown(obj) then
            if hasKeyword(string.lower(obj.Text), TrashConfig.FullKeywords) then
                found = true
                break
            end
        end
    end
    TrashState.NoticeCached = found
    return found
end

local function isTrashFull()
    local carried = getCarriedTrash()
    if carried > 0 then TrashState.ToolDetected = true end

    -- 1) Jumlah sampah di tas mencapai kapasitas
    if carried >= TrashConfig.MaxCarry then return true end
    -- 2) Muncul notifikasi tas penuh di layar
    if fullNoticeVisible() then return true end
    -- 3) Cadangan (sampah bukan Tool): hitung jumlah pick up
    if not TrashState.ToolDetected and TrashState.PickedSinceDispose >= TrashConfig.MaxCarry then
        return true
    end
    return false
end

local function isTrashEmpty()
    if TrashState.DisposedThisPhase < 1 then return false end
    if TrashState.ToolDetected then
        return getCarriedTrash() == 0
    end
    local need = math.clamp(TrashState.PickedSinceDispose, 1, TrashConfig.MaxCarry)
    return TrashState.DisposedThisPhase >= need
end

-- Baca persen kebersihan rumah dari UI game (teks berisi angka + "%")
-- Return: angka 0-100, atau nil bila tidak ditemukan
local lastPctScan = 0
local cachedPct = nil
local function readCleanPercent()
    if os.clock() - lastPctScan < 0.5 then
        return cachedPct
    end
    lastPctScan = os.clock()

    local found = nil
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" and guiShown(obj) then
            local text = string.lower(obj.Text)
            local num = string.match(text, "(%d+%.?%d*)%s*%%")
            if num then
                -- Cocokkan teks + nama objek & 3 parent dengan kata kunci kebersihan
                local parts = { text, obj.Name }
                local inst = obj.Parent
                for _ = 1, 3 do
                    if not inst or inst == PlayerGui then break end
                    table.insert(parts, string.lower(inst.Name))
                    inst = inst.Parent
                end
                if hasKeyword(table.concat(parts, " "), TrashConfig.CleanPercentKeywords) then
                    found = tonumber(num)
                    break
                end
            end
        end
    end

    cachedPct = found
    return found
end

-- Return: "noprompt" | "nofire" | "ok"
local function trashStep(isDispose)
    local prompt = findNearestTrashPrompt(isDispose)
    if not prompt then return "noprompt" end

    if CleanState.USE_TELEPORT then
        local pos = promptPosition(prompt)
        if pos then
            safeTeleport(pos)
            task.wait(0.06)
        end
    end

    local ok = pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        prompt.HoldDuration = 0
        if not firePrompt(prompt) then error("firePrompt gagal") end
    end)

    if not ok then return "nofire" end

    if isDispose then
        TrashState.DisposeCount += 1
        TrashState.DisposedThisPhase += 1
    else
        local hp = promptPosition(prompt)
        if hp then TrashState.HomePos = hp end
        TrashState.PickupCount += 1
        TrashState.PickedSinceDispose += 1
    end
    return "ok"
end

local isCleanRunning = false
local cleanThread = nil

-- Buang cepat: cari tong 1x, TP 1x, lalu buang semua sampah berturut-turut
-- Return: "noprompt" | "nofire" | "ok"
local function disposeBurst()
    local prompt = findNearestTrashPrompt(true)
    if not prompt then return "noprompt" end

    if CleanState.USE_TELEPORT then
        local pos = promptPosition(prompt)
        if pos then
            safeTeleport(pos)
            task.wait(TrashConfig.DisposeSettleDelay)
        end
    end

    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        prompt.HoldDuration = 0
    end)

    local shots
    if TrashState.ToolDetected then
        shots = math.max(getCarriedTrash(), 1)
    else
        shots = math.clamp(TrashState.PickedSinceDispose, 1, TrashConfig.MaxCarry)
    end

    local fired = 0
    for _ = 1, shots do
        if not isCleanRunning or not isScriptRunning then break end
        if not prompt.Parent or not prompt.Enabled then break end

        if not firePrompt(prompt) then break end
        fired += 1
        TrashState.DisposeCount += 1
        TrashState.DisposedThisPhase += 1

        if TrashState.ToolDetected and getCarriedTrash() == 0 then break end
        task.wait(TrashConfig.DisposeFireDelay)
    end

    return fired > 0 and "ok" or "nofire"
end

local function setCleanPhase(phase)
    local prev = TrashState.Phase
    TrashState.Phase = phase
    if phase == "BUANG" then
        TrashState.DisposedThisPhase = 0
    elseif phase == "BERSIH" and prev == "BUANG" then
        TrashState.PickedSinceDispose = 0
    end
    onTrashUpdate()
end

-- ========================================================
-- BACKGROUND WORKERS (DILENGKAPI JARAK JAUH)
-- ========================================================
local isPlantRunning = false
local plantThread = nil

local function executePlantCycle()
    local activePlots = getActivePlots()
    if #activePlots == 0 then return end

    -- Radius khusus Plot 4: hanya tanam plot yang berjarak <= PLOT4_RADIUS dari karakter
    local lahanName = LAHAN_CATEGORIES[currentLahanIndex] or ""
    -- (dilewati bila Auto TP aktif, karena karakter akan teleport ke plotnya sendiri)
    if not PlantConfig.USE_TELEPORT and string.sub(lahanName, 1, 6) == "Plot 4" then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local inRange = {}
            for _, plotPos in ipairs(activePlots) do
                if (plotPos - hrp.Position).Magnitude <= PlantConfig.PLOT4_RADIUS then
                    table.insert(inRange, plotPos)
                end
            end
            activePlots = inRange
        end

        if #activePlots == 0 then
            task.wait(1) -- tidak ada plot dalam radius, cek lagi sebentar
            return
        end
    end

    if beliBibitRF then
        local buySuccess, buyErr = pcall(function()
            return beliBibitRF:InvokeServer(PlantConfig.CROP_NAME, PlantConfig.BUY_COUNT)
        end)
        if not buySuccess then
            warn("[AutoFarm Error]: Beli bibit gagal:", buyErr)
        end
    end

    task.wait(PlantConfig.INTER_ACTION_DELAY)

    for index, plotPos in ipairs(activePlots) do
        if not isPlantRunning or not isScriptRunning then break end

        if PlantConfig.USE_TELEPORT then
            safeTeleport(plotPos)
            task.wait(PlantConfig.TP_SETTLE_DELAY)
            if not isPlantRunning or not isScriptRunning then break end
        end

        if tanamRF then
            local plantSuccess, plantErr = pcall(function()
                return tanamRF:InvokeServer(PlantConfig.CROP_NAME, plotPos)
            end)
            if not plantSuccess then
                warn(string.format("[AutoFarm Error]: Plot #%d gagal: %s", index, tostring(plantErr)))
            end
        end

        task.wait(PlantConfig.INTER_ACTION_DELAY)
    end
end

local function startPlantingLoop()
    plantThread = task.spawn(function()
        while isPlantRunning and isScriptRunning do
            executePlantCycle()
            task.wait(PlantConfig.CYCLE_COOLDOWN)
        end
    end)
end

local function stopPlantingLoop()
    isPlantRunning = false
    if plantThread then
        task.cancel(plantThread)
        plantThread = nil
    end
end

local function cleanDirtStep(target)
    -- Mode Jarak Jauh: Teleport ke dekat kotoran
    if CleanState.USE_TELEPORT then
        safeTeleport(target.Position)
        task.wait(0.06)
    end

    fireCleanSignal(CleanState.CurrentKosanID)

    -- Bypass jarak ProximityPrompt kotoran
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        prompt.HoldDuration = 0
        if prompt.Enabled then
            pcall(firePrompt, prompt)
        end
    end
end

-- Alur: BERSIH (kotoran) > TUNGGU (sampah muncul) > AMBIL (sampai penuh) > BUANG > BERSIH ...
local function startCleaningLoop()
    cleanThread = task.spawn(function()
        local noDirtStreak = 0
        local noPromptStreak = 0
        local disposeStart = 0
        local waitFullStart = nil

        setCleanPhase("BERSIH")

        while isCleanRunning and isScriptRunning do
            local phase = TrashState.Phase

            if not TrashState.Enabled then
                -- Mode sampah dimatikan: hanya bersihkan kotoran seperti biasa
                phase = "BERSIH"
                if TrashState.Phase ~= "BERSIH" then setCleanPhase("BERSIH") end
            end

            if phase == "BERSIH" then
                if TrashState.Enabled then
                    TrashState.CleanPercent = readCleanPercent()
                end

                local target = findNearestDirt()
                if target then
                    noDirtStreak = 0
                    waitFullStart = nil
                    cleanDirtStep(target)
                else
                    noDirtStreak += 1
                    if TrashState.Enabled and noDirtStreak >= TrashConfig.CleanDoneStreak then
                        -- Tidak ada kotoran: pastikan kebersihan sudah 100% dulu
                        local pct = TrashConfig.RequireFullClean and TrashState.CleanPercent or nil
                        local done = (pct == nil) or (pct >= 100)

                        if not done and TrashConfig.CleanPercentTimeout > 0 then
                            waitFullStart = waitFullStart or os.clock()
                            if os.clock() - waitFullStart >= TrashConfig.CleanPercentTimeout then
                                done = true
                            end
                        end

                        if done then
                            noDirtStreak = 0
                            waitFullStart = nil
                            -- Rumah 100% bersih -> tunggu sampah muncul
                            setCleanPhase("TUNGGU")
                        end
                    end
                end

            elseif phase == "TUNGGU" then
                if findNearestDirt() then
                    -- Ada kotoran baru: bersihkan dulu
                    setCleanPhase("BERSIH")
                elseif findNearestTrashPrompt(false) then
                    -- Sampah sudah muncul: mulai ambil
                    noPromptStreak = 0
                    setCleanPhase("AMBIL")
                end

            elseif phase == "AMBIL" then
                local result = trashStep(false)
                noPromptStreak = (result == "ok") and 0 or (noPromptStreak + 1)

                local full = isTrashFull()
                local noMore = noPromptStreak >= TrashConfig.NoPromptLimit
                local carrying = getCarriedTrash() > 0 or TrashState.PickedSinceDispose > 0

                if full or (noMore and carrying) then
                    -- Penuh (atau sampah habis tapi masih bawa) -> buang
                    noPromptStreak = 0
                    disposeStart = os.clock()
                    setCleanPhase("BUANG")
                elseif noMore then
                    -- Tidak ada sampah lagi dan tidak membawa apa-apa -> tunggu lagi
                    noPromptStreak = 0
                    setCleanPhase("TUNGGU")
                end

            elseif phase == "BUANG" then
                local result = disposeBurst()
                noPromptStreak = (result == "ok") and 0 or (noPromptStreak + 1)

                local timedOut = (os.clock() - disposeStart) >= TrashConfig.DisposePhaseTimeout
                local noBin = noPromptStreak >= TrashConfig.NoPromptLimit
                if isTrashEmpty() or timedOut or noBin then
                    noPromptStreak = 0
                    noDirtStreak = 0
                    setCleanPhase("BERSIH")
                end
            end

            onTrashUpdate()
            if TrashState.Phase == "BUANG" then
                task.wait(math.min(CleanState.LoopInterval, TrashConfig.DisposeLoopInterval))
            else
                task.wait(CleanState.LoopInterval)
            end
        end
    end)
end

local function stopCleaningLoop()
    isCleanRunning = false
    if cleanThread then
        task.cancel(cleanThread)
        cleanThread = nil
    end
    TrashState.Phase = "BERSIH"
    TrashState.PickedSinceDispose = 0
    TrashState.DisposedThisPhase = 0
    TrashState.CleanPercent = nil
    onTrashUpdate()
end

-- ========================================================
-- AUTO ACC PENYEWA
-- ========================================================
local TenantConfig = {
    Interval = 1,          -- detik antar permintaan terima penyewa
    SpinAt = 10,           -- spin gratis saat jumlah penyewa mencapai angka ini
    SpinPollInterval = 2,  -- detik antar pengecekan jumlah penyewa
    -- Kata kunci untuk mencari jumlah penyewa di UI / attribute (huruf kecil)
    TenantKeywords = { "penyewa", "tenant" }
}

local TenantState = {
    Running = false,
    CallCount = 0,
    AcceptCount = 0,
    SpinEnabled = false,
    SpinArmed = true,      -- siap spin; aktif lagi setelah jumlah penyewa turun di bawah SpinAt
    SpinBaseline = 0,      -- cadangan: jumlah penyewa diterima yang sudah dipakai untuk spin
    SpinCount = 0,
    DetectedTenants = nil, -- jumlah penyewa terdeteksi
    DetectSource = "-"
}

local tenantRF = nil
local tenantThread = nil
local onTenantUpdate = function() end -- diisi oleh GUI

local function getTenantRemote()
    if tenantRF and tenantRF.Parent then return tenantRF end
    pcall(function()
        tenantRF = ReplicatedStorage
            :WaitForChild("NKSystem", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("PenyewaService", 5)
            :WaitForChild("RF", 5)
            :WaitForChild("Respond", 5)
    end)
    return tenantRF
end

local spinRF = nil
local function getSpinRemote()
    if spinRF and spinRF.Parent then return spinRF end
    pcall(function()
        spinRF = ReplicatedStorage
            :WaitForChild("NKSystem", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("GachaService", 5)
            :WaitForChild("RF", 5)
            :WaitForChild("SpinX10WithFree", 5)
    end)
    return spinRF
end

-- Deteksi jumlah penyewa saat ini.
-- Return: jumlah (angka), sumber ("UI" / "Attr"), atau nil bila tidak ditemukan
local function readTenantCount()
    -- 1) UI: teks seperti "Penyewa: 10/10" atau "Penyewa 10"
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" and guiShown(obj) then
            local text = string.lower(obj.Text)

            local parts = { text, string.lower(obj.Name) }
            local inst = obj.Parent
            for _ = 1, 3 do
                if not inst or inst == PlayerGui then break end
                table.insert(parts, string.lower(inst.Name))
                inst = inst.Parent
            end

            if hasKeyword(table.concat(parts, " "), TenantConfig.TenantKeywords) then
                -- Format "x/y" (mis. 10/10)
                local cur = string.match(text, "(%d+)%s*/%s*%d+")
                if cur then return tonumber(cur), "UI" end

                -- Format "penyewa: 10"
                for _, kw in ipairs(TenantConfig.TenantKeywords) do
                    local n = string.match(text, kw .. "%D*(%d+)")
                    if n then return tonumber(n), "UI" end
                end
            end
        end
    end

    -- 2) Attribute pemain
    local okAttr, attrs = pcall(function() return LocalPlayer:GetAttributes() end)
    if okAttr and attrs then
        for name, value in pairs(attrs) do
            if type(value) == "number" and hasKeyword(string.lower(name), TenantConfig.TenantKeywords) then
                return value, "Attr"
            end
        end
    end

    -- 3) leaderstats / Value di dalam pemain
    for _, child in ipairs(LocalPlayer:GetDescendants()) do
        if (child:IsA("NumberValue") or child:IsA("IntValue"))
            and hasKeyword(string.lower(child.Name), TenantConfig.TenantKeywords) then
            return child.Value, "Value"
        end
    end

    return nil, "-"
end

local spinRF = nil
local function getSpinRemote()
    if spinRF and spinRF.Parent then return spinRF end
    pcall(function()
        spinRF = ReplicatedStorage
            :WaitForChild("NKSystem", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("GachaService", 5)
            :WaitForChild("RF", 5)
            :WaitForChild("SpinX10WithFree", 5)
    end)
    return spinRF
end

local function doSpin()
    local rf = getSpinRemote()
    if not rf then
        warn("[AutoSpin]: Remote GachaService.SpinX10WithFree tidak ditemukan")
        return false
    end

    local ok, result = pcall(function()
        return rf:InvokeServer()
    end)
    if ok then
        TenantState.SpinCount += 1
    else
        warn("[AutoSpin Error]:", result)
    end
    return ok
end

-- Watcher: spin gacha otomatis saat penyewa sudah 10
local spinWatcher = nil

local function startSpinWatcher()
    if spinWatcher then return end
    spinWatcher = task.spawn(function()
        while TenantState.SpinEnabled and isScriptRunning do
            local count, source = readTenantCount()
            TenantState.DetectedTenants = count
            TenantState.DetectSource = source

            if count ~= nil then
                if count >= TenantConfig.SpinAt then
                    if TenantState.SpinArmed then
                        TenantState.SpinArmed = false -- cegah spin berulang selama penyewa masih >= 10
                        doSpin()
                    end
                else
                    TenantState.SpinArmed = true -- penyewa turun: siap spin lagi saat mencapai 10
                end
            else
                -- Cadangan: jumlah penyewa tidak terbaca -> hitung dari yang diterima script
                if TenantState.AcceptCount - TenantState.SpinBaseline >= TenantConfig.SpinAt then
                    TenantState.SpinBaseline += TenantConfig.SpinAt
                    doSpin()
                end
            end

            onTenantUpdate()
            task.wait(TenantConfig.SpinPollInterval)
        end
        spinWatcher = nil
    end)
end

local function stopSpinWatcher()
    TenantState.SpinEnabled = false
    if spinWatcher then
        task.cancel(spinWatcher)
        spinWatcher = nil
    end
end

local function startTenantWorker()
    if tenantThread then return end
    tenantThread = task.spawn(function()
        while TenantState.Running and isScriptRunning do
            local rf = getTenantRemote()
            if rf then
                local ok, result = pcall(function()
                    return rf:InvokeServer(true) -- true = terima penyewa
                end)
                if ok then
                    TenantState.CallCount += 1
                    if result == true then
                        TenantState.AcceptCount += 1
                    end
                    onTenantUpdate()
                else
                    warn("[AutoAccPenyewa Error]:", result)
                end
            else
                warn("[AutoAccPenyewa]: Remote PenyewaService.Respond tidak ditemukan")
            end
            task.wait(TenantConfig.Interval)
        end
        tenantThread = nil
    end)
end

local function stopTenantWorker()
    TenantState.Running = false
    if tenantThread then
        task.cancel(tenantThread)
        tenantThread = nil
    end
end

-- ========================================================
-- ANTI-AFK (CEGAH KICK IDLE 20 MENIT)
-- ========================================================
local isAntiAfkRunning = false
local antiAfkConn = nil
local antiAfkThread = nil
local ANTI_AFK_INTERVAL = 55 -- detik, sinyal cadangan berkala

local function antiAfkPulse()
    local ok = pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)

    if not ok then
        -- Cadangan bila VirtualUser tidak tersedia di executor
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

local function startAntiAfk()
    if antiAfkConn then return end

    -- Respon saat Roblox mendeteksi karakter idle
    antiAfkConn = LocalPlayer.Idled:Connect(antiAfkPulse)

    -- Sinyal cadangan berkala
    antiAfkThread = task.spawn(function()
        while isAntiAfkRunning and isScriptRunning do
            task.wait(ANTI_AFK_INTERVAL)
            if not isAntiAfkRunning or not isScriptRunning then break end
            antiAfkPulse()
        end
    end)
end

local function stopAntiAfk()
    isAntiAfkRunning = false
    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
    if antiAfkThread then
        task.cancel(antiAfkThread)
        antiAfkThread = nil
    end
end

-- ========================================================
-- AUTO ISI PAKAN DOMBA (TernakService.IsiPakan)
-- ========================================================
local TernakConfig = {
    Slots = { 1, 2 },   -- nomor kandang/slot domba yang diisi pakannya
    Interval = 5,       -- detik antar siklus (satu siklus = isi semua slot)
    CallsPerSlot = 2,   -- tiap slot dipanggil 2x berturut-turut (sesuai log: 1,1,2,2)
    RepeatDelay = 0.15, -- detik antar pemanggilan di slot yang sama
    CallDelay = 0.3     -- detik antar slot dalam satu siklus
}

local TernakState = {
    Running = false,
    FillCount = 0,      -- jumlah isi pakan yang berhasil (ok = true)
    SkipCount = 0,      -- ditolak server (mis. pakan masih penuh / stok habis)
    LastStok = nil,
    LastJumlah = nil,
    LastNama = "-"
}

local pakanRF = nil
local ternakThread = nil
local onTernakUpdate = function() end -- diisi oleh GUI

local function getPakanRemote()
    if pakanRF and pakanRF.Parent then return pakanRF end
    pcall(function()
        pakanRF = ReplicatedStorage
            :WaitForChild("NKSystem", 5)
            :WaitForChild("Packages", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("TernakService", 5)
            :WaitForChild("RF", 5)
            :WaitForChild("IsiPakan", 5)
    end)
    return pakanRF
end

-- Isi pakan satu slot. Return true bila server menjawab ok = true
local function feedSlot(slot)
    local rf = getPakanRemote()
    if not rf then
        warn("[AutoPakan]: Remote TernakService.IsiPakan tidak ditemukan")
        return false
    end

    local okCall, result = pcall(function()
        return rf:InvokeServer(slot)
    end)

    if okCall and type(result) == "table" and result.ok then
        TernakState.FillCount += 1
        TernakState.LastStok = result.stok
        TernakState.LastJumlah = result.jumlah
        TernakState.LastNama = tostring(result.nama or "-")
        print(string.format("[IsiPakan] Slot %s OK | %s stok: %s | jumlah: %s",
            tostring(slot), TernakState.LastNama, tostring(result.stok), tostring(result.jumlah)))
        return true
    end

    TernakState.SkipCount += 1
    warn(string.format("[IsiPakan] Slot %s gagal/ditolak server", tostring(slot)))
    if not okCall then
        warn("[AutoPakan Error]:", result)
    elseif type(result) == "table" and result.stok ~= nil then
        TernakState.LastStok = result.stok
    end
    return false
end

local function startTernakWorker()
    if ternakThread then return end
    ternakThread = task.spawn(function()
        while TernakState.Running and isScriptRunning do
            for _, slot in ipairs(TernakConfig.Slots) do
                if not TernakState.Running or not isScriptRunning then break end
                for call = 1, TernakConfig.CallsPerSlot do
                    if not TernakState.Running or not isScriptRunning then break end
                    feedSlot(slot)
                    onTernakUpdate()
                    if call < TernakConfig.CallsPerSlot then
                        task.wait(TernakConfig.RepeatDelay)
                    end
                end
                task.wait(TernakConfig.CallDelay)
            end
            task.wait(TernakConfig.Interval)
        end
        ternakThread = nil
    end)
end

local function stopTernakWorker()
    TernakState.Running = false
    if ternakThread then
        task.cancel(ternakThread)
        ternakThread = nil
    end
end

-- Isi pakan manual: semua slot, sekali jalan, dari mana saja (tanpa mendekat/teleport)
-- Return: jumlah panggilan ok, total panggilan
local function feedAllOnce()
    local okCount, total = 0, 0
    for _, slot in ipairs(TernakConfig.Slots) do
        for call = 1, TernakConfig.CallsPerSlot do
            if not isScriptRunning then return okCount, total end
            total += 1
            if feedSlot(slot) then okCount += 1 end
            onTernakUpdate()
            if call < TernakConfig.CallsPerSlot then
                task.wait(TernakConfig.RepeatDelay)
            end
        end
        task.wait(TernakConfig.CallDelay)
    end
    return okCount, total
end

-- ========================================================
-- HIGH-END CYBER GUI DESIGN (SMITH GANTENG)
-- ========================================================
-- Ukuran GUI sedang (menyesuaikan layar, tidak lebih kecil dari 340x445)
local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
local WIN_WIDTH = math.clamp(400, 340, math.max(340, viewport.X - 20))
local WIN_HEIGHT = math.clamp(500, 445, math.max(445, viewport.Y - 40))
local MINI_HEIGHT = 46

local TWEEN_SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Matikan instance lama bila script dijalankan ulang
do
    local genv = (typeof(getgenv) == "function" and getgenv()) or _G
    if genv.__IndoKostShutdown then
        pcall(genv.__IndoKostShutdown)
        genv.__IndoKostShutdown = nil
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IndoKostUltraHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Pasang GUI: gethui > CoreGui > PlayerGui (otomatis pilih yang tersedia)
do
    if syn and typeof(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, ScreenGui)
    end

    local mounted = false

    if typeof(gethui) == "function" then
        local okHui, hui = pcall(gethui)
        if okHui and hui then
            pcall(function() ScreenGui.Parent = hui end)
            mounted = ScreenGui.Parent ~= nil
        end
    end

    if not mounted and CoreGui then
        pcall(function() ScreenGui.Parent = CoreGui end)
        mounted = ScreenGui.Parent ~= nil
    end

    if not mounted then
        ScreenGui.Parent = PlayerGui
    end
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, WIN_WIDTH, 0, WIN_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -WIN_WIDTH / 2, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(48, 52, 74)
MainStroke.Thickness = 1.4

local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Rotation = 45
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(18, 20, 29)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(11, 13, 19))
})

-- ========================================================
-- HEADER BAR
-- ========================================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, MINI_HEIGHT)
Header.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 14)

local HeaderStroke = Instance.new("UIStroke", Header)
HeaderStroke.Color = Color3.fromRGB(38, 42, 60)
HeaderStroke.Thickness = 1

-- Logo Icon Box
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 28, 0, 28)
LogoBox.Position = UDim2.new(0, 12, 0.5, -14)
LogoBox.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
LogoBox.BorderSizePixel = 0
LogoBox.Parent = Header
Instance.new("UICorner", LogoBox).CornerRadius = UDim.new(0, 7)

local LogoGrad = Instance.new("UIGradient", LogoBox)
LogoGrad.Rotation = 45
LogoGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 130, 246))
})

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Font = Enum.Font.GothamBold
LogoText.Text = "⚡"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 14
LogoText.Parent = LogoBox

-- Title & Creator Subtitle (Smith Ganteng)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -160, 0, 18)
TitleLabel.Position = UDim2.new(0, 48, 0, 7)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "INDO-KOST HUB"
TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Size = UDim2.new(1, -160, 0, 14)
SubTitleLabel.Position = UDim2.new(0, 48, 0, 25)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Font = Enum.Font.GothamBold
SubTitleLabel.Text = "👑 SMITH GANTENG"
SubTitleLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
SubTitleLabel.TextSize = 9
SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLabel.Parent = Header

-- Control Buttons (Minimize & Close)
local HeaderControls = Instance.new("Frame")
HeaderControls.Size = UDim2.new(0, 68, 1, 0)
HeaderControls.Position = UDim2.new(1, -74, 0, 0)
HeaderControls.BackgroundTransparency = 1
HeaderControls.Parent = Header

local ControlsLayout = Instance.new("UIListLayout", HeaderControls)
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlsLayout.Padding = UDim.new(0, 6)

local function createHeaderIconBtn(symbol, bgHover, txtColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(29, 32, 46)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = symbol
    btn.TextColor3 = txtColor or Color3.fromRGB(180, 185, 205)
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = HeaderControls
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", btn)
    st.Color = Color3.fromRGB(45, 48, 68)
    st.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = bgHover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(29, 32, 46) }):Play()
    end)

    return btn
end

local MiniBtn = createHeaderIconBtn("—", Color3.fromRGB(48, 52, 75))
local CloseBtn = createHeaderIconBtn("✕", Color3.fromRGB(225, 29, 72), Color3.fromRGB(255, 120, 140))

-- ========================================================
-- TAB BAR (PILL SEGMENTED CONTROLS)
-- ========================================================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.new(0, 12, 0, MINI_HEIGHT + 8)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)
local tabStroke = Instance.new("UIStroke", TabBar)
tabStroke.Color = Color3.fromRGB(36, 40, 58)
tabStroke.Thickness = 1

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabListLayout.Padding = UDim.new(0, 6)

local function createTabPill(title)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / 5, -6, 1, -6)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(130, 135, 155)
    btn.TextSize = 10
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    local sizeLimit = Instance.new("UITextSizeConstraint", btn)
    sizeLimit.MaxTextSize = 10
    sizeLimit.MinTextSize = 6
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local TabPlantBtn = createTabPill("🌱 PLANT")
local TabCleanBtn = createTabPill("🧹 CLEAN")
local TabTenantBtn = createTabPill("🏠 SEWA")
local TabAfkBtn   = createTabPill("🛡️ AFK")
local TabTernakBtn = createTabPill("🐑 TERNAK")

-- ========================================================
-- CONTENT CONTAINER
-- ========================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -24, 1, -(MINI_HEIGHT + 80))
ContentFrame.Position = UDim2.new(0, 12, 0, MINI_HEIGHT + 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local function createModernCard(parent, height, posY)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.Position = UDim2.new(0, 0, 0, posY)
    card.BackgroundColor3 = Color3.fromRGB(21, 23, 33)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(36, 40, 58)
    stroke.Thickness = 1
    return card
end

-- ========================================================
-- TAB 1: AUTO PLANT PAGE
-- ========================================================
local PlantPage = Instance.new("Frame")
PlantPage.Name = "PlantPage"
PlantPage.Size = UDim2.new(1, 0, 1, 0)
PlantPage.BackgroundTransparency = 1
PlantPage.Visible = true
PlantPage.Parent = ContentFrame

-- Card 1: Target Bibit & Live Status
local PlantStatusCard = createModernCard(PlantPage, 48, 0)

local PlantCardIcon = Instance.new("TextLabel")
PlantCardIcon.Size = UDim2.new(0, 24, 0, 24)
PlantCardIcon.Position = UDim2.new(0, 12, 0.5, -12)
PlantCardIcon.BackgroundTransparency = 1
PlantCardIcon.Font = Enum.Font.GothamBold
PlantCardIcon.Text = "🌶️"
PlantCardIcon.TextSize = 16
PlantCardIcon.Parent = PlantStatusCard

local PlantTargetLabel = Instance.new("TextLabel")
PlantTargetLabel.Size = UDim2.new(1, -120, 0, 16)
PlantTargetLabel.Position = UDim2.new(0, 42, 0, 8)
PlantTargetLabel.BackgroundTransparency = 1
PlantTargetLabel.Font = Enum.Font.GothamBold
PlantTargetLabel.Text = "Tanaman: " .. PlantConfig.CROP_NAME
PlantTargetLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
PlantTargetLabel.TextSize = 11
PlantTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
PlantTargetLabel.Parent = PlantStatusCard

local PlantSubStatus = Instance.new("TextLabel")
PlantSubStatus.Size = UDim2.new(1, -120, 0, 14)
PlantSubStatus.Position = UDim2.new(0, 42, 0, 25)
PlantSubStatus.BackgroundTransparency = 1
PlantSubStatus.Font = Enum.Font.Gotham
PlantSubStatus.Text = "Status: Siap Beroperasi"
PlantSubStatus.TextColor3 = Color3.fromRGB(140, 145, 165)
PlantSubStatus.TextSize = 10
PlantSubStatus.TextXAlignment = Enum.TextXAlignment.Left
PlantSubStatus.Parent = PlantStatusCard

local PlantStatusBadge = Instance.new("Frame")
PlantStatusBadge.Size = UDim2.new(0, 68, 0, 22)
PlantStatusBadge.Position = UDim2.new(1, -78, 0.5, -11)
PlantStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
PlantStatusBadge.BorderSizePixel = 0
PlantStatusBadge.Parent = PlantStatusCard
Instance.new("UICorner", PlantStatusBadge).CornerRadius = UDim.new(0, 6)

local PlantBadgeText = Instance.new("TextLabel")
PlantBadgeText.Size = UDim2.new(1, 0, 1, 0)
PlantBadgeText.BackgroundTransparency = 1
PlantBadgeText.Font = Enum.Font.GothamBold
PlantBadgeText.Text = "● IDLE"
PlantBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
PlantBadgeText.TextSize = 9
PlantBadgeText.Parent = PlantStatusBadge

-- Card 2: Lahan Selector (Interactive Stepper)
local LahanCard = createModernCard(PlantPage, 84, 54)

local LahanCardTitle = Instance.new("TextLabel")
LahanCardTitle.Size = UDim2.new(1, -24, 0, 16)
LahanCardTitle.Position = UDim2.new(0, 12, 0, 8)
LahanCardTitle.BackgroundTransparency = 1
LahanCardTitle.Font = Enum.Font.GothamBold
LahanCardTitle.Text = "LOKASI LAHAN AKTIF"
LahanCardTitle.TextColor3 = Color3.fromRGB(99, 102, 241)
LahanCardTitle.TextSize = 9
LahanCardTitle.TextXAlignment = Enum.TextXAlignment.Left
LahanCardTitle.Parent = LahanCard

local LahanStepperBox = Instance.new("Frame")
LahanStepperBox.Size = UDim2.new(1, -24, 0, 34)
LahanStepperBox.Position = UDim2.new(0, 12, 0, 26)
LahanStepperBox.BackgroundColor3 = Color3.fromRGB(15, 16, 24)
LahanStepperBox.BorderSizePixel = 0
LahanStepperBox.Parent = LahanCard
Instance.new("UICorner", LahanStepperBox).CornerRadius = UDim.new(0, 6)
local stpStroke = Instance.new("UIStroke", LahanStepperBox)
stpStroke.Color = Color3.fromRGB(42, 46, 66)
stpStroke.Thickness = 1

local PrevLahanBtn = Instance.new("TextButton")
PrevLahanBtn.Size = UDim2.new(0, 32, 1, 0)
PrevLahanBtn.Position = UDim2.new(0, 0, 0, 0)
PrevLahanBtn.BackgroundTransparency = 1
PrevLahanBtn.Font = Enum.Font.GothamBold
PrevLahanBtn.Text = "◀"
PrevLahanBtn.TextColor3 = Color3.fromRGB(180, 185, 210)
PrevLahanBtn.TextSize = 11
PrevLahanBtn.AutoButtonColor = false
PrevLahanBtn.Parent = LahanStepperBox

local NextLahanBtn = Instance.new("TextButton")
NextLahanBtn.Size = UDim2.new(0, 32, 1, 0)
NextLahanBtn.Position = UDim2.new(1, -32, 0, 0)
NextLahanBtn.BackgroundTransparency = 1
NextLahanBtn.Font = Enum.Font.GothamBold
NextLahanBtn.Text = "▶"
NextLahanBtn.TextColor3 = Color3.fromRGB(180, 185, 210)
NextLahanBtn.TextSize = 11
NextLahanBtn.AutoButtonColor = false
NextLahanBtn.Parent = LahanStepperBox

local LahanDisplayBtn = Instance.new("TextButton")
LahanDisplayBtn.Size = UDim2.new(1, -64, 1, 0)
LahanDisplayBtn.Position = UDim2.new(0, 32, 0, 0)
LahanDisplayBtn.BackgroundTransparency = 1
LahanDisplayBtn.Font = Enum.Font.GothamBold
LahanDisplayBtn.Text = "📍 " .. LAHAN_CATEGORIES[currentLahanIndex] .. " (" .. #getActivePlots() .. " Plots)"
LahanDisplayBtn.TextColor3 = Color3.fromRGB(245, 245, 255)
LahanDisplayBtn.TextSize = 10
LahanDisplayBtn.AutoButtonColor = false
LahanDisplayBtn.Parent = LahanStepperBox

local LahanSubInfo = Instance.new("TextLabel")
LahanSubInfo.Size = UDim2.new(1, -24, 0, 14)
LahanSubInfo.Position = UDim2.new(0, 12, 0, 64)
LahanSubInfo.BackgroundTransparency = 1
LahanSubInfo.Font = Enum.Font.Gotham
LahanSubInfo.Text = "Tekan panah atau klik teks untuk mengganti lahan"
LahanSubInfo.TextColor3 = Color3.fromRGB(120, 125, 145)
LahanSubInfo.TextSize = 9
LahanSubInfo.TextXAlignment = Enum.TextXAlignment.Left
LahanSubInfo.Parent = LahanCard

-- Card 3: Parameter Tanam
local PlantConfigCard = createModernCard(PlantPage, 32, 144)

local ConfigInfoLabel = Instance.new("TextLabel")
ConfigInfoLabel.Size = UDim2.new(1, -24, 1, 0)
ConfigInfoLabel.Position = UDim2.new(0, 12, 0, 0)
ConfigInfoLabel.BackgroundTransparency = 1
ConfigInfoLabel.Font = Enum.Font.GothamMedium
ConfigInfoLabel.Text = string.format("⚡ Beli: %d | Delay: %.2fs | Cooldown: %.2fs | R4: %d", PlantConfig.BUY_COUNT, PlantConfig.INTER_ACTION_DELAY, PlantConfig.CYCLE_COOLDOWN, PlantConfig.PLOT4_RADIUS)
ConfigInfoLabel.TextColor3 = Color3.fromRGB(150, 155, 175)
ConfigInfoLabel.TextSize = 9
ConfigInfoLabel.TextXAlignment = Enum.TextXAlignment.Center
ConfigInfoLabel.Parent = PlantConfigCard

-- Card 4: Toggle Auto TP (Plant)
local PlantTpCard = createModernCard(PlantPage, 40, 182)

local PlantTpLabel = Instance.new("TextLabel")
PlantTpLabel.Size = UDim2.new(1, -90, 1, 0)
PlantTpLabel.Position = UDim2.new(0, 12, 0, 0)
PlantTpLabel.BackgroundTransparency = 1
PlantTpLabel.Font = Enum.Font.GothamBold
PlantTpLabel.Text = "🚀 Auto TP ke Plot"
PlantTpLabel.TextColor3 = Color3.fromRGB(230, 230, 245)
PlantTpLabel.TextSize = 10
PlantTpLabel.TextXAlignment = Enum.TextXAlignment.Left
PlantTpLabel.Parent = PlantTpCard

local TpPlantBtn = Instance.new("TextButton")
TpPlantBtn.Name = "TpPlantBtn"
TpPlantBtn.Size = UDim2.new(0, 60, 0, 24)
TpPlantBtn.Position = UDim2.new(1, -72, 0.5, -12)
TpPlantBtn.BackgroundColor3 = PlantConfig.USE_TELEPORT and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
TpPlantBtn.BorderSizePixel = 0
TpPlantBtn.Font = Enum.Font.GothamBold
TpPlantBtn.Text = PlantConfig.USE_TELEPORT and "ON" or "OFF"
TpPlantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpPlantBtn.TextSize = 10
TpPlantBtn.AutoButtonColor = false
TpPlantBtn.Parent = PlantTpCard
Instance.new("UICorner", TpPlantBtn).CornerRadius = UDim.new(0, 6)

-- Toggle Auto Plant Hero Button
local TogglePlantBtn = Instance.new("TextButton")
TogglePlantBtn.Name = "TogglePlantBtn"
TogglePlantBtn.Size = UDim2.new(1, 0, 0, 42)
TogglePlantBtn.Position = UDim2.new(0, 0, 1, -44)
TogglePlantBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
TogglePlantBtn.BorderSizePixel = 0
TogglePlantBtn.Font = Enum.Font.GothamBold
TogglePlantBtn.Text = "▶  START AUTO PLANT"
TogglePlantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePlantBtn.TextSize = 11
TogglePlantBtn.AutoButtonColor = false
TogglePlantBtn.Parent = PlantPage
Instance.new("UICorner", TogglePlantBtn).CornerRadius = UDim.new(0, 10)

local PlantBtnGrad = Instance.new("UIGradient", TogglePlantBtn)
PlantBtnGrad.Rotation = 45
PlantBtnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
})

-- ========================================================
-- TAB 2: AUTO CLEAN PAGE
-- ========================================================
local CleanPage = Instance.new("Frame")
CleanPage.Name = "CleanPage"
CleanPage.Size = UDim2.new(1, 0, 1, 0)
CleanPage.BackgroundTransparency = 1
CleanPage.Visible = false
CleanPage.Parent = ContentFrame

-- Card 1: Clean Status & Room
local CleanStatusCard = createModernCard(CleanPage, 48, 0)

local CleanCardIcon = Instance.new("TextLabel")
CleanCardIcon.Size = UDim2.new(0, 24, 0, 24)
CleanCardIcon.Position = UDim2.new(0, 12, 0.5, -12)
CleanCardIcon.BackgroundTransparency = 1
CleanCardIcon.Font = Enum.Font.GothamBold
CleanCardIcon.Text = "🧹"
CleanCardIcon.TextSize = 16
CleanCardIcon.Parent = CleanStatusCard

local CleanOwnerLabel = Instance.new("TextLabel")
CleanOwnerLabel.Size = UDim2.new(1, -120, 0, 16)
CleanOwnerLabel.Position = UDim2.new(0, 42, 0, 8)
CleanOwnerLabel.BackgroundTransparency = 1
CleanOwnerLabel.Font = Enum.Font.GothamBold
CleanOwnerLabel.Text = string.format("Owner: %s | Room: %s", CleanState.KosanOwner, CleanState.RoomNumber)
CleanOwnerLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
CleanOwnerLabel.TextSize = 11
CleanOwnerLabel.TextXAlignment = Enum.TextXAlignment.Left
CleanOwnerLabel.Parent = CleanStatusCard

local CleanSubStatus = Instance.new("TextLabel")
CleanSubStatus.Size = UDim2.new(1, -120, 0, 14)
CleanSubStatus.Position = UDim2.new(0, 42, 0, 25)
CleanSubStatus.BackgroundTransparency = 1
CleanSubStatus.Font = Enum.Font.Gotham
CleanSubStatus.Text = "Target: Objek Kotoran (Plastic)"
CleanSubStatus.TextColor3 = Color3.fromRGB(140, 145, 165)
CleanSubStatus.TextSize = 10
CleanSubStatus.TextXAlignment = Enum.TextXAlignment.Left
CleanSubStatus.Parent = CleanStatusCard

local CleanStatusBadge = Instance.new("Frame")
CleanStatusBadge.Size = UDim2.new(0, 68, 0, 22)
CleanStatusBadge.Position = UDim2.new(1, -78, 0.5, -11)
CleanStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
CleanStatusBadge.BorderSizePixel = 0
CleanStatusBadge.Parent = CleanStatusCard
Instance.new("UICorner", CleanStatusBadge).CornerRadius = UDim.new(0, 6)

local CleanBadgeText = Instance.new("TextLabel")
CleanBadgeText.Size = UDim2.new(1, 0, 1, 0)
CleanBadgeText.BackgroundTransparency = 1
CleanBadgeText.Font = Enum.Font.GothamBold
CleanBadgeText.Text = "● IDLE"
CleanBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
CleanBadgeText.TextSize = 9
CleanBadgeText.Parent = CleanStatusBadge

-- Card 2: Toggle Jarak Jauh (Auto TP Kotoran)
local CleanTpCard = createModernCard(CleanPage, 40, 54)

local CleanTpLabel = Instance.new("TextLabel")
CleanTpLabel.Size = UDim2.new(1, -90, 1, 0)
CleanTpLabel.Position = UDim2.new(0, 12, 0, 0)
CleanTpLabel.BackgroundTransparency = 1
CleanTpLabel.Font = Enum.Font.GothamBold
CleanTpLabel.Text = "🚀 Mode Jarak Jauh (Auto TP)"
CleanTpLabel.TextColor3 = Color3.fromRGB(230, 230, 245)
CleanTpLabel.TextSize = 10
CleanTpLabel.TextXAlignment = Enum.TextXAlignment.Left
CleanTpLabel.Parent = CleanTpCard

local TpCleanBtn = Instance.new("TextButton")
TpCleanBtn.Name = "TpCleanBtn"
TpCleanBtn.Size = UDim2.new(0, 60, 0, 24)
TpCleanBtn.Position = UDim2.new(1, -72, 0.5, -12)
TpCleanBtn.BackgroundColor3 = CleanState.USE_TELEPORT and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
TpCleanBtn.BorderSizePixel = 0
TpCleanBtn.Font = Enum.Font.GothamBold
TpCleanBtn.Text = CleanState.USE_TELEPORT and "ON" or "OFF"
TpCleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpCleanBtn.TextSize = 10
TpCleanBtn.AutoButtonColor = false
TpCleanBtn.Parent = CleanTpCard
Instance.new("UICorner", TpCleanBtn).CornerRadius = UDim.new(0, 6)

-- Card 3: Modern Inputs Container
local InputsCard = createModernCard(CleanPage, 126, 100)

local function createCyberInput(name, placeholder, defaultValue, labelText, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 0, 12)
    lbl.Position = UDim2.new(0, 12, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(99, 102, 241)
    lbl.TextSize = 8
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = InputsCard

    local box = Instance.new("TextBox")
    box.Name = name
    box.Size = UDim2.new(1, -24, 0, 24)
    box.Position = UDim2.new(0, 12, 0, posY + 14)
    box.BackgroundColor3 = Color3.fromRGB(15, 16, 24)
    box.BorderSizePixel = 0
    box.TextColor3 = Color3.fromRGB(240, 240, 250)
    box.Text = tostring(defaultValue)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(100, 105, 125)
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ClearTextOnFocus = false
    box.Parent = InputsCard
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    local bStroke = Instance.new("UIStroke", box)
    bStroke.Color = Color3.fromRGB(42, 46, 66)
    bStroke.Thickness = 1

    box.Focused:Connect(function()
        TweenService:Create(bStroke, TWEEN_FAST, { Color = Color3.fromRGB(99, 102, 241) }):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(bStroke, TWEEN_FAST, { Color = Color3.fromRGB(42, 46, 66) }):Play()
    end)

    return box
end

local IdInput     = createCyberInput("IdInput", "Contoh: UserID_RoomID", CleanState.CurrentKosanID, "ID KOSAN (USERID_ROOMID):", 6)
local RadiusInput = createCyberInput("RadiusInput", "Jarak deteksi studs", CleanState.Radius, "RADIUS DETEKSI (STUDS):", 46)
local LoopInput   = createCyberInput("LoopInput", "Delay loop detik", CleanState.LoopInterval, "LOOP INTERVAL (DETIK):", 86)

-- Card: Sampah Otomatis (Ambil + Buang) setelah rumah bersih
do
    local trashCard = createModernCard(CleanPage, 36, 232)

    local trashLabel = Instance.new("TextLabel")
    trashLabel.Size = UDim2.new(1, -90, 1, 0)
    trashLabel.Position = UDim2.new(0, 12, 0, 0)
    trashLabel.BackgroundTransparency = 1
    trashLabel.Font = Enum.Font.GothamBold
    trashLabel.Text = "🗑️ Sampah: Tunggu > Ambil > Buang"
    trashLabel.TextColor3 = Color3.fromRGB(230, 230, 245)
    trashLabel.TextSize = 10
    trashLabel.TextXAlignment = Enum.TextXAlignment.Left
    trashLabel.Parent = trashCard

    local trashBtn = Instance.new("TextButton")
    trashBtn.Name = "TrashToggleBtn"
    trashBtn.Size = UDim2.new(0, 60, 0, 22)
    trashBtn.Position = UDim2.new(1, -72, 0.5, -11)
    trashBtn.BackgroundColor3 = TrashState.Enabled and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
    trashBtn.BorderSizePixel = 0
    trashBtn.Font = Enum.Font.GothamBold
    trashBtn.Text = TrashState.Enabled and "ON" or "OFF"
    trashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    trashBtn.TextSize = 10
    trashBtn.AutoButtonColor = false
    trashBtn.Parent = trashCard
    Instance.new("UICorner", trashBtn).CornerRadius = UDim.new(0, 6)

    local PHASE_LABELS = {
        BERSIH = "BERSIHKAN",
        TUNGGU = "TUNGGU SAMPAH",
        AMBIL  = "AMBIL SAMPAH",
        BUANG  = "BUANG SAMPAH"
    }

    onTrashUpdate = function()
        if not isCleanRunning then
            CleanSubStatus.Text = "Target: Objek Kotoran (Plastic)"
            return
        end
        if not TrashState.Enabled then
            CleanSubStatus.Text = "Fase: BERSIHKAN (sampah OFF)"
            return
        end
        local label = PHASE_LABELS[TrashState.Phase] or TrashState.Phase
        if TrashState.Phase == "BERSIH" and TrashState.CleanPercent then
            label = string.format("%s %d%%", label, math.floor(TrashState.CleanPercent))
        end
        CleanSubStatus.Text = string.format("Fase: %s | Bawa: %d/%d", label, getCarriedTrash(), TrashConfig.MaxCarry)
    end

    table.insert(Connections, trashBtn.Activated:Connect(function()
        TrashState.Enabled = not TrashState.Enabled
        local col = TrashState.Enabled and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
        TweenService:Create(trashBtn, TWEEN_FAST, { BackgroundColor3 = col }):Play()
        trashBtn.Text = TrashState.Enabled and "ON" or "OFF"
        onTrashUpdate()
    end))
end

-- Toggle Auto Clean Hero Button
local ToggleCleanBtn = Instance.new("TextButton")
ToggleCleanBtn.Name = "ToggleCleanBtn"
ToggleCleanBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleCleanBtn.Position = UDim2.new(0, 0, 1, -44)
ToggleCleanBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
ToggleCleanBtn.BorderSizePixel = 0
ToggleCleanBtn.Font = Enum.Font.GothamBold
ToggleCleanBtn.Text = "▶  START AUTO CLEAN"
ToggleCleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleCleanBtn.TextSize = 11
ToggleCleanBtn.AutoButtonColor = false
ToggleCleanBtn.Parent = CleanPage
Instance.new("UICorner", ToggleCleanBtn).CornerRadius = UDim.new(0, 10)

local CleanBtnGrad = Instance.new("UIGradient", ToggleCleanBtn)
CleanBtnGrad.Rotation = 45
CleanBtnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
})

-- ========================================================
-- TAB 3: ANTI-AFK PAGE (TERPISAH)
-- ========================================================
local AfkPage = Instance.new("Frame")
AfkPage.Name = "AfkPage"
AfkPage.Size = UDim2.new(1, 0, 1, 0)
AfkPage.BackgroundTransparency = 1
AfkPage.Visible = false
AfkPage.Parent = ContentFrame

-- Card 1: Status Anti-AFK
local AfkStatusCard = createModernCard(AfkPage, 48, 0)

local AfkCardIcon = Instance.new("TextLabel")
AfkCardIcon.Size = UDim2.new(0, 24, 0, 24)
AfkCardIcon.Position = UDim2.new(0, 12, 0.5, -12)
AfkCardIcon.BackgroundTransparency = 1
AfkCardIcon.Font = Enum.Font.GothamBold
AfkCardIcon.Text = "🛡️"
AfkCardIcon.TextSize = 16
AfkCardIcon.Parent = AfkStatusCard

local AfkTitleLabel = Instance.new("TextLabel")
AfkTitleLabel.Size = UDim2.new(1, -120, 0, 16)
AfkTitleLabel.Position = UDim2.new(0, 42, 0, 8)
AfkTitleLabel.BackgroundTransparency = 1
AfkTitleLabel.Font = Enum.Font.GothamBold
AfkTitleLabel.Text = "Anti-AFK"
AfkTitleLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
AfkTitleLabel.TextSize = 11
AfkTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
AfkTitleLabel.Parent = AfkStatusCard

local AfkSubStatus = Instance.new("TextLabel")
AfkSubStatus.Size = UDim2.new(1, -120, 0, 14)
AfkSubStatus.Position = UDim2.new(0, 42, 0, 25)
AfkSubStatus.BackgroundTransparency = 1
AfkSubStatus.Font = Enum.Font.Gotham
AfkSubStatus.Text = "Cegah kick idle 20 menit"
AfkSubStatus.TextColor3 = Color3.fromRGB(140, 145, 165)
AfkSubStatus.TextSize = 10
AfkSubStatus.TextXAlignment = Enum.TextXAlignment.Left
AfkSubStatus.Parent = AfkStatusCard

local AfkStatusBadge = Instance.new("Frame")
AfkStatusBadge.Size = UDim2.new(0, 68, 0, 22)
AfkStatusBadge.Position = UDim2.new(1, -78, 0.5, -11)
AfkStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
AfkStatusBadge.BorderSizePixel = 0
AfkStatusBadge.Parent = AfkStatusCard
Instance.new("UICorner", AfkStatusBadge).CornerRadius = UDim.new(0, 6)

local AfkBadgeText = Instance.new("TextLabel")
AfkBadgeText.Size = UDim2.new(1, 0, 1, 0)
AfkBadgeText.BackgroundTransparency = 1
AfkBadgeText.Font = Enum.Font.GothamBold
AfkBadgeText.Text = "● OFF"
AfkBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
AfkBadgeText.TextSize = 9
AfkBadgeText.Parent = AfkStatusBadge

-- Card 2: Info
local AfkInfoCard = createModernCard(AfkPage, 48, 54)

local AfkInfoLabel = Instance.new("TextLabel")
AfkInfoLabel.Size = UDim2.new(1, -24, 1, 0)
AfkInfoLabel.Position = UDim2.new(0, 12, 0, 0)
AfkInfoLabel.BackgroundTransparency = 1
AfkInfoLabel.Font = Enum.Font.GothamMedium
AfkInfoLabel.Text = "Berjalan terpisah dari Auto Plant & Auto Clean. Bisa dinyalakan sendiri."
AfkInfoLabel.TextColor3 = Color3.fromRGB(150, 155, 175)
AfkInfoLabel.TextSize = 9
AfkInfoLabel.TextWrapped = true
AfkInfoLabel.TextXAlignment = Enum.TextXAlignment.Center
AfkInfoLabel.Parent = AfkInfoCard

-- Toggle Anti-AFK Hero Button
local ToggleAfkBtn = Instance.new("TextButton")
ToggleAfkBtn.Name = "ToggleAfkBtn"
ToggleAfkBtn.Size = UDim2.new(1, 0, 0, 42)
ToggleAfkBtn.Position = UDim2.new(0, 0, 1, -44)
ToggleAfkBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
ToggleAfkBtn.BorderSizePixel = 0
ToggleAfkBtn.Font = Enum.Font.GothamBold
ToggleAfkBtn.Text = "▶  START ANTI AFK"
ToggleAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAfkBtn.TextSize = 11
ToggleAfkBtn.AutoButtonColor = false
ToggleAfkBtn.Parent = AfkPage
Instance.new("UICorner", ToggleAfkBtn).CornerRadius = UDim.new(0, 10)

local AfkBtnGrad = Instance.new("UIGradient", ToggleAfkBtn)
AfkBtnGrad.Rotation = 45
AfkBtnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
})

-- Helper tombol START/STOP besar (dipakai tab Penyewa)
local function createHeroToggle(parent, name, text, posY)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 1, posY)
    btn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local grad = Instance.new("UIGradient", btn)
    grad.Rotation = 45
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
    })
    return btn, grad
end


-- ========================================================
-- TAB: AUTO ACC PENYEWA (TOMBOL TERPISAH)
-- ========================================================
local TenantPage = Instance.new("Frame")
TenantPage.Name = "TenantPage"
TenantPage.Size = UDim2.new(1, 0, 1, 0)
TenantPage.BackgroundTransparency = 1
TenantPage.Visible = false
TenantPage.Parent = ContentFrame

do
    local statusCard = createModernCard(TenantPage, 48, 0)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.Text = "🏠"
    icon.TextSize = 16
    icon.Parent = statusCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 16)
    title.Position = UDim2.new(0, 42, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Acc Penyewa"
    title.TextColor3 = Color3.fromRGB(240, 240, 250)
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = statusCard

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -120, 0, 14)
    sub.Position = UDim2.new(0, 42, 0, 25)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Diterima: 0 | Req: 0 | Spin: 0"
    sub.TextColor3 = Color3.fromRGB(140, 145, 165)
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = statusCard

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 68, 0, 22)
    badge.Position = UDim2.new(1, -78, 0.5, -11)
    badge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
    badge.BorderSizePixel = 0
    badge.Parent = statusCard
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Font = Enum.Font.GothamBold
    badgeText.Text = "● OFF"
    badgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
    badgeText.TextSize = 9
    badgeText.Parent = badge

    local infoCard = createModernCard(TenantPage, 48, 54)
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -24, 1, 0)
    info.Position = UDim2.new(0, 12, 0, 0)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamMedium
    info.Text = "Penyewa: belum terdeteksi\nSpin otomatis saat penyewa sudah 10"
    info.TextColor3 = Color3.fromRGB(150, 155, 175)
    info.TextSize = 9
    info.TextWrapped = true
    info.Parent = infoCard

    local toggleBtn, toggleGrad = createHeroToggle(TenantPage, "ToggleTenantBtn", "▶  START AUTO ACC PENYEWA", -92)
    local spinBtn, spinGrad = createHeroToggle(TenantPage, "ToggleSpinBtn", "▶  START AUTO SPIN (SAAT 10 PENYEWA)", -44)

    onTenantUpdate = function()
        sub.Text = string.format("Diterima: %d | Req: %d | Spin: %d", TenantState.AcceptCount, TenantState.CallCount, TenantState.SpinCount)
        if TenantState.DetectedTenants ~= nil then
            info.Text = string.format("Penyewa: %d/%d (%s)\nSpin otomatis saat penyewa sudah %d",
                TenantState.DetectedTenants, TenantConfig.SpinAt, TenantState.DetectSource, TenantConfig.SpinAt)
        else
            info.Text = string.format("Penyewa: belum terdeteksi (hitung dari diterima)\nSpin otomatis tiap %d penyewa", TenantConfig.SpinAt)
        end
    end

    table.insert(Connections, toggleBtn.Activated:Connect(function()
        TenantState.Running = not TenantState.Running

        if TenantState.Running then
            toggleGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
            })
            toggleBtn.Text = "■  STOP AUTO ACC PENYEWA (RUNNING)"
            badgeText.Text = "● ACTIVE"
            badgeText.TextColor3 = Color3.fromRGB(52, 211, 153)
            badge.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
            startTenantWorker()
        else
            toggleGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
            })
            toggleBtn.Text = "▶  START AUTO ACC PENYEWA"
            badgeText.Text = "● OFF"
            badgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
            badge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
            stopTenantWorker()
        end
    end))

    table.insert(Connections, spinBtn.Activated:Connect(function()
        TenantState.SpinEnabled = not TenantState.SpinEnabled

        if TenantState.SpinEnabled then
            spinGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
            })
            spinBtn.Text = "■  STOP AUTO SPIN (RUNNING)"
            TenantState.SpinArmed = true
            startSpinWatcher()
        else
            spinGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
            })
            spinBtn.Text = "▶  START AUTO SPIN (SAAT 10 PENYEWA)"
            stopSpinWatcher()
        end
    end))
end

-- ========================================================
-- TERNAK PAGE (AUTO ISI PAKAN DOMBA)
-- ========================================================
local TernakPage = Instance.new("Frame")
TernakPage.Name = "TernakPage"
TernakPage.Size = UDim2.new(1, 0, 1, 0)
TernakPage.BackgroundTransparency = 1
TernakPage.Visible = false
TernakPage.Parent = ContentFrame

do
    local statusCard = createModernCard(TernakPage, 48, 0)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.Text = "🐑"
    icon.TextSize = 16
    icon.Parent = statusCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 16)
    title.Position = UDim2.new(0, 42, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Isi Pakan Domba"
    title.TextColor3 = Color3.fromRGB(240, 240, 250)
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = statusCard

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -120, 0, 14)
    sub.Position = UDim2.new(0, 42, 0, 25)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Isi: 0 | Skip: 0 | Stok: -"
    sub.TextColor3 = Color3.fromRGB(140, 145, 165)
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = statusCard

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 68, 0, 22)
    badge.Position = UDim2.new(1, -78, 0.5, -11)
    badge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
    badge.BorderSizePixel = 0
    badge.Parent = statusCard
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Font = Enum.Font.GothamBold
    badgeText.Text = "● OFF"
    badgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
    badgeText.TextSize = 9
    badgeText.Parent = badge

    -- Card input: slot & interval
    local inputsCard = createModernCard(TernakPage, 90, 54)

    local function makeInput(name, placeholder, defaultValue, labelText, posY)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -24, 0, 12)
        lbl.Position = UDim2.new(0, 12, 0, posY)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(99, 102, 241)
        lbl.TextSize = 8
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = inputsCard

        local box = Instance.new("TextBox")
        box.Name = name
        box.Size = UDim2.new(1, -24, 0, 24)
        box.Position = UDim2.new(0, 12, 0, posY + 14)
        box.BackgroundColor3 = Color3.fromRGB(15, 16, 24)
        box.BorderSizePixel = 0
        box.TextColor3 = Color3.fromRGB(240, 240, 250)
        box.Text = tostring(defaultValue)
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Color3.fromRGB(100, 105, 125)
        box.Font = Enum.Font.Gotham
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.Parent = inputsCard
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
        local bStroke = Instance.new("UIStroke", box)
        bStroke.Color = Color3.fromRGB(42, 46, 66)
        bStroke.Thickness = 1

        table.insert(Connections, box.Focused:Connect(function()
            TweenService:Create(bStroke, TWEEN_FAST, { Color = Color3.fromRGB(99, 102, 241) }):Play()
        end))
        table.insert(Connections, box.FocusLost:Connect(function()
            TweenService:Create(bStroke, TWEEN_FAST, { Color = Color3.fromRGB(42, 46, 66) }):Play()
        end))
        return box
    end

    local slotsText = table.concat(TernakConfig.Slots, ",")
    local SlotInput = makeInput("SlotInput", "Contoh: 1,2,3", slotsText, "SLOT KANDANG (PISAH KOMA):", 4)
    local IntervalInput = makeInput("PakanIntervalInput", "Detik antar siklus", TernakConfig.Interval, "INTERVAL ISI (DETIK):", 46)

    table.insert(Connections, SlotInput.FocusLost:Connect(function()
        local slots = {}
        for token in string.gmatch(SlotInput.Text, "%d+") do
            local n = tonumber(token)
            if n and n >= 1 then table.insert(slots, n) end
        end
        if #slots > 0 then
            TernakConfig.Slots = slots
        end
        SlotInput.Text = table.concat(TernakConfig.Slots, ",")
    end))

    table.insert(Connections, IntervalInput.FocusLost:Connect(function()
        local n = tonumber(IntervalInput.Text)
        if n then
            TernakConfig.Interval = math.clamp(n, 0.5, 600)
        end
        IntervalInput.Text = tostring(TernakConfig.Interval)
    end))

    local toggleBtn, toggleGrad = createHeroToggle(TernakPage, "ToggleTernakBtn", "▶  START AUTO ISI PAKAN", -44)

    -- Tombol isi pakan manual (sekali tekan, tanpa harus mendekat)
    local FEED_NOW_TEXT = "🍽️  ISI PAKAN SEKARANG (TANPA MENDEKAT)"
    local feedBtn, feedGrad = createHeroToggle(TernakPage, "FeedNowBtn", FEED_NOW_TEXT, -92)
    feedGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 130, 246))
    })

    local feedBusy = false
    table.insert(Connections, feedBtn.Activated:Connect(function()
        if feedBusy then return end
        feedBusy = true
        task.spawn(function()
            feedBtn.Text = "⏳  MENGISI PAKAN..."
            local okCount, total = feedAllOnce()
            onTernakUpdate()
            if isScriptRunning then
                feedBtn.Text = string.format("✔  SELESAI (%d/%d BERHASIL)", okCount, total)
                task.wait(1.5)
                feedBtn.Text = FEED_NOW_TEXT
            end
            feedBusy = false
        end)
    end))

    onTernakUpdate = function()
        sub.Text = string.format("Isi: %d | Skip: %d | Stok %s: %s",
            TernakState.FillCount, TernakState.SkipCount,
            TernakState.LastNama, TernakState.LastStok ~= nil and tostring(TernakState.LastStok) or "-")
    end

    table.insert(Connections, toggleBtn.Activated:Connect(function()
        TernakState.Running = not TernakState.Running

        if TernakState.Running then
            toggleGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
            })
            toggleBtn.Text = "■  STOP AUTO ISI PAKAN (RUNNING)"
            badgeText.Text = "● ACTIVE"
            badgeText.TextColor3 = Color3.fromRGB(52, 211, 153)
            badge.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
            startTernakWorker()
        else
            toggleGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
            })
            toggleBtn.Text = "▶  START AUTO ISI PAKAN"
            badgeText.Text = "● OFF"
            badgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
            badge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
            stopTernakWorker()
        end
    end))
end

-- ========================================================
-- FOOTER BAR (CREDIT: SMITH GANTENG)
-- ========================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 22)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterStroke = Instance.new("UIStroke", Footer)
FooterStroke.Color = Color3.fromRGB(32, 35, 50)
FooterStroke.Thickness = 1

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.GothamBold
FooterLabel.Text = "✨ smith ganteng ✨"
FooterLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
FooterLabel.TextSize = 10
FooterLabel.Parent = Footer

-- ========================================================
-- TAB SWITCHING ANIMATION
-- ========================================================
local TAB_ACTIVE_BG   = Color3.fromRGB(38, 42, 62)
local TAB_INACTIVE_BG = Color3.fromRGB(20, 22, 32)
local TAB_ACTIVE_TXT  = Color3.fromRGB(255, 255, 255)
local TAB_INACTIVE_TXT = Color3.fromRGB(130, 135, 155)

local TAB_MAP = {
    Plant = { page = PlantPage, btn = TabPlantBtn },
    Clean = { page = CleanPage, btn = TabCleanBtn },
    Tenant = { page = TenantPage, btn = TabTenantBtn },
    Afk   = { page = AfkPage,   btn = TabAfkBtn },
    Ternak = { page = TernakPage, btn = TabTernakBtn },
}

local function switchTab(tab)
    for name, entry in pairs(TAB_MAP) do
        local active = (name == tab)
        entry.page.Visible = active
        TweenService:Create(entry.btn, TWEEN_SMOOTH, {
            BackgroundColor3 = active and TAB_ACTIVE_BG or TAB_INACTIVE_BG,
            TextColor3 = active and TAB_ACTIVE_TXT or TAB_INACTIVE_TXT
        }):Play()
    end
end

-- Default active tab
switchTab("Plant")

table.insert(Connections, TabPlantBtn.Activated:Connect(function() switchTab("Plant") end))
table.insert(Connections, TabCleanBtn.Activated:Connect(function() switchTab("Clean") end))
table.insert(Connections, TabTenantBtn.Activated:Connect(function() switchTab("Tenant") end))
table.insert(Connections, TabAfkBtn.Activated:Connect(function() switchTab("Afk") end))
table.insert(Connections, TabTernakBtn.Activated:Connect(function() switchTab("Ternak") end))

-- ========================================================
-- LOGIC HANDLERS & ANIMATIONS
-- ========================================================

-- Update Lahan Stepper UI
local function updateLahanDisplay()
    local name = LAHAN_CATEGORIES[currentLahanIndex]
    local plots = LAHAN_PRESETS[name] or {}
    LahanDisplayBtn.Text = "📍 " .. name .. " (" .. #plots .. " Plots)"
    PlantSubStatus.Text = string.format("Plot Terpilih: %d Titik Koordinat", #plots)
end

table.insert(Connections, PrevLahanBtn.Activated:Connect(function()
    currentLahanIndex = currentLahanIndex - 1
    if currentLahanIndex < 1 then currentLahanIndex = #LAHAN_CATEGORIES end
    updateLahanDisplay()
end))

table.insert(Connections, NextLahanBtn.Activated:Connect(function()
    currentLahanIndex = currentLahanIndex + 1
    if currentLahanIndex > #LAHAN_CATEGORIES then currentLahanIndex = 1 end
    updateLahanDisplay()
end))

table.insert(Connections, LahanDisplayBtn.Activated:Connect(function()
    currentLahanIndex = currentLahanIndex + 1
    if currentLahanIndex > #LAHAN_CATEGORIES then currentLahanIndex = 1 end
    updateLahanDisplay()
end))

-- Toggle Auto TP Button (Plant)
table.insert(Connections, TpPlantBtn.Activated:Connect(function()
    PlantConfig.USE_TELEPORT = not PlantConfig.USE_TELEPORT
    local col = PlantConfig.USE_TELEPORT and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
    TweenService:Create(TpPlantBtn, TWEEN_FAST, { BackgroundColor3 = col }):Play()
    TpPlantBtn.Text = PlantConfig.USE_TELEPORT and "ON" or "OFF"
end))

-- Toggle Jarak Jauh Button (Clean)
table.insert(Connections, TpCleanBtn.Activated:Connect(function()
    CleanState.USE_TELEPORT = not CleanState.USE_TELEPORT
    local col = CleanState.USE_TELEPORT and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 48, 65)
    TweenService:Create(TpCleanBtn, TWEEN_FAST, { BackgroundColor3 = col }):Play()
    TpCleanBtn.Text = CleanState.USE_TELEPORT and "ON" or "OFF"
end))

-- Input Listeners for Clean
table.insert(Connections, IdInput.FocusLost:Connect(function()
    CleanState.CurrentKosanID = IdInput.Text
    local o, r = parseKosanID(IdInput.Text)
    CleanState.KosanOwner, CleanState.RoomNumber = o, r
    CleanOwnerLabel.Text = string.format("Owner: %s | Room: %s", o, r)
end))

table.insert(Connections, RadiusInput.FocusLost:Connect(function()
    local val = tonumber(RadiusInput.Text)
    CleanState.Radius = (val and val > 0) and val or CleanConfig.DefaultRadius
    RadiusInput.Text = tostring(CleanState.Radius)
end))

table.insert(Connections, LoopInput.FocusLost:Connect(function()
    local val = tonumber(LoopInput.Text)
    CleanState.LoopInterval = (val and val >= CleanConfig.MinLoopInterval) and val or CleanConfig.DefaultLoop
    LoopInput.Text = tostring(CleanState.LoopInterval)
end))

-- Toggle Plant Button Logic
table.insert(Connections, TogglePlantBtn.Activated:Connect(function()
    isPlantRunning = not isPlantRunning

    if isPlantRunning then
        PlantBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
        })
        TogglePlantBtn.Text = "■  STOP AUTO PLANT (RUNNING)"
        PlantBadgeText.Text = "● ACTIVE"
        PlantBadgeText.TextColor3 = Color3.fromRGB(52, 211, 153)
        PlantStatusBadge.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
        startPlantingLoop()
    else
        PlantBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
        })
        TogglePlantBtn.Text = "▶  START AUTO PLANT"
        PlantBadgeText.Text = "● IDLE"
        PlantBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
        PlantStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
        stopPlantingLoop()
    end
end))

-- Toggle Clean Button Logic
table.insert(Connections, ToggleCleanBtn.Activated:Connect(function()
    isCleanRunning = not isCleanRunning

    if isCleanRunning then
        CleanBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
        })
        ToggleCleanBtn.Text = "■  STOP AUTO CLEAN (RUNNING)"
        CleanBadgeText.Text = "● ACTIVE"
        CleanBadgeText.TextColor3 = Color3.fromRGB(52, 211, 153)
        CleanStatusBadge.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
        startCleaningLoop()
    else
        CleanBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
        })
        ToggleCleanBtn.Text = "▶  START AUTO CLEAN"
        CleanBadgeText.Text = "● IDLE"
        CleanBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
        CleanStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
        stopCleaningLoop()
    end
end))

-- Toggle Anti-AFK Button Logic
table.insert(Connections, ToggleAfkBtn.Activated:Connect(function()
    isAntiAfkRunning = not isAntiAfkRunning

    if isAntiAfkRunning then
        AfkBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 211, 153)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129))
        })
        ToggleAfkBtn.Text = "■  STOP ANTI AFK (RUNNING)"
        AfkBadgeText.Text = "● ACTIVE"
        AfkBadgeText.TextColor3 = Color3.fromRGB(52, 211, 153)
        AfkStatusBadge.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
        startAntiAfk()
    else
        AfkBtnGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 63, 94)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 29, 72))
        })
        ToggleAfkBtn.Text = "▶  START ANTI AFK"
        AfkBadgeText.Text = "● OFF"
        AfkBadgeText.TextColor3 = Color3.fromRGB(160, 165, 185)
        AfkStatusBadge.BackgroundColor3 = Color3.fromRGB(30, 33, 46)
        stopAntiAfk()
    end
end))

-- Minimize & Restore Window Animation
local isMinimized = false
table.insert(Connections, MiniBtn.Activated:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and MINI_HEIGHT or WIN_HEIGHT

    TabBar.Visible = not isMinimized
    ContentFrame.Visible = not isMinimized
    Footer.Visible = not isMinimized
    MiniBtn.Text = isMinimized and "+" or "—"

    TweenService:Create(MainFrame, TWEEN_SMOOTH, {
        Size = UDim2.new(0, WIN_WIDTH, 0, targetHeight)
    }):Play()
end))

-- Drag window manual (support mouse & touch di semua executor)
do
    local dragging = false
    local dragInput, dragStart, startPos

    table.insert(Connections, Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end))

    table.insert(Connections, Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and dragStart then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

-- Close & Complete Cleanup
local function shutdown()
    isScriptRunning = false
    pcall(stopPlantingLoop)
    pcall(stopCleaningLoop)
    pcall(stopTenantWorker)
    pcall(stopSpinWatcher)
    pcall(stopAntiAfk)
    pcall(stopTernakWorker)

    for _, conn in ipairs(Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end
    table.clear(Connections)

    pcall(function() ScreenGui:Destroy() end)
end

table.insert(Connections, CloseBtn.Activated:Connect(shutdown))

do
    local genv = (typeof(getgenv) == "function" and getgenv()) or _G
    genv.__IndoKostShutdown = shutdown
end
