local imgui = require("mimgui")

local menu_active = imgui.new.bool(true)
local toggle = imgui.new.bool(false)

local esp_toggle = imgui.new.bool(false)
local esp_name = false

local playerId = imgui.new.int(0)
local playerId2 = imgui.new.int(0)

local encoding = require 'encoding' 

local esp_l_tg = imgui.new.bool(false)
local esp_linhas = imgui.new.bool(false)

local dist = imgui.new.bool(false)
local dist_t = imgui.new.bool(false)

local esp_id = imgui.new.bool(false)
local esp_id_t = imgui.new.bool(false)

encoding.default = 'CP1251' 
local u8 = encoding.UTF8

local fonte = nil

local socket = require("socket.http")
local ltn12 = require("ltn12")



function imgui.Theme()
  imgui.SwitchContext()
  imgui.GetStyle().FrameRounding = 10
  imgui.GetStyle().FramePadding = imgui.ImVec2(10,8)
  imgui.GetStyle().ChildRounding = 2
  imgui.GetStyle().WindowPadding = imgui.ImVec2(4.0,4.0)
  imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.0,0.5)
  imgui.GetStyle().WindowRounding = 50
  imgui.GetStyle().ItemSpacing = imgui.ImVec2(5.0,4.0)
  -- colors
  imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(1,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.WindowBg].w = 0.2
  imgui.GetStyle().Colors[imgui.Col.Tab] = imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.TabActive] =  imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.8,0,0,1)
  imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.8,0,0,1)
  -- fonte
  local io = imgui.GetIO()
  fonte = io.Fonts:AddFontFromFileTTF("/storage/emulated/0/Download/teste2.ttf", 28)
  
end

function sendNickToDiscord()
  local result, myid = sampGetPlayerIDByCharHandle(PLAYER_PED)
  local mynick = sampGetPlayerNickname(myid)
  if result then
    local urlwebhook  = "" --editar depois e colocar o meu webhook
    local body = '("Content":" Nick ': .. mynick .. "')'
    local response_body = {}
    local res, code, response_headers = socket.request{
      url = urlwebhook,
      method = "POST",
      headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#body)
    }
      source = ltn12.source.string(body), 
      sink = ltn12.sink.table(response_body)
    }
    rr = string.format("%s", res)
    status = string.format("%s",code)  
    print(rr)
    print(status)
  end
end

imgui.OnInitialize(function()
    imgui.Theme()
end)

function esps()
  local myx,myy,myz = getCharCoordinates(PLAYER_PED)
  local mx,my = convert3DCoordsToScreen(myx,myy,myz)
  local font = renderCreateFont("Arial", 16, 0)
  for id = 0, 400 do
    local result, ped = sampGetCharHandleBySampPlayerId(id)
    if result and doesCharExist(ped) then
      local name = sampGetPlayerNickname(id)
      local text = string.format("%s", name)
      local x,y,z = getCharCoordinates(ped)
      local sx,sy = convert3DCoordsToScreen(x,y,z)
      if isPointOnScreen(x,y,z,1) then
        if esp_name then
          renderFontDrawText(font, text, sx,sy, 0xFF90EE90)
        end
        if esp_linhas then
          renderDrawLine(mx,my,sx,sy,3.0,0xFF7CFC00)
        end
        if dist then
          local d = getDistanceBetweenCoords3d(x,y,z,myx,myy,myz)
          local font = renderCreateFont("Arial", 14, 0)
          local text = string.format("DIST: %1f", tostring(d))
          renderFontDrawText(font, text, sx+20,sy+30, 0xFFFFFFFF)
        end
      end
      if esp_id then
        local font = renderCreateFont("Arial", 11,0)
        if result then
          local result, id = sampGetPlayerIdByCharHandle(ped)
          local x,y,z = getCharCoordinates(ped)
          local text = string.format("%d", id)
          if isPointOnScreen(x,y,z,1) then
            renderFontDrawText(font, text, sx+15,sy, 0xFFFFFFFF)
          end
        end
      end 
    end
  end
end

local x,y = getScreenResolution()
imgui.OnFrame(
    function()
      return true
    end,
    function(player)
      imgui.SetNextWindowSize(imgui.ImVec2(700,600))
      if menu_active[0] then
        if imgui.Begin('Ackles Menu', toggle, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
          local text = "ACKLES MENU"
          local windowWidth = imgui.GetWindowSize().x
          local textSize = imgui.CalcTextSize(text).x
          imgui.SetCursorPosX((windowWidth - textSize) / 2 -45)
          imgui.SetWindowFontScale(1.8)
          imgui.PushFont(fonte)
          imgui.Text(text)
          imgui.PopFont()
          imgui.SetWindowFontScale(1.0)
          if imgui.BeginTabBar('Tabs') then
            if imgui.BeginTabItem(u8'Player') then 
              imgui.Spacing()
              if imgui.Button(u8'LOGIN BPS') then
                sampSendChat("/logar 123456")
              end
              imgui.Spacing()
              if imgui.Button(u8'All cidades') then
                  sampSendChat("/logar 123456")
              end
              imgui.Spacing()
              if imgui.Button(u8'Registrar') then
                sampSendChat("/registrar 123456")
              end
              imgui.Spacing()
              if imgui.Button("Vida 100") then
                setCharHealth(PLAYER_PED, 100)
              end
              if imgui.Button("Colete") then
                addArmourToChar(PLAYER_PED, 100)
              end
              if imgui.Button("No damege") then
                writeMemory(0x4C4D00, 1, 0xC3, true)
              end
              imgui.Spacing()
              imgui.InputInt(" ", playerId)
              local id = playerId[0]
              local name = sampGetPlayerNickname(id)
              imgui.Text("NOME DO PLAYER: " .. name)
              imgui.EndTabItem()
            end
            if imgui.BeginTabItem(u8'TELEPORT') then
              local result,x,y,z = getTargetBlipCoordinates()
              imgui.Spacing()
              if imgui.Button("Posicão marcada") then
                if result then
                  setCharCoordinates(PLAYER_PED, x,y,z)
                end
              end
              imgui.Spacing()
              imgui.Text("TELEPORT JOGADOR POR ID ")
              imgui.InputInt(" ", playerId2)
              local id2 = playerId2[0]
              imgui.Text(u8"APENAS JOGADORES PERTO")
              if imgui.Button("TELEPORT") then
                if id2 > 0 then
                  local result, ped = sampGetCharHandleBySampPlayerId(id2)
                  if result and doesCharExist(ped) then
                    local x,y,z = getCharCoordinates(ped)
                    setCharCoordinates(PLAYER_PED, x,y+2,z)
                  end
                end
              end
              imgui.EndTabItem()
            end
            if imgui.BeginTabItem(u8'ARMAS') then
              imgui.Spacing()
              imgui.Text("RISCO DE BAN")
              if imgui.Button("Desert") then
                giveWeaponToChar(PLAYER_PED, 24, 100)
              end
              imgui.SameLine()
              if imgui.Button("Sniper") then
                giveWeaponToChar(PLAYER_PED, 34, 100)
              end
              imgui.SameLine()
              if imgui.Button("Doze") then
                giveWeaponToChar(PLAYER_PED, 26, 100)
              end
              imgui.SameLine()
              if imgui.Button("M4A1") then
                giveWeaponToChar(PLAYER_PED, 31, 100)
              end
              imgui.SameLine()
              imgui.EndTabItem()
            end
            if imgui.BeginTabItem('CAR') then
              imgui.BeginChild("teste4", imgui.ImVec2(155,55), true)
              
              if imgui.Button("REPARAR") then
                local car = storeCarCharIsInNoSave(PLAYER_PED)
                setCarHealth(car, 1000)
                
              end
              imgui.EndChild()
              imgui.EndTabItem()
            end
            if imgui.BeginTabItem('ESP') then
              imgui.BeginChild("teste2", imgui.ImVec2(250,55), true)
              if imgui.Checkbox(u8'Esp Name', esp_toggle) then
                esp_name = esp_toggle[0]
                if esp_name then
                  sampAddChatMessage("Esp Name Ativo", 0xFFFF0000)
                else
                  sampAddChatMessage("Esp Name Desativo", 0xFFFF0000)
                end
              end
              imgui.EndChild()
              imgui.SameLine()
              imgui.BeginChild("teste3", imgui.ImVec2(250,55), true)
              if imgui.Checkbox("ESP LINHAS", esp_l_tg) then
                esp_linhas = esp_l_tg[0]
                if esp_linhas then
                  sampAddChatMessage("ESP LINHAS ATIVO", 0xFFFF0000)
                else
                  sampAddChatMessage("ESP LINHAS DESATIVO", 0xFFFF0000)
                end
              end
              imgui.EndChild()
              imgui.BeginChild("teste5", imgui.ImVec2(250,55), true)
              if imgui.Checkbox("ESP DIST", dist_t) then
                dist = dist_t[0]
                if dist then
                  sampAddChatMessage("ATIVO", 0xFFFF0000)
                else
                  sampAddChatMessage("DESATIVO", 0xFFFFFFFF)
                end
              end
              imgui.EndChild()
              imgui.SameLine()
              imgui.BeginChild("teste6", imgui.ImVec2(255,55), true)
              if imgui.Checkbox("ESP ID", esp_id_t) then
                esp_id = esp_id_t[0]
                if esp_id then
                  sampAddChatMessage("ATIVO", 0XFFFF0000)
                else
                  sampAddChatMessage("DESATIVO", 0xFFFFFFFF)
                end
              end
              
              imgui.EndChild()
              imgui.EndTabItem()
              
            end
          end
        end
      end
    imgui.End()
    end)

sampRegisterChatCommand("ackles", function()
  menu_active[0] = true end)

function main()
  while not isSampAvailable() do wait(0) end
  sendNickToDiscord()
  while true do
    esps()
    wait(0)
  end
end
