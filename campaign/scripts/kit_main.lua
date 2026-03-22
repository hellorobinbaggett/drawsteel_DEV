-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end
function VisDataCleared()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end
function InvisDataAdded()
	self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

function onLockModeChanged(bReadOnly)
	WindowManager.callSafeControlsSetLockMode(self, { "notes", "equipment", "distancebonus" }, bReadOnly);
end

"speedbonus", "stabilitybonus", "disengagebonus", "stamina", "meleedamagebonus_tier1", "meleedamagebonus_tier2", 
	"meleedamagebonus_tier3", "rangeddamagebonus_tier1", "rangeddamagebonus_tier2", "rangeddamagebonus_tier3", bReadOnly);
	"signatureabilities";
	
	notes.setReadOnly(bReadOnly);
end
