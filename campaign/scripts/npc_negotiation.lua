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
	WindowManager.callSafeControlUpdate(self, "motivations", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "pitfalls", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "impressionscore", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "languge_name", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "languge_name_label", bReadOnly);


	WindowManager.callSafeControlUpdate(self, "sub_pack", bReadOnly, bID);
end