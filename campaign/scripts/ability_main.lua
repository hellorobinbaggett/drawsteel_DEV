-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
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

	local bSection1 = false;
	local bSection2 = false;
	local bSection3 = false;
	local bSection4 = false;

	if WindowManager.callSafeControlUpdate(self, "notes", bReadOnly) then bSection1 = true; end;

	if WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "type", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "distance", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "target", bReadOnly) then bSection2 = true; end;

	if WindowManager.callSafeControlUpdate(self, "characteristicoption", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "tier1", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "tier2", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "tier3", bReadOnly) then bSection3 = true; end;
	
	if WindowManager.callSafeControlUpdate(self, "trigger", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "effect", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "special", bReadOnly) then bSection4 = true; end;

	divider1.setVisible(bSection1);
	divider2.setVisible(bSection2);
	divider3.setVisible(bSection3);
	divider4.setVisible(bSection4);

	-- hides fields
	WindowManager.callSafeControlUpdate(self, "notes", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special", bReadOnly);

	-- hidden data
	WindowManager.callSafeControlUpdate(self, "class", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "subclass", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "ancestry", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "abilitytype", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "ability_cost", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "ability_cost_string", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "ability_level", bReadOnly);

end
