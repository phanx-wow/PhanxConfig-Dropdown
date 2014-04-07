--[[--------------------------------------------------------------------
	PhanxConfig-Dropdown
	Simple color picker widget generator.
	Based on tekKonfig-Dropdown by Tekkub.
	Requires LibStub.

	This library is not intended for use by other authors. Absolutely no
	support of any kind will be provided for other authors using it, and
	its internals may change at any time without notice.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(strmatch("$Revision$", "%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Dropdown", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local function Dropdown_OnEnter(self)
	local container = self:GetParent()
	if container.OnEnter then
		container:OnEnter()
	elseif container.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(container.tooltipText, nil, nil, nil, nil, true)
	end
end

local function Dropdown_OnLeave(self)
	local container = self:GetParent()
	if container.OnLeave then
		container:OnLeave()
	else
		GameTooltip:Hide()
	end
end

local function Dropdown_OnShow(self)
	local container = self:GetParent()
	local width = container:GetWidth() - 19
	UIDropDownMenu_SetWidth(self, width)
	UIDropDownMenu_SetButtonWidth(self, width)
end

local function Button_OnClick(self)
	local dropdown = self:GetParent()
	local container = dropdown:GetParent()

	PlaySound("igMainMenuOptionCheckBoxOn")
	ToggleDropDownMenu(nil, nil, dropdown, nil, 12, 22)

	local listFrame = DropDownList1
	if listFrame:IsShown() and listFrame.dropdown:GetParent() == container then
		local listWidth = dropdown:GetWidth() - 21
		if listFrame:GetWidth() < listWidth then
			local buttonWidth = listWidth - 30
			listFrame:SetWidth(listWidth)
			for i = 1, listFrame.numButtons do
				local buttonFrame = _G["DropDownList1Button"..i]
				buttonFrame:SetWidth(buttonWidth)
			end
		end
	end
end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	return UIDropDownMenu_GetSelectedValue(self.dropdown) or self.valueText:GetText()
end
function methods:SetValue(value, text)
	UIDropDownMenu_SetSelectedValue(self.dropdown, value or "UNKNOWN")
	self.valueText:SetText(text or value)
end

function methods:GetLabel()
	return self.labelText:GetText()
end
function methods:SetLabel(text)
	if type(text) ~= "string" then text = "" end
	self.labelText:SetText(text)
end

function methods:GetTooltip()
	return self.tooltipText
end
function methods:SetTooltip(text)
	if type(text) ~= "string" then text = nil end
	self.tooltipText = text
end

function methods:Enable()
	self.labelText:SetFontObject(GameFontNormal)
	self.valueText:SetFontObject(GameFontHighlightSmall)
	self.button:Enable()
end
function methods:Disable()
	self.labelText:SetFontObject(GameFontDisable)
	self.valueText:SetFontObject(GameFontDisableSmall)
	self.button:Disable()
end

-------------------------------------------------------------------------

local function GetInitFunc(t)
	local infoList = t
	return function()
		for i = 1, #infoList do
			UIDropDownMenu_AddButton(infoList[i])
		end
	end
end

local i = 0
function lib:New(parent, name, tooltipText, init)
	assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-Dropdown: Parent is not a valid frame!")

	i = i + 1
	local NAME = "PhanxConfigDropdown" .. i

	local frame = CreateFrame("Frame", NAME.."Container", parent)
	frame:SetSize(186, 42)
--[[
	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetAllPoints(true)
	frame.bg:SetTexture(0, 128, 0, 0.5)
]]
	local dropdown = CreateFrame("Frame", NAME, frame, "UIDropDownMenuTemplate") -- UIDropDownMenu system requires a global name
	dropdown:SetPoint("BOTTOMLEFT", -16, -4)
	dropdown:SetPoint("BOTTOMRIGHT", 15, -4)
	dropdown:SetHitRectInsets(0, 0, -10, 0)
	dropdown:SetScript("OnShow", Dropdown_OnShow)
	dropdown:SetScript("OnEnter", Dropdown_OnEnter)
	dropdown:SetScript("OnLeave", Dropdown_OnLeave)
	frame.dropdown = dropdown

	frame.left = _G[NAME.."Left"]
	frame.right = _G[NAME.."Right"]
	frame.middle = _G[NAME.."Middle"]
	frame.icon = _G[NAME.."Icon"]

	local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, 5, 0)
	label:SetPoint("TOPRIGHT", frame, -5, 0)
	label:SetJustifyH("LEFT")
	frame.labelText = label

	frame.valueText = _G[NAME.."Text"]
	UIDropDownMenu_JustifyText(dropdown, "LEFT")

	frame.button = _G[NAME.."Button"]
	frame.button:SetScript("OnClick", Button_OnClick)

	for name, func in pairs(methods) do
		frame[name] = func
	end

	frame:SetLabel(name)
	frame:SetTooltip(tooltipText)

	if type(init) == "function" then
		frame.Initialize = init
	elseif type(init) == "table" then
		frame.Initialize = GetInitFunction(init)
	end
	UIDropDownMenu_Initialize(dropdown, function(self, level)
		--print("Initialize!")
		if frame.Initialize then
			frame:Initialize(self, level)
		end
	end)

	return frame
end

function lib.CreateDropdown(...) return lib:New(...) end