--// reaper.lol loader

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--========================================================
-- CONFIG
--========================================================

local CONFIG = {
    Name = "reaper.lol",
    Version = "1.0.0",

    GetKeyURL = "https://jnkie.com/get-key/reaperlol",

    ScriptURL = "https://api.jnkie.com/api/v1/luascripts/public/70f3ededa6365a2f4d8396f07ca841c36b430d61f0e5d5296395e842c99b2abb/download",

    Discord = "https://discord.gg/reaperlol",

    Folder = "reaper",
    KeyFile = "reaper/key.txt",
}

--========================================================
-- RE-EXEC CLEANUP
--========================================================

local ENV = getgenv and getgenv() or _G

-- Accept either of these before running the loader:
--   script_key = "YOUR_KEY"
--   SCRIPT_KEY = "YOUR_KEY"
-- `SCRIPT_KEY` remains the canonical value passed to the protected script.
local providedKey = ENV.script_key or ENV.SCRIPT_KEY or _G.script_key or _G.SCRIPT_KEY or script_key or SCRIPT_KEY

if ENV.__REAPER_LOADER_CLEANUP then
    pcall(ENV.__REAPER_LOADER_CLEANUP)
end

--========================================================
-- FILESYSTEM
--========================================================

local function trim(str)
    return tostring(str or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function ensureFolder()
    if not makefolder or not isfolder then
        return false
    end

    if not isfolder(CONFIG.Folder) then
        local ok = pcall(function()
            makefolder(CONFIG.Folder)
        end)

        if not ok then
            return false
        end
    end

    return true
end

local function readSavedKey()
    if not isfile or not readfile then
        return nil
    end

    if not isfile(CONFIG.KeyFile) then
        return nil
    end

    local ok, result = pcall(function()
        return readfile(CONFIG.KeyFile)
    end)

    if not ok then
        return nil
    end

    result = trim(result)

    if result == "" then
        return nil
    end

    return result
end

local function saveKey(key)
    if not writefile then
        return false
    end

    if not ensureFolder() then
        return false
    end

    return pcall(function()
        writefile(CONFIG.KeyFile, key)
    end)
end

local function deleteSavedKey()
    if not delfile or not isfile then
        return
    end

    if isfile(CONFIG.KeyFile) then
        pcall(function()
            delfile(CONFIG.KeyFile)
        end)
    end
end

--========================================================
-- GUI PARENT
--========================================================

local guiParent

if gethui then
    local ok, result = pcall(gethui)

    if ok and result then
        guiParent = result
    end
end

if not guiParent then
    guiParent = CoreGui
end

--========================================================
-- GUI
--========================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "reaper_lol_loader"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.fromOffset(470, 300)
Main.Position = UDim2.new(0.5, -235, 0.5, -150)

Main.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
Main.BorderSizePixel = 0

Main.Parent = ScreenGui

local Scale = Instance.new("UIScale")
Scale.Scale = 0.96
Scale.Parent = Main

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(40, 40, 44)
Stroke.Thickness = 1
Stroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")

Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(22, 0)
Title.Size = UDim2.new(1, -80, 1, 0)

Title.Font = Enum.Font.GothamSemibold
Title.Text = CONFIG.Name
Title.TextSize = 17
Title.TextColor3 = Color3.fromRGB(245, 245, 247)
Title.TextXAlignment = Enum.TextXAlignment.Left

Title.Parent = Header

local Close = Instance.new("TextButton")

Close.Size = UDim2.fromOffset(32, 32)
Close.Position = UDim2.new(1, -44, 0, 11)

Close.BackgroundTransparency = 1
Close.AutoButtonColor = false

Close.Font = Enum.Font.GothamMedium
Close.Text = "×"
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(130, 130, 136)

Close.Parent = Header

--========================================================
-- BODY
--========================================================

local Body = Instance.new("Frame")

Body.Position = UDim2.fromOffset(22, 61)
Body.Size = UDim2.new(1, -44, 1, -80)

Body.BackgroundTransparency = 1
Body.Parent = Main

local Heading = Instance.new("TextLabel")

Heading.BackgroundTransparency = 1
Heading.Size = UDim2.new(1, 0, 0, 27)

Heading.Font = Enum.Font.GothamSemibold
Heading.Text = "Welcome back"
Heading.TextSize = 20
Heading.TextColor3 = Color3.fromRGB(245, 245, 247)
Heading.TextXAlignment = Enum.TextXAlignment.Left

Heading.Parent = Body

local Subtitle = Instance.new("TextLabel")

Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(0, 29)
Subtitle.Size = UDim2.new(1, 0, 0, 20)

Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Enter your license key to continue."
Subtitle.TextSize = 13
Subtitle.TextColor3 = Color3.fromRGB(135, 135, 142)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

Subtitle.Parent = Body

--========================================================
-- KEY FIELD
--========================================================

local Input = Instance.new("Frame")

Input.Position = UDim2.fromOffset(0, 62)
Input.Size = UDim2.new(1, 0, 0, 44)

Input.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Input.BorderSizePixel = 0

Input.Parent = Body

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 9)
InputCorner.Parent = Input

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(45, 45, 50)
InputStroke.Thickness = 1
InputStroke.Parent = Input

local KeyBox = Instance.new("TextBox")

KeyBox.BackgroundTransparency = 1
KeyBox.Position = UDim2.fromOffset(14, 0)
KeyBox.Size = UDim2.new(1, -28, 1, 0)

KeyBox.ClearTextOnFocus = false

KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "License key"
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 106)

KeyBox.Text = ""
KeyBox.TextSize = 14
KeyBox.TextColor3 = Color3.fromRGB(235, 235, 238)
KeyBox.TextXAlignment = Enum.TextXAlignment.Left

KeyBox.Parent = Input

--========================================================
-- AUTH BUTTON
--========================================================

local Authenticate = Instance.new("TextButton")

Authenticate.Position = UDim2.fromOffset(0, 117)
Authenticate.Size = UDim2.new(1, 0, 0, 44)

Authenticate.BackgroundColor3 = Color3.fromRGB(242, 242, 244)
Authenticate.BorderSizePixel = 0

Authenticate.AutoButtonColor = false

Authenticate.Font = Enum.Font.GothamSemibold
Authenticate.Text = "Authenticate"
Authenticate.TextSize = 14
Authenticate.TextColor3 = Color3.fromRGB(18, 18, 20)

Authenticate.Parent = Body

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 9)
AuthCorner.Parent = Authenticate

--========================================================
-- LOWER BUTTONS
--========================================================

local GetKey = Instance.new("TextButton")

GetKey.Position = UDim2.fromOffset(0, 170)
GetKey.Size = UDim2.fromOffset(110, 30)

GetKey.BackgroundTransparency = 1
GetKey.AutoButtonColor = false

GetKey.Font = Enum.Font.GothamMedium
GetKey.Text = "Get Key"
GetKey.TextSize = 13
GetKey.TextColor3 = Color3.fromRGB(175, 175, 181)
GetKey.TextXAlignment = Enum.TextXAlignment.Left

GetKey.Parent = Body

local ClearKey = Instance.new("TextButton")

ClearKey.Position = UDim2.fromOffset(115, 170)
ClearKey.Size = UDim2.fromOffset(110, 30)

ClearKey.BackgroundTransparency = 1
ClearKey.AutoButtonColor = false

ClearKey.Font = Enum.Font.GothamMedium
ClearKey.Text = "Clear Key"
ClearKey.TextSize = 13
ClearKey.TextColor3 = Color3.fromRGB(175, 175, 181)
ClearKey.TextXAlignment = Enum.TextXAlignment.Left

ClearKey.Parent = Body

local Discord = Instance.new("TextButton")

Discord.AnchorPoint = Vector2.new(1, 0)

Discord.Position = UDim2.new(1, 0, 0, 170)
Discord.Size = UDim2.fromOffset(110, 30)

Discord.BackgroundTransparency = 1
Discord.AutoButtonColor = false

Discord.Font = Enum.Font.GothamMedium
Discord.Text = "Discord"
Discord.TextSize = 13
Discord.TextColor3 = Color3.fromRGB(175, 175, 181)
Discord.TextXAlignment = Enum.TextXAlignment.Right

Discord.Parent = Body

--========================================================
-- STATUS
--========================================================

local StatusDot = Instance.new("Frame")

StatusDot.Size = UDim2.fromOffset(6, 6)
StatusDot.Position = UDim2.new(0, 0, 1, -9)

StatusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 126)
StatusDot.BorderSizePixel = 0

StatusDot.Parent = Body

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local Status = Instance.new("TextLabel")

Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 12, 1, -19)
Status.Size = UDim2.new(0.65, -12, 0, 20)

Status.Font = Enum.Font.Gotham
Status.Text = "Ready"
Status.TextSize = 12
Status.TextColor3 = Color3.fromRGB(125, 125, 132)
Status.TextXAlignment = Enum.TextXAlignment.Left

Status.Parent = Body

local Version = Instance.new("TextLabel")

Version.AnchorPoint = Vector2.new(1, 0)

Version.BackgroundTransparency = 1
Version.Position = UDim2.new(1, 0, 1, -19)
Version.Size = UDim2.fromOffset(100, 20)

Version.Font = Enum.Font.Gotham
Version.Text = "v" .. CONFIG.Version
Version.TextSize = 12
Version.TextColor3 = Color3.fromRGB(85, 85, 92)
Version.TextXAlignment = Enum.TextXAlignment.Right

Version.Parent = Body

--========================================================
-- STATE
--========================================================

local busy = false
local destroyed = false

local function setStatus(text, kind)
    Status.Text = text

    if kind == "success" then
        local color = Color3.fromRGB(118, 205, 139)

        Status.TextColor3 = color
        StatusDot.BackgroundColor3 = color

    elseif kind == "error" then
        local color = Color3.fromRGB(215, 95, 95)

        Status.TextColor3 = color
        StatusDot.BackgroundColor3 = color

    elseif kind == "loading" then
        local color = Color3.fromRGB(205, 205, 210)

        Status.TextColor3 = color
        StatusDot.BackgroundColor3 = color

    else
        Status.TextColor3 = Color3.fromRGB(125, 125, 132)
        StatusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 126)
    end
end

local function setBusy(state)
    busy = state

    KeyBox.TextEditable = not state
    Authenticate.Active = not state

    if state then
        Authenticate.Text = "Authenticating..."
        Authenticate.BackgroundColor3 = Color3.fromRGB(180, 180, 184)
    else
        Authenticate.Text = "Authenticate"
        Authenticate.BackgroundColor3 = Color3.fromRGB(242, 242, 244)
    end
end

--========================================================
-- CLIPBOARD
--========================================================

local function copyText(text)
    if not setclipboard then
        return false
    end

    return pcall(function()
        setclipboard(text)
    end)
end

--========================================================
-- CLOSE
--========================================================

local function destroyLoader()
    if destroyed then
        return
    end

    destroyed = true

    local fade = TweenService:Create(
        Scale,
        TweenInfo.new(
            0.16,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            Scale = 0.97,
        }
    )

    fade:Play()

    task.delay(0.17, function()
        pcall(function()
            ScreenGui:Destroy()
        end)
    end)
end

ENV.__REAPER_LOADER_CLEANUP = destroyLoader

--========================================================
-- LAUNCH JNKIE SCRIPT
--========================================================

local function looksLikeInvalidKeyError(err)
    local message = string.lower(tostring(err or ""))

    return message:find("expired", 1, true)
        or message:find("invalid key", 1, true)
        or message:find("invalid license", 1, true)
        or message:find("license invalid", 1, true)
        or message:find("unauthorized", 1, true)
        or message:find("key invalid", 1, true)
        or message:find("key expired", 1, true)
end

local function launchProtectedScript(key, sourceKind)
    key = trim(key)

    if key == "" then
        setBusy(false)
        setStatus("Enter a license key.", "error")
        return false
    end

    setStatus("Checking license...", "loading")

    -- JNKIE's generated script looks for uppercase SCRIPT_KEY.
    ENV.SCRIPT_KEY = key
    ENV.script_key = key
    _G.SCRIPT_KEY = key
    _G.script_key = key

    local ok, result = pcall(function()
        local source = game:HttpGet(CONFIG.ScriptURL)

        local compiled, compileError = loadstring(source)

        if not compiled then
            error(compileError or "Unable to compile script")
        end

        return compiled()
    end)

    if not ok then
        setBusy(false)
        warn("[reaper.lol]", result)

        -- Never kick or close the loader because authentication failed.
        if sourceKind == "saved" and looksLikeInvalidKeyError(result) then
            deleteSavedKey()
            KeyBox.Text = ""
            setStatus("Saved key expired or is invalid. Enter a new key.", "error")
        elseif sourceKind == "provided" and looksLikeInvalidKeyError(result) then
            KeyBox.Text = key
            setStatus("Provided key expired or is invalid.", "error")
        else
            KeyBox.Text = key
            setStatus("License rejected or service unavailable.", "error")
        end

        return false
    end

    -- Successful authentication = remember automatically.
    saveKey(key)

    setStatus("Authenticated. Key remembered.", "success")

    task.wait(0.2)
    destroyLoader()

    return true
end

--========================================================
-- AUTH
--========================================================

local function authenticate(keyOverride, sourceKind)
    if busy or destroyed then
        return
    end

    local key = trim(keyOverride or KeyBox.Text)

    if key == "" then
        setStatus("Enter a license key.", "error")

        TweenService:Create(
            InputStroke,
            TweenInfo.new(0.12),
            {
                Color = Color3.fromRGB(190, 80, 80),
            }
        ):Play()

        task.delay(0.5, function()
            if InputStroke.Parent then
                TweenService:Create(
                    InputStroke,
                    TweenInfo.new(0.2),
                    {
                        Color = Color3.fromRGB(45, 45, 50),
                    }
                ):Play()
            end
        end)

        return
    end

    KeyBox.Text = key
    setBusy(true)

    task.spawn(function()
        launchProtectedScript(key, sourceKind or "manual")
    end)
end

--========================================================
-- BUTTONS
--========================================================

Authenticate.MouseButton1Click:Connect(authenticate)

KeyBox.FocusLost:Connect(function(pressedEnter)
    if pressedEnter then
        authenticate()
    end
end)

GetKey.MouseButton1Click:Connect(function()
    if copyText(CONFIG.GetKeyURL) then
        setStatus("Get Key link copied.", "success")
    else
        setStatus(
            "Get Key: " .. CONFIG.GetKeyURL,
            "success"
        )
    end
end)

ClearKey.MouseButton1Click:Connect(function()

    deleteSavedKey()

    ENV.SCRIPT_KEY = nil
    ENV.script_key = nil
    _G.SCRIPT_KEY = nil
    _G.script_key = nil

    KeyBox.Text = ""

    setStatus(
        "Saved key cleared.",
        "success"
    )
end)


Discord.MouseButton1Click:Connect(function()
    if CONFIG.Discord == "PUT_YOUR_DISCORD_INVITE_HERE" then
        setStatus("Discord not configured yet.", "error")
        return
    end

    if copyText(CONFIG.Discord) then
        setStatus("Discord invite copied.", "success")
    else
        setStatus(CONFIG.Discord, "success")
    end
end)

Close.MouseButton1Click:Connect(destroyLoader)

--========================================================
-- DRAGGING
--========================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch
    then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = false
    end
end)

--========================================================
-- HOVERS
--========================================================

Authenticate.MouseEnter:Connect(function()
    if busy then
        return
    end

    TweenService:Create(
        Authenticate,
        TweenInfo.new(0.1),
        {
            BackgroundColor3 = Color3.fromRGB(220, 220, 223),
        }
    ):Play()
end)

Authenticate.MouseLeave:Connect(function()
    if busy then
        return
    end

    TweenService:Create(
        Authenticate,
        TweenInfo.new(0.1),
        {
            BackgroundColor3 = Color3.fromRGB(242, 242, 244),
        }
    ):Play()
end)

--========================================================
-- OPEN ANIMATION
--========================================================

Main.BackgroundTransparency = 1

TweenService:Create(
    Main,
    TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),
    {
        BackgroundTransparency = 0,
    }
):Play()

TweenService:Create(
    Scale,
    TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),
    {
        Scale = 1,
    }
):Play()

--========================================================
-- AUTO KEY / SAVED KEY
--========================================================

providedKey = trim(providedKey)
local savedKey = readSavedKey()

-- Priority:
--   1. key supplied alongside the loader
--   2. remembered key
--   3. normal manual key UI
if providedKey ~= "" then
    KeyBox.Text = providedKey
    setStatus("Provided key detected. Verifying...", "loading")

    task.defer(function()
        authenticate(providedKey, "provided")
    end)
elseif savedKey then
    KeyBox.Text = savedKey
    setStatus("Saved key found. Verifying...", "loading")

    task.defer(function()
        authenticate(savedKey, "saved")
    end)
else
    setStatus("Ready", "idle")
end
