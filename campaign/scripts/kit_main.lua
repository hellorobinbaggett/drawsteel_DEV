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

	WindowManager.callSafeControlUpdate(self, "notes", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "equipment", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distancebonus", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "speedbonus", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "stabilitybonus", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "disengagebonus", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "stamina", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "meleedamagebonus_tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "meleedamagebonus_tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "meleedamagebonus_tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "rangeddamagebonus_tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "rangeddamagebonus_tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "rangeddamagebonus_tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "signatureabilities", bReadOnly);
	
	notes.setReadOnly(bReadOnly);
end
