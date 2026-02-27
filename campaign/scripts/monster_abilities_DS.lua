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

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);
	local tFields = { 
		"level_name", "organization_name",
		"ev", "keywords_name"
	};
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);

	local bSection1 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "abilityname", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "type", bReadOnly, true) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "target", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "characteristic", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "tier1", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "tier2", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "tier3", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "trigger", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "effect", bReadOnly) then bSection1 = true; end;
		if WindowManager.callSafeControlUpdate(self, "special", bReadOnly) then bSection1 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "abilityname", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "type", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "characteristic", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "tier1", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "tier2", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "tier3", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "effect", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "special", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "reach", bReadOnly, true);
	end
end
