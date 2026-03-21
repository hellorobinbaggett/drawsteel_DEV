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

-- ABILITY 1
	local bSection1 = false;
	local bSection2 = false;
	local bSection3 = false;
	local bSection4 = false;
	if WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability", bReadOnly) then bSection2 = true; end;if WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_keywords", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_type", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_distance", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_target", bReadOnly) then bSection2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_characteristic_label", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_mod", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier1", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier2", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier3", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_trigger", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_effect", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_special", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string", bReadOnly) then bSection4 = true; end;
	-- hides fields
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_keywords", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_type", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_mod", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string", bReadOnly);


-- ABILITY 2
	local bSection1_2 = false;
	local bSection2_2 = false;
	local bSection3_2 = false;
	local bSection4_2 = false;
	if WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_2", bReadOnly) then bSection2_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_keywords_2", bReadOnly) then bSection2_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_type_2", bReadOnly) then bSection2_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_distance_2", bReadOnly) then bSection2_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_target_2", bReadOnly) then bSection2_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_mod_2", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_characteristic_label_2", bReadOnly) then bSection3_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier1_2", bReadOnly) then bSection3_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier2_2", bReadOnly) then bSection3_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier3_2", bReadOnly) then bSection3_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_trigger_2", bReadOnly) then bSection4_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_effect_2", bReadOnly) then bSection4_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_special_2", bReadOnly) then bSection4_2 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_2", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_2", bReadOnly) then bSection4 = true; end;
	-- hides fields
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_keywords_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_type_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_mod_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_2", bReadOnly);


-- ABILITY 3
	local bSection1_3 = false;
	local bSection2_3 = false;
	local bSection3_3 = false;
	local bSection4_3 = false;
	if WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_3", bReadOnly) then bSection2_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_keywords_3", bReadOnly) then bSection2_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_type_3", bReadOnly) then bSection2_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_distance_3", bReadOnly) then bSection2_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_target_3", bReadOnly) then bSection2_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_mod_3", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_characteristic_label_3", bReadOnly) then bSection3_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier1_3", bReadOnly) then bSection3_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier2_3", bReadOnly) then bSection3_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier3_3", bReadOnly) then bSection3_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_trigger_3", bReadOnly) then bSection4_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_effect_3", bReadOnly) then bSection4_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_special_3", bReadOnly) then bSection4_3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_3", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_3", bReadOnly) then bSection4 = true; end;
	-- hides fields
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_keywords_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_type_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_mod_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_3", bReadOnly);

-- ABILITY 4
	local bSection1_4 = false;
	local bSection2_4 = false;
	local bSection3_4 = false;
	local bSection4_4 = false;
	if WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_4", bReadOnly) then bSection2_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_keywords_4", bReadOnly) then bSection2_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_type_4", bReadOnly) then bSection2_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_distance_4", bReadOnly) then bSection2_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_target_4", bReadOnly) then bSection2_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_mod_4", bReadOnly) then bSection3 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_characteristic_label_4", bReadOnly) then bSection3_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier1_4", bReadOnly) then bSection3_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier2_4", bReadOnly) then bSection3_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_tier3_4", bReadOnly) then bSection3_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_trigger_4", bReadOnly) then bSection4_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_effect_4", bReadOnly) then bSection4_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_special_4", bReadOnly) then bSection4_4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_4", bReadOnly) then bSection4 = true; end;
	if WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_4", bReadOnly) then bSection4 = true; end;
	-- hides fields
	WindowManager.callSafeControlUpdate(self, "malice_abilityname_ability_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_keywords_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_type_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_distance_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_target_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_mod_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier1_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier2_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_tier3_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_trigger_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_effect_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_special_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "malice_ability_cost_string_4", bReadOnly);

end