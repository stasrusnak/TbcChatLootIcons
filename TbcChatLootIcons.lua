local ICON_SIZE = 40


local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED") 

function frame:OnEvent(event, addonName)
    if event == "ADDON_LOADED" and addonName == "TbcChatLootIcons" then
        -- Загрузка сохраненных настроек
        if TbcChatLootIconsSavedVariables then
            if TbcChatLootIconsSavedVariables.ICON_SIZE then
                ICON_SIZE = TbcChatLootIconsSavedVariables.ICON_SIZE 
            end 
        end 
    end
end

frame:SetScript("OnEvent", frame.OnEvent)

-- Прочие части вашего кода
-- ...


local function SimpleRound(val, valStep)
    return floor(val / valStep) * valStep
end

local function CreateIconSizeSlider(parent, name, title, minVal, maxVal, valStep)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", name .. "EditBox", slider, "InputBoxTemplate")
    
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(valStep)
    slider.text = _G[name .. "Text"]
    slider.text:SetText(title)
    slider.textLow = _G[name .. "Low"]
    slider.textHigh = _G[name .. "High"]
    slider.textLow:SetText(floor(minVal))
    slider.textHigh:SetText(floor(maxVal))
    -- slider.textLow:SetTextColor(0.4, 0.4, 0.4)
    -- slider.textHigh:SetTextColor(0.4, 0.4, 0.4)
    editbox:SetWidth(70)
    editbox:SetHeight(30)
    -- editbox:SetSize(50, 30)
    editbox:ClearAllPoints()
    editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editbox:SetText(slider:GetValue())
    editbox:SetAutoFocus(false)
    
    slider:SetScript("OnValueChanged", function(self, value)
        self.editbox:SetText(SimpleRound(value, valStep))
        ICON_SIZE = value
    end)
    
    editbox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    
    editbox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    
    slider.editbox = editbox
    return slider
end

-- Применение фильтра для всех основных окон чата
local hooks = {}
for i=1, NUM_CHAT_WINDOWS do
    local f = _G["ChatFrame"..i]
    hooks[f] = f.AddMessage
    f.AddMessage = function(frame, text, red, green, blue, id)
        text = tostring(text) or "" 
        -- Добавление иконок предметов
        local function Icon(link)
            local texture = GetItemIcon(link)
            return "\124T" .. texture .. ":" .. ICON_SIZE .. "\124t" .. link
        end
        text = text:gsub("(\124c%x+\124Hitem:.-\124h\124r)", Icon)
        return hooks[frame](frame, text, red, green, blue, id)
    end
end


 
 

-- Фрейм для настроек аддона
local OptionsFrame = CreateFrame("Frame", "TbcChatLootIconsOptionsFrame", UIParent )
OptionsFrame:SetWidth(300)
OptionsFrame:SetHeight(200) 
OptionsFrame:SetPoint("CENTER")
OptionsFrame.title = OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
OptionsFrame.title:SetPoint("TOP", OptionsFrame, "TOP", 0, -5)
OptionsFrame.title:SetText("Настройки аддона")
OptionsFrame:SetMovable(true)
OptionsFrame:EnableMouse(true)
OptionsFrame:RegisterForDrag("LeftButton")
OptionsFrame:SetScript("OnDragStart", OptionsFrame.StartMoving)
OptionsFrame:SetScript("OnDragStop", OptionsFrame.StopMovingOrSizing)
 
OptionsFrame:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8", -- Используем стандартную белую текстуру
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Файл текстуры для рамки
    edgeSize = 16, -- Размер рамки
    insets = { left = 5, right = 5, top = 5, bottom = 5 } -- Отступы внутри рамки
})
OptionsFrame:SetBackdropColor(0, 0, 0, 1) -- Цвет фона (черный)
OptionsFrame:SetBackdropBorderColor(1, 1, 1, 1) -- Цвет рамки (белый)


-- Добавление крестика закрытия окна
OptionsFrame.closeButton = CreateFrame("Button", nil, OptionsFrame, "UIPanelCloseButton")
OptionsFrame.closeButton:SetPoint("TOPRIGHT", OptionsFrame, "TOPRIGHT", -10, -10)
OptionsFrame.closeButton:SetScript("OnClick", function()
    OptionsFrame:Hide()
end)

OptionsFrame:Hide()

-- Элемент управления для выбора размера иконки
local Slider = CreateIconSizeSlider(OptionsFrame, "TbcChatLootIconsIconSizeSlider", "Размер иконки", 20, 100, 5)
Slider:SetPoint("TOPLEFT", OptionsFrame, "TOPLEFT", 20, -50)


-- Кнопка "Сохранить настройки"
local SaveButton = CreateFrame("Button", "TbcChatLootIconsSaveButton", OptionsFrame, "UIPanelButtonTemplate")
SaveButton:SetText("Сохранить настройки")
SaveButton:SetWidth(120)
SaveButton:SetHeight(25) 
SaveButton:SetPoint("BOTTOM", OptionsFrame, "BOTTOM", 0, 15)

-- Функция сохранения настроек
local function SaveSettings()
    -- Сохранение параметров в файле настроек в папке WTF
    TbcChatLootIconsSavedVariables = {
        ICON_SIZE = ICON_SIZE
    }
end

-- Обработчик события для кнопки "Сохранить настройки"
SaveButton:SetScript("OnClick", function()
    SaveSettings() 
    DEFAULT_CHAT_FRAME:AddMessage("Настройки сохранены!")
end)
 
 
-- Отображение меню настроек аддона
local function ShowOptionsFrame()
    OptionsFrame:Show()
end

-- Регистрация команды для отображения меню настроек
SLASH_MYADDON1 = "/looticons"
SlashCmdList["MYADDON"] = ShowOptionsFrame




-- Create minimap button
local minibtn = CreateFrame("Button", "TbcChatLootIconsMiniMapIcon", Minimap) 
minibtn:SetFrameLevel(8) 
minibtn:SetMovable(true) 
minibtn:SetWidth(25)
minibtn:SetHeight(25)  
minibtn:SetNormalTexture("Interface\\Icons\\INV_SummerFest_Symbol_Medium.blp") -- Установка текстуры иконки 
minibtn:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
  
 
local myIconPos = 0
 
-- Control movement
local function UpdateMapBtn()
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
    minibtn:ClearAllPoints()
    minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
end
 
minibtn:RegisterForDrag("LeftButton")
minibtn:SetScript("OnDragStart", function()
    minibtn:StartMoving()
    minibtn:SetScript("OnUpdate", UpdateMapBtn)
end)
 
minibtn:SetScript("OnDragStop", function()
    minibtn:StopMovingOrSizing();
    minibtn:SetScript("OnUpdate", nil)
    UpdateMapBtn();
end)
 
-- Set position
minibtn:ClearAllPoints();
minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)),(80 * sin(myIconPos)) - 52)
 
-- Control clicks
minibtn:SetScript("OnClick", function()
    ShowOptionsFrame()
end)


 