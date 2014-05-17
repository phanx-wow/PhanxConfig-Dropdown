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
		GameTooltip:SetOwner(container, "ANCHOR_RIGHT")
		GameTooltip:AddLine(container.tooltipText, 1, 1, 1, true)
		GameTooltip:Show()
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

local function Button_OnClick(self)
	local dropdown = self:GetParent()
	local container = dropdown:GetParent()

	PlaySound("igMainMenuOptionCheckBoxOn")
	if container.easyMenu then
		EasyMenu(container.easyMenu, dropdown, nil, 12, 22)
	else
		ToggleDropDownMenu(nil, nil, dropdown, nil, 12, 22)
	end

	local listFrame = DropDownList1
	if listFrame:IsShown() and dropdown:GetParent() == container then
		local listWidth = dropdown:GetWidth() - 21
		if listFrame:GetWidth() < listWidth then
			listFrame:SetWidth(listWidth)
			listFrame:SetPoint("TOPRIGHT", dropdown, "BOTTOMRIGHT", -12, 22)
			local buttonWidth = listWidth - 30
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

function methods:SetMenu(menu)
	self.easyMenu = nil
	self.dropdown.initialize = nil

	if type(menu) == "function" then
		self.dropdown.initialize = menu
	elseif type(menu) == "table" then
		self.easyMenu = menu
	else
		self.dropdown.initialize = function(...)
			if self.Initialize then
				self:Initialize(...)
			end
		end
	end
end

------------------------------------------------------------------------

local i = 0
function lib:New(parent, label, tooltip, menu)
	assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "PhanxConfig-Dropdown: parent must be a frame")

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
	dropdown:SetScript("OnEnter", Dropdown_OnEnter)
	dropdown:SetScript("OnLeave", Dropdown_OnLeave)
	frame.dropdown = dropdown

	frame.left = _G[NAME.."Left"]

	frame.right = _G[NAME.."Right"]
	frame.right:ClearAllPoints()
	frame.right:SetPoint("TOPRIGHT", 0, 17)

	frame.middle = _G[NAME.."Middle"]
	frame.middle:SetPoint("RIGHT", frame.right, "LEFT")

	frame.icon = _G[NAME.."Icon"]

	frame.valueText = _G[NAME.."Text"]
	frame.valueText:SetPoint("LEFT", frame.left, 27, 2)
	frame.valueText:SetJustifyH("LEFT")

	frame.button = _G[NAME.."Button"]
	frame.button:SetPoint("TOPLEFT", frame.left, 18, -18) -- TODO: check
	frame.button:SetScript("OnClick", Button_OnClick)

	local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, 5, 0)
	label:SetPoint("TOPRIGHT", frame, -5, 0)
	label:SetJustifyH("LEFT")
	frame.labelText = label

	for name, func in pairs(methods) do
		frame[name] = func
	end

	frame:SetLabel(label)
	frame:SetTooltip(tooltip)

	if menu then
		frame:SetMenu(menu)
	else
		dropdown.initialize = function(...)
			if frame.Initialize then
				frame:Initialize(...)
			end
		end
	end

	return frame
end

function lib.CreateDropdown(...) return lib:New(...) end