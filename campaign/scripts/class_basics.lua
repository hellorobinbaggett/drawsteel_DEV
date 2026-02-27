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

	WindowManager.callSafeControlUpdate(self, "basicnotes", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "startingStamina", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "staminaPerLevel", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "startingRecoveries", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingMight", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingAgility", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingReason", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingIntuition", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingPresence", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingMight3", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingAgility3", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingReason3", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingIntuition3", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingPresence3", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingMight2", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingAgility2", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingReason2", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingIntuition2", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "startingPresence2", bReadOnly);
end
