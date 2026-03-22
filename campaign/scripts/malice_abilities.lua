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

	WindowManager.callSafeControlUpdate(self, "malice_mod", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "malice_mod_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_1", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "malice_mod_1_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_2", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "malice_mod_1_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_3", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "sub_pack", bReadOnly, bID);
end