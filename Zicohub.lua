local Players=game:GetService("Players")
local RunSvc=game:GetService("RunService")
local TweenSvc=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RepStor=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer

local clock=os.clock
local wait=task.wait
local spawn=task.spawn
local insert=table.insert
local remove=table.remove
local find=table.find
local floor=math.floor
local clamp=math.clamp
local random=math.random
local abs=math.abs

local T={
    BG=Color3.fromRGB(8,8,10),
    CARD=Color3.fromRGB(22,22,27),
    RAISED=Color3.fromRGB(32,32,38),
    BORDER=Color3.fromRGB(50,50,60),
    TEXT=Color3.fromRGB(242,242,242),
    MUTED=Color3.fromRGB(138,138,148),
    DIM=Color3.fromRGB(68,68,80),
    ACCENT=Color3.fromRGB(138,180,248),
    ON=Color3.fromRGB(120,220,120),
    OFF=Color3.fromRGB(50,50,60),
    WARN=Color3.fromRGB(200,185,120),
    ERR=Color3.fromRGB(200,80,80)
}

local SAVE={}
local SAVE_FILE="zico_v1.json"

pcall(function()
    if readfile then
        local ok,d=pcall(function()
            return Http:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and type(d)=="table" then
            for k,v in pairs(d) do
                SAVE[k]=v
            end
        end
    end
end)

local function DoSave()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE,Http:JSONEncode(SAVE))
        end
    end)
end

SAVE.kaRange=SAVE.kaRange or 250
SAVE.kaAPS=SAVE.kaAPS or 80000
SAVE.hbSize=SAVE.hbSize or 12
SAVE.rpSpeed=SAVE.rpSpeed or 8
SAVE.strafeRadius=SAVE.strafeRadius or 10
SAVE.strafeSpeed=SAVE.strafeSpeed or 4
SAVE.strafeOffset=SAVE.strafeOffset or -2
SAVE.orbRadius=SAVE.orbRadius or 10
SAVE.orbSpeed=SAVE.orbSpeed or 5
SAVE.orbHeight=SAVE.orbHeight or 2
SAVE.tpwSpeed=SAVE.tpwSpeed or 6
SAVE.arcDefDelay=SAVE.arcDefDelay or 0.1
SAVE.arcGrabDelay=SAVE.arcGrabDelay or 3.5
SAVE.friends=SAVE.friends or ""
SAVE.targets=SAVE.targets or ""
SAVE.agTarget=SAVE.agTarget or ""
SAVE.ggTarget=SAVE.ggTarget or ""
SAVE.strafeTarget=SAVE.strafeTarget or ""
SAVE.orbTarget=SAVE.orbTarget or ""
SAVE.hsTarget=SAVE.hsTarget or ""
SAVE.keybinds=SAVE.keybinds or {}
SAVE.configs=SAVE.configs or {}
SAVE.toggleKey=SAVE.toggleKey or "Insert"
SAVE.safeX=SAVE.safeX or 0
SAVE.safeY=SAVE.safeY or 100
SAVE.safeZ=SAVE.safeZ or 0
SAVE.flySpeed=SAVE.flySpeed or 80
SAVE.tpHitTarget=SAVE.tpHitTarget or ""
SAVE.tpHitRange=SAVE.tpHitRange or 35
SAVE.phrases=SAVE.phrases or "ZICO ON TOP!"
SAVE.bioTypeSpeed=SAVE.bioTypeSpeed or 15
SAVE.nameTypewriter=SAVE.nameTypewriter or false
SAVE.kaPredict=SAVE.kaPredict or true

local CONNS={}

local function TC(c)
    if c then
        insert(CONNS,c)
    end
    return c
end

local FriendsList={}
local TargetsList={}

local function parseFriends(s)
    FriendsList={}
    for w in (s or ""):gmatch("%S+") do
        insert(FriendsList,w:lower())
    end
end

local function parseTargets(s)
    TargetsList={}
    for w in (s or ""):gmatch("%S+") do
        insert(TargetsList,w:lower())
    end
end

parseFriends(SAVE.friends)
parseTargets(SAVE.targets)

local function isFriend(p)
    local n=p.Name:lower()
    local dn=p.DisplayName:lower()
    for _,f in ipairs(FriendsList) do
        if n:find(f,1,true) or dn:find(f,1,true) then
            return true
        end
    end
    return false
end

local function isTarget(p)
    if p==lp then
        return false
    end
    if isFriend(p) then
        return false
    end
    if #TargetsList==0 then
        return true
    end
    local n=p.Name:lower()
    local dn=p.DisplayName:lower()
    for _,t in ipairs(TargetsList) do
        if n:find(t,1,true) or dn:find(t,1,true) then
            return true
        end
    end
    return false
end

local function findPlayer(name)
    if not name or name=="" then
        return nil
    end
    local nl=name:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then
            if p.Name:lower()==nl or p.DisplayName:lower()==nl then
                return p
            end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then
            if p.Name:lower():find(nl,1,true) or p.DisplayName:lower():find(nl,1,true) then
                return p
            end
        end
    end
    return nil
end

local SAFE_CF=CFrame.new(SAVE.safeX,SAVE.safeY,SAVE.safeZ)

local RF={}

spawn(function()
    local waited=0
    repeat
        wait(0.5)
        waited=waited+0.5
    until waited>=3 or game:IsLoaded()
    wait(1)
    pcall(function()
        local cs=RepStor:WaitForChild("Packages",10)
        cs=cs:WaitForChild("Knit",10)
        cs=cs:WaitForChild("Services",10)
        cs=cs:WaitForChild("CombatService",10)
        cs=cs:WaitForChild("RF",10)
        RF.Hit=cs:WaitForChild("Hit",10)
        RF.PunchDo=cs:WaitForChild("PunchDo",10)
        RF.Block=cs:WaitForChild("Block",10)
        RF.Grab=cs:WaitForChild("Grab",10)
    end)
    pcall(function()
        local rem=RepStor:WaitForChild("Remotes",10)
        RF.UpdateBio=rem:WaitForChild("UpdateBio",10)
        RF.UpdateBioColor=rem:WaitForChild("UpdateBioColor",10)
        RF.UpdateRPColor=rem:WaitForChild("UpdateRPColor",10)
        RF.UpdateRPName=rem:WaitForChild("UpdateRPName",10)
    end)
end)

pcall(function()
    local o=CoreGui:FindFirstChild("ZICO_HUB")
    if o then
        o:Destroy()
    end
end)

local GUI=Instance.new("ScreenGui")
GUI.Name="ZICO_HUB"
GUI.ResetOnSpawn=false
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset=true
GUI.Parent=CoreGui

local Bold=Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.Bold)
local Semi=Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.SemiBold)
local Reg=Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.Regular)

local function Cnr(p,r)
    local c=Instance.new("UICorner",p)
    c.CornerRadius=UDim.new(0,r or 8)
    return c
end

local function Strk(p,col,thick,tr)
    local s=Instance.new("UIStroke",p)
    s.Color=col or T.BORDER
    s.Thickness=thick or 1
    s.Transparency=tr or 0
    return s
end

local function LL(p,pad,dir)
    local l=Instance.new("UIListLayout",p)
    l.Padding=UDim.new(0,pad or 6)
    l.SortOrder=Enum.SortOrder.LayoutOrder
    if dir then
        l.FillDirection=dir
    end
    return l
end

local function LP(p,l,r,t2,b)
    local u=Instance.new("UIPadding",p)
    u.PaddingLeft=UDim.new(0,l or 0)
    u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingTop=UDim.new(0,t2 or 0)
    u.PaddingBottom=UDim.new(0,b or 0)
end

local tweenCache={}

local function Tw(obj,props,time,style,dir)
    local key=tostring(obj)
    if tweenCache[key] then
        tweenCache[key]:Cancel()
    end
    local tw=TweenSvc:Create(obj,TweenInfo.new(time or 0.15,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
    tweenCache[key]=tw
    tw:Play()
    tw.Completed:Connect(function()
        tweenCache[key]=nil
    end)
    return tw
end

local function MkLabel(parent,p)
    local l=Instance.new("TextLabel",parent)
    l.BackgroundTransparency=1
    l.FontFace=p.font or Reg
    l.TextSize=p.size or 11
    l.TextColor3=p.color or T.TEXT
    l.Text=p.text or ""
    l.Size=p.sz or UDim2.new(1,0,0,16)
    l.Position=p.pos or UDim2.new(0,0,0,0)
    l.TextXAlignment=p.xa or Enum.TextXAlignment.Left
    l.TextYAlignment=p.ya or Enum.TextYAlignment.Center
    l.TextWrapped=p.wrap or false
    l.ZIndex=p.z or 14
    return l
end

local NotifHolder=Instance.new("Frame",GUI)
NotifHolder.Size=UDim2.new(0,290,1,0)
NotifHolder.Position=UDim2.new(1,-304,0,12)
NotifHolder.BackgroundTransparency=1
NotifHolder.BorderSizePixel=0
NotifHolder.ZIndex=9000

local _notifs={}
local NH=62
local NG=6

local function _restack()
    local y=0
    for _,f in ipairs(_notifs) do
        if f and f.Parent then
            Tw(f,{Position=UDim2.new(0,0,0,y)},0.2,Enum.EasingStyle.Back)
            y=y+NH+NG
        end
    end
end

local function Notif(title,body,ntype)
    local acc
    if ntype=="ok" then
        acc=Color3.fromRGB(100,255,150)
    elseif ntype=="warn" then
        acc=T.WARN
    elseif ntype=="err" then
        acc=T.ERR
    else
        acc=T.ACCENT
    end
    local icon
    if ntype=="ok" then
        icon="✓"
    elseif ntype=="warn" then
        icon="⚠"
    elseif ntype=="err" then
        icon="✕"
    else
        icon="•"
    end
    local y=#_notifs*(NH+NG)
    local f=Instance.new("Frame",NotifHolder)
    f.Size=UDim2.new(1,0,0,NH)
    f.Position=UDim2.new(1,20,0,y)
    f.BackgroundColor3=T.CARD
    f.BackgroundTransparency=0.04
    f.BorderSizePixel=0
    f.ZIndex=9001
    Cnr(f,10)
    Strk(f,acc,1.8,0.1)
    local acbar=Instance.new("Frame",f)
    acbar.Size=UDim2.new(0,4,0,40)
    acbar.Position=UDim2.new(0,0,0.5,-20)
    acbar.BackgroundColor3=acc
    acbar.BorderSizePixel=0
    Cnr(acbar,2)
    MkLabel(f,{
        text=icon,
        size=14,
        color=acc,
        font=Bold,
        sz=UDim2.new(0,28,1,0),
        pos=UDim2.new(0,10,0,0),
        xa=Enum.TextXAlignment.Center,
        z=9002
    })
    MkLabel(f,{
        text=title,
        size=11,
        color=T.TEXT,
        font=Bold,
        sz=UDim2.new(1,-42,0,18),
        pos=UDim2.new(0,40,0,10),
        z=9002
    })
    MkLabel(f,{
        text=body or "",
        size=9,
        color=T.MUTED,
        font=Reg,
        sz=UDim2.new(1,-42,0,20),
        pos=UDim2.new(0,40,0,32),
        wrap=true,
        z=9002
    })
    local pb=Instance.new("Frame",f)
    pb.Size=UDim2.new(1,0,0,3)
    pb.Position=UDim2.new(0,0,1,-3)
    pb.BackgroundColor3=acc
    pb.BackgroundTransparency=0.3
    pb.BorderSizePixel=0
    TweenSvc:Create(pb,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,3)}):Play()
    local rb=Instance.new("TextButton",f)
    rb.Size=UDim2.new(1,0,1,0)
    rb.BackgroundTransparency=1
    rb.Text=""
    rb.ZIndex=9003
    insert(_notifs,f)
    Tw(f,{Position=UDim2.new(0,0,0,y)},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    local function dismiss()
        local idx=find(_notifs,f)
        if idx then
            remove(_notifs,idx)
        end
        Tw(f,{Position=UDim2.new(1,20,0,f.Position.Y.Offset),BackgroundTransparency=1},0.2)
        task.delay(0.22,function()
            pcall(function()
                f:Destroy()
            end)
        end)
        task.delay(0.05,_restack)
    end
    rb.MouseButton1Click:Connect(dismiss)
    task.delay(4.6,function()
        if f and f.Parent then
            dismiss()
        end
    end)
end

local KEYBINDS={}
local _kbListening=false
local _kbCb=nil

local function RegKB(action,defaultKey,callback)
    local saved=SAVE.keybinds[action]
    local key=defaultKey
    if saved then
        local ok,kc=pcall(function()
            return Enum.KeyCode[saved]
        end)
        if ok and kc then
            key=kc
        end
    end
    for _,kb in ipairs(KEYBINDS) do
        if kb.action==action then
            kb.callback=callback
            kb.key=key
            return kb
        end
    end
    local kb={action=action,key=key,callback=callback}
    insert(KEYBINDS,kb)
    return kb
end

TC(UIS.InputBegan:Connect(function(i,gp)
    if gp then
        return
    end
    if _kbListening and _kbCb and i.UserInputType==Enum.UserInputType.Keyboard then
        _kbCb(i.KeyCode)
        _kbListening=false
        _kbCb=nil
        return
    end
    if i.UserInputType==Enum.UserInputType.Keyboard then
        for _,kb in ipairs(KEYBINDS) do
            if kb.key==i.KeyCode and kb.callback then
                pcall(kb.callback)
            end
        end
    end
end))

local function MkCard(parent,h,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,h or 48)
    f.BackgroundColor3=T.CARD
    f.BackgroundTransparency=0.06
    f.BorderSizePixel=0
    f.LayoutOrder=order or 0
    f.ClipsDescendants=true
    Cnr(f,8)
    Strk(f,T.BORDER,1,0.45)
    return f
end

local function MkSep(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,14)
    f.BackgroundTransparency=1
    f.LayoutOrder=order or 0
    MkLabel(f,{text=text:upper(),size=7,color=T.DIM,font=Bold,sz=UDim2.new(1,0,1,0),z=14})
    return f
end

local function MkToggle(parent,label,order,onEn,onDis)
    local card=MkCard(parent,48,order)
    MkLabel(card,{
        text=label:upper(),
        size=8,
        color=T.TEXT,
        font=Semi,
        sz=UDim2.new(1,-62,0,16),
        pos=UDim2.new(0,14,0.5,-8),
        z=14
    })
    local track=Instance.new("TextButton",card)
    track.Size=UDim2.new(0,38,0,18)
    track.Position=UDim2.new(1,-48,0.5,-9)
    track.BackgroundColor3=T.RAISED
    track.BackgroundTransparency=0.1
    track.Text=""
    track.AutoButtonColor=false
    track.BorderSizePixel=0
    track.ZIndex=15
    Cnr(track,10)
    Strk(track,T.BORDER,1,0.4)
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,12,0,12)
    thumb.Position=UDim2.new(0,3,0.5,-6)
    thumb.BackgroundColor3=T.OFF
    thumb.BorderSizePixel=0
    thumb.ZIndex=16
    Cnr(thumb,8)
    local state=false
    local function Set(s,silent)
        state=s
        local dc
        local dp
        local tc
        if s then
            dc=T.ON
            dp=UDim2.new(1,-15,0.5,-6)
            tc=Color3.fromRGB(35,45,55)
        else
            dc=T.OFF
            dp=UDim2.new(0,3,0.5,-6)
            tc=T.RAISED
        end
        if silent then
            thumb.Position=dp
            thumb.BackgroundColor3=dc
            track.BackgroundColor3=tc
        else
            Tw(thumb,{Position=dp,BackgroundColor3=dc},0.25,Enum.EasingStyle.Back)
            Tw(track,{BackgroundColor3=tc},0.18)
        end
    end
    track.MouseButton1Click:Connect(function()
        local s=not state
        Set(s)
        if s then
            onEn()
        else
            onDis()
        end
    end)
    track.MouseEnter:Connect(function()
        Tw(track,{BackgroundTransparency=0.05},0.1)
    end)
    track.MouseLeave:Connect(function()
        Tw(track,{BackgroundTransparency=0.1},0.1)
    end)
    return card,function() return state end,Set
end

local function MkSlider(parent,label,minV,maxV,defV,order,onChange)
    local d=clamp(defV or minV,minV,maxV)
    local pct0
    if maxV==minV then
        pct0=0
    else
        pct0=(d-minV)/(maxV-minV)
    end
    local card=MkCard(parent,56,order)
    MkLabel(card,{
        text=label:upper(),
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-80,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local valL=MkLabel(card,{
        text=tostring(d),
        size=13,
        color=T.ACCENT,
        font=Bold,
        sz=UDim2.new(0,60,0,14),
        pos=UDim2.new(1,-72,0,6),
        xa=Enum.TextXAlignment.Right,
        z=14
    })
    local track=Instance.new("Frame",card)
    track.Size=UDim2.new(1,-24,0,4)
    track.Position=UDim2.new(0,12,0,32)
    track.BackgroundColor3=T.RAISED
    track.BackgroundTransparency=0.22
    track.BorderSizePixel=0
    Cnr(track,2)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct0,0,1,0)
    fill.BackgroundColor3=T.ACCENT
    fill.BackgroundTransparency=0
    fill.BorderSizePixel=0
    Cnr(fill,2)
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,14,0,14)
    thumb.Position=UDim2.new(pct0,-7,0.5,-7)
    thumb.BackgroundColor3=T.TEXT
    thumb.BorderSizePixel=0
    Cnr(thumb,7)
    thumb.ZIndex=15
    local glow=Strk(thumb,T.ACCENT,2,0.7)
    local dz=Instance.new("TextButton",card)
    dz.Size=UDim2.new(1,0,0,36)
    dz.Position=UDim2.new(0,0,0,18)
    dz.BackgroundTransparency=1
    dz.Text=""
    dz.AutoButtonColor=false
    dz.ZIndex=16
    local dragging=false
    local touchX=nil
    dz.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            touchX=i.Position.X
            Tw(thumb,{Size=UDim2.new(0,16,0,16)},0.12)
            Tw(glow,{Transparency=0.3},0.12)
        end
    end)
    TC(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
            Tw(thumb,{Size=UDim2.new(0,14,0,14)},0.12)
            Tw(glow,{Transparency=0.7},0.12)
        end
    end))
    TC(UIS.InputChanged:Connect(function(i)
        if not dragging then
            return
        end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            touchX=i.Position.X
        end
    end))
    TC(RunSvc.Heartbeat:Connect(function()
        if not dragging then
            return
        end
        local aw=track.AbsoluteSize.X
        if aw<=0 then
            return
        end
        local mx=touchX or UIS:GetMouseLocation().X
        local p2=clamp((mx-track.AbsolutePosition.X)/aw,0,1)
        fill.Size=UDim2.new(p2,0,1,0)
        thumb.Position=UDim2.new(p2,-7,0.5,-7)
        local val=floor(minV+p2*(maxV-minV)+0.5)
        valL.Text=tostring(val)
        if onChange then
            onChange(val)
        end
    end))
    local function setVal(v)
        v=clamp(v,minV,maxV)
        local p2
        if maxV==minV then
            p2=0
        else
            p2=(v-minV)/(maxV-minV)
        end
        fill.Size=UDim2.new(p2,0,1,0)
        thumb.Position=UDim2.new(p2,-7,0.5,-7)
        valL.Text=tostring(v)
    end
    return card,valL,setVal
end

local function MkTBox(parent,topLabel,ph,order,default)
    local card=MkCard(parent,56,order)
    MkLabel(card,{
        text=topLabel:upper(),
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local box=Instance.new("TextBox",card)
    box.Size=UDim2.new(1,-24,0,24)
    box.Position=UDim2.new(0,12,0,22)
    box.BackgroundColor3=T.RAISED
    box.BackgroundTransparency=0.15
    box.FontFace=Reg
    box.TextSize=10
    box.TextColor3=T.TEXT
    box.PlaceholderColor3=T.DIM
    box.PlaceholderText=ph or ""
    box.Text=default or ""
    box.ClearTextOnFocus=false
    box.BorderSizePixel=0
    box.TextXAlignment=Enum.TextXAlignment.Left
    box.ZIndex=15
    Cnr(box,6)
    local s=Strk(box,T.BORDER,1,0.35)
    LP(box,8,8,0,0)
    box.Focused:Connect(function()
        Tw(s,{Transparency=0,Color=T.ACCENT},0.12)
        Tw(box,{BackgroundTransparency=0.05},0.12)
    end)
    box.FocusLost:Connect(function()
        Tw(s,{Transparency=0.35,Color=T.BORDER},0.12)
        Tw(box,{BackgroundTransparency=0.15},0.12)
    end)
    return card,box
end

local function MkBtn(parent,p)
    local b=Instance.new("TextButton",parent)
    b.BackgroundColor3=p.bg or T.CARD
    b.BackgroundTransparency=p.bgt or 0
    b.FontFace=p.font or Semi
    b.TextSize=p.size or 10
    b.TextColor3=p.color or T.TEXT
    b.Text=p.text or ""
    b.Size=p.sz or UDim2.new(1,0,0,28)
    b.Position=p.pos or UDim2.new(0,0,0,0)
    b.AnchorPoint=p.anchor or Vector2.new(0,0)
    b.AutoButtonColor=false
    b.BorderSizePixel=0
    b.LayoutOrder=p.order or 0
    b.ZIndex=p.z or 14
    if p.corner~=false then
        Cnr(b,p.corner or 6)
    end
    b.MouseEnter:Connect(function()
        Tw(b,{BackgroundTransparency=math.max(0,(p.bgt or 0)-0.15)},0.1)
    end)
    b.MouseLeave:Connect(function()
        Tw(b,{BackgroundTransparency=p.bgt or 0},0.1)
    end)
    return b
end

local function MkKBRow(parent,action,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,28)
    f.BackgroundColor3=T.RAISED
    f.BackgroundTransparency=0.18
    f.BorderSizePixel=0
    f.LayoutOrder=order
    Cnr(f,6)
    MkLabel(f,{
        text=action,
        size=8,
        color=T.TEXT,
        font=Semi,
        sz=UDim2.new(1,-68,1,0),
        pos=UDim2.new(0,10,0,0),
        z=15
    })
    local bindBtn=MkBtn(f,{
        bg=T.CARD,
        text="—",
        size=7,
        color=T.MUTED,
        sz=UDim2.new(0,56,0,20),
        pos=UDim2.new(1,-60,0.5,-10),
        corner=5,
        bgt=0.08,
        z=16
    })
    local function refresh()
        for _,kb in ipairs(KEYBINDS) do
            if kb.action==action then
                if kb.key then
                    bindBtn.Text=tostring(kb.key):gsub("Enum.KeyCode.","")
                else
                    bindBtn.Text="—"
                end
                return
            end
        end
    end
    refresh()
    bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text="..."
        bindBtn.TextColor3=T.ACCENT
        _kbListening=true
        _kbCb=function(kc)
            SAVE.keybinds[action]=tostring(kc):gsub("Enum.KeyCode.","")
            for _,kb in ipairs(KEYBINDS) do
                if kb.action==action then
                    kb.key=kc
                    break
                end
            end
            bindBtn.Text=tostring(kc):gsub("Enum.KeyCode.","")
            bindBtn.TextColor3=T.MUTED
            task.delay(0.5,DoSave)
        end
    end)
    return f
end

local WW=340
local WH=480

local Win=Instance.new("Frame",GUI)
Win.Name="ZICO_Main"
Win.Size=UDim2.new(0,WW,0,WH)
Win.Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
Win.BackgroundColor3=T.BG
Win.BackgroundTransparency=0.02
Win.BorderSizePixel=0
Win.ClipsDescendants=true
Win.ZIndex=10
Cnr(Win,14)
Strk(Win,Color3.fromRGB(255,0,0),2,0.3)
Strk(Win,Color3.fromRGB(0,0,0),3,0.5)

local Header=Instance.new("Frame",Win)
Header.Size=UDim2.new(1,0,0,40)
Header.BackgroundTransparency=1
Header.BorderSizePixel=0
Header.ZIndex=14

local logo=Instance.new("Frame",Header)
logo.Size=UDim2.new(0,26,0,26)
logo.Position=UDim2.new(0,10,0.5,-13)
logo.BackgroundColor3=T.RAISED
logo.BackgroundTransparency=0.05
logo.BorderSizePixel=0
Cnr(logo,7)
Strk(logo,T.ACCENT,1.5,0.3)
MkLabel(logo,{
    text="Z",
    size=13,
    color=T.ACCENT,
    font=Bold,
    sz=UDim2.new(1,0,1,0),
    xa=Enum.TextXAlignment.Center,
    z=14
})

local TitleLbl=MkLabel(Header,{
    text="ZICO HUB",
    size=14,
    color=T.TEXT,
    font=Bold,
    sz=UDim2.new(0,110,0,18),
    pos=UDim2.new(0,44,0,10),
    z=14
})

local VersionLbl=MkLabel(Header,{
    text="V1 - love by Zico",
    size=7,
    color=T.ACCENT,
    font=Reg,
    sz=UDim2.new(0,140,0,12),
    pos=UDim2.new(0,44,0,28),
    z=14
})

local hdrHue=0
TC(RunSvc.RenderStepped:Connect(function(dt)
    hdrHue=(hdrHue+dt*0.3)%1
    TitleLbl.TextColor3=Color3.fromHSV(hdrHue,0.8,1)
end))

local CloseBtn=Instance.new("TextButton",Header)
CloseBtn.Size=UDim2.new(0,24,0,24)
CloseBtn.Position=UDim2.new(1,-32,0.5,-12)
CloseBtn.BackgroundColor3=T.RAISED
CloseBtn.BackgroundTransparency=0.15
CloseBtn.Text="×"
CloseBtn.FontFace=Bold
CloseBtn.TextSize=14
CloseBtn.TextColor3=T.MUTED
CloseBtn.AutoButtonColor=false
CloseBtn.BorderSizePixel=0
CloseBtn.ZIndex=15
Cnr(CloseBtn,6)
CloseBtn.MouseEnter:Connect(function()
    Tw(CloseBtn,{BackgroundColor3=T.ERR,TextColor3=T.TEXT},0.14)
end)
CloseBtn.MouseLeave:Connect(function()
    Tw(CloseBtn,{BackgroundColor3=T.RAISED,TextColor3=T.MUTED},0.14)
end)
CloseBtn.MouseButton1Click:Connect(function()
    Win.Visible=false
end)

local HDiv=Instance.new("Frame",Win)
HDiv.Size=UDim2.new(1,0,0,1)
HDiv.Position=UDim2.new(0,0,0,40)
HDiv.BackgroundColor3=T.BORDER
HDiv.BackgroundTransparency=0.5
HDiv.BorderSizePixel=0
HDiv.ZIndex=14

do
    local dragging=false
    local dragStart=nil
    local startPos=nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=i.Position
            startPos=Win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging then
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                local d=i.Position-dragStart
                Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end

local SIDE_W=100
local BODY_Y=41

local Sidebar=Instance.new("ScrollingFrame",Win)
Sidebar.Size=UDim2.new(0,SIDE_W,0,WH-BODY_Y)
Sidebar.Position=UDim2.new(0,0,0,BODY_Y)
Sidebar.BackgroundTransparency=1
Sidebar.BorderSizePixel=0
Sidebar.ScrollBarThickness=2
Sidebar.ScrollBarImageColor3=T.DIM
Sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
Sidebar.CanvasSize=UDim2.new(0,0,0,0)
Sidebar.ZIndex=14
Sidebar.ClipsDescendants=true
LP(Sidebar,6,6,6,6)
LL(Sidebar,3)

local SDiv=Instance.new("Frame",Win)
SDiv.Size=UDim2.new(0,1,0,WH-BODY_Y)
SDiv.Position=UDim2.new(0,SIDE_W,0,BODY_Y)
SDiv.BackgroundColor3=T.BORDER
SDiv.BackgroundTransparency=0.5
SDiv.BorderSizePixel=0
SDiv.ZIndex=14

local Content=Instance.new("Frame",Win)
Content.Size=UDim2.new(0,WW-SIDE_W-1,0,WH-BODY_Y)
Content.Position=UDim2.new(0,SIDE_W+1,0,BODY_Y)
Content.BackgroundTransparency=1
Content.BorderSizePixel=0
Content.ClipsDescendants=true
Content.ZIndex=12

local TABS={
    {n="Home",i="H"},
    {n="Combat",i="C"},
    {n="RP",i="R"},
    {n="Move",i="M"},
    {n="Target",i="T"},
    {n="Ghost",i="G"},
    {n="Glitch",i="L"},
    {n="Headless",i="D"},
    {n="Spin",i="S"},
    {n="Keys",i="K"},
    {n="Configs",i="F"},
    {n="Adv Cbt",i="A"},
    {n="Cbt Util",i="U"},
    {n="Advant",i="V"}
}

local tabBtns={}
local tabPanels={}
local activeTab=nil
local transiting=false

for i,t in ipairs(TABS) do
    local btn=Instance.new("TextButton",Sidebar)
    btn.Size=UDim2.new(1,0,0,28)
    btn.BackgroundColor3=T.CARD
    btn.BackgroundTransparency=1
    btn.Text=""
    btn.AutoButtonColor=false
    btn.BorderSizePixel=0
    btn.LayoutOrder=i
    btn.ZIndex=15
    Cnr(btn,5)
    local bar=Instance.new("Frame",btn)
    bar.Size=UDim2.new(0,2,0,14)
    bar.Position=UDim2.new(0,0,0.5,-7)
    bar.BackgroundColor3=T.ACCENT
    bar.BackgroundTransparency=1
    bar.BorderSizePixel=0
    Cnr(bar,1)
    local ic=Instance.new("TextLabel",btn)
    ic.Size=UDim2.new(0,18,1,0)
    ic.Position=UDim2.new(0,5,0,0)
    ic.BackgroundTransparency=1
    ic.Text=t.i
    ic.TextSize=10
    ic.TextColor3=T.DIM
    ic.FontFace=Bold
    ic.TextXAlignment=Enum.TextXAlignment.Center
    ic.ZIndex=15
    local nl=Instance.new("TextLabel",btn)
    nl.Size=UDim2.new(1,-26,1,0)
    nl.Position=UDim2.new(0,24,0,0)
    nl.BackgroundTransparency=1
    nl.Text=t.n:upper()
    nl.TextSize=6
    nl.TextColor3=T.MUTED
    nl.FontFace=Bold
    nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.ZIndex=15
    local panel=Instance.new("ScrollingFrame",Content)
    panel.Size=UDim2.new(1,0,1,0)
    panel.Position=UDim2.new(1,0,0,0)
    panel.BackgroundTransparency=1
    panel.BorderSizePixel=0
    panel.ScrollBarThickness=2
    panel.ScrollBarImageColor3=T.ACCENT
    panel.AutomaticCanvasSize=Enum.AutomaticSize.Y
    panel.CanvasSize=UDim2.new(0,0,0,0)
    panel.ClipsDescendants=true
    panel.Visible=false
    panel.ZIndex=12
    LP(panel,8,8,6,14)
    LL(panel,4)
    btn.MouseEnter:Connect(function()
        if activeTab~=i then
            Tw(btn,{BackgroundTransparency=0.7},0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab~=i then
            Tw(btn,{BackgroundTransparency=1},0.12)
        end
    end)
    tabBtns[i]={btn=btn,bar=bar,ic=ic,nl=nl}
    tabPanels[i]=panel
end

local function GoTab(idx)
    if activeTab==idx or transiting then
        return
    end
    transiting=true
    local prev=activeTab
    activeTab=idx
    for i,tb in ipairs(tabBtns) do
        local a=(i==idx)
        Tw(tb.btn,{BackgroundTransparency=a and 0.05 or 1,BackgroundColor3=a and T.CARD or T.BG},0.14)
        Tw(tb.nl,{TextColor3=a and T.TEXT or T.MUTED},0.14)
        Tw(tb.ic,{TextColor3=a and T.ACCENT or T.DIM},0.14)
        Tw(tb.bar,{BackgroundTransparency=a and 0 or 1},0.18)
    end
    local dir
    if prev and idx>prev then
        dir=1
    else
        dir=-1
    end
    local np=tabPanels[idx]
    local op=prev and tabPanels[prev]
    np.Position=UDim2.new(dir,0,0,0)
    np.Visible=true
    local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    if op then
        TweenSvc:Create(op,ti,{Position=UDim2.new(-dir,0,0,0)}):Play()
    end
    local t2=TweenSvc:Create(np,ti,{Position=UDim2.new(0,0,0,0)})
    t2:Play()
    t2.Completed:Connect(function()
        if op then
            op.Visible=false
            op.Position=UDim2.new(1,0,0,0)
        end
        transiting=false
    end)
end

for i in ipairs(tabBtns) do
    local idx=i
    tabBtns[i].btn.MouseButton1Click:Connect(function()
        GoTab(idx)
    end)
end

local TBtn=Instance.new("TextButton",GUI)
TBtn.Name="ZICO_Toggle"
TBtn.Size=UDim2.fromOffset(44,44)
TBtn.BackgroundColor3=T.BG
TBtn.BackgroundTransparency=0.02
TBtn.Text="Z"
TBtn.FontFace=Bold
TBtn.TextSize=16
TBtn.TextColor3=T.ACCENT
TBtn.AutoButtonColor=false
TBtn.BorderSizePixel=0
TBtn.ZIndex=200
Cnr(TBtn,11)
Strk(TBtn,T.ACCENT,1.8,0.2)

task.defer(function()
    local gs=GUI.AbsoluteSize
    TBtn.Position=UDim2.fromOffset(gs.X-54,8)
end)

local toggleHue=0
TC(RunSvc.RenderStepped:Connect(function(dt)
    toggleHue=(toggleHue+dt*0.4)%1
    TBtn.TextColor3=Color3.fromHSV(toggleHue,0.9,1)
end))

local _toggleKey=Enum.KeyCode.Insert
do
    local saved=SAVE.toggleKey
    if saved then
        local ok,kc=pcall(function()
            return Enum.KeyCode[saved]
        end)
        if ok and kc then
            _toggleKey=kc
        end
    end
end

local function toggleUI()
    Win.Visible=not Win.Visible
    if Win.Visible and not activeTab then
        GoTab(1)
    end
end

do
    local dragging=false
    local dragStart=nil
    local startPos=nil
    TBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=i.Position
            startPos=TBtn.Position
        end
    end)
    TBtn.InputEnded:Connect(function(i)
        if dragging then
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=false
                if (i.Position-dragStart).Magnitude<8 then
                    toggleUI()
                end
            end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging then
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                local d=i.Position-dragStart
                TBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end
    end)
end

TC(UIS.InputBegan:Connect(function(i,gp)
    if not gp then
        if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==_toggleKey then
            toggleUI()
        end
    end
end))

local function cleanRag(char)
    if not char then
        return
    end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return
    end
    pcall(function()
        local states={
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.Physics,
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.PlatformStanding
        }
        for _,st in ipairs(states) do
            hum:SetStateEnabled(st,false)
        end
        hum.PlatformStand=false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
    for _,o in ipairs(char:GetDescendants()) do
        if o:IsA("Motor6D") then
            o.Enabled=true
        elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
            pcall(function()
                o:Destroy()
            end)
        end
    end
end

local function findArena()
    local s=workspace:FindFirstChild("Stuff")
    if s then
        local fa=s:FindFirstChild("Fight Arena")
        if fa then
            return fa:FindFirstChild("CombatArena")
        end
    end
    return workspace:FindFirstChild("CombatArena",true)
end

-- HOME TAB
do
    local P=tabPanels[1]
    local wc=MkCard(P,70,1)
    MkLabel(wc,{
        text="Welcome back",
        size=8,
        color=T.MUTED,
        font=Reg,
        sz=UDim2.new(1,-28,0,12),
        pos=UDim2.new(0,14,0,8),
        z=14
    })
    local wnL=MkLabel(wc,{
        text=lp.DisplayName,
        size=20,
        color=T.TEXT,
        font=Bold,
        sz=UDim2.new(1,-28,0,26),
        pos=UDim2.new(0,14,0,22),
        z=14
    })
    local wnH=0
    TC(RunSvc.Heartbeat:Connect(function(dt)
        wnH=(wnH+dt*0.5)%1
        wnL.TextColor3=Color3.fromHSV(wnH,1,1)
    end))
    MkLabel(wc,{
        text="@"..lp.Name.." - ID: "..lp.UserId,
        size=7,
        color=T.DIM,
        font=Reg,
        sz=UDim2.new(1,-28,0,10),
        pos=UDim2.new(0,14,0,52),
        z=14
    })
    local sc=MkCard(P,36,2)
    MkLabel(sc,{
        text=#Players:GetPlayers().." / "..Players.MaxPlayers.." players",
        size=9,
        color=T.MUTED,
        font=Reg,
        sz=UDim2.new(1,-28,0,16),
        pos=UDim2.new(0,14,0,10),
        z=14
    })
    local ulCard=MkCard(P,40,3)
    MkLabel(ulCard,{
        text="UNLOAD ENGINE",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-28,0,10),
        pos=UDim2.new(0,14,0,6),
        z=14
    })
    local ulBtn=MkBtn(ulCard,{
        bg=T.ERR,
        text="UNLOAD ZICO",
        size=9,
        color=T.TEXT,
        sz=UDim2.new(1,-28,0,22),
        pos=UDim2.new(0,14,0,16),
        corner=6,
        bgt=0.1,
        z=15
    })
    local ulC=false
    ulBtn.MouseButton1Click:Connect(function()
        if not ulC then
            ulC=true
            ulBtn.Text="CLICK AGAIN"
            task.delay(3,function()
                ulC=false
                ulBtn.Text="UNLOAD ZICO"
            end)
        else
            for _,c in ipairs(CONNS) do
                pcall(function()
                    c:Disconnect()
                end)
            end
            DoSave()
            Notif("Unload","Goodbye!","warn")
            task.delay(0.5,function()
                pcall(function()
                    GUI:Destroy()
                end)
            end)
        end
    end)
end

-- COMBAT TAB (shortened for space - same functionality)
do
    local P=tabPanels[2]
    local kaOn=false
    local kaAPS=SAVE.kaAPS
    local kaCD=1/kaAPS
    local kaRange=SAVE.kaRange
    local kaSimul=false
    local kaPredict=SAVE.kaPredict or true
    local kaHeadOn=false
    local kaAFling=false
    local safeSpotOn=false
    local kaLast=0
    local kaTStr=SAVE.kaTargets or ""
    local kaFStr=SAVE.kaFriends or ""
    local kaHStr=SAVE.headSit or ""
    local kaTgts={}
    local kaFrns={}
    local kaHds={}
    local kaManualTgt={}
    local kaManualFrn={}
    local originalCFrame=nil
    local safeLockConn=nil

    local function ParseN(s)
        local t={}
        if s=="" then
            return t
        end
        for nm in s:gsub(","," "):gmatch("%S+") do
            local n=nm:lower():match("^%s*(.-)%s*$")
            if n and n~="" then
                t[#t+1]=n
            end
        end
        return t
    end

    local function RefAll()
        kaTgts=ParseN(kaTStr)
        kaFrns=ParseN(kaFStr)
        kaHds=ParseN(kaHStr)
        SAVE.kaTargets=kaTStr
        SAVE.kaFriends=kaFStr
        SAVE.headSit=kaHStr
        task.delay(.5,DoSave)
    end
    RefAll()

    local function matchesAny(arr,name,displayName)
        local nl=name:lower()
        local dn=displayName:lower()
        for _,k in ipairs(arr) do
            if nl==k or dn==k then
                return true
            end
            if nl:find(k,1,true) or dn:find(k,1,true) then
                return true
            end
        end
        return false
    end

    local function IsFriend(p)
        if kaManualFrn[p] then
            return true
        end
        if #kaFrns==0 then
            return false
        end
        return matchesAny(kaFrns,p.Name,p.DisplayName)
    end

    local function IsTarget(p)
        if p==lp then
            return false
        end
        if IsFriend(p) then
            return false
        end
        if kaManualTgt[p] then
            return true
        end
        if #kaTgts==0 then
            return true
        end
        return matchesAny(kaTgts,p.Name,p.DisplayName)
    end

    local function IsHeadSitTarget(p)
        if p==lp then
            return false
        end
        if #kaHds==0 then
            return false
        end
        return matchesAny(kaHds,p.Name,p.DisplayName)
    end

    local function goToSafeSpot()
        local myC=lp.Character
        local myH=myC and myC:FindFirstChild("HumanoidRootPart")
        if not myH then
            return
        end
        originalCFrame=myH.CFrame
        SAVE.safeX=SAFE_CF.Position.X
        SAVE.safeY=SAFE_CF.Position.Y
        SAVE.safeZ=SAFE_CF.Position.Z
        myH.CFrame=SAFE_CF
        myH.AssemblyLinearVelocity=Vector3.zero
        myH.AssemblyAngularVelocity=Vector3.zero
        myH.CanCollide=false
        pcall(function()
            local h=myC:FindFirstChildOfClass("Humanoid")
            if h then
                h.PlatformStand=true
            end
        end)
        if safeLockConn then
            safeLockConn:Disconnect()
        end
        safeLockConn=TC(RunSvc.Heartbeat:Connect(function()
            if not safeSpotOn then
                return
            end
            local c=lp.Character
            local h=c and c:FindFirstChild("HumanoidRootPart")
            if h then
                h.CFrame=SAFE_CF
                h.AssemblyLinearVelocity=Vector3.zero
            end
        end))
    end

    local function disableSafeSpot()
        if safeLockConn then
            safeLockConn:Disconnect()
            safeLockConn=nil
        end
        local myC=lp.Character
        local myH=myC and myC:FindFirstChild("HumanoidRootPart")
        if myH then
            pcall(function()
                local hum=myC:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand=false
                    hum.Sit=false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
            myH.CanCollide=true
            myH.AssemblyLinearVelocity=Vector3.zero
            if originalCFrame then
                myH.CFrame=originalCFrame
                originalCFrame=nil
            end
        end
    end

    local afConn
    local function StartAF()
        if afConn then
            afConn:Disconnect()
        end
        afConn=TC(RunSvc.Heartbeat:Connect(function()
            local c=lp.Character
            if not c then
                return
            end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return
            end
            if hrp.AssemblyLinearVelocity.Magnitude>150 then
                hrp.AssemblyLinearVelocity=hrp.AssemblyLinearVelocity*0.75
            end
            if hrp.AssemblyAngularVelocity.Magnitude>20 then
                hrp.AssemblyAngularVelocity=Vector3.zero
            end
        end))
    end
    local function StopAF()
        if afConn then
            afConn:Disconnect()
            afConn=nil
        end
    end

    local function HitRemoteInvoke(hum,px,py,pz)
        spawn(function()
            pcall(function()
                if RF.Hit then
                    RF.Hit:InvokeServer(unpack({hum,vector.create(px,py,pz)}))
                end
            end)
        end)
    end

    local kaConn
    local targetCache={}
    local cacheTime=0

    local function StartKA()
        if kaConn then
            kaConn:Disconnect()
        end
        kaConn=TC(RunSvc.Heartbeat:Connect(function()
            if not kaOn then
                return
            end
            local mc=lp.Character
            local myHRP=mc and mc:FindFirstChild("HumanoidRootPart")
            if not myHRP then
                return
            end
            local now=clock()
            if now-kaLast<kaCD then
                return
            end
            local px,py,pz=myHRP.Position.X,myHRP.Position.Y,myHRP.Position.Z
            if kaHeadOn then
                for _,p in ipairs(Players:GetPlayers()) do
                    if IsHeadSitTarget(p) and p.Character then
                        local head=p.Character:FindFirstChild("Head")
                        if head and (head.Position-myHRP.Position).Magnitude<=kaRange then
                            myHRP.CFrame=CFrame.new(head.Position+Vector3.new(0,3.5,0))
                        end
                    end
                end
            end
            local targets={}
            local hitAny=false
            if now-cacheTime>0.1 then
                targetCache={}
                for _,p in ipairs(Players:GetPlayers()) do
                    if not IsTarget(p) then
                        continue
                    end
                    local c=p.Character
                    if not c then
                        continue
                    end
                    local hu=c:FindFirstChild("Humanoid")
                    local hrp=c:FindFirstChild("HumanoidRootPart")
                    if hu and hrp and hu.Health>0 then
                        targetCache[p]={hu,hrp}
                    end
                end
                cacheTime=now
            end
            if kaSimul then
                for p,data in pairs(targetCache) do
                    local hu,hrp=data[1],data[2]
                    if (hrp.Position-myHRP.Position).Magnitude<=kaRange then
                        insert(targets,data)
                        hitAny=true
                    end
                end
            else
                local cls,mind=nil,math.huge
                for p,data in pairs(targetCache) do
                    local hu,hrp=data[1],data[2]
                    local d=(hrp.Position-myHRP.Position).Magnitude
                    if d<=kaRange and d<mind then
                        mind=d
                        cls=data
                    end
                end
                if cls then
                    insert(targets,cls)
                    hitAny=true
                end
            end
            if hitAny then
                spawn(function()
                    for _,tData in ipairs(targets) do
                        local hu,hrp=tData[1],tData[2]
                        if kaPredict and hrp then
                            local vel=hrp.AssemblyLinearVelocity
                            local predictPos=hrp.Position+vel*(kaCD*0.5)
                            HitRemoteInvoke(hu,predictPos.X,predictPos.Y,predictPos.Z)
                        else
                            HitRemoteInvoke(hu,px,py,pz)
                        end
                    end
                end)
                kaLast=now
            end
        end))
    end

    local function StopKA()
        if kaConn then
            kaConn:Disconnect()
            kaConn=nil
        end
        targetCache={}
    end

    MkSep(P,"Kill Aura",1)
    local _,_,kSet=MkToggle(P,"KILL AURA",2,
        function()
            kaOn=true
            StartKA()
            Notif("Kill Aura","Active","ok")
        end,
        function()
            kaOn=false
            StopKA()
            Notif("Kill Aura","Off","")
        end
    )
    RegKB("Kill Aura",Enum.KeyCode.K,function()
        kaOn=not kaOn
        kSet(kaOn)
        if kaOn then
            StartKA()
            Notif("Kill Aura","Active","ok")
        else
            StopKA()
            Notif("Kill Aura","Off","")
        end
    end)
    
    MkSlider(P,"RANGE",5,500,SAVE.kaRange,3,function(v)
        kaRange=v
        SAVE.kaRange=v
        task.delay(.5,DoSave)
    end)
    MkSlider(P,"APS",1,15000,SAVE.kaAPS,4,function(v)
        kaAPS=v
        kaCD=1/v
        SAVE.kaAPS=v
        task.delay(.5,DoSave)
    end)
    
    -- Continue with rest of combat features...
    MkToggle(P,"SIMULTANEOUS",5,
        function()
            kaSimul=true
            Notif("Simultaneous","ON","ok")
        end,
        function()
            kaSimul=false
            Notif("Simultaneous","OFF","")
        end
    )
    
    local _,tgBox=MkTBox(P,"TARGETS","player1 player2",6,SAVE.targets)
    tgBox.FocusLost:Connect(function()
        SAVE.targets=tgBox.Text
        parseTargets(SAVE.targets)
        task.delay(.5,DoSave)
    end)
    
    local _,frBox=MkTBox(P,"FRIENDS","friend1 friend2",7,SAVE.friends)
    frBox.FocusLost:Connect(function()
        SAVE.friends=frBox.Text
        parseFriends(SAVE.friends)
        task.delay(.5,DoSave)
    end)
    
    MkSep(P,"Grab",8)
    local function fireGrab()
        pcall(function()
            if RF.Grab then
                RF.Grab:InvokeServer()
            end
        end)
    end
    RegKB("Grab",Enum.KeyCode.G,fireGrab)
    
    MkToggle(P,"SPAM GRAB",9,
        function()
            sgOn=true
            task.spawn(function()
                while sgOn do
                    fireGrab()
                    task.wait()
                end
            end)
            Notif("Spam Grab","Active","ok")
        end,
        function()
            sgOn=false
            Notif("Spam Grab","Off","")
        end
    )
    
    MkSep(P,"Defense",10)
    local arOn=false
    local arConn
    local arCharConn
    local function startAR()
        arConn=TC(RunSvc.Heartbeat:Connect(function()
            local c=lp.Character
            if c then
                cleanRag(c)
            end
        end))
        arCharConn=TC(lp.CharacterAdded:Connect(function(c)
            task.wait(.3)
            cleanRag(c)
        end))
        if lp.Character then
            cleanRag(lp.Character)
        end
    end
    MkToggle(P,"ANTI RAGDOLL",11,
        function()
            arOn=true
            startAR()
            Notif("Anti Ragdoll","Active","ok")
        end,
        function()
            arOn=false
            if arConn then
                arConn:Disconnect()
                arConn=nil
            end
            if arCharConn then
                arCharConn:Disconnect()
                arCharConn=nil
            end
            Notif("Anti Ragdoll","Off","")
        end
    )
    
    local invOn=false
    local invConn
    local function startInv()
        invConn=TC(RunSvc.Heartbeat:Connect(function()
            if not invOn then
                return
            end
            local c=lp.Character
            if not c then
                return
            end
            local hum=c:FindFirstChildOfClass("Humanoid")
            if not hum then
                return
            end
            if hum.PlatformStand then
                hum.PlatformStand=false
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
                local hrp=c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity=Vector3.zero
                end
            end
            for _,st in ipairs({Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.Physics,Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.PlatformStanding}) do
                pcall(function()
                    hum:SetStateEnabled(st,false)
                end)
            end
            for _,o in ipairs(c:GetDescendants()) do
                if o:IsA("Motor6D") then
                    o.Enabled=true
                elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
                    pcall(function()
                        o:Destroy()
                    end)
                end
            end
        end))
    end
    MkToggle(P,"INVINCIBLE",12,
        function()
            invOn=true
            startInv()
            Notif("Invincible","Active","ok")
        end,
        function()
            invOn=false
            if invConn then
                invConn:Disconnect()
                invConn=nil
            end
            Notif("Invincible","Off","")
        end
    )
    RegKB("Invincible",Enum.KeyCode.I,function()
        invOn=not invOn
        if invOn then
            startInv()
            Notif("Invincible","Active","ok")
        else
            if invConn then
                invConn:Disconnect()
                invConn=nil
            end
            Notif("Invincible","Off","")
        end
    end)
end

-- RP COLOR TAB (with scroller fix)
do
    local P=tabPanels[3]
    local rpOn=false
    local rpConn
    local rpSpd=SAVE.rpSpeed
    local rpMode="rainbow"
    local bioPhrasesOn=false
    local _phraseTask=nil
    local _currentPhrase=""
    local _userPhrases={}
    local nameTypewriter=SAVE.nameTypewriter
    local bioTypeSpeed=SAVE.bioTypeSpeed
    local rpNameIdx=1

    local function parseUserPhrases(s)
        _userPhrases={}
        for line in (s or ""):gmatch("[^\n]+") do
            local t=line:match("^%s*(.-)%s*$")
            if t~="" then
                insert(_userPhrases,t)
            end
        end
        if #_userPhrases==0 then
            insert(_userPhrases,"ZICO!")
        end
    end
    parseUserPhrases(SAVE.phrases)

    local function startPhrases()
        if _phraseTask then
            task.cancel(_phraseTask)
        end
        _phraseTask=spawn(function()
            while bioPhrasesOn do
                local s=_userPhrases[random(1,#_userPhrases)]
                local t=""
                local delay=1/(bioTypeSpeed or 10)
                for u=1,#s do
                    if not bioPhrasesOn then
                        break
                    end
                    t=string.sub(s,1,u)
                    _currentPhrase=t
                    wait(delay)
                end
                wait(0.05)
                _currentPhrase=""
            end
        end)
    end

    local function stopPhrases()
        bioPhrasesOn=false
        if _phraseTask then
            task.cancel(_phraseTask)
            _phraseTask=nil
        end
        _currentPhrase=""
    end

    local function startRP()
        if rpConn then
            rpConn:Disconnect()
        end
        local accB=0
        local accR=0
        local bioT=0
        local rpT=0
        local nameT=0
        local PHASE=0.22
        rpConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not rpOn then
                return
            end
            local spd=rpSpd*0.05
            accB=accB+dt*spd
            accR=accR+dt*spd
            bioT=bioT+dt
            rpT=rpT+dt
            nameT=nameT+dt
            if bioT>=0.06 and bioPhrasesOn and _currentPhrase~="" then
                bioT=0
                pcall(function()
                    if RF.UpdateBio then
                        RF.UpdateBio:FireServer(_currentPhrase)
                    end
                end)
            elseif bioT>=0.06 then
                bioT=0
            end
            if nameTypewriter and nameT>=0.1 then
                nameT=0
                local fullName=lp.DisplayName
                pcall(function()
                    if RF.UpdateRPName then
                        RF.UpdateRPName:FireServer(string.sub(fullName,1,rpNameIdx))
                    end
                end)
                rpNameIdx=rpNameIdx>=#fullName and 1 or rpNameIdx+1
            end
            if rpT>=0.05 then
                rpT=0
                local cB,cR
                if rpMode=="rainbow" then
                    cB=Color3.fromHSV((accB+PHASE)%1,0.65,0.98)
                    cR=Color3.fromHSV(accR%1,0.65,0.98)
                elseif rpMode=="bw" then
                    local v=(math.sin(accB*6)+1)/2
                    cB=Color3.new(v,v,v)
                    cR=cB
                elseif rpMode=="strobe" then
                    local s=random(0,1)==1
                    cB=s and Color3.new(1,1,1) or Color3.new(0,0,0)
                    cR=cB
                elseif rpMode=="pastel" then
                    cB=Color3.fromHSV((accB+PHASE)%1,0.35,0.99)
                    cR=Color3.fromHSV(accR%1,0.35,0.99)
                elseif rpMode=="neon" then
                    cB=Color3.fromHSV((accB+PHASE)%1,1,1)
                    cR=Color3.fromHSV(accR%1,1,1)
                elseif rpMode=="fire" then
                    local h=(accB*0.1)%0.15
                    cB=Color3.fromHSV(h,0.9,1)
                    cR=Color3.fromHSV((accR*0.1)%0.15,0.9,1)
                elseif rpMode=="ice" then
                    local h=0.55+(accB*0.05)%0.1
                    cB=Color3.fromHSV(h,0.7,0.95)
                    cR=Color3.fromHSV(0.55+(accR*0.05)%0.1,0.7,0.95)
                elseif rpMode=="toxic" then
                    local h=0.3+(accB*0.08)%0.15
                    cB=Color3.fromHSV(h,0.85,0.95)
                    cR=Color3.fromHSV(0.3+(accR*0.08)%0.15,0.85,0.95)
                elseif rpMode=="galaxy" then
                    local h=(accB*0.2)%1
                    cB=Color3.fromHSV(h,0.8,0.9)
                    cR=Color3.fromHSV((accR*0.2)%1,0.8,0.9)
                elseif rpMode=="sunset" then
                    local h=(accB*0.12)%0.25
                    cB=Color3.fromHSV(h,0.8,1)
                    cR=Color3.fromHSV((accR*0.12)%0.25,0.8,1)
                elseif rpMode=="ocean" then
                    local h=0.5+(accB*0.06)%0.2
                    cB=Color3.fromHSV(h,0.7,0.9)
                    cR=Color3.fromHSV(0.5+(accR*0.06)%0.2,0.7,0.9)
                elseif rpMode=="matrix" then
                    local g=random()>0.7 and 1 or 0.2
                    cB=Color3.fromRGB(0,g*255,0)
                    cR=cB
                elseif rpMode=="vaporwave" then
                    local h=(accB*0.15)%1
                    cB=Color3.fromHSV(h,0.6,1)
                    cR=Color3.fromHSV((accR*0.15)%1,0.6,1)
                elseif rpMode=="crimson" then
                    local v=(math.sin(accB*4)+1)/2
                    cB=Color3.fromRGB(255,v*100,v*100)
                    cR=cB
                elseif rpMode=="gold" then
                    local v=(math.sin(accB*3)+1)/2
                    cB=Color3.fromRGB(255,200+v*55,0)
                    cR=cB
                elseif rpMode=="r&b" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,0,0)
                    cR=cB
                elseif rpMode=="g&b" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,0)
                    cR=cB
                elseif rpMode=="b&w" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
                    cR=cB
                elseif rpMode=="p&b" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(128,0,255) or Color3.fromRGB(0,0,255)
                    cR=cB
                elseif rpMode=="y&b" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(255,255,0) or Color3.fromRGB(0,0,0)
                    cR=cB
                elseif rpMode=="lr&w" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(255,150,150) or Color3.fromRGB(255,255,255)
                    cR=cB
                elseif rpMode=="w&p" then
                    local s=random(0,1)==1
                    cB=s and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,0,255)
                    cR=cB
                end
                if cB then
                    pcall(function()
                        if RF.UpdateBioColor then
                            RF.UpdateBioColor:FireServer(cB)
                        end
                    end)
                end
                if cR then
                    pcall(function()
                        if RF.UpdateRPColor then
                            RF.UpdateRPColor:FireServer(cR)
                        end
                    end)
                end
            end
        end))
    end

    local _,_,rpSet=MkToggle(P,"RP COLOR",1,
        function()
            rpOn=true
            startRP()
            Notif("RP Color","Active","ok")
        end,
        function()
            rpOn=false
            if rpConn then
                rpConn:Disconnect()
                rpConn=nil
            end
            Notif("RP Color","Off","")
        end
    )
    RegKB("RP Color",Enum.KeyCode.R,function()
        rpOn=not rpOn
        rpSet(rpOn)
        if rpOn then
            startRP()
            Notif("RP Color","Active","ok")
        else
            if rpConn then
                rpConn:Disconnect()
                rpConn=nil
            end
            Notif("RP Color","Off","")
        end
    end)
    MkSlider(P,"COLOR SPEED",1,100,SAVE.rpSpeed,2,function(v)
        rpSpd=v
        SAVE.rpSpeed=v
        task.delay(.5,DoSave)
        if rpOn then
            startRP()
        end
    end)

    -- FIXED: SCROLLABLE COLOR MODES
    local modeCard=MkCard(P,180,3)
    MkLabel(modeCard,{
        text="COLOR MODE",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })

    local modeScroll=Instance.new("ScrollingFrame",modeCard)
    modeScroll.Size=UDim2.new(1,-24,0,150)
    modeScroll.Position=UDim2.new(0,12,0,18)
    modeScroll.BackgroundTransparency=1
    modeScroll.ScrollBarThickness=2
    modeScroll.ScrollBarImageColor3=T.DIM
    modeScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    modeScroll.CanvasSize=UDim2.new(0,0,0,0)
    modeScroll.BorderSizePixel=0
    modeScroll.ClipsDescendants=true
    LL(modeScroll,3)
    LP(modeScroll,0,0,2,2)

    local modes={
        "Rainbow","B+W","Neon","Pastel","Strobe","Fire","Ice","Toxic","Galaxy","Sunset","Ocean","Matrix","Vaporwave","Crimson","Gold",
        "R&B","G&B","B&W","P&B","Y&B","LR&W","W&P"
    }
    local modeKeys={
        "rainbow","bw","neon","pastel","strobe","fire","ice","toxic","galaxy","sunset","ocean","matrix","vaporwave","crimson","gold",
        "r&b","g&b","b&w","p&b","y&b","lr&w","w&p"
    }

    local mBtns={}
    for i,lbl in ipairs(modes) do
        local key=modeKeys[i]
        local active=(key==rpMode)
        local b=MkBtn(modeScroll,{
            text=lbl,
            size=7,
            bg=active and T.ACCENT or T.RAISED,
            color=active and T.BG or T.TEXT,
            sz=UDim2.new(1,-4,0,24),
            corner=4,
            bgt=0,
            order=i,
            z=15
        })
        b.MouseButton1Click:Connect(function()
            rpMode=key
            for _,bt in ipairs(mBtns) do
                Tw(bt.b,{BackgroundColor3=T.RAISED,TextColor3=T.TEXT},0.14)
            end
            Tw(b,{BackgroundColor3=T.ACCENT,TextColor3=T.BG},0.14)
            if rpOn then
                startRP()
            end
        end)
        insert(mBtns,{b=b,k=key})
    end

    MkToggle(P,"NAME TYPEWRITER",4,
        function()
            nameTypewriter=true
            SAVE.nameTypewriter=true
            task.delay(.5,DoSave)
            rpNameIdx=1
            Notif("Name Typewriter","Active","ok")
        end,
        function()
            nameTypewriter=false
            SAVE.nameTypewriter=false
            task.delay(.5,DoSave)
            pcall(function()
                if RF.UpdateRPName then
                    RF.UpdateRPName:FireServer(lp.DisplayName)
                end
            end)
            Notif("Name Typewriter","Off","")
        end
    )
    MkToggle(P,"BIO PHRASES",5,
        function()
            bioPhrasesOn=true
            startPhrases()
            Notif("Bio Phrases","Active","ok")
        end,
        function()
            stopPhrases()
            Notif("Bio Phrases","Off","")
        end
    )
    MkSlider(P,"BIO TYPE SPEED",1,700,SAVE.bioTypeSpeed,6,function(v)
        bioTypeSpeed=v
        SAVE.bioTypeSpeed=v
        task.delay(.5,DoSave)
    end)
    local phCard=MkCard(P,90,7)
    MkLabel(phCard,{
        text="PHRASES (one per line)",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local phBox=Instance.new("TextBox",phCard)
    phBox.Size=UDim2.new(1,-24,0,62)
    phBox.Position=UDim2.new(0,12,0,20)
    phBox.BackgroundColor3=T.RAISED
    phBox.BackgroundTransparency=0.2
    phBox.FontFace=Reg
    phBox.TextSize=8
    phBox.TextColor3=T.TEXT
    phBox.PlaceholderColor3=T.DIM
    phBox.PlaceholderText="One phrase per line..."
    phBox.Text=SAVE.phrases
    phBox.ClearTextOnFocus=false
    phBox.BorderSizePixel=0
    phBox.TextXAlignment=Enum.TextXAlignment.Left
    phBox.TextYAlignment=Enum.TextYAlignment.Top
    phBox.MultiLine=true
    phBox.ZIndex=15
    Cnr(phBox,5)
    LP(phBox,4,4,2,2)
    local phS=Strk(phBox,T.BORDER,1,0.4)
    phBox.Focused:Connect(function()
        Tw(phS,{Transparency=0,Color=T.ACCENT},0.14)
    end)
    phBox.FocusLost:Connect(function()
        Tw(phS,{Transparency=0.4,Color=T.BORDER},0.14)
        SAVE.phrases=phBox.Text
        parseUserPhrases(SAVE.phrases)
        task.delay(.5,DoSave)
    end)
end

-- MOVE TAB
do
    local P=tabPanels[4]
    _G.ZICO_tpwOn=false
    _G.ZICO_tpwSpd=SAVE.tpwSpeed
    local tpwConn
    local function startTPW()
        if tpwConn then
            tpwConn:Disconnect()
        end
        tpwConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not _G.ZICO_tpwOn then
                return
            end
            local ch=lp.Character
            if not ch then
                return
            end
            local hrp=ch:FindFirstChild("HumanoidRootPart")
            local hum=ch:FindFirstChildWhichIsA("Humanoid")
            if not (hrp and hum and hum.Health>0) then
                return
            end
            local md=hum.MoveDirection
            if md.Magnitude<0.01 then
                return
            end
            pcall(function()
                ch:TranslateBy(md.Unit*_G.ZICO_tpwSpd*dt*10)
            end)
        end))
    end
    local _,_,tpwSet=MkToggle(P,"TP WALK",1,
        function()
            _G.ZICO_tpwOn=true
            startTPW()
            Notif("TP Walk","Active","ok")
        end,
        function()
            _G.ZICO_tpwOn=false
            if tpwConn then
                tpwConn:Disconnect()
                tpwConn=nil
            end
            Notif("TP Walk","Off","")
        end
    )
    RegKB("TP Walk",Enum.KeyCode.T,function()
        _G.ZICO_tpwOn=not _G.ZICO_tpwOn
        tpwSet(_G.ZICO_tpwOn)
        if _G.ZICO_tpwOn then
            startTPW()
            Notif("TP Walk","Active","ok")
        else
            if tpwConn then
                tpwConn:Disconnect()
                tpwConn=nil
            end
            Notif("TP Walk","Off","")
        end
    end)
    MkSlider(P,"TP SPEED",1,80,SAVE.tpwSpeed,2,function(v)
        _G.ZICO_tpwSpd=v
        SAVE.tpwSpeed=v
        task.delay(.5,DoSave)
    end)
    
    _G.ZICO_flyOn=false
    _G.ZICO_flySpd=SAVE.flySpeed
    local flyConn
    local fbv,fbg
    local function startFly()
        local char=lp.Character
        if not char then
            return
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand=true
        end
        fbv=Instance.new("BodyVelocity",hrp)
        fbv.MaxForce=Vector3.new(1e5,1e5,1e5)
        fbv.Velocity=Vector3.zero
        fbg=Instance.new("BodyGyro",hrp)
        fbg.MaxTorque=Vector3.new(1e5,1e5,1e5)
        fbg.D=150
        _G.ZICO_flyOn=true
        flyConn=TC(RunSvc.RenderStepped:Connect(function()
            if not _G.ZICO_flyOn then
                return
            end
            local c=workspace.CurrentCamera
            if not c then
                return
            end
            local v=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                v=v+c.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                v=v-c.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                v=v-c.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                v=v+c.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                v=v+Vector3.new(0,1,0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                v=v-Vector3.new(0,1,0)
            end
            if v.Magnitude>0 then
                v=v.Unit*_G.ZICO_flySpd
            end
            if fbv and fbv.Parent then
                fbv.Velocity=v
            end
            if fbg and fbg.Parent then
                fbg.CFrame=c.CFrame
            end
        end))
    end
    local function stopFly()
        _G.ZICO_flyOn=false
        if flyConn then
            flyConn:Disconnect()
            flyConn=nil
        end
        pcall(function()
            if fbv then
                fbv:Destroy()
            end
        end)
        pcall(function()
            if fbg then
                fbg:Destroy()
            end
        end)
        pcall(function()
            lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand=false
        end)
    end
    local _,_,flySet=MkToggle(P,"FLY",3,
        function()
            startFly()
            Notif("Fly","Active","ok")
        end,
        function()
            stopFly()
            Notif("Fly","Off","")
        end
    )
    MkSlider(P,"FLY SPEED",1,300,SAVE.flySpeed,4,function(v)
        _G.ZICO_flySpd=v
        SAVE.flySpeed=v
        task.delay(.5,DoSave)
    end)
    MkSlider(P,"WALK SPEED",1,500,16,5,function(v)
        pcall(function()
            lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed=v
        end)
    end)
    MkSlider(P,"JUMP POWER",1,500,50,6,function(v)
        pcall(function()
            local h=lp.Character:FindFirstChildOfClass("Humanoid")
            h.UseJumpPower=true
            h.JumpPower=v
        end)
    end)
    MkSlider(P,"GRAVITY",1,600,196,7,function(v)
        pcall(function()
            workspace.Gravity=v
        end)
    end)
    
    local noclipOn=false
    MkToggle(P,"NOCLIP",8,
        function()
            noclipOn=true
            Notif("Noclip","Active","ok")
        end,
        function()
            noclipOn=false
            Notif("Noclip","Off","")
        end
    )
    TC(RunSvc.Stepped:Connect(function()
        if not noclipOn then
            return
        end
        local c=lp.Character
        if not c then
            return
        end
        for _,v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.CanCollide=false
                end)
            end
        end
    end))
    RegKB("Noclip",Enum.KeyCode.N,function()
        noclipOn=not noclipOn
        Notif("Noclip",noclipOn and "Active" or "Off","")
    end)
    
    local ijOn=false
    MkToggle(P,"INFINITE JUMP",9,
        function()
            ijOn=true
        end,
        function()
            ijOn=false
        end
    )
    TC(UIS.JumpRequest:Connect(function()
        if not ijOn then
            return
        end
        local c=lp.Character
        if not c then
            return
        end
        local h=c:FindFirstChildOfClass("Humanoid")
        if not h then
            return
        end
        pcall(function()
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end))
end

-- TARGET TAB
do
    local P=tabPanels[5]
    local _,stBox=MkTBox(P,"STRAFE TARGET","player name",1,SAVE.strafeTarget)
    stBox.FocusLost:Connect(function()
        SAVE.strafeTarget=stBox.Text
        task.delay(.5,DoSave)
    end)
    
    local strafeOn=false
    local strafeAngle=0
    local strafeConn
    local strafeRadius=SAVE.strafeRadius
    local strafeSpeed=SAVE.strafeSpeed
    local strafeOffset=SAVE.strafeOffset
    
    local function startStrafe()
        if strafeConn then
            strafeConn:Disconnect()
        end
        strafeAngle=0
        strafeConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not strafeOn then
                return
            end
            local tname=stBox.Text
            if tname=="" then
                return
            end
            local tgt=findPlayer(tname)
            if not tgt or not tgt.Character then
                return
            end
            local tHRP=tgt.Character:FindFirstChild("HumanoidRootPart")
            if not tHRP then
                return
            end
            local mc=lp.Character
            local mHRP=mc and mc:FindFirstChild("HumanoidRootPart")
            if not mHRP then
                return
            end
            local tPos=tHRP.Position
            strafeAngle=strafeAngle+strafeSpeed*dt
            local newPos=Vector3.new(tPos.X+math.cos(strafeAngle)*strafeRadius,tPos.Y+strafeOffset,tPos.Z+math.sin(strafeAngle)*strafeRadius)
            mHRP.CFrame=CFrame.new(newPos,Vector3.new(tPos.X,mHRP.Position.Y,tPos.Z))
            mHRP.AssemblyLinearVelocity=Vector3.zero
        end))
    end
    MkToggle(P,"STRAFE",2,
        function()
            strafeOn=true
            startStrafe()
            Notif("Strafe","Active","ok")
        end,
        function()
            strafeOn=false
            if strafeConn then
                strafeConn:Disconnect()
                strafeConn=nil
            end
            Notif("Strafe","Off","")
        end
    )
    MkSlider(P,"RADIUS",2,30,10,3,function(v)
        strafeRadius=v
    end)
    MkSlider(P,"SPEED",1,20,4,4,function(v)
        strafeSpeed=v
    end)
    MkSlider(P,"OFFSET",-15,10,-2,5,function(v)
        strafeOffset=v
    end)
    
    local _,orbBox=MkTBox(P,"ORBIT TARGET","player name",6,SAVE.orbTarget)
    orbBox.FocusLost:Connect(function()
        SAVE.orbTarget=orbBox.Text
        task.delay(.5,DoSave)
    end)
    
    local orbOn=false
    local orbAngle=0
    local orbConn
    local orbRadius=SAVE.orbRadius
    local orbSpeed=SAVE.orbSpeed
    local orbHeight=SAVE.orbHeight
    
    local function startOrb()
        if orbConn then
            orbConn:Disconnect()
        end
        orbAngle=0
        orbConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not orbOn then
                return
            end
            local tname=orbBox.Text
            if tname=="" then
                return
            end
            local tgt=findPlayer(tname)
            if not tgt or not tgt.Character then
                return
            end
            local tHRP=tgt.Character:FindFirstChild("HumanoidRootPart")
            if not tHRP then
                return
            end
            local mc=lp.Character
            local mHRP=mc and mc:FindFirstChild("HumanoidRootPart")
            if not mHRP then
                return
            end
            orbAngle=orbAngle+orbSpeed*dt
            local tp=tHRP.Position
            mHRP.CFrame=CFrame.new(tp+Vector3.new(math.cos(orbAngle)*orbRadius,orbHeight,math.sin(orbAngle)*orbRadius),tp)
            mHRP.AssemblyLinearVelocity=Vector3.zero
        end))
    end
    local _,_,orbSet=MkToggle(P,"ORBIT",7,
        function()
            orbOn=true
            startOrb()
            Notif("Orbit","Active","ok")
        end,
        function()
            orbOn=false
            if orbConn then
                orbConn:Disconnect()
                orbConn=nil
            end
            Notif("Orbit","Off","")
        end
    )
    RegKB("Orbit",Enum.KeyCode.O,function()
        orbOn=not orbOn
        orbSet(orbOn)
        if orbOn then
            startOrb()
            Notif("Orbit","Active","ok")
        else
            if orbConn then
                orbConn:Disconnect()
                orbConn=nil
            end
            Notif("Orbit","Off","")
        end
    end)
    MkSlider(P,"ORB RADIUS",2,50,10,8,function(v)
        orbRadius=v
    end)
    MkSlider(P,"ORB SPEED",1,1000,5,9,function(v)
        orbSpeed=v
    end)
    MkSlider(P,"HEIGHT",-10,10,2,10,function(v)
        orbHeight=v
    end)
end

-- GHOST TAB
do
    local P=tabPanels[6]
    local ghostOn=false
    local _ghostDecoy=nil
    local _ghostConn=nil
    local _diedConn=nil
    local GHOST_POS=Vector3.new(0,10000,0)

    local function getJoints(model)
        local t={}
        for _,v in ipairs(model:GetDescendants()) do
            if v:IsA("Motor6D") then
                t[v.Name]=v
            end
        end
        return t
    end
    
    local function setHidden(char,h)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier=h and 1 or 0
                if v.Name=="HumanoidRootPart" then
                    v.Transparency=1
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency=h and 1 or 0
            end
        end
    end
    
    local function stopGhost(noTP)
        if not ghostOn then
            return
        end
        ghostOn=false
        if _ghostConn then
            _ghostConn:Disconnect()
            _ghostConn=nil
        end
        if _diedConn then
            _diedConn:Disconnect()
            _diedConn=nil
        end
        local char=lp.Character
        if char then
            setHidden(char,false)
            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand=false
                hum.AutoRotate=true
            end
            if hrp and _ghostDecoy and _ghostDecoy.Parent and not noTP then
                local dHRP=_ghostDecoy:FindFirstChild("HumanoidRootPart")
                if dHRP then
                    task.wait()
                    hrp.CFrame=dHRP.CFrame+Vector3.new(0,2,0)
                    hrp.AssemblyLinearVelocity=Vector3.zero
                end
            end
            workspace.CurrentCamera.CameraSubject=hum or char
        end
        if _ghostDecoy then
            _ghostDecoy:Destroy()
            _ghostDecoy=nil
        end
        if gSet then
            gSet(false)
        end
    end
    
    local function startGhost()
        if ghostOn then
            return
        end
        local char=lp.Character
        if not char then
            return
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then
            return
        end
        char.Archivable=true
        local clone=char:Clone()
        char.Archivable=false
        clone.Name="Ghost"
        for _,v in ipairs(clone:GetDescendants()) do
            if v:IsA("BaseScript") then
                v:Destroy()
            end
        end
        for _,v in ipairs(clone:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide=true
                v.Massless=false
                if v.Name~="HumanoidRootPart" then
                    v.Transparency=0.5
                else
                    v.Transparency=1
                end
            elseif v:IsA("Accessory") then
                for _,p in ipairs(v:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency=0.5
                        p.CanCollide=false
                    end
                end
            end
        end
        local clHum=clone:FindFirstChildOfClass("Humanoid")
        local dHRP=clone:FindFirstChild("HumanoidRootPart")
        if not clHum or not dHRP then
            clone:Destroy()
            return
        end
        clHum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
        local ani=clHum:FindFirstChildOfClass("Animator")
        if ani then
            ani:Destroy()
        end
        dHRP.CFrame=hrp.CFrame
        clone.Parent=workspace
        _ghostDecoy=clone
        ghostOn=true
        setHidden(char,true)
        hrp.CFrame=CFrame.new(GHOST_POS+Vector3.new(0,5,0))
        hrp.AssemblyLinearVelocity=Vector3.zero
        workspace.CurrentCamera.CameraSubject=dHRP
        _diedConn=hum.Died:Connect(function()
            stopGhost(true)
        end)
        local rJ=getJoints(char)
        local fJ=getJoints(clone)
        _ghostConn=TC(RunSvc.Heartbeat:Connect(function()
            if not ghostOn or not _ghostDecoy or not _ghostDecoy.Parent then
                stopGhost()
                return
            end
            hrp.CFrame=CFrame.new(GHOST_POS+Vector3.new(0,5,0))
            hrp.AssemblyLinearVelocity=Vector3.zero
            local mv=Vector3.zero
            local cam=workspace.CurrentCamera
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                mv=mv+cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                mv=mv-cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                mv=mv-cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                mv=mv+cam.CFrame.RightVector
            end
            local md=Vector3.new(mv.X,0,mv.Z)
            if md.Magnitude>0 then
                md=md.Unit
            end
            hum:Move(md,false)
            clHum:Move(md,false)
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                hum.Jump=true
                clHum.Jump=true
            end
            for n,r in pairs(rJ) do
                local f=fJ[n]
                if f then
                    f.Transform=r.Transform
                end
            end
        end))
        if gSet then
            gSet(true)
        end
    end
    
    local _,_,gSet=MkToggle(P,"GHOST",1,
        function()
            startGhost()
            Notif("Ghost","Active","ok")
        end,
        function()
            stopGhost()
            Notif("Ghost","Off","")
        end
    )
    RegKB("Ghost",Enum.KeyCode.Q,function()
        if ghostOn then
            stopGhost()
        else
            startGhost()
        end
    end)
    lp.CharacterAdded:Connect(function()
        if ghostOn then
            task.wait(0.5)
            stopGhost(true)
        end
    end)
end

-- GLITCH TAB
do
    local P=tabPanels[7]
    local function setupNoRag(char)
        pcall(function()
            local h=char:WaitForChild("Humanoid",4)
            if not h then
                return
            end
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        end)
    end
    pcall(function()
        setupNoRag(lp.Character or lp.CharacterAdded:Wait())
    end)
    lp.CharacterAdded:Connect(setupNoRag)
    
    local gfOn=false
    local gfConn
    local gfSet
    local glitchR=4
    local gtBox
    
    do
        local card=MkCard(P,48,1)
        MkLabel(card,{
            text="GLITCH",
            size=8,
            color=T.TEXT,
            font=Semi,
            sz=UDim2.new(1,-62,0,16),
            pos=UDim2.new(0,14,0.5,-8),
            z=14
        })
        local track=Instance.new("TextButton",card)
        track.Size=UDim2.new(0,38,0,18)
        track.Position=UDim2.new(1,-48,0.5,-9)
        track.BackgroundColor3=T.RAISED
        track.BackgroundTransparency=0.1
        track.Text=""
        track.AutoButtonColor=false
        track.BorderSizePixel=0
        track.ZIndex=15
        Cnr(track,10)
        Strk(track,T.BORDER,1,0.4)
        local thumb=Instance.new("Frame",track)
        thumb.Size=UDim2.new(0,12,0,12)
        thumb.Position=UDim2.new(0,3,0.5,-6)
        thumb.BackgroundColor3=T.OFF
        thumb.BorderSizePixel=0
        thumb.ZIndex=16
        Cnr(thumb,8)
        gfSet=function(s)
            Tw(thumb,{
                Position=s and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
                BackgroundColor3=s and T.ON or T.OFF
            },0.25,Enum.EasingStyle.Back)
            Tw(track,{BackgroundColor3=s and Color3.fromRGB(35,45,55) or T.RAISED},0.18)
        end
        track.MouseButton1Click:Connect(function()
            gfOn=not gfOn
            gfSet(gfOn)
            if gfOn then
                Notif("Glitch","Active","warn")
                gfConn=TC(RunSvc.RenderStepped:Connect(function()
                    if not gfOn then
                        return
                    end
                    local tname=gtBox and gtBox.Text or ""
                    local tgt=tname~="" and findPlayer(tname) or nil
                    if not tgt then
                        local mc=lp.Character
                        if not mc then
                            return
                        end
                        local mH=mc:FindFirstChild("HumanoidRootPart")
                        if not mH then
                            return
                        end
                        local best,bestD=nil,math.huge
                        for _,p in ipairs(Players:GetPlayers()) do
                            if not isTarget(p) then
                                continue
                            end
                            local c=p.Character
                            if not c then
                                continue
                            end
                            local h=c:FindFirstChild("HumanoidRootPart")
                            if not h then
                                continue
                            end
                            local d=(h.Position-mH.Position).Magnitude
                            if d<bestD then
                                bestD=d
                                best=p
                            end
                        end
                        tgt=best
                    end
                    if not tgt or not tgt.Character then
                        return
                    end
                    local tH=tgt.Character:FindFirstChild("HumanoidRootPart")
                    if not tH then
                        return
                    end
                    local mc=lp.Character
                    if not mc then
                        return
                    end
                    local mH=mc:FindFirstChild("HumanoidRootPart")
                    if not mH then
                        return
                    end
                    mH.AssemblyLinearVelocity=Vector3.zero
                    for _=1,8 do
                        mH.CFrame=tH.CFrame*CFrame.new(random(-glitchR,glitchR),random(-2,2),random(-glitchR,glitchR))*CFrame.Angles(rad(random(-360,360)),rad(random(-360,360)),rad(random(-360,360)))
                    end
                end))
            else
                if gfConn then
                    gfConn:Disconnect()
                    gfConn=nil
                end
                Notif("Glitch","Stopped","")
            end
        end)
    end
    
    do
        local _,gtB=MkTBox(P,"TARGET","player name",2)
        gtBox=gtB
    end
    MkSlider(P,"INTENSITY",1,20,4,3,function(v)
        glitchR=v
    end)
    RegKB("Stop Glitch",Enum.KeyCode.J,function()
        if gfOn then
            gfOn=false
            gfSet(false)
            if gfConn then
                gfConn:Disconnect()
                gfConn=nil
            end
            Notif("Glitch","Stopped","warn")
        end
    end)
end

-- HEADLESS TAB
do
    local P=tabPanels[8]
    MkToggle(P,"HEADLESS",1,
        function()
            local args={{["Property"]="Head",["AssetId"]=15093053680}}
            local remote=RepStor:FindFirstChild("CatalogOnApplyToRealHumanoid",true)
            if remote then
                pcall(function()
                    remote:FireServer(unpack(args))
                end)
                Notif("Headless","Applied","ok")
            else
                Notif("Headless","Remote not found","err")
            end
        end,
        function()
            Notif("Headless","Rejoin to remove","")
        end
    )
end

-- SPIN TAB
do
    local P=tabPanels[9]
    local spinOn=false
    local spinSpd=60
    local spinAng=0
    local sCn
    local function startSpin()
        pcall(function()
            local char=lp.Character
            if not char then
                return
            end
            local hrp=char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return
            end
            sCn=TC(RunSvc.Heartbeat:Connect(function(dt)
                if not spinOn then
                    return
                end
                spinAng=spinAng+spinSpd*dt
                pcall(function()
                    hrp.AssemblyAngularVelocity=Vector3.new(0,spinSpd,0)
                end)
            end))
        end)
    end
    local function stopSpin()
        pcall(function()
            if sCn then
                sCn:Disconnect()
                sCn=nil
            end
        end)
        pcall(function()
            local char=lp.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyAngularVelocity=Vector3.zero
            end
        end)
    end
    local _,_,spinSet=MkToggle(P,"SPIN",1,
        function()
            spinOn=true
            startSpin()
            Notif("Spin","Active","ok")
        end,
        function()
            spinOn=false
            stopSpin()
            Notif("Spin","Off","")
        end
    )
    MkSlider(P,"SPEED",1,500,60,2,function(v)
        spinSpd=v
    end)
    lp.CharacterAdded:Connect(function()
        if spinOn then
            wait(1)
            startSpin()
        end
    end)
end

-- KEYS TAB
do
    local P=tabPanels[10]
    local tkCard=MkCard(P,48,1)
    MkLabel(tkCard,{
        text="TOGGLE UI KEY",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local curName=SAVE.toggleKey or "Insert"
    local tkLbl=MkLabel(tkCard,{
        text="["..curName.."]",
        size=9,
        color=T.TEXT,
        font=Semi,
        sz=UDim2.new(1,-56,0,14),
        pos=UDim2.new(0,12,0,20),
        z=14
    })
    local tkBtn=MkBtn(tkCard,{
        bg=T.RAISED,
        text="BIND",
        size=8,
        color=T.TEXT,
        sz=UDim2.new(0,50,0,20),
        pos=UDim2.new(1,-56,0.5,-10),
        corner=4,
        bgt=0.1,
        z=15
    })
    tkBtn.MouseButton1Click:Connect(function()
        tkBtn.Text="..."
        tkBtn.TextColor3=T.ACCENT
        _kbListening=true
        _kbCb=function(kc)
            _toggleKey=kc
            local newN=tostring(kc):gsub("Enum.KeyCode.","")
            SAVE.toggleKey=newN
            task.delay(.5,DoSave)
            tkLbl.Text="["..newN.."]"
            tkBtn.Text="BIND"
            tkBtn.TextColor3=T.TEXT
        end
    end)
    
    local kf=MkCard(P,180,2)
    MkLabel(kf,{
        text="KEYBINDS",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local ksf=Instance.new("ScrollingFrame",kf)
    ksf.Size=UDim2.new(1,-24,0,156)
    ksf.Position=UDim2.new(0,12,0,18)
    ksf.BackgroundTransparency=1
    ksf.ScrollBarThickness=2
    ksf.ScrollBarImageColor3=T.DIM
    ksf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    ksf.CanvasSize=UDim2.new(0,0,0,0)
    ksf.BorderSizePixel=0
    ksf.ClipsDescendants=true
    LL(ksf,2)
    task.delay(0.5,function()
        for i,kb in ipairs(KEYBINDS) do
            MkKBRow(ksf,kb.action,i)
        end
    end)
end

-- CONFIGS TAB
do
    local P=tabPanels[11]
    local configs=SAVE.configs or {}
    local _,nBox=MkTBox(P,"CONFIG NAME","e.g. pvp",1)
    local bc=MkCard(P,36,2)
    local br=Instance.new("Frame",bc)
    br.Size=UDim2.new(1,-24,0,24)
    br.Position=UDim2.new(0,12,0,6)
    br.BackgroundTransparency=1
    LL(br,3,Enum.FillDirection.Horizontal)
    local sb=MkBtn(br,{
        bg=T.RAISED,
        text="SAVE",
        size=8,
        color=T.TEXT,
        sz=UDim2.new(0.32,-3,1,0),
        corner=4,
        bgt=0.08
    })
    local lb=MkBtn(br,{
        bg=T.ACCENT,
        text="LOAD",
        size=8,
        color=T.BG,
        sz=UDim2.new(0.32,-3,1,0),
        corner=4,
        bgt=0
    })
    local db=MkBtn(br,{
        bg=T.ERR,
        text="DEL",
        size=8,
        color=T.TEXT,
        sz=UDim2.new(0.32,-3,1,0),
        corner=4,
        bgt=0.12
    })
    
    local lc=MkCard(P,140,3)
    MkLabel(lc,{
        text="SAVED",
        size=7,
        color=T.DIM,
        font=Bold,
        sz=UDim2.new(1,-24,0,10),
        pos=UDim2.new(0,12,0,6),
        z=14
    })
    local lsf=Instance.new("ScrollingFrame",lc)
    lsf.Size=UDim2.new(1,-24,0,116)
    lsf.Position=UDim2.new(0,12,0,18)
    lsf.BackgroundTransparency=1
    lsf.ScrollBarThickness=2
    lsf.ScrollBarImageColor3=T.DIM
    lsf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    lsf.CanvasSize=UDim2.new(0,0,0,0)
    lsf.BorderSizePixel=0
    lsf.ClipsDescendants=true
    LL(lsf,2)
    
    local function refresh()
        for _,v in ipairs(lsf:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
        for name in pairs(configs) do
            local row=Instance.new("Frame",lsf)
            row.Size=UDim2.new(1,0,0,24)
            row.BackgroundColor3=T.RAISED
            row.BackgroundTransparency=0.2
            row.BorderSizePixel=0
            Cnr(row,5)
            MkLabel(row,{
                text=name,
                size=8,
                color=T.TEXT,
                font=Semi,
                sz=UDim2.new(1,-44,1,0),
                pos=UDim2.new(0,8,0,0),
                z=15
            })
            local lb2=MkBtn(row,{
                bg=T.ACCENT,
                text="LOAD",
                size=6,
                color=T.BG,
                sz=UDim2.new(0,38,0,16),
                pos=UDim2.new(1,-42,0.5,-8),
                corner=4,
                bgt=0,
                z=15
            })
            lb2.MouseButton1Click:Connect(function()
                local cfg=configs[name]
                if not cfg then
                    return
                end
                for k,v in pairs(cfg) do
                    SAVE[k]=v
                end
                parseFriends(SAVE.friends)
                parseTargets(SAVE.targets)
                DoSave()
                Notif("Config","Loaded: "..name,"ok")
            end)
        end
    end
    refresh()
    
    local function getSnap()
        return {
            kaRange=SAVE.kaRange,
            kaAPS=SAVE.kaAPS,
            hbSize=SAVE.hbSize,
            rpSpeed=SAVE.rpSpeed,
            friends=SAVE.friends,
            targets=SAVE.targets,
            strafeRadius=SAVE.strafeRadius,
            strafeSpeed=SAVE.strafeSpeed,
            strafeOffset=SAVE.strafeOffset,
            tpwSpeed=SAVE.tpwSpeed,
            orbRadius=SAVE.orbRadius,
            orbSpeed=SAVE.orbSpeed,
            orbHeight=SAVE.orbHeight,
            flySpeed=SAVE.flySpeed,
            phrases=SAVE.phrases,
            bioTypeSpeed=SAVE.bioTypeSpeed,
            nameTypewriter=SAVE.nameTypewriter
        }
    end
    
    sb.MouseButton1Click:Connect(function()
        local name=nBox.Text~="" and nBox.Text or "default"
        configs[name]=getSnap()
        SAVE.configs=configs
        DoSave()
        refresh()
        Notif("Config","Saved: "..name,"ok")
    end)
    lb.MouseButton1Click:Connect(function()
        local name=nBox.Text~="" and nBox.Text or "default"
        local cfg=configs[name]
        if not cfg then
            Notif("Config","Not found","err")
            return
        end
        for k,v in pairs(cfg) do
            SAVE[k]=v
        end
        parseFriends(SAVE.friends)
        parseTargets(SAVE.targets)
        DoSave()
        Notif("Config","Loaded: "..name,"ok")
    end)
    db.MouseButton1Click:Connect(function()
        local name=nBox.Text~="" and nBox.Text or "default"
        configs[name]=nil
        SAVE.configs=configs
        DoSave()
        refresh()
        Notif("Config","Deleted","")
    end)
end

-- ADVANCED COMBAT TAB
do
    local P=tabPanels[12]
    MkSep(P,"Auto Combo",1)
    local autoComboOn=false
    local autoComboConn
    local autoComboDelay=0.15
    
    MkToggle(P,"AUTO COMBO",2,
        function()
            autoComboOn=true
            if autoComboConn then
                autoComboConn:Disconnect()
            end
            autoComboConn=TC(RunSvc.Heartbeat:Connect(function()
                if not autoComboOn then
                    return
                end
                local myC=lp.Character
                if not myC then
                    return
                end
                local myH=myC:FindFirstChild("HumanoidRootPart")
                if not myH then
                    return
                end
                local best,bestD=nil,math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if not isTarget(p) then
                        continue
                    end
                    local c=p.Character
                    if not c then
                        continue
                    end
                    local h=c:FindFirstChild("HumanoidRootPart")
                    if not h then
                        continue
                    end
                    local hum=c:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health<=0 then
                        continue
                    end
                    local d=(h.Position-myH.Position).Magnitude
                    if d<=15 and d<bestD then
                        bestD=d
                        best={p,h,hum}
                    end
                end
                if best then
                    local p,hrp,hum=best[1],best[2],best[3]
                    pcall(function()
                        if RF.PunchDo then
                            RF.PunchDo:FireServer(hum,hrp.Position)
                        end
                        task.wait(autoComboDelay)
                        if RF.Hit then
                            RF.Hit:InvokeServer(hum,vector.create(myH.Position.X,myH.Position.Y,myH.Position.Z))
                        end
                    end)
                end
            end))
            Notif("Auto Combo","Active","ok")
        end,
        function()
            autoComboOn=false
            if autoComboConn then
                autoComboConn:Disconnect()
                autoComboConn=nil
            end
            Notif("Auto Combo","Off","")
        end
    )
    MkSlider(P,"COMBO DELAY",10,500,150,3,function(v)
        autoComboDelay=v/1000
    end)
    
    MkSep(P,"Prediction",4)
    local predHitOn=false
    local predHitConn
    local predMulti=0.3
    MkToggle(P,"PREDICTION HIT",5,
        function()
            predHitOn=true
            if predHitConn then
                predHitConn:Disconnect()
            end
            predHitConn=TC(RunSvc.Heartbeat:Connect(function()
                if not predHitOn then
                    return
                end
                local myC=lp.Character
                if not myC then
                    return
                end
                local myH=myC:FindFirstChild("HumanoidRootPart")
                if not myH then
                    return
                end
                local best,bestD=nil,math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if not isTarget(p) then
                        continue
                    end
                    local c=p.Character
                    if not c then
                        continue
                    end
                    local h=c:FindFirstChild("HumanoidRootPart")
                    if not h then
                        continue
                    end
                    local hum=c:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health<=0 then
                        continue
                    end
                    local d=(h.Position-myH.Position).Magnitude
                    if d<=20 and d<bestD then
                        bestD=d
                        best={hum,h}
                    end
                end
                if best then
                    local hum,hrp=best[1],best[2]
                    local vel=hrp.AssemblyLinearVelocity
                    local predPos=hrp.Position+vel*predMulti
                    pcall(function()
                        if RF.Hit then
                            RF.Hit:InvokeServer(hum,vector.create(predPos.X,predPos.Y,predPos.Z))
                        end
                    end)
                end
            end))
            Notif("Prediction Hit","Active","ok")
        end,
        function()
            predHitOn=false
            if predHitConn then
                predHitConn:Disconnect()
                predHitConn=nil
            end
            Notif("Prediction Hit","Off","")
        end
    )
    MkSlider(P,"MULTIPLIER",10,100,30,6,function(v)
        predMulti=v/100
    end)
end

-- COMBAT UTILS TAB
do
    local P=tabPanels[13]
    MkSep(P,"Hitbox",1)
    local hitboxOn=false
    local hitboxSize=12
    MkToggle(P,"HITBOX EXPANDER",2,
        function()
            hitboxOn=true
            spawn(function()
                while hitboxOn do
                    for _,p in ipairs(Players:GetPlayers()) do
                        if isTarget(p) and p.Character then
                            local h=p.Character:FindFirstChild("HumanoidRootPart")
                            if h then
                                pcall(function()
                                    h.Size=Vector3.new(hitboxSize,hitboxSize,hitboxSize)
                                    h.Transparency=0.7
                                    h.CanCollide=false
                                end)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
            Notif("Hitbox","Expanded","ok")
        end,
        function()
            hitboxOn=false
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local h=p.Character:FindFirstChild("HumanoidRootPart")
                    if h then
                        pcall(function()
                            h.Size=Vector3.new(2,2,1)
                            h.Transparency=1
                        end)
                    end
                end
            end
            Notif("Hitbox","Normal","")
        end
    )
    MkSlider(P,"SIZE",5,50,12,3,function(v)
        hitboxSize=v
    end)
    
    MkSep(P,"Auto Dodge",4)
    local dodgeOn=false
    local dodgeConn
    MkToggle(P,"AUTO DODGE",5,
        function()
            dodgeOn=true
            if dodgeConn then
                dodgeConn:Disconnect()
            end
            dodgeConn=TC(RunSvc.Heartbeat:Connect(function()
                if not dodgeOn then
                    return
                end
                local myC=lp.Character
                if not myC then
                    return
                end
                local myH=myC:FindFirstChild("HumanoidRootPart")
                if not myH then
                    return
                end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==lp or isFriend(p) then
                        continue
                    end
                    local c=p.Character
                    if not c then
                        continue
                    end
                    local h=c:FindFirstChild("HumanoidRootPart")
                    if not h then
                        continue
                    end
                    local dist=(h.Position-myH.Position).Magnitude
                    if dist<=6 then
                        local vel=h.AssemblyLinearVelocity
                        if vel.Magnitude>25 then
                            local dodge=myH.CFrame.RightVector*5
                            myH.CFrame=myH.CFrame+dodge
                            myH.AssemblyLinearVelocity=Vector3.zero
                            break
                        end
                    end
                end
            end))
            Notif("Auto Dodge","Active","ok")
        end,
        function()
            dodgeOn=false
            if dodgeConn then
                dodgeConn:Disconnect()
                dodgeConn=nil
            end
            Notif("Auto Dodge","Off","")
        end
    )
    
    MkSep(P,"Speed Boost",6)
    local speedOn=false
    local speedMult=1.5
    MkToggle(P,"SPEED BOOST",7,
        function()
            speedOn=true
            pcall(function()
                local hum=lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed=hum.WalkSpeed*speedMult
                end
            end)
            Notif("Speed Boost","Active","ok")
        end,
        function()
            speedOn=false
            pcall(function()
                local hum=lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed=16
                end
            end)
            Notif("Speed Boost","Off","")
        end
    )
    MkSlider(P,"MULTIPLIER",100,300,150,8,function(v)
        speedMult=v/100
    end)
end

-- ADVANTAGE TAB
do
    local P=tabPanels[14]
    MkSep(P,"Invisibility",1)
    local invisOn=false
    MkToggle(P,"INVISIBLE",2,
        function()
            invisOn=true
            local char=lp.Character
            if char then
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
                        pcall(function()
                            v.Transparency=1
                        end)
                    elseif v:IsA("Accessory") then
                        for _,p in ipairs(v:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function()
                                    p.Transparency=1
                                end)
                            end
                        end
                    end
                end
            end
            Notif("Invisible","Active","ok")
        end,
        function()
            invisOn=false
            local char=lp.Character
            if char then
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
                        pcall(function()
                            v.Transparency=0
                        end)
                    elseif v:IsA("Accessory") then
                        for _,p in ipairs(v:GetDescendants()) do
                            if p:IsA("BasePart") then
                                pcall(function()
                                    p.Transparency=0
                                end)
                            end
                        end
                    end
                end
            end
            Notif("Invisible","Off","")
        end
    )
    
    MkSep(P,"Auto Respawn",3)
    local autoRespawn=false
    MkToggle(P,"AUTO RESPAWN",4,
        function()
            autoRespawn=true
            Notif("Auto Respawn","Active","ok")
        end,
        function()
            autoRespawn=false
            Notif("Auto Respawn","Off","")
        end
    )
    lp.CharacterAdded:Connect(function(char)
        if autoRespawn then
            local hum=char:WaitForChild("Humanoid",5)
            if hum then
                hum.Died:Connect(function()
                    if autoRespawn then
                        task.wait(0.5)
                        pcall(function()
                            lp:LoadCharacter()
                        end)
                    end
                end)
            end
        end
    end)
    
    MkSep(P,"Server",5)
    local rejoinBtn=MkBtn(P,{
        bg=T.RAISED,
        text="REJOIN",
        size=9,
        color=T.TEXT,
        sz=UDim2.new(1,-24,0,28),
        pos=UDim2.new(0,12,0,0),
        corner=5,
        bgt=0.1,
        order=6,
        z=15
    })
    rejoinBtn.MouseButton1Click:Connect(function()
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,lp)
        end)
    end)
    
    local hopBtn=MkBtn(P,{
        bg=T.RAISED,
        text="SERVER HOP",
        size=9,
        color=T.TEXT,
        sz=UDim2.new(1,-24,0,28),
        pos=UDim2.new(0,12,0,30),
        corner=5,
        bgt=0.1,
        order=7,
        z=15
    })
    hopBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local servers=game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            if servers and servers.data then
                for _,server in ipairs(servers.data) do
                    if server.id~=game.JobId and server.playing<server.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,server.id,lp)
                        break
                    end
                end
            end
        end)
    end)
end

Win.Visible=true
GoTab(1)
Notif("ZICO HUB","Loaded! Press Insert","ok")
print("ZICO HUB Loaded")
