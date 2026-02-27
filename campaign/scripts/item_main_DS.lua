--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	self.onStateChanged();
end

function onLockModeChanged()
	self.onStateChanged();
end
function onIDModeChanged()
	self.onStateChanged();
end

function onStateChanged()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = RecordDataManager.getIDState("item", nodeRecord);
	
	WindowManager.callSafeControlsSetLockMode(self, { "notes", "description", }, bReadOnly);
	WindowManager.callSafeControlsSetVisible(self, { "notes", "description", }, bID);

    local bSection1 = false;
	if WindowManager.callSafeControlUpdate(self, "type", bReadOnly) then bSection1 = true; end;
    if WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly) then bSection1 = true; end;
	if WindowManager.callSafeControlUpdate(self, "prerequisite", bReadOnly) then bSection1 = true; end;
	if WindowManager.callSafeControlUpdate(self, "projectroll", bReadOnly) then bSection1 = true; end;
	if WindowManager.callSafeControlUpdate(self, "projectrollcharacteristic", bReadOnly) then bSection1 = true; end;
	if WindowManager.callSafeControlUpdate(self, "projectgoal", bReadOnly) then bSection1 = true; end;
	-- hides fields
	WindowManager.callSafeControlUpdate(self, "type", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "prerequisite", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "projectroll", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "projectrollcharacteristic", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "projectgoal", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "sub_pack", bReadOnly, bID);
end

function onDrop(_, _, draginfo)
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	if bReadOnly then
		return false;
	end
	return ItemManager.handleAnyDropOnItemRecord(nodeRecord, draginfo);
end
