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
	WindowManager.callSafeControlsSetLockMode(self, { 
		"malice_mod", "malice_tier1", "malice_tier2", "malice_tier3", "malice_trigger", "malice_effect", "malice_special", 
		"malice_ability_cost", "malice_ability_cost_string", "malice_abilityname_ability", "malice_keywords", "malice_type", 
		"malice_distance", "malice_target", "malice_mod", "malice_tier1", "malice_tier2", "malice_tier3", "malice_trigger", 
		"malice_effect", "malice_special", "malice_ability_cost", "malice_ability_cost_string",

		"malice_mod_1", "malice_tier1_1", "malice_tier2_1", "malice_tier3_1", "malice_trigger_1", "malice_effect_1", "malice_special_1", 
		"malice_ability_cost_1", "malice_ability_cost_string_1", "malice_abilityname_ability_1", "malice_keywords_1", "malice_type_1", 
		"malice_distance_1", "malice_target_1", "malice_mod_1", "malice_tier1_1", "malice_tier2_1", "malice_tier3_1", "malice_trigger_1", 
		"malice_effect_1", "malice_special_1", "malice_ability_cost_1", "malice_ability_cost_string",

		"malice_mod_2", "malice_tier1_2", "malice_tier2_2", "malice_tier3_2", "malice_trigger_2", "malice_effect_2", "malice_special_2", 
		"malice_ability_cost_2", "malice_ability_cost_string_2", "malice_abilityname_ability_2", "malice_keywords_2", "malice_type_2", 
		"malice_distance_2", "malice_target_2", "malice_mod_2", "malice_tier1_2", "malice_tier2_2", "malice_tier3_2", "malice_trigger_2", 
		"malice_effect_2", "malice_special_2", "malice_ability_cost_2", "malice_ability_cost_string",

		"malice_mod_3", "malice_tier1_3", "malice_tier2_3", "malice_tier3_3", "malice_trigger_3", "malice_effect_3", "malice_special_3", 
		"malice_ability_cost_3", "malice_ability_cost_string_3", "malice_abilityname_ability_3", "malice_keywords_3", "malice_type_3", 
		"malice_distance_3", "malice_target_3", "malice_mod_3", "malice_tier1_3", "malice_tier2_3", "malice_tier3_3", "malice_trigger_3", 
		"malice_effect_3", "malice_special_3", "malice_ability_cost_3", "malice_ability_cost_string"

	}, bReadOnly);
end