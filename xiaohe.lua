--[[
============================================================
  贺 · 悬浮球多功能面板 v3.0 完整版
  作者：小贺
  整合：梅西Shell + 殺脚本 + PY Hub 全部功能
  第 1 段 / 3 段
============================================================
]]

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local VIM          = game:GetService("VirtualInputManager")
local VUser        = game:GetService("VirtualUser")
local HttpService  = game:GetService("HttpService")
local StarterGui   = game:GetService("StarterGui")
local TeleportSvc  = game:GetService("TeleportService")
local RS           = game:GetService("ReplicatedStorage")
local LP           = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera

--==================== 状态表 ====================
local S = {
    silentAim=false, aimPart="Head", fovRadius=250, wallCheck=false, hitChance=100,
    triggerbot=false, hitSound=false, tracer=false, tracerColor=Color3.fromRGB(255,50,50),
    showFOV=false, hitboxEnabled=false, hitboxSize=10, adornColor=Color3.fromRGB(255,255,255),
    gunScale=false, gunScaleMult=10,
    ragebot=false, rageRange=150, rageInterval=0.05, ragePart="Head",
    rageJobCheck=false, rageWallCheck=false, rageAliveCheck=false, rageCombatCheck=false,
    ragePoliceLock=false, rageCivilianLock=false, rageBeam=false,
    aura=false, auraRange=50, auraDamage=5, auraOnlyPolice=false, auraOnlyCivilian=false,
    auraCombatCheck=false,
    aimbot=false, aimFov=50, aimFovShow=false, aimCrosshair=false, aimTracer=false,
    aimTeamCheck=false, aimFriendCheck=false, aimWallCheck=false, aimPrediction=false,
    aimOnlyPolice=false, aimOnlyCivilian=false, aimCombatCheck=false,
    aimSmooth=1, aimFovThick=2, aimColor="红色",
    esp=false, chams=false, fullBright=false, nightVision=false,
    cameraFOV=70, skyTheme="默认",
    genESP=false, genPercent=true, genDist=true, genFilter=true,
    survESP=false, survBox=false, survRole=false, survName=false, survSkin=false, survLogin=false,
    survHP=false, survStatus=false, survDist=false,
    killESP=false, killBox=false, killRole=false, killName=false, killSkin=false, killLogin=false,
    killHP=false, killStatus=false, killDist=false,
    itemESP=false,
    rangeActive=false, rangeSize=10, rangeTrans=0.7, rangeColor="红色", rangeMaterial="Neon",
    rangeAffectNPC=false, rangeTeamCheck=false, rangeCorpseCheck=false, rangeOutline=false,
    rangeCollision=false, rangeGlow=false, rangePulse=false,
    hitboxVisual=false, hitboxMat="Plastic", hitboxColor=Color3.fromRGB(255,64,64),
    hitboxHitColor=Color3.fromRGB(128,255,128), hitboxTrans=1, hitboxHitTrans=1,
    fly=false, flySpeed=50, spin=false, spinSpeed=5,
    speedHack=false, speedValue=16, noclip=false, infJump=false, godMode=false,
    antiAfk=false, flySwim=false,
    hitboxExt=false, hitboxExtRange=10, hitboxTrack=false, hitboxTrackRange=60,
    antiStun=false, speedBoost=false, noSlowdown=false, noAbilitySlowdown=false,
    invis=false, showSidebar=false, chatHide=false,
    privacyReveal=false, fullBrightLv=0, noShadow=false, noFog=false, sceneSwitch=false,
    staminaInf=false, staminaMax=100, staminaGain=25, staminaLoss=10, sprintSpeed=28,
    autoUnsprint=false, autoSprint=false, noSprintTween=false,
    slasherEnraged=false, slasherEnragedMult=2.111, slasherParry=false,
    slasherParryRange=15, slasherParryVis=false,
    jd404Parry=false, jd404Range=15, jd404Vis=false,
    antiBackstab=false, antiBackstabRange=40, antiBackstabDur=1.5,
    killAll=false, killAllTeleport=false,
    suction=false, suctionStrength=50, suctionDist=100,
    autoFarm=false, autoRob=false, autoATM=false,
    autoMission=false, priorityMission=false, missionInterval=2,
    taxiSafe=false, taxiDelayMode="随机时间", taxi=false, bus=false, farmer=false,
    autoHack=false, golf=false,
    currentTarget=nil, lastAimUpdate=0, frameCount=0,
}

local Conn = {}
local function bind(c) table.insert(Conn, c); return c end
local function getChar() return LP.Character end
local function getHRP()
    local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function isTeam(p)
    local mt=LP.Team; if not mt then return false end
    local ot=p and p.Team; return ot~=nil and ot==mt
end

--==================== 背景模糊 ====================
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
blur.Name = "HeBlur"

--==================== 毛玻璃工厂 ====================
local function glassify(frame, radius, light)
    frame.BackgroundColor3 = light and Color3.fromRGB(255,255,255) or Color3.fromRGB(28,28,34)
    frame.BackgroundTransparency = light and 0.35 or 0.28
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, radius or 18)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = light and 0.5 or 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local grad = Instance.new("UIGradient", frame)
    grad.Rotation = 135
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,235)),
    }
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, light and 0.55 or 0.82),
        NumberSequenceKeypoint.new(0.5, light and 0.75 or 0.92),
        NumberSequenceKeypoint.new(1, light and 0.6 or 0.85),
    }
    return corner, stroke, grad
end

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HeBallUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

--==================== 悬浮球 ====================
local ball = Instance.new("TextButton")
ball.Name="HeBall"
ball.Size=UDim2.fromOffset(62,62)
ball.Position=UDim2.new(0,40,0.5,-31)
ball.Text="贺"
ball.TextColor3=Color3.fromRGB(255,255,255)
ball.TextSize=26
ball.Font=Enum.Font.GothamBold
ball.AutoButtonColor=false
ball.Active=true
ball.Draggable=false
ball.BackgroundTransparency=1
ball.TextTransparency=1
ball.Parent=screenGui

local ballCorner, ballStroke, ballGrad = glassify(ball, 31, false)
ballCorner.CornerRadius = UDim.new(1, 0)

local ballGlow = Instance.new("UIStroke", ball)
ballGlow.Thickness=2
ballGlow.Color=Color3.fromRGB(255,215,0)
ballGlow.Transparency=1
ballGlow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local ballGlowGrad = Instance.new("UIGradient", ballGlow)
ballGlowGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,80,80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,215,0)),
}
bind(RunService.Heartbeat:Connect(function()
    if ballGlowGrad.Parent then
        ballGlowGrad.Rotation=(ballGlowGrad.Rotation+2)%360
    end
end))

--==================== 主窗口 ====================
local win = Instance.new("Frame")
win.Name="HeWindow"
win.Size=UDim2.fromOffset(640,460)
win.Position=UDim2.new(0.5,-320,0.5,-230)
win.BackgroundTransparency=1
win.BorderSizePixel=0
win.Visible=false
win.Active=true
win.Parent=screenGui
glassify(win, 24, false)

local topBar = Instance.new("Frame", win)
topBar.Size=UDim2.new(1,0,0,42)
topBar.BackgroundTransparency=1
topBar.BorderSizePixel=0
glassify(topBar, 24, false)

local title = Instance.new("TextLabel", topBar)
title.Text="  贺 · 多功能面板 v3.0"
title.Size=UDim2.new(1,-70,1,0)
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=15
title.TextXAlignment=Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Text="✕"
closeBtn.Size=UDim2.fromOffset(28,28)
closeBtn.Position=UDim2.new(1,-36,0.5,-14)
closeBtn.BackgroundColor3=Color3.fromRGB(255,255,255)
closeBtn.BackgroundTransparency=0.8
closeBtn.TextColor3=Color3.fromRGB(255,100,100)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=14
closeBtn.AutoButtonColor=false
Instance.new("UICorner", closeBtn).CornerRadius=UDim.new(1,0)

local sideBar = Instance.new("Frame", win)
sideBar.Size=UDim2.new(0,140,1,-52)
sideBar.Position=UDim2.new(0,6,0,46)
sideBar.BackgroundTransparency=1
sideBar.BorderSizePixel=0
glassify(sideBar, 18, false)

local content = Instance.new("ScrollingFrame", win)
content.Size=UDim2.new(1,-160,1,-60)
content.Position=UDim2.new(0,150,0,50)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
content.ScrollBarImageTransparency=0.5
content.CanvasSize=UDim2.new(0,0,0,0)
content.AutomaticCanvasSize=Enum.AutomaticSize.Y
content.ScrollingDirection=Enum.ScrollingDirection.Y
local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding=UDim.new(0,6)
contentLayout.SortOrder=Enum.SortOrder.LayoutOrder

--==================== UI 组件 ====================
local function makeToggle(parent, text, default, callback)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-8,0,34)
    f.BackgroundTransparency=1
    f.BorderSizePixel=0
    glassify(f,12,false)
    local lbl=Instance.new("TextLabel",f)
    lbl.Text="  "..text
    lbl.Size=UDim2.new(1,-70,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(235,235,245)
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f)
    btn.Size=UDim2.fromOffset(42,22)
    btn.Position=UDim2.new(1,-50,0.5,-11)
    btn.BackgroundColor3=default and Color3.fromRGB(80,220,130) or Color3.fromRGB(120,120,130)
    btn.BackgroundTransparency=default and 0.2 or 0.55
    btn.Text=default and "ON" or "OFF"
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=11
    btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local st=Instance.new("UIStroke",btn)
    st.Thickness=1; st.Color=Color3.fromRGB(255,255,255); st.Transparency=0.6
    local state=default
    btn.MouseButton1Click:Connect(function()
        state=not state
        btn.BackgroundColor3=state and Color3.fromRGB(80,220,130) or Color3.fromRGB(120,120,130)
        btn.BackgroundTransparency=state and 0.2 or 0.55
        btn.Text=state and "ON" or "OFF"
        pcall(callback,state)
    end)
end

local function makeSlider(parent,text,min,max,default,callback)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-8,0,52)
    f.BackgroundTransparency=1
    f.BorderSizePixel=0
    glassify(f,12,false)
    local lbl=Instance.new("TextLabel",f)
    lbl.Text="  "..text..": "..default
    lbl.Size=UDim2.new(1,0,0,22)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(235,235,245)
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(1,-20,0,8)
    bar.Position=UDim2.new(0,10,0,32)
    bar.BackgroundColor3=Color3.fromRGB(InputType255,255.Touch, then255)
    bar.BackgroundTrans
parency=0.75
    bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(255,255,255)
    fill.BackgroundTransparency=0.15
    fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local drag=false
    local function upd(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local val=min+(max-min)*rel
        if (max-min)>10 then val=math.floor(val) end
        fill.Size=UDim2.new(rel,0,1,0)
        lbl.Text="  "..text..": "..(math.floor(val*100)/100)
        pcall(callback,val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.User            drag=true; upd(i.Position.X)
        end
    end)
    bind(UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end))
    bind(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end))
end

local function makeButton(parent,text,callback)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,-8,0,34)
    btn.BackgroundTransparency=1
    btn.BorderSizePixel=0
    btn.Text=text
    btn.TextColor3=Color3.fromRGB(235,235,245)
    btn.Font=Enum.Font.Gotham
    btn.TextSize=13
    btn.AutoButtonColor=false
    glassify(btn,12,false)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function makeLabel(parent,text)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,-8,0,24)
    l.BackgroundTransparency=1
    l.Text="  "..text
    l.TextColor3=Color3.fromRGB(170,180,200)
    l.Font=Enum.Font.GothamBold
    l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left
end

--==================== FOV 圈 ====================
local fovCircle
if Drawing and Drawing.new then
    pcall(function()
        fovCircle=Drawing.new("Circle")
        fovCircle.Visible=false
        fovCircle.Radius=S.fovRadius
        fovCircle.Color=Color3.fromRGB(255,50,50)
        fovCircle.Thickness=1.5
        fovCircle.Transparency=0.8
        fovCircle.Filled=false
        fovCircle.NumSides=64
    end)
end
bind(RunService.RenderStepped:Connect(function()
    if fovCircle and Camera then
        fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end))

--==================== 目标查找 ====================
local function findTarget()
    if not S.silentAim then S.currentTarget=nil; return end
    local cam=Camera; if not cam then return end
    local camCF=cam.CFrame
    local closestDist=math.huge
    local best=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and not isTeam(p) then
            local c=p.Character
            if c and not c:FindFirstChild("ForceField") then
                local hum=c:FindFirstChildOfClass("Humanoid")
                local part
                if S.aimPart=="Random" then
                    local parts={"Head","HumanoidRootPart","Left Arm","Right Arm","Left Leg","Right Leg"}
                    part=c:FindFirstChild(parts[math.random(1,#parts)])
                else
                    part=c:FindFirstChild(S.aimPart) or c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
                end
                if hum and hum.Health>0 and part then
                    local toT=part.Position-camCF.Position
                    local dist=toT.Magnitude
                    if dist<closestDist and dist<1000 then
                        local ang=math.deg(math.acos(math.clamp(camCF.LookVector:Dot(toT.Unit),-1,1)))
                        if ang<=S.fovRadius/8 then
                            if S.wallCheck then
                                local rp=RaycastParams.new()
                                rp.FilterDescendantsInstances={LP.Character,c}
                                rp.FilterType=Enum.RaycastFilterType.Exclude
                                if not Workspace:Raycast(camCF.Position,toT,rp) then
                                    best=part; closestDist=dist
                                end
                            else
                                best=part; closestDist=dist
                            end
                        end
                    end
                end
            end
        end
    end
    S.currentTarget=best
end
bind(RunService.RenderStepped:Connect(function()
    if tick()-S.lastAimUpdate>=0.05 then
        S.lastAimUpdate=tick()
        pcall(findTarget)
    end
end))

--==================== 弹道 ====================
local function createTracer(fromPos,toPos)
    if not S.tracer then return end
    task.spawn(function()
        pcall(function()
            local dir=toPos-fromPos
            local dist=dir.Magnitude
            if dist<0.01 then return end
            local part=Instance.new("Part")
            part.Anchored=true; part.CanCollide=false
            part.Material=Enum.Material.Neon
            part.Color=S.tracerColor
            part.Size=Vector3.new(0.12,0.12,dist)
            part.CFrame=CFrame.lookAt(fromPos,toPos)*CFrame.new(0,0,-dist/2)
            part.Transparency=0.15
            part.Parent=Workspace
            task.wait(0.15)
            part:Destroy()
        end)
    end)
end

--==================== 静默瞄准 Hook ====================
if hookmetamethod and newcclosure and getnamecallmethod then
    local oldNamecall
    oldNamecall=hookmetamethod(game,"__namecall",newcclosure(function(self,...)
        local method=getnamecallmethod()
        if checkcaller() then return oldNamecall(self,...) end
        if self~=Workspace then return oldNamecall(self,...) end
        if method~="Raycast" and method~="FindPartOnRay" and method~="FindPartOnRayWithIgnoreList" then
            return oldNamecall(self,...)
        end
        if not S.silentAim or not S.currentTarget then return oldNamecall(self,...) end
        if math.random(1,100)>S.hitChance then return oldNamecall(self,...) end
        local args={...}
        local origin,dir
        if method=="Raycast" then
            origin,dir=args[1],args[2]
        else
            local ray=args[1]
            if typeof(ray)=="Ray" then origin,dir=ray.Origin,ray.Direction end
        end
        if not origin or not dir then return oldNamecall(self,...) end
        local tPos=S.currentTarget.Position
        if S.hitSound then
            task.spawn(function()
                pcall(function()
                    local s=Instance.new("Sound")
                    s.SoundId="rbxassetid://6534948092"
                    s.Volume=1.5
                    s.Parent=game:GetService("SoundService")
                    s:Play()
                    task.wait(1); s:Destroy()
                end)
            end)
        end
        createTracer(origin,tPos)
        if method=="Raycast" then
            return {Instance=S.currentTarget,Position=tPos,Normal=(tPos-origin).Unit,
                    Material=Enum.Material.Plastic,Distance=(tPos-origin).Magnitude}
        else
            return S.currentTarget,tPos,(tPos-origin).Unit
        end
    end))
end

--==================== 触发开火 ====================
bind(RunService.RenderStepped:Connect(function()
    if S.triggerbot and S.silentAim and S.currentTarget then
        local tc=S.currentTarget.Parent
        if tc then
            local p=Players:GetPlayerFromCharacter(tc)
            if p and not isTeam(p) then
                local hum=tc:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    pcall(function()
                        VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                        task.wait()
                        VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                    end)
                end
            end
        end
    end
end))

--==================== Hitbox 扩展 ====================
local originalSizes={}
local adornments={}
local function clearHitbox(p)
    if adornments[p] then pcall(function() adornments[p]:Destroy() end); adornments[p]=nil end
    if originalSizes[p] then
        local c=p.Character
        if c then
            local hb=c:FindFirstChild("Hitbox")
            local head=hb and hb:FindFirstChild("Head_Hitbox")
            if head then pcall(function() head.Size=originalSizes[p] end) end
        end
        originalSizes[p]=nil
    end
end
bind(RunService.Heartbeat:Connect(function()
    S.frameCount=S.frameCount+1
    if S.frameCount%3~=0 then return end
    if not S.hitboxEnabled then
        for p in pairs(adornments) do clearHitbox(p) end
        return
    end
    local tSize=Vector3.new(S.hitboxSize,S.hitboxSize,S.hitboxSize)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hb=p.Character:FindFirstChild("Hitbox")
            local head=hb and hb:FindFirstChild("Head_Hitbox")
            if head then
                if not originalSizes[p] then originalSizes[p]=head.Size end
                head.Size=tSize
                if not adornments[p] then
                    local a=Instance.new("BoxHandleAdornment")
                    a.AlwaysOnTop=true; a.ZIndex=10; a.Adornee=head; a.Parent=head
                    adornments[p]=a
                end
                adornments[p].Size=tSize
                adornments[p].Color3=S.adornColor
                adornments[p].Transparency=0.4
            end
        end
    end
end))

--==================== ESP ====================
local espObjs={}
bind(RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or isTeam(p) then
            if espObjs[p] then for _,o in pairs(espObjs[p]) do o.Visible=false end end
        else
            local c=p.Character
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if S.esp and c and hum and hum.Health>0 and hrp and Camera then
                if not espObjs[p] and Drawing and Drawing.new then
                    espObjs[p]={
                        Box=Drawing.new("Square"),
                        Name=Drawing.new("Text"),
                        HP=Drawing.new("Text"),
                    }
                    espObjs[p].Box.Thickness=1.5
                    espObjs[p].Box.Filled=false
                    espObjs[p].Name.Size=14; espObjs[p].Name.Center=true
                    espObjs[p].Name.Outline=true; espObjs[p].Name.Color=Color3.fromRGB(255,255,255)
                    espObjs[p].HP.Size=12; espObjs[p].HP.Center=true
                    espObjs[p].HP.Outline=true
                end
                local e=espObjs[p]
                if e then
                    local head=c:FindFirstChild("Head")
                    if head then
                        local hp,on1=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
                        local fp,on2=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
                        if on1 or on2 then
                            local h=math.abs(hp.Y-fp.Y)
                            local w=h*0.55
                            e.Box.Size=Vector2.new(w,h)
                            e.Box.Position=Vector2.new(hp.X-w/2,hp.Y)
                            local hpPct=hum.Health/math.max(hum.MaxHealth,1)
                            e.Box.Color=Color3.fromRGB(255-math.floor(hpPct*255),math.floor(hpPct*255),0)
                            e.Box.Visible=true
                            e.Name.Position=Vector2.new(hp.X,hp.Y-18)
                            e.Name.Text=p.Name
                            e.Name.Visible=true
                            e.HP.Position=Vector2.new(hp.X,fp.Y+2)
                            e.HP.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                            e.HP.Visible=true
                        else
                            e.Box.Visible=false; e.Name.Visible=false; e.HP.Visible=false
                        end
                    end
                end
            else
                if espObjs[p] then for _,o in pairs(espObjs[p]) do o.Visible=false end end
            end
        end
    end
end))

--==================== 彩虹透视 ====================
local chamsObjs={}
bind(RunService.Heartbeat:Connect(function()
    if not S.chams then
        for _,o in pairs(chamsObjs) do pcall(function() o:Destroy() end) end
        table.clear(chamsObjs); return
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and not isTeam(p) and p.Character then
            if not chamsObjs[p] or chamsObjs[p].Parent~=p.Character then
                if chamsObjs[p] then pcall(function() chamsObjs[p]:Destroy() end) end
                local hl=Instance.new("Highlight")
                hl.FillTransparency=0.7
                hl.OutlineTransparency=0
                hl.Parent=p.Character
                chamsObjs[p]=hl
            end
            local t=tick()
            pcall(function()
                chamsObjs[p].FillColor=Color3.new(
                    0.5+0.5*math.sin(t*3),
                    0.5+0.5*math.sin(t*3+2),
                    0.5+0.5*math.sin(t*3+4)
                )
                chamsObjs[p].OutlineColor=chamsObjs[p].FillColor
            end)
        end
    end
end))

--==================== 天空主题 ====================
local function updateSky(theme)
    pcall(function()
        for _,o in ipairs(Lighting:GetChildren()) do
            if o:IsA("Sky") then o:Destroy() end
        end
        local sky=Instance.new("Sky",Lighting)
        sky.Name="HeSky"
        if theme=="日落" then
            sky.SkyboxBk="rbxassetid://11808530"
            sky.SkyboxDn="rbxassetid://11808534"
            sky.SkyboxFt="rbxassetid://11808536"
            sky.SkyboxLf="rbxassetid://11808538"
            sky.SkyboxRt="rbxassetid://11808540"
            sky.SkyboxUp="rbxassetid://11808542"
        elseif theme=="星云" then
            sky.SkyboxBk="rbxassetid://159454299"
            sky.SkyboxDn="rbxassetid://159454296"
            sky.SkyboxFt="rbxassetid://159454293"
            sky.SkyboxLf="rbxassetid://159454286"
            sky.SkyboxRt="rbxassetid://159454300"
            sky.SkyboxUp="rbxassetid://159454288"
        else
            sky.SkyboxBk="rbxassetid://6444884337"
            sky.SkyboxDn="rbxassetid://6444884785"
            sky.SkyboxFt="rbxassetid://6444884337"
            sky.SkyboxLf="rbxassetid://6444884337"
            sky.SkyboxRt="rbxassetid://6444884337"
            sky.SkyboxUp="rbxassetid://6444884337"
        end
        sky.StarCount=3000
    end)
end

bind(RunService.Heartbeat:Connect(function()
    if S.fullBright then
        pcall(function()
            Lighting.Brightness=2
            Lighting.ClockTime=12
            Lighting.GlobalShadows=false
            Lighting.FogEnd=786543
            Lighting.Ambient=Color3.fromRGB(178,178,178)
        end)
    end
    if S.nightVision then
        pcall(function()
            Lighting.Ambient=Color3.fromRGB(100,100,100)
            Lighting.Brightness=2
            Lighting.ClockTime=14
        end)
    end
    if S.cameraFOV and Camera then Camera.FieldOfView=S.cameraFOV end
    if S.skyTheme~="默认" then
        local has=false
        for _,c in ipairs(Lighting:GetChildren()) do
            if c:IsA("Sky") and c.Name=="HeSky" then has=true break end
        end
        if not has then pcall(function() updateSky(S.skyTheme) end) end
    end
end))

--==================== Tab 系统 ====================
local tabs={}
local currentTab=nil

local function switchTab(name)
    if currentTab==name then return end
    currentTab=name
    for _,c in ipairs(content:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("TextLabel") then
            c:Destroy()
        end
    end
    if tabs[name] then pcall(tabs[name]) end
end

--==================== 战斗 Tab ====================
tabs["战斗"]=function()
    makeLabel(content,"▶ 静默瞄准")
    makeToggle(content,"启用静默瞄准",false,function(v) S.silentAim=v end)
    makeSlider(content,"FOV 半径",50,1000,250,function(v)
        S.fovRadius=v
        if fovCircle then fovCircle.Radius=v end
    end)
    makeToggle(content,"显示 FOV 圈",false,function(v)
        S.showFOV=v
        if fovCircle then fovCircle.Visible=v end
    end)
    makeToggle(content,"墙壁检测",false,function(v) S.wallCheck=v end)
    makeSlider(content,"命中率 %",1,100,100,function(v) S.hitChance=v end)
    makeToggle(content,"触发开火",false,function(v) S.triggerbot=v end)
    makeLabel(content,"▶ 瞄准部位")
    makeButton(content,"头部 (Head)",function() S.aimPart="Head" end)
    makeButton(content,"躯干 (Torso)",function() S.aimPart="Torso" end)
    makeButton(content,"根部件 (HRP)",function() S.aimPart="HumanoidRootPart" end)
    makeButton(content,"随机",function() S.aimPart="Random" end)
    makeLabel(content,"▶ Hitbox 扩展")
    makeToggle(content,"启用 Hitbox",false,function(v) S.hitboxEnabled=v end)
    makeSlider(content,"Hitbox 大小",1,100,10,function(v) S.hitboxSize=v end)
    makeLabel(content,"▶ 打击反馈")
    makeToggle(content,"击中音效",false,function(v) S.hitSound=v end)
    makeToggle(content,"弹道显示",false,function(v) S.tracer=v end)
    makeLabel(content,"▶ 放大枪")
    makeToggle(content,"启用放大枪",false,function(v) S.gunScale=v end)
    makeSlider(content,"放大倍数",2,50,10,function(v) S.gunScaleMult=v end)
    makeLabel(content,"▶ Ragebot")
    makeToggle(content,"启用 Ragebot",false,function(v) S.ragebot=v end)
    makeSlider(content,"攻击距离",10,500,150,function(v) S.rageRange=v end)
    makeSlider(content,"攻击间隔",0.01,1,0.05,function(v) S.rageInterval=v end)
    makeButton(content,"攻击头部",function() S.ragePart="Head" end)
    makeButton(content,"攻击躯干",function() S.ragePart="Torso" end)
    makeToggle(content,"职业检测",false,function(v) S.rageJobCheck=v end)
    makeToggle(content,"墙壁检测",false,function(v) S.rageWallCheck=v end)
    makeToggle(content,"活体检测",false,function(v) S.rageAliveCheck=v end)
    makeToggle(content,"战斗状态检测",false,function(v) S.rageCombatCheck=v end)
    makeToggle(content,"锁定警察",false,function(v) S.ragePoliceLock=v end)
    makeToggle(content,"锁定平民",false,function(v) S.rageCivilianLock=v end)
    makeToggle(content,"弹道显示",false,function(v) S.rageBeam=v end)
    makeLabel(content,"▶ 杀戮光环")
    makeToggle(content,"启用光环",false,function(v) S.aura=v end)
    makeSlider(content,"攻击范围",10,500,50,function(v) S.auraRange=v end)
    makeSlider(content,"伤害倍率",1,100,5,function(v) S.auraDamage=v end)
    makeToggle(content,"只攻击警察",false,function(v) S.auraOnlyPolice=v end)
    makeToggle(content,"只攻击平民",false,function(v) S.auraOnlyCivilian=v end)
    makeToggle(content,"战斗检测",false,function(v) S.auraCombatCheck=v end)
    makeLabel(content,"▶ 自瞄")
    makeToggle(content,"启用自瞄",false,function(v) S.aimbot=v end)
    makeToggle(content,"显示 FOV 圈",false,function(v) S.aimFovShow=v end)
    makeToggle(content,"显示准心",false,function(v) S.aimCrosshair=v end)
    makeToggle(content,"显示追踪线",false,function(v) S.aimTracer=v end)
    makeToggle(content,"队伍检测",false,function(v) S.aimTeamCheck=v end)
    makeToggle(content,"好友检测",false,function(v) S.aimFriendCheck=v end)
    makeToggle(content,"墙壁检测",false,function(v) S.aimWallCheck=v end)
    makeToggle(content,"预判自瞄",false,function(v) S.aimPrediction=v end)
    makeToggle(content,"只自瞄警察",false,function(v) S.aimOnlyPolice=v end)
    makeToggle(content,"只自瞄平民",false,function(v) S.aimOnlyCivilian=v end)
    makeToggle(content,"战斗检测",false,function(v) S.aimCombatCheck=v end)
    makeSlider(content,"FOV 圈大小",1,500,50,function(v) S.aimFov=v end)
    makeSlider(content,"平滑度",0.1,1,1,function(v) S.aimSmooth=v end)
    makeSlider(content,"FOV 圈厚度",1,5,2,function(v) S.aimFovThick=v end)
end

--==================== 视觉 Tab ====================
tabs["视觉"]=function()
    makeLabel(content,"▶ ESP 透视")
    makeToggle(content,"启用 ESP",false,function(v) S.esp=v end)
    makeToggle(content,"彩虹透视",false,function(v) S.chams=v end)
    makeLabel(content,"▶ 画面调节")
    makeToggle(content,"全亮",false,function(v)
        S.fullBright=v
        if not v then
            pcall(function()
                Lighting.Brightness=1
                Lighting.GlobalShadows=true
                Lighting.Ambient=Color3.fromRGB(70,70,70)
            end)
        end
    end)
    makeToggle(content,"夜视",false,function(v) S.nightVision=v end)
    makeSlider(content,"相机 FOV",30,140,70,function(v)
        S.cameraFOV=v
        if Camera then Camera.FieldOfView=v end
    end)
    makeLabel(content,"▶ 天空主题")
    makeButton(content,"默认",function() S.skyTheme="默认"; updateSky("默认") end)
    makeButton(content,"日落",function() S.skyTheme="日落"; updateSky("日落") end)
    makeButton(content,"星云",function() S.skyTheme="星云"; updateSky("星云") end)
    makeLabel(content,"▶ 发电机透视")
    makeToggle(content,"启用发电机透视",false,function(v) S.genESP=v end)
    makeToggle(content,"显示进度 %",true,function(v) S.genPercent=v end)
    makeToggle(content,"显示距离",true,function(v) S.genDist=v end)
    makeToggle(content,"过滤假发电机",true,function(v) S.genFilter=v end)
    makeLabel(content,"▶ 幸存者透视")
    makeToggle(content,"启用幸存者透视",false,function(v) S.survESP=v end)
    makeToggle(content,"2D 框",false,function(v) S.survBox=v end)
    makeToggle(content,"显示幸存者标签",false,function(v) S.survRole=v end)
    makeToggle(content,"显示角色名称",false,function(v) S.survName=v end)
    makeToggle(content,"显示皮肤名称",false,function(v) S.survSkin=v end)
    makeToggle(content,"显示用户名",false,function(v) S.survLogin=v end)
    makeToggle(content,"显示生命值",false,function(v) S.survHP=v end)
    makeToggle(content,"显示状态",false,function(v) S.survStatus=v end)
    makeToggle(content,"显示距离",false,function(v) S.survDist=v end)
    makeLabel(content,"▶ 杀手透视")
    makeToggle(content,"启用杀手透视",false,function(v) S.killESP=v end)
    makeToggle(content,"2D 框",false,function(v) S.killBox=v end)
    makeToggle(content,"显示杀手标签",false,function(v) S.killRole=v end)
    makeToggle(content,"显示角色名称",false,function(v) S.killName=v end)
    makeToggle(content,"显示皮肤名称",false,function(v) S.killSkin=v end)
    makeToggle(content,"显示用户名",false,function(v) S.killLogin=v end)
    makeToggle(content,"显示生命值",false,function(v) S.killHP=v end)
    makeToggle(content,"显示状态",false,function(v) S.killStatus=v end)
    makeToggle(content,"显示距离",false,function(v) S.killDist=v end)
    makeLabel(content,"▶ 物品透视")
    makeToggle(content,"启用物品透视",false,function(v) S.itemESP=v end)
    makeLabel(content,"▶ 范围可视化")
    makeToggle(content,"启用范围",false,function(v) S.rangeActive=v end)
    makeSlider(content,"范围大小",1,100,10,function(v) S.rangeSize=v end)
    makeSlider(content,"透明度",0,1,0.7,function(v) S.rangeTrans=v end)
    makeToggle(content,"NPC 范围",false,function(v) S.rangeAffectNPC=v end)
    makeToggle(content,"队伍检测",false,function(v) S.rangeTeamCheck=v end)
    makeToggle(content,"活体检测",false,function(v) S.rangeCorpseCheck=v end)
    makeToggle(content,"显示轮廓",false,function(v) S.rangeOutline=v end)
    makeToggle(content,"启用碰撞",false,function(v) S.rangeCollision=v end)
    makeToggle(content,"发光效果",false,function(v) S.rangeGlow=v end)
    makeToggle(content,"脉动效果",false,function(v) S.rangePulse=v end)
end

--==================== 侧边栏按钮 ====================
local tabList={"战斗","视觉","移动","工具","幸存者","杀手","刷钱","权限","设置"}
for i,name in ipairs(tabList) do
    local btn=Instance.new("TextButton",sideBar)
    btn.Size=UDim2.new(1,-12,0,34)
    btn.Position=UDim2.new(0,6,0,8+(i-1)*38)
    btn.BackgroundTransparency=1
    btn.Text=name
    btn.TextColor3=Color3.fromRGB(220,220,235)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=13
    btn.AutoButtonColor=false
    glassify(btn,12,false)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--==================== 悬浮球拖拽+点击 ====================
local pressPos,startPos,isDragging=nil,nil,false
local CLICK_THRESHOLD=8

ball.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
    or input.UserInputType==Enum.UserInputType.Touch then
        pressPos=input.Position
        startPos=ball.Position
        isDragging=false
    end
end)
bind(UIS.InputChanged:Connect(function(input)
    if not pressPos then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement
    or input.UserInputType==Enum.UserInputType.Touch then
        local delta=input.Position-pressPos
        if delta.Magnitude>CLICK_THRESHOLD then
            isDragging=true
            ball.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                    startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end
end))
bind(UIS.InputEnded:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1
    and input.UserInputType~=Enum.UserInputType.Touch then return end
    if not pressPos then return end
    local moved=(input.Position-pressPos).Magnitude
    pressPos=nil
    if moved<CLICK_THRESHOLD and not isDragging then
        if not win.Visible then
            win.Visible=true
            ball.Visible=false
            TweenService:Create(blur,TweenInfo.new(0.35),{Size=20}):Play()
            if not currentTab then switchTab("战斗") end
        else
            win.Visible=false
            ball.Visible=true
            TweenService:Create(blur,TweenInfo.new(0.3),{Size=0}):Play()
        end
    end
    isDragging=false
end))

do
    local d,ds,sp=false,nil,nil
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            d=true; ds=input.Position; sp=win.Position
        end
    end)
    bind(UIS.InputChanged:Connect(function(input)
        if d and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-ds
            win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+delta.X,sp.Y.Scale,sp.Y.Offset+delta.Y)
        end
    end))
    bind(UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            d=false
        end
    end))
end

closeBtn.MouseButton1Click:Connect(function()
    win.Visible=false
    ball.Visible=true
    TweenService:Create(blur,TweenInfo.new(0.3),{Size=0}):Play()
end)

bind(UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.RightShift then
        if not win.Visible then
            win.Visible=true
            ball.Visible=false
            TweenService:Create(blur,TweenInfo.new(0.35),{Size=20}):Play()
            if not currentTab then switchTab("战斗") end
        else
            win.Visible=false
            ball.Visible=true
            TweenService:Create(blur,TweenInfo.new(0.3),{Size=0}):Play()
        end
    end
end))--==================== 移动：飞行 ====================
local flyBV, flyBG, flyConn = nil, nil, nil

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV=nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG=nil end
    local hum=getHum()
    if hum then pcall(function() hum.PlatformStand=false; hum.AutoRotate=true end) end
end

local function startFly()
    if flyConn then stopFly() end
    local hrp=getHRP()
    local hum=getHum()
    if not hrp or not hum then return end
    hum.PlatformStand=true
    hum.AutoRotate=false
    flyBV=Instance.new("BodyVelocity",hrp)
    flyBV.MaxForce=Vector3.new(1e7,1e7,1e7)
    flyBV.Velocity=Vector3.zero
    flyBG=Instance.new("BodyGyro",hrp)
    flyBG.MaxTorque=Vector3.new(1e7,1e7,1e7)
    flyBG.P=1e5
    flyBG.CFrame=hrp.CFrame
    flyConn=RunService.RenderStepped:Connect(function()
        if not S.fly or not flyBV or not flyBG then return end
        local cam=Camera; if not cam then return end
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
        flyBV.Velocity=dir.Magnitude>0 and dir.Unit*S.flySpeed or Vector3.zero
        flyBG.CFrame=cam.CFrame
    end)
end

--==================== 旋转 ====================
bind(RunService.Heartbeat:Connect(function()
    if S.spin then
        local hrp=getHRP()
        if hrp then pcall(function() hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(S.spinSpeed),0) end) end
    end
end))

--==================== 加速/穿墙/上帝/防挂机 ====================
bind(RunService.Heartbeat:Connect(function()
    local c=getChar()
    if c then
        local hum=c:FindFirstChildOfClass("Humanoid")
        if S.speedHack and hum then hum.WalkSpeed=S.speedValue end
        if S.noclip then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end
        if S.godMode and hum then
            hum.MaxHealth=999999; hum.Health=999999
        end
    end
    if S.antiAfk then
        pcall(function()
            VUser:CaptureController()
            VUser:ClickButton2(Vector2.new())
        end)
    end
end))

bind(UIS.JumpRequest:Connect(function()
    if S.infJump then
        local hum=getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

--==================== 飞行游泳 ====================
local terrain=Workspace:FindFirstChildOfClass("Terrain")
local flyParts={}
local waterSettings={WaterTransparency=0.7,WaterReflectance=0.2,WaterWaveSize=0.5,WaterWaveSpeed=0.5,WaterColor=Color3.fromRGB(0,100,200)}
local airSettings={WaterTransparency=1,WaterReflectance=0,WaterWaveSize=0,WaterWaveSpeed=0,WaterColor=Color3.fromRGB(255,255,255)}

bind(RunService.RenderStepped:Connect(function()
    if S.flySwim and getChar() and terrain then
        local hrp=getHRP()
        local head=getChar() and getChar():FindFirstChild("Head")
        if hrp and head then
            local headCF=head.CFrame
            local hrpCF=hrp.CFrame
            local size=hrp.Size+Vector3.new(0,0.1,0)
            pcall(function()
                terrain.WaterTransparency=airSettings.WaterTransparency
                terrain.WaterReflectance=airSettings.WaterReflectance
                terrain.WaterWaveSize=airSettings.WaterWaveSize
                terrain.WaterWaveSpeed=airSettings.WaterWaveSpeed
                terrain.WaterColor=airSettings.WaterColor
                terrain:FillBlock(headCF,size,Enum.Material.Water)
                terrain:FillBlock(hrpCF,size,Enum.Material.Water)
            end)
            table.insert(flyParts,{time=tick(),cf=headCF,size=size})
            table.insert(flyParts,{time=tick(),cf=hrpCF,size=size})
        end
    end
end))

task.spawn(function()
    while true do
        local now=tick()
        for i=#flyParts,1,-1 do
            local p=flyParts[i]
            if now-p.time>=0.8 then
                pcall(function() terrain:FillBlock(p.cf,p.size,Enum.Material.Air) end)
                table.remove(flyParts,i)
            end
        end
        if terrain then
            pcall(function()
                terrain.WaterTransparency=waterSettings.WaterTransparency
                terrain.WaterReflectance=waterSettings.WaterReflectance
                terrain.WaterWaveSize=waterSettings.WaterWaveSize
                terrain.WaterWaveSpeed=waterSettings.WaterWaveSpeed
                terrain.WaterColor=waterSettings.WaterColor
            end)
        end
        task.wait(0.05)
    end
end)

--==================== 碰撞箱扩展 ====================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if S.hitboxExt then
            local c=getChar()
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myUsername=c:GetAttribute("Username") or LP.Name
                local myHitboxName=myUsername.."Hitbox"
                local hbFolder=Workspace:FindFirstChild("Hitboxes")
                local detected=false
                if hbFolder then
                    for _,part in ipairs(hbFolder:GetChildren()) do
                        if part.Name==myHitboxName and (part.Position-hrp.Position).Magnitude<=15 then
                            detected=true; break
                        end
                    end
                end
                if detected then
                    local vel=hrp.AssemblyLinearVelocity
                    if vel.Magnitude>0.5 then
                        local distance=S.hitboxExtRange*6
                        local moveDir=vel.Magnitude>0 and vel.Unit or hrp.CFrame.LookVector
                        local newVel=vel+(moveDir*distance)
                        hrp.AssemblyLinearVelocity=Vector3.new(newVel.X,vel.Y,newVel.Z)
                        RunService.RenderStepped:Wait()
                        local hrp2=getHRP()
                        if hrp2 then hrp2.AssemblyLinearVelocity=vel end
                    end
                end
            end
        end
    end
end)

--==================== 碰撞箱追踪 ====================
task.spawn(function()
    while task.wait() do
        if S.hitboxTrack then
            local c=getChar()
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                local isAttack=false
                for _,track in ipairs(hum:GetPlayingAnimationTracks()) do
                    if track.Animation and track.Animation.AnimationId and (track.TimePosition/math.max(track.Length,0.01)<0.75) then
                        isAttack=true; break
                    end
                end
                if isAttack then
                    local closest, closestDist=nil, S.hitboxTrackRange
                    local function scan(list)
                        for _,model in ipairs(list) do
                            if model~=c and model:FindFirstChild("HumanoidRootPart") then
                                local h=model:FindFirstChildOfClass("Humanoid")
                                if h and h.Health>0 then
                                    local d=(model.HumanoidRootPart.Position-hrp.Position).Magnitude
                                    if d<closestDist then closestDist=d; closest=model end
                                end
                            end
                        end
                    end
                    local pf=Workspace:FindFirstChild("Players")
                    if pf then scan(pf:GetDescendants()) end
                    if closest then
                        local ping=0.05
                        pcall(function() ping=tonumber(game:GetService("Stats").PerformanceStats.Ping:GetValue())/1000 end)
                        local rnd=Vector3.new(math.random(-15,15)/10,0,math.random(-15,15)/10)
                        local tp=closest.HumanoidRootPart.Position+rnd+(closest.HumanoidRootPart.Velocity*(ping*1.25))
                        local newVel=(tp-hrp.Position)/math.max(ping*2,0.01)
                        local oldVel=hrp.Velocity
                        hrp.Velocity=newVel
                        RunService.RenderStepped:Wait()
                        hrp.Velocity=oldVel
                    end
                end
            end
        end
    end
end)

--==================== 防眩晕 ====================
bind(RunService.RenderStepped:Connect(function()
    if S.antiStun then
        pcall(function()
            for _,e in ipairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    e.Enabled=false
                end
            end
            if Camera then
                for _,e in ipairs(Camera:GetChildren()) do
                    if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled=false end
                end
            end
            local pf=Workspace:FindFirstChild("Players")
            if pf then
                for _,folderName in ipairs({"Killers","Survivors"}) do
                    local folder=pf:FindFirstChild(folderName)
                    if folder then
                        for _,m in ipairs(folder:GetChildren()) do
                            local sm=m:FindFirstChild("SpeedMultipliers")
                            if sm then
                                local st=sm:FindFirstChild("Stunned")
                                if st then st.Value=1 end
                            end
                        end
                    end
                end
            end
        end)
    end
end))

--==================== 速度提升 ====================
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if S.speedBoost then
            local c=getChar()
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.MoveDirection.Magnitude>0 then
                hrp:TranslateBy(hum.MoveDirection*7*0.03)
            end
        end
    end
end)

--==================== 无减速 ====================
task.spawn(function()
    while task.wait() do
        if S.noSlowdown then
            local c=getChar()
            local sm=c and c:FindFirstChild("SpeedMultipliers")
            if sm then
                for _,v in ipairs(sm:GetChildren()) do
                    if v:IsA("NumberValue") and v.Value<1 then v.Value=1 end
                end
            end
        end
    end
end)

--==================== 无技能减速 ====================
task.spawn(function()
    while task.wait() do
        if S.noAbilitySlowdown then
            local c=getChar()
            local sm=c and c:FindFirstChild("SpeedMultipliers")
            if sm then
                for _,v in ipairs(sm:GetChildren()) do
                    if v:IsA("NumberValue") and v.Value<1 then v.Value=1 end
                end
            end
        end
    end
end)

--==================== 工具：传送 ====================
local function teleportTo(pos)
    local hrp=getHRP()
    if hrp then
        pcall(function()
            hrp.CFrame=typeof(pos)=="CFrame" and pos or CFrame.new(pos)
        end)
    end
end

local function smartTP(keywords,fallback)
    pcall(function()
        local hrp=getHRP()
        if not hrp then return end
        local list=type(keywords)=="table" and keywords or {keywords}
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                for _,kw in ipairs(list) do
                    if n:find(kw:lower(),1,true) then
                        hrp.CFrame=obj.CFrame+Vector3.new(0,5,0)
                        return
                    end
                end
            end
        end
        if fallback then
            hrp.CFrame=typeof(fallback)=="CFrame" and fallback or CFrame.new(fallback)
        end
    end)
end

--==================== 工具：隐身 ====================
local function setGhost(on)
    local c=getChar()
    if not c then return end
    pcall(function()
        c:SetAttribute("Invisible",on or nil)
        for _,d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") and d.Name~="HumanoidRootPart" then
                d.LocalTransparencyModifier=on and 0.55 or 0
                d.Material=on and Enum.Material.ForceField or Enum.Material.SmoothPlastic
            elseif d:IsA("Decal") and d.Name=="face" then
                d.Transparency=on and 0.55 or 0
            end
        end
    end)
end

--==================== 工具：服务器浏览器 ====================
local function openServerBrowser()
    local gui=Instance.new("ScreenGui")
    gui.Name="HeServerBrowser"
    gui.Parent=guiParent
    local main=Instance.new("Frame",gui)
    main.Size=UDim2.fromOffset(420,320)
    main.Position=UDim2.new(0.5,-210,0.5,-160)
    main.BackgroundColor3=Color3.fromRGB(25,25,32)
    main.BorderSizePixel=0
    main.Active=true
    main.Draggable=true
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
    local title=Instance.new("TextLabel",main)
    title.Size=UDim2.new(1,0,0,30)
    title.BackgroundColor3=Color3.fromRGB(35,35,45)
    title.Text="  服务器浏览器"
    title.TextColor3=Color3.fromRGB(255,255,255)
    title.Font=Enum.Font.GothamBold
    title.TextSize=14
    title.TextXAlignment=Enum.TextXAlignment.Left
    local close=Instance.new("TextButton",title)
    close.Size=UDim2.fromOffset(24,24)
    close.Position=UDim2.new(1,-28,0,3)
    close.Text="✕"
    close.BackgroundTransparency=1
    close.TextColor3=Color3.fromRGB(255,100,100)
    close.Font=Enum.Font.GothamBold
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    local list=Instance.new("ScrollingFrame",main)
    list.Size=UDim2.new(1,-20,1,-80)
    list.Position=UDim2.new(0,10,0,40)
    list.BackgroundColor3=Color3.fromRGB(35,35,45)
    list.BorderSizePixel=0
    list.ScrollBarThickness=4
    list.CanvasSize=UDim2.new(0,0,0,0)
    Instance.new("UICorner",list).CornerRadius=UDim.new(0,8)
    local layout=Instance.new("UIListLayout",list)
    layout.Padding=UDim.new(0,4)
    local refresh=Instance.new("TextButton",main)
    refresh.Size=UDim2.fromOffset(100,30)
    refresh.Position=UDim2.new(0,10,1,-38)
    refresh.BackgroundColor3=Color3.fromRGB(60,120,220)
    refresh.Text="刷新"
    refresh.TextColor3=Color3.fromRGB(255,255,255)
    refresh.Font=Enum.Font.GothamBold
    refresh.TextSize=13
    Instance.new("UICorner",refresh).CornerRadius=UDim.new(0,6)
    local status=Instance.new("TextLabel",main)
    status.Size=UDim2.new(1,-130,0,30)
    status.Position=UDim2.new(0,120,1,-38)
    status.BackgroundTransparency=1
    status.Text="准备就绪"
    status.TextColor3=Color3.fromRGB(200,200,200)
    status.Font=Enum.Font.Gotham
    status.TextSize=12
    status.TextXAlignment=Enum.TextXAlignment.Left
    local function fetch()
        status.Text="正在获取服务器..."
        for _,c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
        end
        local ok,res=pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if ok and res and res.data then
            for i,s in ipairs(res.data) do
                local btn=Instance.new("TextButton",list)
                btn.Size=UDim2.new(1,-8,0,44)
                btn.BackgroundColor3=Color3.fromRGB(50,50,60)
                btn.Text=""
                btn.AutoButtonColor=false
                Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
                local info=Instance.new("TextLabel",btn)
                info.Size=UDim2.new(1,-80,1,0)
                info.Position=UDim2.new(0,8,0,0)
                info.BackgroundTransparency=1
                info.Text=s.playing.."/"..s.maxPlayers.." · ID: "..tostring(s.id):sub(1,8)
                info.TextColor3=Color3.fromRGB(230,230,230)
                info.Font=Enum.Font.Gotham
                info.TextSize=12
                info.TextXAlignment=Enum.TextXAlignment.Left
                local join=Instance.new("TextButton",btn)
                join.Size=UDim2.fromOffset(60,26)
                join.Position=UDim2.new(1,-68,0.5,-13)
                join.BackgroundColor3=Color3.fromRGB(70,180,70)
                join.Text="加入"
                join.TextColor3=Color3.fromRGB(255,255,255)
                join.Font=Enum.Font.GothamBold
                join.TextSize=12
                Instance.new("UICorner",join).CornerRadius=UDim.new(0,6)
                join.MouseButton1Click:Connect(function()
                    status.Text="正在加入..."
                    pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,LP) end)
                end)
            end
            list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
            status.Text="找到 "..#res.data.." 个服务器"
        else
            status.Text="获取失败"
        end
    end
    refresh.MouseButton1Click:Connect(fetch)
    fetch()
end

--==================== 工具：保存点 ====================
local Waypoints={}
local wpFile="He_Waypoints.json"
local function loadWP()
    pcall(function()
        if isfile and isfile(wpFile) then
            local data=HttpService:JSONDecode(readfile(wpFile))
            for k,v in pairs(data) do
                if type(v)=="table" and #v==12 then Waypoints[k]=CFrame.new(unpack(v)) end
            end
        end
    end)
end
local function saveWP()
    pcall(function()
        local data={}
        for k,cf in pairs(Waypoints) do data[k]={cf:GetComponents()} end
        writefile(wpFile,HttpService:JSONEncode(data))
    end)
end
loadWP()

--==================== 工具 Tab ====================
tabs["工具"]=function()
    makeLabel(content,"▶ 常用传送")
    makeButton(content,"出生点",function() teleportTo(CFrame.new(-607,23,-280)) end)
    makeButton(content,"银行",function() smartTP({"Bank","Vault"},CFrame.new(-441,23,-286)) end)
    makeButton(content,"警察局",function() smartTP({"Police","Cop"},CFrame.new(-266,23,-99)) end)
    makeButton(content,"枪店",function() smartTP({"Gun","Weapon"},CFrame.new(-90,23,-79)) end)
    makeButton(content,"医院",function() smartTP({"Hospital","Medical"},CFrame.new(113,23,-478)) end)
    makeButton(content,"商店",function() smartTP({"Store","Market"},CFrame.new(-67,23,-592)) end)
    makeButton(content,"加油站",function() smartTP({"Gas","Fuel"},CFrame.new(585,23,-216)) end)
    makeButton(content,"公园",function() smartTP({"Park"},CFrame.new(-139,23,-1010)) end)
    makeButton(content,"黑帮区",function() smartTP({"Gang"},CFrame.new(-802,23,-313)) end)
    makeButton(content,"军事基地",function() smartTP({"Military","Army"},CFrame.new(769,23,-418)) end)
    makeButton(content,"下水道",function() smartTP({"Sewer"},CFrame.new(86,-26,-480)) end)
    makeButton(content,"向上 50",function()
        local hrp=getHRP(); if hrp then hrp.CFrame=hrp.CFrame+Vector3.new(0,50,0) end
    end)
    makeButton(content,"向下 50",function()
        local hrp=getHRP(); if hrp then hrp.CFrame=hrp.CFrame+Vector3.new(0,-50,0) end
    end)

    makeLabel(content,"▶ 传送到玩家")
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            makeButton(content,p.Name,function()
                local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then teleportTo(hrp.CFrame) end
            end)
        end
    end

    makeLabel(content,"▶ 保存点")
    makeButton(content,"保存当前位置为点 1",function()
        local hrp=getHRP()
        if hrp then Waypoints["wp1"]=hrp.CFrame; saveWP() end
    end)
    makeButton(content,"传送到点 1",function()
        if Waypoints["wp1"] then
            local hrp=getHRP()
            if hrp then hrp.CFrame=Waypoints["wp1"] end
        end
    end)
    makeButton(content,"删除点 1",function() Waypoints["wp1"]=nil; saveWP() end)

    makeLabel(content,"▶ 功能")
    makeButton(content,"自杀",function()
        local hum=getHum(); if hum then hum.Health=0 end
    end)
    makeToggle(content,"隐身",false,function(v) S.invis=v; setGhost(v) end)
    makeToggle(content,"显示侧边栏",false,function(v) S.showSidebar=v end)
    makeToggle(content,"显示聊天",false,function(v)
        S.chatHide=not v
        pcall(function()
            local cfg=game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration")
            if cfg then cfg.Enabled=v end
        end)
    end)
    makeButton(content,"翻译过的 Dex",function()
        pcall(function()
            loadstring(game:HttpGet("https://gitee.com/cmbhbh/cmbh/raw/master/Bex.lua"))()
        end)
    end)
    makeButton(content,"低画质脚本",function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/vexroxd/My-Script-/main/roblox%20fps%20unlocker%20script.lua"))()
        end)
    end)

    makeLabel(content,"▶ 服务器")
    makeButton(content,"打开服务器浏览器",openServerBrowser)
    makeButton(content,"重新加入当前服务器",function()
        pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP) end)
    end)
    makeButton(content,"加入低延迟服务器",function()
        local ok,data=pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if ok and data and data.data then
            local avail={}
            for _,s in ipairs(data.data) do
                if s.playing<s.maxPlayers and s.id~=game.JobId then table.insert(avail,s) end
            end
            if #avail>0 then
                local chosen=avail[math.random(1,#avail)]
                pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId,chosen.id,LP) end)
            end
        end
    end)
    makeButton(content,"加入新手服务器",function()
        local ok,data=pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if ok and data and data.data then
            table.sort(data.data,function(a,b) return a.playing<b.playing end)
            local cur=#Players:GetPlayers()
            for _,s in ipairs(data.data) do
                if s.playing<cur and s.id~=game.JobId and s.playing>0 then
                    pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,LP) end)
                    return
                end
            end
        end
    end)

    makeLabel(content,"▶ 场景设置")
    makeSlider(content,"亮度数值",0,3,0,function(v) S.fullBrightLv=v end)
    makeToggle(content,"无阴影",false,function(v) S.noShadow=v end)
    makeToggle(content,"除雾",false,function(v) S.noFog=v end)
    makeToggle(content,"场景总开关",false,function(v) S.sceneSwitch=v end)
end

--==================== 场景设置后台 ====================
bind(RunService.RenderStepped:Connect(function()
    if S.sceneSwitch then
        pcall(function()
            Lighting.FogStart=S.noFog and 0 or (Lighting:GetAttribute("FogStart") or 0)
            Lighting.FogEnd=S.noFog and math.huge or (Lighting:GetAttribute("FogEnd") or 100000)
            Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
            Lighting.Brightness=S.fullBrightLv or 0
            Lighting.GlobalShadows=not S.noShadow
            local atm=Lighting:FindFirstChildOfClass("Atmosphere")
            if atm and S.noFog then atm.Density=0 end
        end)
    end
end))

--==================== 幸存者：体力管理 ====================
local origStamina={}
task.spawn(function()
    local sprinting
    pcall(function()
        sprinting=require(RS:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting"))
        origStamina.MaxStamina=sprinting.MaxStamina
        origStamina.StaminaGain=sprinting.StaminaGain
        origStamina.StaminaLoss=sprinting.StaminaLoss
        origStamina.SprintSpeed=sprinting.SprintSpeed
    end)
    while task.wait(0.5) do
        if sprinting then
            pcall(function()
                if S.staminaInf then
                    sprinting.StaminaLoss=0
                    sprinting.StaminaGain=9999
                end
                if S.staminaMax~=100 then sprinting.MaxStamina=S.staminaMax end
                if S.staminaGain~=25 then sprinting.StaminaGain=S.staminaGain end
                if S.staminaLoss~=10 then sprinting.StaminaLoss=S.staminaLoss end
                if S.sprintSpeed~=28 then sprinting.SprintSpeed=S.sprintSpeed end
            end)
        end
    end
end)

--==================== 幸存者：冲刺控制 ====================
task.spawn(function()
    local sprinting
    pcall(function()
        sprinting=require(RS:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting"))
    end)
    while task.wait() do
        if sprinting then
            pcall(function()
                if S.autoUnsprint and sprinting.Stamina<3 then
                    sprinting.IsSprinting=false
                    if sprinting.__sprintedEvent then sprinting.__sprintedEvent:Fire(false) end
                end
                if S.autoSprint then
                    if not S.autoUnsprint or sprinting.Stamina==100 then
                        if not sprinting.IsSprinting then
                            sprinting.IsSprinting=true
                            if sprinting.__sprintedEvent then sprinting.__sprintedEvent:Fire(true) end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者：无冲刺过渡 ====================
do
    local hooked=false
    local TweenSvc=game:GetService("TweenService")
    local oldNc=nil
    task.spawn(function()
        while true do
            task.wait(0.1)
            if S.noSprintTween and not hooked then
                hooked=true
                pcall(function()
                    oldNc=hookmetamethod(game,"__namecall",function(self,...)
                        local m=getnamecallmethod()
                        if S.noSprintTween and not checkcaller() and self==TweenSvc and m=="Create" then
                            local args={...}
                            local ok,sp=pcall(function()
                                return require(RS.Systems.Character.Game.Sprinting)
                            end)
                            if ok and sp and args[1]==sp.__speedMultiplier then
                                args[2]=TweenInfo.new(0)
                            end
                            return oldNc(self,unpack(args))
                        end
                        return oldNc(self,...)
                    end)
                end)
            end
        end
    end)
end

--==================== 幸存者：自动背刺 ====================
task.spawn(function()
    local lastTrigger=0
    while true do
        task.wait(0.05)
        if not S.autoBackstab then continue end
        local c=getChar()
        local hrp=c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local pf=Workspace:FindFirstChild("Players")
        local kf=pf and pf:FindFirstChild("Killers")
        if not kf then continue end
        for _,killer in ipairs(kf:GetChildren()) do
            local khrp=killer:FindFirstChild("HumanoidRootPart")
            local khum=killer:FindFirstChildOfClass("Humanoid")
            if khrp and khum and khum.Health>0 then
                local dist=(khrp.Position-hrp.Position).Magnitude
                if dist<=S.antiBackstabRange and os.clock()-lastTrigger>=5 then
                    local toP=(hrp.Position-khrp.Position).Unit
                    local back=-khrp.CFrame.LookVector
                    if toP:Dot(back)>=math.cos(math.rad(70)) then
                        lastTrigger=os.clock()
                        pcall(function()
                            hrp.CFrame=hrp.CFrame:Lerp(CFrame.new(
                                khrp.Position-khrp.CFrame.LookVector*3.5,
                                khrp.Position+khrp.CFrame.LookVector
                            ),0.55)
                        end)
                        task.wait(0.45)
                        local dagger=LP.PlayerGui:FindFirstChild("MainUI")
                        dagger=dagger and dagger:FindFirstChild("AbilityContainer")
                        dagger=dagger and dagger:FindFirstChild("Dagger")
                        if dagger then pcall(function() dagger:Activate() end) end
                    end
                end
            end
        end
    end
end)

--==================== 幸存者：访客1337 自动格挡 ====================
task.spawn(function()
    while true do
        task.wait(0.05)
        if not S.visitorAutoBlock then continue end
        local c=getChar()
        if not c then continue end
        local pf=Workspace:FindFirstChild("Players")
        local kf=pf and pf:FindFirstChild("Killers")
        if not kf then continue end
        for _,killer in ipairs(kf:GetChildren()) do
            local query=killer:FindFirstChild("QueryHitbox")
            local khrp=killer:FindFirstChild("HumanoidRootPart")
            local cHrp=c:FindFirstChild("HumanoidRootPart")
            if query and khrp and cHrp then
                local d=(khrp.Position-cHrp.Position).Magnitude
                if d<=12 then
                    local mainUI=LP.PlayerGui:FindFirstChild("MainUI")
                    local abil=mainUI and mainUI:FindFirstChild("AbilityContainer")
                    local block=abil and (abil:FindFirstChild("Block") or abil:FindFirstChild("Guard"))
                    if block then pcall(function() block:Activate() end) end
                end
            end
        end
    end
end)

--==================== 幸存者：维罗妮卡 ====================
task.spawn(function()
    while true do
        task.wait(0.1)
        if S.veronicaAutoTrick then
            local c=getChar()
            if c and c.Name=="Veeronica" then
                pcall(function()
                    VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game)
                    task.wait()
                    VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game)
                end)
            end
        end
    end
end)

--==================== 幸存者：移除 1x4 弹窗 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.removePopup then
            pcall(function()
                local pg=LP:FindFirstChild("PlayerGui")
                local temp=pg and pg:FindFirstChild("TemporaryUI")
                if temp then
                    for _,c in ipairs(temp:GetChildren()) do
                        if c.Name=="1x1x1x1Popup" then c:Destroy() end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者：吸血鬼挣脱 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.vampireEscape then
            pcall(function()
                local pf=Workspace:FindFirstChild("Players")
                local kf=pf and pf:FindFirstChild("Killers")
                if kf then
                    for _,killer in ipairs(kf:GetChildren()) do
                        if killer.Name:lower()=="nosferatu" then
                            local kp=Players:GetPlayerFromCharacter(killer)
                            if kp then
                                local remote=RS:FindFirstChild("Modules")
                                remote=remote and remote:FindFirstChild("Network")
                                remote=remote and remote:FindFirstChild("Network")
                                remote=remote and remote:FindFirstChild("RemoteEvent")
                                if remote then
                                    remote:FireServer(kp.Name.."NosHookQTE",{true})
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者：禁用脚气/脚印 ====================
local function getInGame()
    local m=Workspace:FindFirstChild("Map")
    return m and m:FindFirstChild("Ingame")
end
task.spawn(function()
    while task.wait(0.5) do
        local ig=getInGame()
        if ig then
            if S.disableJohnTrail then
                pcall(function()
                    for _,c in ipairs(ig:GetChildren()) do
                        if c:IsA("Folder") and c.Name:find("JohnDoeTrail") then
                            for _,p in ipairs(c:GetChildren()) do
                                if p:IsA("BasePart") then p.CanTouch=false end
                            end
                        end
                    end
                end)
            end
            if S.disableFootprints then
                pcall(function()
                    for _,c in ipairs(ig:GetChildren()) do
                        if c:IsA("Folder") and c.Name:find("Shadows") then
                            for _,p in ipairs(c:GetChildren()) do
                                if p:IsA("BasePart") then p.CanTouch=false end
                            end
                        end
                    end
                end)
            end
        end
    end
end)

--==================== 幸存者：医疗包传送 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.medkitTP then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local m=Workspace:FindFirstChild("Map")
                    m=m and m:FindFirstChild("Ingame")
                    local medkit=m and m:FindFirstChild("Medkit",true)
                    if medkit then
                        local root=medkit:FindFirstChild("ItemRoot",true)
                        if root then
                            root.CFrame=hrp.CFrame+hrp.CFrame.LookVector*3
                            local prompt=root:FindFirstChild("ProximityPrompt",true)
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者：可乐传送 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.colaTP then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local m=Workspace:FindFirstChild("Map")
                    m=m and m:FindFirstChild("Ingame")
                    local cola=m and m:FindFirstChild("BloxyCola",true)
                    if cola then
                        local root=cola:FindFirstChild("ItemRoot",true)
                        if root then
                            root.CFrame=hrp.CFrame+hrp.CFrame.LookVector*3
                            local prompt=root:FindFirstChild("ProximityPrompt",true)
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者：发电机自动修复 ====================
task.spawn(function()
    while task.wait(0.3) do
        if S.autoRepair then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local gen=nil
                    local minD=math.huge
                    local m=Workspace:FindFirstChild("Map")
                    m=m and m:FindFirstChild("Ingame")
                    m=m and m:FindFirstChild("Map")
                    if m then
                        for _,g in ipairs(m:GetChildren()) do
                            if g.Name=="Generator" then
                                local p=g:FindFirstChildWhichIsA("BasePart")
                                if p then
                                    local d=(p.Position-hrp.Position).Magnitude
                                    if d<minD then minD=d; gen=g end
                                end
                            end
                        end
                    end
                    if gen then
                        local remotes=gen:FindFirstChild("Remotes")
                        local re=remotes and remotes:FindFirstChild("RE")
                        if re and re:IsA("RemoteEvent") then re:FireServer() end
                    end
                end
            end)
        end
    end
end)

--==================== 幸存者 Tab ====================
tabs["幸存者"]=function()
    makeLabel(content,"▶ 体力管理")
    makeToggle(content,"无限体力",false,function(v) S.staminaInf=v end)
    makeSlider(content,"体力大小",0,99999,100,function(v) S.staminaMax=v end)
    makeSlider(content,"体力恢复",0,250,25,function(v) S.staminaGain=v end)
    makeSlider(content,"体力消耗",0,100,10,function(v) S.staminaLoss=v end)
    makeSlider(content,"奔跑速度",0,200,28,function(v) S.sprintSpeed=v end)

    makeLabel(content,"▶ 冲刺控制")
    makeToggle(content,"自动停止冲刺",false,function(v) S.autoUnsprint=v end)
    makeToggle(content,"始终启用冲刺",false,function(v) S.autoSprint=v end)
    makeToggle(content,"无冲刺过渡",false,function(v) S.noSprintTween=v end)
    makeToggle(content,"无减速",false,function(v) S.noSlowdown=v end)
    makeToggle(content,"无技能减速",false,function(v) S.noAbilitySlowdown=v end)

    makeLabel(content,"▶ 自动背刺")
    makeToggle(content,"启用自动背刺",false,function(v) S.autoBackstab=v end)
    makeSlider(content,"检测范围",1,30,8,function(v) S.antiBackstabRange=v end)

    makeLabel(content,"▶ 访客1337")
    makeToggle(content,"自动格挡",false,function(v) S.visitorAutoBlock=v end)

    makeLabel(content,"▶ 维罗妮卡")
    makeToggle(content,"自动特技",false,function(v) S.veronicaAutoTrick=v end)

    makeLabel(content,"▶ 其他功能")
    makeToggle(content,"自动移除 1x1 弹窗",false,function(v) S.removePopup=v end)
    makeToggle(content,"吸血鬼自动挣脱",false,function(v) S.vampireEscape=v end)
    makeToggle(content,"禁用约翰脚气伤害",false,function(v) S.disableJohnTrail=v end)
    makeToggle(content,"禁用约翰脚印伤害",false,function(v) S.disableFootprints=v end)

    makeLabel(content,"▶ 物品传送互动")
    makeToggle(content,"医疗包传送并互动",false,function(v) S.medkitTP=v end)
    makeToggle(content,"可乐传送并互动",false,function(v) S.colaTP=v end)

    makeLabel(content,"▶ 发电机")
    makeToggle(content,"（旧）自动修复发电机",false,function(v) S.autoRepair=v end)
end--==================== 杀手：杀死全部人 ====================
local killAllState={
    active=false,
    teleport=false,
    currentTarget=nil,
    conn=nil,
}

local function getNearestSurvivor()
    local c=getChar()
    local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pf=Workspace:FindFirstChild("Players")
    local sf=pf and pf:FindFirstChild("Survivors")
    if not sf then return nil end
    local best,bestDist=nil,math.huge
    for _,m in ipairs(sf:GetChildren()) do
        local h=m:FindFirstChildOfClass("Humanoid")
        local r=m:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health>0 then
            local d=(r.Position-hrp.Position).Magnitude
            if d<bestDist then bestDist=d; best=m end
        end
    end
    return best
end

local function killAllLoop()
    if killAllState.conn then killAllState.conn:Disconnect() end
    killAllState.conn=RunService.Heartbeat:Connect(function()
        if not killAllState.active then return end
        if killAllState.currentTarget and (not killAllState.currentTarget.Parent
           or not killAllState.currentTarget:FindFirstChildOfClass("Humanoid")
           or killAllState.currentTarget:FindFirstChildOfClass("Humanoid").Health<=0) then
            killAllState.currentTarget=nil
        end
        if not killAllState.currentTarget then
            killAllState.currentTarget=getNearestSurvivor()
            if not killAllState.currentTarget then return end
        end
        local c=getChar()
        local hrp=c and c:FindFirstChild("HumanoidRootPart")
        local hum=c and c:FindFirstChildOfClass("Humanoid")
        local thrp=killAllState.currentTarget:FindFirstChild("HumanoidRootPart")
        if not hrp or not hum or not thrp then return end
        if killAllState.teleport then
            hrp.CFrame=CFrame.new(thrp.Position-thrp.CFrame.LookVector*2.7+Vector3.new(0,1.5,0))
            hrp.CFrame=CFrame.lookAt(hrp.Position,thrp.Position)
        else
            hum:MoveTo(thrp.Position)
        end
    end)
end

--==================== 杀手：吸力 ====================
local suctionConn=nil
local function suctionLoop()
    if suctionConn then suctionConn:Disconnect() end
    suctionConn=RunService.RenderStepped:Connect(function()
        if not S.suction then return end
        local c=getChar()
        local hrp=c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pf=Workspace:FindFirstChild("Players")
        local sf=pf and pf:FindFirstChild("Survivors")
        if not sf then return end
        local best,bestDist=nil,S.suctionDist
        for _,m in ipairs(sf:GetChildren()) do
            local h=m:FindFirstChildOfClass("Humanoid")
            local r=m:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health>0 then
                local d=(r.Position-hrp.Position).Magnitude
                if d<bestDist then bestDist=d; best=r end
            end
        end
        if best then
            local dir=(best.Position-hrp.Position)
            if dir.Magnitude>0.1 then
                dir=dir.Unit
                local cur=hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity=cur:Lerp(cur+dir*S.suctionStrength,0.3)
            end
        end
    end)
end

--==================== 杀手：斩首者格挡 ====================
local function getSlasherCd()
    local pg=LP:FindFirstChild("PlayerGui")
    local main=pg and pg:FindFirstChild("MainUI")
    local abil=main and main:FindFirstChild("AbilityContainer")
    local rp=abil and abil:FindFirstChild("RagingPace")
    local cd=rp and rp:FindFirstChild("CooldownTime")
    if cd and cd.Visible and cd.Text~="" then return tonumber(cd.Text) or 0 end
    return 0
end

task.spawn(function()
    local lastParry=0
    while true do
        task.wait(0.05)
        if S.slasherEnraged then
            pcall(function()
                local pf=Workspace:FindFirstChild("Players")
                local kf=pf and pf:FindFirstChild("Killers")
                if kf then
                    for _,m in ipairs(kf:GetChildren()) do
                        if not m.Name:match("^Fake") and not m.Name:match("Fake$") then
                            local sm=m:FindFirstChild("SpeedMultipliers")
                            local en=sm and sm:FindFirstChild("ENRAGED")
                            if en then en.Value=S.slasherEnragedMult end
                        end
                    end
                end
            end)
        end
        if S.slasherParry then
            local c=getChar()
            local myName=c and c.Name or ""
            if c and myName:find("Slasher") and c:GetAttribute("Username")==LP.Name then
                local cd=getSlasherCd()
                if cd<=0 and os.clock()-lastParry>=0.5 then
                    local pf=Workspace:FindFirstChild("Players")
                    local sf=pf and pf:FindFirstChild("Survivors")
                    if sf then
                        for _,s in ipairs(sf:GetChildren()) do
                            local shrp=s:FindFirstChild("HumanoidRootPart")
                            local hrp=c:FindFirstChild("HumanoidRootPart")
                            if shrp and hrp then
                                local d=(shrp.Position-hrp.Position).Magnitude
                                if d<=S.slasherParryRange then
                                    lastParry=os.clock()
                                    local remote=RS:FindFirstChild("Modules")
                                    remote=remote and remote:FindFirstChild("Network")
                                    remote=remote and remote:FindFirstChild("Network")
                                    remote=remote and remote:FindFirstChild("RemoteEvent")
                                    if remote then
                                        local args={"UseActorAbility",{buffer.fromstring("\003\n\000\000\000RagingPace")}}
                                        for i=1,3 do pcall(function() remote:FireServer(unpack(args)) end) end
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--==================== 杀手：约翰多 404 格挡 ====================
local function get404Cd()
    local pg=LP:FindFirstChild("PlayerGui")
    local main=pg and pg:FindFirstChild("MainUI")
    local abil=main and main:FindFirstChild("AbilityContainer")
    local ef=abil and abil:FindFirstChild("404Error")
    local cd=ef and ef:FindFirstChild("CooldownTime")
    if cd and cd.Visible and cd.Text~="" then return tonumber(cd.Text) or 0 end
    return 0
end

task.spawn(function()
    local lastParry=0
    while true do
        task.wait(0.1)
        if S.jd404Parry then
            local c=getChar()
            local myName=c and c.Name or ""
            if c and myName:find("JohnDoe") and c:GetAttribute("Username")==LP.Name then
                local cd=get404Cd()
                if cd<=0 and os.clock()-lastParry>=2 then
                    local pf=Workspace:FindFirstChild("Players")
                    local sf=pf and pf:FindFirstChild("Survivors")
                    if sf then
                        for _,s in ipairs(sf:GetChildren()) do
                            local shrp=s:FindFirstChild("HumanoidRootPart")
                            local hrp=c:FindFirstChild("HumanoidRootPart")
                            if shrp and hrp then
                                local d=(shrp.Position-hrp.Position).Magnitude
                                if d<=S.jd404Range then
                                    lastParry=os.clock()
                                    local remote=RS:FindFirstChild("Modules")
                                    remote=remote and remote:FindFirstChild("Network")
                                    remote=remote and remote:FindFirstChild("Network")
                                    remote=remote and remote:FindFirstChild("RemoteEvent")
                                    if remote then
                                        local args={"UseActorAbility",{buffer.fromstring("\003\b\000\000\000404Error")}}
                                        pcall(function() remote:FireServer(unpack(args)) end)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--==================== 杀手：防背刺 ====================
task.spawn(function()
    while true do
        task.wait(0.2)
        if S.antiBackstab then
            pcall(function()
                local pf=Workspace:FindFirstChild("Players")
                if pf then
                    for _,folder in ipairs(pf:GetChildren()) do
                        local tt=folder:FindFirstChild("TwoTime")
                        if tt then
                            local c=getChar()
                            local hrp=c and c:FindFirstChild("HumanoidRootPart")
                            local trhp=tt:FindFirstChild("HumanoidRootPart")
                            if hrp and trhp and (hrp.Position-trhp.Position).Magnitude<=S.antiBackstabRange then
                                local deadline=tick()+S.antiBackstabDur
                                while tick()<deadline and S.antiBackstab do
                                    hrp.CFrame=CFrame.lookAt(hrp.Position,Vector3.new(trhp.Position.X,hrp.Position.Y,trhp.Position.Z))
                                    RunService.RenderStepped:Wait()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 杀手：Ragebot 后台 ====================
task.spawn(function()
    while true do
        task.wait(S.rageInterval)
        if S.ragebot then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local remote=RS:FindFirstChild("Modules")
                remote=remote and remote:FindFirstChild("Network")
                remote=remote and remote:FindFirstChild("Network")
                remote=remote and remote:FindFirstChild("RemoteEvent")
                if not remote then return end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then
                        if S.ragePoliceLock and (not p.Team or p.Team.Name~="Police") then continue end
                        if S.rageCivilianLock and (not p.Team or p.Team.Name~="Civilian") then continue end
                        local pc=p.Character
                        if pc then
                            local hum=pc:FindFirstChildOfClass("Humanoid")
                            local ph=pc:FindFirstChild(S.ragePart) or pc:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health>0 and ph then
                                local d=(ph.Position-hrp.Position).Magnitude
                                if d<=S.rageRange then
                                    local canHit=true
                                    if S.rageWallCheck then
                                        local rp=RaycastParams.new()
                                        rp.FilterDescendantsInstances={c,pc}
                                        rp.FilterType=Enum.RaycastFilterType.Exclude
                                        if Workspace:Raycast(hrp.Position,ph.Position-hrp.Position,rp) then canHit=false end
                                    end
                                    if canHit then
                                        remote:FireServer("damage",{
                                            bodyParts={{S.ragePart,1}},
                                            shotCode={hrp.Position,(ph.Position-hrp.Position).Unit},
                                            pos=ph.Position,
                                            target=p,
                                            damageFactor=1.5,
                                            bulletProofTool=false,
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 杀手：光环后台 ====================
task.spawn(function()
    local last=0
    while true do
        task.wait(0.05)
        if S.aura and tick()-last>=0.05 then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local remote=RS:FindFirstChild("Modules")
                remote=remote and remote:FindFirstChild("Network")
                remote=remote and remote:FindFirstChild("Network")
                remote=remote and remote:FindFirstChild("RemoteEvent")
                if not remote then return end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then
                        if S.auraOnlyPolice and (not p.Team or p.Team.Name~="Police") then continue end
                        if S.auraOnlyCivilian and (not p.Team or p.Team.Name~="Civilian") then continue end
                        local pc=p.Character
                        if pc then
                            local hum=pc:FindFirstChildOfClass("Humanoid")
                            local ph=pc:FindFirstChild("Head") or pc:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health>0 and ph then
                                if (ph.Position-hrp.Position).Magnitude<=S.auraRange then
                                    remote:FireServer("damage",{
                                        bodyParts={{"Head",1}},
                                        shotCode={hrp.Position,(ph.Position-hrp.Position).Unit},
                                        pos=ph.Position,
                                        target=p,
                                        damageFactor=S.auraDamage,
                                        bulletProofTool=false,
                                    })
                                    last=tick()
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 杀手：自瞄 ====================
task.spawn(function()
    local target=nil
    local unlockAt=0
    while true do
        task.wait(0.03)
        if S.aimbot then
            local c=getChar()
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and Camera then
                if target and (not target.Parent or not target.Parent:FindFirstChildOfClass("Humanoid")
                   or target.Parent:FindFirstChildOfClass("Humanoid").Health<=0) then
                    target=nil
                end
                if not target or tick()>unlockAt then
                    local closest,bestDist=nil,S.aimFov
                    local cc=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p~=LP then
                            if S.aimTeamCheck and isTeam(p) then continue end
                            if S.aimOnlyPolice and (not p.Team or p.Team.Name~="Police") then continue end
                            if S.aimOnlyCivilian and (not p.Team or p.Team.Name~="Civilian") then continue end
                            local pc=p.Character
                            local ph=pc and pc:FindFirstChild("Head")
                            local h=pc and pc:FindFirstChildOfClass("Humanoid")
                            if ph and h and h.Health>0 then
                                local sp,on=Camera:WorldToViewportPoint(ph.Position)
                                if on then
                                    local d=(Vector2.new(sp.X,sp.Y)-cc).Magnitude
                                    if d<bestDist then bestDist=d; closest=ph end
                                end
                            end
                        end
                    end
                    target=closest
                    if target then unlockAt=tick()+0.4 end
                end
                if target then
                    hum.AutoRotate=false
                    local flat=Vector3.new(target.Position.X-hrp.Position.X,0,target.Position.Z-hrp.Position.Z).Unit
                    if flat.Magnitude>0 then
                        hrp.CFrame=hrp.CFrame:Lerp(CFrame.new(hrp.Position,hrp.Position+flat),S.aimSmooth*0.5)
                    end
                else
                    hum.AutoRotate=true
                end
            end
        end
    end
end)

--==================== 刷钱：自动捡钱 ====================
task.spawn(function()
    while true do
        task.wait(0.3)
        if S.autoFarm then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("BasePart") and (d.Name=="Cash" or d.Name=="MoneyDrop") then
                            hrp.CFrame=CFrame.new(d.Position)
                            task.wait(0.05)
                            firetouchinterest(hrp,d,0)
                            firetouchinterest(hrp,d,1)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 刷钱：自动抢银行 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.autoRob then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,door in ipairs(Workspace:GetDescendants()) do
                        if door:IsA("BasePart") and (door.Name=="BankDoor" or door.Name:find("Vault")) then
                            hrp.CFrame=CFrame.new(door.Position)
                            task.wait(0.3)
                            local cd=door:FindFirstChild("ClickDetector")
                            if cd then fireclickdetector(cd) end
                            local pp=door:FindFirstChild("ProximityPrompt")
                            if pp then fireproximityprompt(pp) end
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 刷钱：自动抢 ATM ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.autoATM then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,atm in ipairs(Workspace:GetDescendants()) do
                        if atm:IsA("BasePart") and atm.Name:find("ATM") then
                            hrp.CFrame=CFrame.new(atm.Position)
                            task.wait(0.2)
                            local cd=atm:FindFirstChild("ClickDetector")
                            if cd then fireclickdetector(cd) end
                            local pp=atm:FindFirstChild("ProximityPrompt")
                            if pp then fireproximityprompt(pp) end
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 刷钱：自动接任务 ====================
local function getTeamJobs()
    if not getgc then return nil end
    for _,v in pairs(getgc(true)) do
        if type(v)=="table" and rawget(v,"teamJobs") then return v.teamJobs end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(S.missionInterval)
        if S.autoMission then
            pcall(function()
                local jobs=getTeamJobs()
                if jobs then
                    local joined=false
                    for _,j in pairs(jobs) do if j.joined then joined=true; break end end
                    if not joined then
                        local pick=nil
                        if S.priorityMission then
                            local best=-math.huge
                            for k,v in pairs(jobs) do
                                if not v.joined then
                                    local score=(v.profitability or 1)*1000000+(v.reward or 0)
                                    if score>best then best=score; pick=k end
                                end
                            end
                        else
                            for k,v in pairs(jobs) do
                                if not v.joined then pick=k; break end
                            end
                        end
                        if pick then
                            local remote=RS:FindFirstChild("Remote")
                            local func=remote and remote:FindFirstChild("PlayerFunc")
                            if func then func:InvokeServer("talkToMission",tostring(pick).."join") end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 刷钱：自动黑客小游戏 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.autoHack then
            pcall(function()
                local rules=RS:FindFirstChild("Modules")
                rules=rules and rules:FindFirstChild("GameRules")
                if rules then
                    rules.disableHacking=true
                    rules.disableMinigames=true
                end
            end)
        end
    end
end)

--==================== 刷钱：出租车/公交/农民 ====================
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.taxi then
            pcall(function()
                local g=Workspace:FindFirstChild("Gameplay")
                g=g and g:FindFirstChild("Entities")
                g=g and g:FindFirstChild("ClientContent")
                if g and g:IsA("Model") then
                    local pp=g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
                    local hrp=getHRP()
                    if pp and hrp then
                        hrp.CFrame=CFrame.new(pp.Position)
                    end
                end
            end)
        end
        if S.bus then
            pcall(function()
                local g=Workspace:FindFirstChild("Gameplay")
                g=g and g:FindFirstChild("Entities")
                g=g and g:FindFirstChild("ClientContent")
                g=g and g:GetChildren()[1]
                local area=g and g:FindFirstChild("Area")
                local hrp=getHRP()
                if area and hrp then
                    hrp.CFrame=area.CFrame*CFrame.new(17.5,3,6.5)*CFrame.Angles(0,math.rad(270),0)
                end
            end)
        end
        if S.farmer then
            pcall(function()
                local c=getChar()
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.ActionText=="Pick Up" then
                            local parent=d.Parent
                            local pos=parent:IsA("BasePart") and parent.Position or (parent.PrimaryPart and parent.PrimaryPart.Position)
                            if pos and (pos-hrp.Position).Magnitude<8 then
                                fireproximityprompt(d)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--==================== 权限：解锁全部角色和皮肤 ====================
local function unlockAllRoles()
    task.spawn(function()
        pcall(function()
            local purchased=LP:WaitForChild("PlayerData"):WaitForChild("Purchased")
            local kf=purchased:FindFirstChild("Killers") or Instance.new("Folder",purchased)
            kf.Name="Killers"
            local sf=purchased:FindFirstChild("Survivors") or Instance.new("Folder",purchased)
            sf.Name="Survivors"
            local skf=purchased:FindFirstChild("Skins") or Instance.new("Folder",purchased)
            skf.Name="Skins"
            local assets=RS:WaitForChild("Assets")
            local killers=assets:WaitForChild("Killers")
            for _,k in ipairs(killers:GetChildren()) do
                if not kf:FindFirstChild(k.Name) then Instance.new("StringValue",kf).Name=k.Name end
            end
            local survivors=assets:WaitForChild("Survivors")
            for _,s in ipairs(survivors:GetChildren()) do
                if not sf:FindFirstChild(s.Name) then Instance.new("StringValue",sf).Name=s.Name end
            end
            local skins=assets:WaitForChild("Skins")
            for _,sk in ipairs(skins:GetDescendants()) do
                if (sk:IsA("Folder") or sk:IsA("Model")) and not skf:FindFirstChild(sk.Name) then
                    Instance.new("StringValue",skf).Name=sk.Name
                end
            end
        end)
    end)
end

local function unlockAllEmotes()
    task.spawn(function()
        pcall(function()
            local purchased=LP:WaitForChild("PlayerData"):WaitForChild("Purchased")
            local ef=purchased:FindFirstChild("Emotes") or Instance.new("Folder",purchased)
            ef.Name="Emotes"
            local assets=RS:WaitForChild("Assets"):WaitForChild("Emotes")
            for _,m in ipairs(assets:GetDescendants()) do
                if m:IsA("ModuleScript") and not ef:FindFirstChild(m.Name) then
                    Instance.new("StringValue",ef).Name=m.Name
                end
            end
        end)
    end)
end

local function unlockVIP()
    pcall(function()
        LP:SetAttribute("VIP",true)
        local pd=LP:WaitForChild("PlayerData")
        local v=pd:FindFirstChild("VIP")
        if not v then
            v=Instance.new("BoolValue"); v.Name="VIP"; v.Parent=pd
        end
        v.Value=true
    end)
end

--==================== 杀手 Tab ====================
tabs["杀手"]=function()
    makeLabel(content,"▶ 杀死全部人")
    makeToggle(content,"击杀模式",false,function(v)
        killAllState.active=v
        if v then killAllLoop()
        elseif killAllState.conn then killAllState.conn:Disconnect(); killAllState.conn=nil end
    end)
    makeToggle(content,"传送模式",false,function(v)
        killAllState.teleport=v
    end)
    makeButton(content,"切换目标",function()
        killAllState.currentTarget=getNearestSurvivor()
    end)

    makeLabel(content,"▶ 吸力")
    makeToggle(content,"冲向幸存者",false,function(v)
        S.suction=v
        if v then suctionLoop() elseif suctionConn then suctionConn:Disconnect(); suctionConn=nil end
    end)
    makeSlider(content,"吸力强度",5,100,50,function(v) S.suctionStrength=v end)
    makeSlider(content,"最大搜索距离",20,200,100,function(v) S.suctionDist=v end)

    makeLabel(content,"▶ 斩首者格挡")
    makeToggle(content,"狂暴速度",false,function(v) S.slasherEnraged=v end)
    makeSlider(content,"狂暴速度倍率",2.111,3.4,2.111,function(v) S.slasherEnragedMult=v end)
    makeToggle(content,"自动狂暴速度格挡",false,function(v) S.slasherParry=v end)
    makeSlider(content,"狂暴速度格挡范围",5,40,15,function(v) S.slasherParryRange=v end)

    makeLabel(content,"▶ 约翰多格挡")
    makeToggle(content,"自动404错误格挡",false,function(v) S.jd404Parry=v end)
    makeSlider(content,"404错误格挡范围",5,40,15,function(v) S.jd404Range=v end)

    makeLabel(content,"▶ 有蚊子！")
    makeToggle(content,"启用防背刺",false,function(v) S.antiBackstab=v end)
    makeSlider(content,"检测范围",10,120,40,function(v) S.antiBackstabRange=v end)
    makeSlider(content,"注视时间",0.3,5,1.5,function(v) S.antiBackstabDur=v end)

    makeLabel(content,"▶ 自瞄")
    makeToggle(content,"使用自瞄",false,function(v) S.aimbot=v end)
    makeToggle(content,"队伍检测",false,function(v) S.aimTeamCheck=v end)
    makeToggle(content,"只自瞄警察",false,function(v) S.aimOnlyPolice=v end)
    makeToggle(content,"只自瞄平民",false,function(v) S.aimOnlyCivilian=v end)
    makeSlider(content,"最大距离",5,500,50,function(v) S.aimFov=v end)
    makeSlider(content,"平滑度",0.05,1,0.35,function(v) S.aimSmooth=v end)
end

--==================== 刷钱 Tab ====================
tabs["刷钱"]=function()
    makeLabel(content,"▶ 自动刷钱")
    makeToggle(content,"自动捡钱",false,function(v) S.autoFarm=v end)
    makeToggle(content,"自动抢银行",false,function(v) S.autoRob=v end)
    makeToggle(content,"自动抢 ATM",false,function(v) S.autoATM=v end)

    makeLabel(content,"▶ 任务系统")
    makeToggle(content,"自动接取任务",false,function(v) S.autoMission=v end)
    makeToggle(content,"优先高收益任务",false,function(v) S.priorityMission=v end)
    makeSlider(content,"接取间隔",1,10,2,function(v) S.missionInterval=v end)

    makeLabel(content,"▶ 载具刷钱")
    makeToggle(content,"出租车刷钱",false,function(v) S.taxi=v end)
    makeToggle(content,"公交车刷钱",false,function(v) S.bus=v end)
    makeToggle(content,"农民刷钱",false,function(v) S.farmer=v end)
    makeToggle(content,"自动黑客小游戏",false,function(v) S.autoHack=v end)
end

--==================== 权限 Tab ====================
tabs["权限"]=function()
    makeLabel(content,"▶ 解锁")
    makeButton(content,"解锁全部角色和皮肤",unlockAllRoles)
    makeButton(content,"解锁所有动作",unlockAllEmotes)
    makeButton(content,"解锁 VIP 权限",unlockVIP)

    makeLabel(content,"▶ 修改系统 - 数值")
    local statFields={
        Money="钱",
        NetWorth="净资产",
        KillerChance="杀手几率",
        TimePlayed="游玩时间",
        KillerWins="杀手胜利",
        Kills="击杀数",
        SurvivorWins="幸存者胜利",
        ObjectivesCompleted="任务完成数",
    }
    for k,label in pairs(statFields) do
        makeSlider(content,label,0,1000000,0,function(v)
            pcall(function()
                local pd=LP:FindFirstChild("PlayerData")
                local stats=pd and pd:FindFirstChild("Stats")
                if stats then
                    local obj=stats:FindFirstChild(k,true)
                    if obj and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                        obj.Value=math.floor(v)
                    end
                end
            end)
        end)
    end
end

--==================== 设置 Tab ====================
tabs["设置"]=function()
    makeLabel(content,"▶ 界面")
    makeButton(content,"重置悬浮球位置",function()
        ball.Position=UDim2.new(0,40,0.5,-31)
    end)
    makeButton(content,"关闭面板",function()
        win.Visible=false
        ball.Visible=true
        TweenService:Create(blur,TweenInfo.new(0.3),{Size=0}):Play()
    end)
    makeButton(content,"毛玻璃强度测试",function()
        TweenService:Create(blur,TweenInfo.new(0.4),{Size=24}):Play()
    end)

    makeLabel(content,"▶ 配置")
    makeButton(content,"保存配置",function()
        pcall(function()
            local save={}
            for k,v in pairs(S) do
                if type(v)~="table" and type(v)~="userdata" and type(v)~="Instance" then
                    save[k]=v
                end
            end
            writefile("He_Config.json",HttpService:JSONEncode(save))
            StarterGui:SetCore("SendNotification",{Title="贺",Text="配置已保存"})
        end)
    end)
    makeButton(content,"加载配置",function()
        pcall(function()
            if isfile("He_Config.json") then
                local data=HttpService:JSONDecode(readfile("He_Config.json"))
                for k,v in pairs(data) do S[k]=v end
                StarterGui:SetCore("SendNotification",{Title="贺",Text="配置已加载"})
            end
        end)
    end)

    makeLabel(content,"▶ 关于")
    makeButton(content,"版本：v3.0 · 作者：小贺",function() end)
    makeButton(content,"RightShift 打开/关闭面板",function() end)
end

--==================== 角色重生重置飞行 ====================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.fly then stopFly(); task.wait(0.1); startFly() end
end)

--==================== 开场特效 ====================
local function playIntro(onFinish)
    local introGui=Instance.new("ScreenGui")
    introGui.Name="HeIntro"
    introGui.ResetOnSpawn=false
    introGui.IgnoreGuiInset=true
    introGui.DisplayOrder=9999
    introGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    introGui.Parent=guiParent

    local black=Instance.new("Frame",introGui)
    black.Size=UDim2.fromScale(1,1)
    black.BackgroundColor3=Color3.new(0,0,0)
    black.BorderSizePixel=0
    black.ZIndex=1

    local glow=Instance.new("Frame",introGui)
    glow.Size=UDim2.fromOffset(0,0)
    glow.Position=UDim2.fromScale(0.5,0.5)
    glow.AnchorPoint=Vector2.new(0.5,0.5)
    glow.BackgroundColor3=Color3.fromRGB(255,215,0)
    glow.BackgroundTransparency=1
    glow.BorderSizePixel=0
    Instance.new("UICorner",glow).CornerRadius=UDim.new(1,0)
    glow.ZIndex=2

    local beams={}
    for i=1,12 do
        local b=Instance.new("Frame",introGui)
        b.Size=UDim2.new(0,2,0,0)
        b.Position=UDim2.fromScale(0.5,0.5)
        b.AnchorPoint=Vector2.new(0.5,1)
        b.Rotation=i*30
        b.BackgroundColor3=Color3.fromRGB(255,215,0)
        b.BackgroundTransparency=1
        b.BorderSizePixel=0
        b.ZIndex=3
        beams[i]=b
    end

    local particles={}
    for i=1,60 do
        local p=Instance.new("Frame",introGui)
        local sz=math.random(3,7)
        p.Size=UDim2.fromOffset(sz,sz)
        p.BackgroundColor3=(i%3==0) and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,90,90)
        p.BorderSizePixel=0
        p.ZIndex=4
        Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
        local ang=math.random()*math.pi*2
        local dst=math.random(600,1400)
        p.Position=UDim2.new(0.5,math.cos(ang)*dst,0.5,math.sin(ang)*dst)
        particles[i]=p
    end

    local rings={}
    for i=1,3 do
        local r=Instance.new("Frame",introGui)
        r.Size=UDim2.fromOffset(0,0)
        r.Position=UDim2.fromScale(0.5,0.5)
        r.AnchorPoint=Vector2.new(0.5,0.5)
        r.BackgroundTransparency=1
        r.ZIndex=5
        local s=Instance.new("UIStroke",r)
        s.Thickness=4
        s.Color=Color3.fromRGB(255,215,0)
        s.Transparency=1
        Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
        rings[i]={f=r,s=s}
    end

    local title=Instance.new("TextLabel",introGui)
    title.Size=UDim2.fromOffset(600,600)
    title.Position=UDim2.fromScale(0.5,0.5)
    title.AnchorPoint=Vector2.new(0.5,0.5)
    title.BackgroundTransparency=1
    title.Text="贺"
    title.Font=Enum.Font.GothamBlack
    title.TextSize=0
    title.TextColor3=Color3.fromRGB(255,215,0)
    title.TextTransparency=1
    title.ZIndex=6

    local subtitle=Instance.new("TextLabel",introGui)
    subtitle.Size=UDim2.fromOffset(700,40)
    subtitle.Position=UDim2.new(0.5,0,0.5,170)
    subtitle.AnchorPoint=Vector2.new(0.5,0.5)
    subtitle.BackgroundTransparency=1
    subtitle.Text="H E   ·   L I Q U I D   G L A S S"
    subtitle.Font=Enum.Font.GothamBold
    subtitle.TextSize=16
    subtitle.TextColor3=Color3.fromRGB(220,220,220)
    subtitle.TextTransparency=1
    subtitle.ZIndex=6

    local scan=Instance.new("Frame",introGui)
    scan.Size=UDim2.new(1,0,0,3)
    scan.Position=UDim2.new(0,0,0,-10)
    scan.BackgroundColor3=Color3.fromRGB(255,215,0)
    scan.BorderSizePixel=0
    scan.BackgroundTransparency=0.2
    scan.ZIndex=7

    local cornerL=Instance.new("TextLabel",introGui)
    cornerL.Size=UDim2.fromOffset(220,20)
    cornerL.Position=UDim2.new(0,24,1,-34)
    cornerL.BackgroundTransparency=1
    cornerL.Text="LOADING..."
    cornerL.TextColor3=Color3.fromRGB(255,215,0)
    cornerL.Font=Enum.Font.Code
    cornerL.TextSize=12
    cornerL.TextXAlignment=Enum.TextXAlignment.Left
    cornerL.TextTransparency=1
    cornerL.ZIndex=7

    local cornerR=Instance.new("TextLabel",introGui)
    cornerR.Size=UDim2.fromOffset(220,20)
    cornerR.Position=UDim2.new(1,-244,1,-34)
    cornerR.BackgroundTransparency=1
    cornerR.Text="v3.0 · HE"
    cornerR.TextColor3=Color3.fromRGB(255,215,0)
    cornerR.Font=Enum.Font.Code
    cornerR.TextSize=12
    cornerR.TextXAlignment=Enum.TextXAlignment.Right
    cornerR.TextTransparency=1
    cornerR.ZIndex=7

    local skipped=false
    local skipConn
    skipConn=UIS.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch
        or input.KeyCode==Enum.KeyCode.Space then
            skipped=true
            if skipConn then skipConn:Disconnect(); skipConn=nil end
            pcall(function() introGui:Destroy() end)
            if onFinish then pcall(onFinish) end
        end
    end)

    task.spawn(function()
        task.wait(0.05)
        TweenService:Create(cornerL,TweenInfo.new(0.4),{TextTransparency=0.3}):Play()
        TweenService:Create(cornerR,TweenInfo.new(0.4),{TextTransparency=0.3}):Play()

        for _,p in ipairs(particles) do
            task.spawn(function()
                task.wait(math.random()*0.15)
                TweenService:Create(p,TweenInfo.new(0.75,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
                    Position=UDim2.fromScale(0.5,0.5),
                    BackgroundTransparency=0.5,
                }):Play()
            end)
        end
        if skipped then return end
        task.wait(0.75)

        TweenService:Create(glow,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Size=UDim2.fromOffset(1000,1000),
            BackgroundTransparency=0.85,
        }):Play()
        for _,p in ipairs(particles) do
            TweenService:Create(p,TweenInfo.new(0.3),{
                BackgroundTransparency=1,
                Size=UDim2.fromOffset(0,0),
            }):Play()
        end
        if skipped then return end
        task.wait(0.1)

        title.TextTransparency=0
        TweenService:Create(title,TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            TextSize=180,
        }):Play()
        if skipped then return end
        task.wait(0.1)

        for i,r in ipairs(rings) do
            task.spawn(function()
                task.wait((i-1)*0.12)
                r.s.Transparency=0.2
                TweenService:Create(r.f,TweenInfo.new(1.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Size=UDim2.fromOffset(500+i*350,500+i*350),
                }):Play()
                TweenService:Create(r.s,TweenInfo.new(1.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Transparency=1,
                    Thickness=0.3,
                }):Play()
            end)
        end
        if skipped then return end
        task.wait(0.15)

        for i,b in ipairs(beams) do
            task.spawn(function()
                task.wait(i*0.03)
                b.BackgroundTransparency=0.4
                TweenService:Create(b,TweenInfo.new(0.6,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Size=UDim2.new(0,2,0,400),
                }):Play()
                task.wait(0.3)
                TweenService:Create(b,TweenInfo.new(0.4),{
                    BackgroundTransparency=1,
                    Size=UDim2.new(0,2,0,0),
                }):Play()
            end)
        end
        if skipped then return end
        task.wait(0.25)

        TweenService:Create(scan,TweenInfo.new(0.9,Enum.EasingStyle.Linear),{
            Position=UDim2.new(0,0,1,10),
        }):Play()
        if skipped then return end
        task.wait(0.4)

        TweenService:Create(subtitle,TweenInfo.new(0.5),{TextTransparency=0}):Play()
        if skipped then return end
        task.wait(1.2)

        local bp=ball.AbsolutePosition
        local bs=ball.AbsoluteSize
        local bc=Vector2.new(bp.X+bs.X/2,bp.Y+bs.Y/2)

        TweenService:Create(title,TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
            Position=UDim2.fromOffset(bc.X,bc.Y),
            TextSize=30,
            TextTransparency=1,
        }):Play()
        TweenService:Create(subtitle,TweenInfo.new(0.35),{TextTransparency=1}):Play()
        TweenService:Create(cornerL,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(cornerR,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(glow,TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
            Size=UDim2.fromOffset(70,70),
            Position=UDim2.fromOffset(bc.X,bc.Y),
            BackgroundTransparency=0.6,
        }):Play()
        TweenService:Create(black,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            BackgroundTransparency=1,
        }):Play()

        if skipped then return end
        task.wait(0.65)

        if skipConn then skipConn:Disconnect(); skipConn=nil end
        pcall(function() introGui:Destroy() end)

        ball.Size=UDim2.fromOffset(0,0)
        TweenService:Create(ball,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.fromOffset(62,62),
        }):Play()

        if onFinish then pcall(onFinish) end
    end)
end

--==================== 正式启动 ====================
win.Visible=false
ball.Visible=false

playIntro(function()
    ball.Visible=true
    ball.BackgroundTransparency=0.28
    ball.TextTransparency=0
    ballStroke.Transparency=0.75
    ballGlow.Transparency=0.3
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title="贺 v3.0",
            Text="点击「贺」打开完整面板 · 9 个分类",
            Duration=3,
        })
    end)
end)

print("[贺] v3.0 完整版加载完成 · 作者：小贺")
