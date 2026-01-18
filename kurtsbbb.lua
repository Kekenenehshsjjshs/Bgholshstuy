script_name("RAMPAGE")
script_author("treywisp | android fixed + resized by cup")

local sampev = require("samp.events")
local imgui = require("mimgui")

local rampage_text = {
    "First Blood",
    "Double Kill",
    "Triple Kill",
    "Quadra Kill",
    "Penta Kill",
    "Hexa Kill",
    "Hepta Kill",
    "Wicked Sick",
    "Godlike",
    "Hitman",
    "Godness Kill",
    "Most Respected",
    "Unreal Kill",
    "Bruh Moment",
    "You Mad?",
    "Stop Please",
    "Are You a God?",
    "Extreme Kill",
    "Massacre",
    "Ultimate Slayer"
}

local func_vars = {
    screen_width = select(1, getScreenResolution()),
    frame_path = getWorkingDirectory() .. "/RAMPAGE/img",
    sound = getWorkingDirectory() .. "/RAMPAGE/sounds/sound.mp3",

    gif = nil,
    font = nil,

    first_start = false,
    current_kills = 0
}

-- ================= FADE SETTING =================
local fade = {
    start_timer = 0,
    alpha = 1.0,
    show_time = 2.0,   --  LEBIH LAMA TAMPIL
    fade_time = 1.2    --  FADE LEBIH HALUS
}

local imgui_states = {
    window_state = imgui.new.bool(false),
    frame_time = imgui.new.int(60)
}

-- ================= FADE LOGIC =================
local function updateFade()
    local t = os.clock() - fade.start_timer
    if t < fade.show_time then return end

    local f = (t - fade.show_time) / fade.fade_time
    if f < 1 then
        fade.alpha = 1.0 - f
    else
        imgui_states.window_state[0] = false
    end
end

local function playSound()
    if doesFileExist(func_vars.sound) then
        local a = loadAudioStream(func_vars.sound)
        if a then
            setAudioStreamVolume(a, 1.0)
            setAudioStreamState(a, 1)
        end
    end
end

local function rampage()
    func_vars.current_kills = math.min(func_vars.current_kills + 1, #rampage_text)
    fade.start_timer = os.clock()
    fade.alpha = 1.0
    imgui_states.window_state[0] = true
    playSound()
end

-- ================= FRAME LOADER =================
function imgui.LoadFrames(path)
    local t = { current = 1, last_frame_time = os.clock() }
    local i = 1
    while true do
        local file = string.format("%s/%d.png", path, i)
        if not doesFileExist(file) then break end
        t[i] = imgui.CreateTextureFromFile(file)
        i = i + 1
    end
    t.max = i - 1
    return t.max > 0 and t or nil
end

function imgui.DrawFrames(images, size, frame_time)
    if not images or not images[images.current] then return end
    imgui.Image(images[images.current], size, nil, nil,
        imgui.ImVec4(1, 1, 1, fade.alpha))

    if os.clock() - images.last_frame_time >= (frame_time / 1000) then
        images.last_frame_time = os.clock()
        images.current = images.current + 1
        if images.current > images.max then
            images.current = 1
        end
    end
end

-- ================= TEXT EFFECT =================
function imgui.TextWithShadow(text)
    local pos = imgui.GetCursorPos()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, fade.alpha))
    imgui.SetCursorPos(imgui.ImVec2(pos.x + 3, pos.y + 3))
    imgui.Text(text)
    imgui.PopStyleColor()
    imgui.SetCursorPos(pos)
    imgui.TextColored(imgui.ImVec4(1, 1, 1, fade.alpha), text)
end

function imgui.CenterText(text)
    local w = imgui.GetWindowWidth()
    local s = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(w / 2 - s.x / 2)
    imgui.TextWithShadow(text)
end

-- ================= INIT =================
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    imgui.GetIO().FontGlobalScale = 1.6 --  FONT DIPERBESAR
    func_vars.gif = imgui.LoadFrames(func_vars.frame_path)
    func_vars.font = imgui.GetIO().Fonts:AddFontDefault()
end)

imgui.OnFrame(
    function() return imgui_states.window_state[0] end,
    function()
        if not func_vars.first_start then
            imgui_states.window_state[0] = false
            func_vars.first_start = true
            return
        end

        --  WINDOW LEBIH BESAR
        imgui.SetNextWindowSize(imgui.ImVec2(820, 260), imgui.Cond.Always)
        imgui.SetNextWindowPos(
            imgui.ImVec2(func_vars.screen_width / 2, 200),
            imgui.Cond.Always,
            imgui.ImVec2(0.5, 0.5)
        )

        imgui.Begin("RAMPAGE", nil,
            imgui.WindowFlags.NoTitleBar +
            imgui.WindowFlags.NoResize +
            imgui.WindowFlags.NoInputs +
            imgui.WindowFlags.NoBackground)

        updateFade()

        --  GIF DIPERBESAR
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 180) / 2)
        imgui.DrawFrames(func_vars.gif, imgui.ImVec2(180, 135), imgui_states.frame_time[0])

        imgui.PushFont(func_vars.font)
        imgui.Spacing()
        imgui.CenterText(rampage_text[func_vars.current_kills])
        imgui.PopFont()

        imgui.End()
    end
)

-- ================= MAIN =================
function main()
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("[RAMPAGE] Loaded", -1)
    while true do wait(0) end
end

function sampev.onSendSpawn()
    func_vars.current_kills = 0
end

function sampev.onPlayerDeathNotification(killer_id, victim_id)
    if killer_id == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
        rampage()
    end
end
