-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- self.onSummaryChanged();
	update();
end
function VisDataCleared()
	update();
end
function InvisDataAdded()
	update();
end

-- function onSummaryChanged()
-- 	local nodeRecord = getDatabaseNode();

-- 	local tFirstSummary = {};
-- 	local sSize = DB.getValue(nodeRecord, "level_name", "");
-- 	if sSize ~= "" then
-- 		table.insert(tFirstSummary, sSize);
-- 	end
-- 	local sType = DB.getValue(nodeRecord, "level_name", "");
-- 	if sType ~= "" then
-- 		table.insert(tFirstSummary, sType);
-- 	end
-- 	local sFirstSummary = table.concat(tFirstSummary, " ");

-- 	local tSecondSummary = {};
-- 	if sFirstSummary ~= "" then
-- 		table.insert(tSecondSummary, sFirstSummary);
-- 	end
-- 	local sAlign = DB.getValue(nodeRecord, "level_name", "");
-- 	if sAlign ~= "" then
-- 		table.insert(tSecondSummary, sAlign);
-- 	end

-- 	summary.setValue(table.concat(tSecondSummary, ", "));
-- end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);
	local tFields = { 
		"level_name", "organization_name",
		"ev", "keywords_name"
	};
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
	WindowManager.callSafeControlUpdate(self, "keywords_name", bReadOnly);

	local bSection1 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "keywords_name", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "level_name", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "role_name", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "ev", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait1", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait2", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait3", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait4", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait5", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait6", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait7", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "label_trait8", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name1", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name2", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name3", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name4", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name5", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name6", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name7", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "traits_name8", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "creaturerole_name", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "organization_name", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "maxstamina", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "nonid_name", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "speed", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "reach", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "stability_label", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "freestrike", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "ev_description", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "monsterkeywords_name", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "role_name", bReadOnly) then bSection1 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "keywords_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "level_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "role_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "ev", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "traits_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "creaturerole_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "organization_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "maxstamina", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "nonid_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "speed", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "reach", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "stability_label", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "freestrike", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "ev_description", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "monsterkeywords_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "role_name", bReadOnly, true);
	end
	-- divider.setVisible(bSection1);

	local bSection2 = false;
	if Session.IsHost then
		-- if WindowManager.callSafeControlUpdate(self, "size", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "maxstamina", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "mgt", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "agl", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "rea", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "inu", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "prs", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "stability", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "languages_name", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "weakness_name", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "immunity_name", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "sizenote_name", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "staminanote_name", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "withcaptain", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "speedtype_name", bReadOnly) then bSection2 = true; end;
	else
		-- WindowManager.callSafeControlUpdate(self, "size", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "maxstamina", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "mgt", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "agl", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "rea", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "inu", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "prs", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "stability", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "languages_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "weakness_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "immunity_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "withcaptain", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "sizenote_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "staminanote_name", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "speedtype_name", bReadOnly, true);
	end

	local bSection3 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "trait1", bReadOnly, true) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "trait2", bReadOnly, true) then bSection2 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "trait1", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "trait2", bReadOnly, true);
	end
	
	
	local bSection3 = false;
	if WindowManager.callSafeControlUpdate(self, "skills", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "items", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "languages", bReadOnly) then bSection = true; end;
	-- divider2.setVisible(bSection3);
end

function onValueChanged()
	window.onHealthChanged();
end

function onHealthChanged()
	stamina.setColor(getPCSheetWoundColor(getDatabaseNode()));
end

function getPCSheetWoundColor(nodePC)
	local nMaxStamina = 0;
	local nCurrentStamina = 0;
	if nodePC then
		nMaxStamina = math.max(DB.getValue(nodePC, "stamina.max", 0), 0);
		nCurrentStamina = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
	end

	local sColor = "630000";

	local nWindedValue = nMaxStamina / 2;
	local nLowHealth = nMaxStamina / 6;
	
	if nCurrentStamina > nWindedValue then
		sColor = "1a6313";
	end

	if nWindedValue > nCurrentStamina and nCurrentStamina > nLowHealth then
		sColor = "a37800";
	end

	return sColor;
end