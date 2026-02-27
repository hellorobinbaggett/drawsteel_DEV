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
	if WindowManager.callSafeControlUpdate(self, "abilityname", bReadOnly) then bSection1 = true; end;
	local bSection2 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_2", bReadOnly) then bSection2 = true; end;
	local bSection3 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_3", bReadOnly) then bSection3 = true; end;
	local bSection4 = false
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_4", bReadOnly) then bSection4 = true; end;
	local bSection5 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_5", bReadOnly) then bSection5 = true; end;
	local bSection6 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_6", bReadOnly) then bSection6 = true; end;
	local bSection7 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_7", bReadOnly) then bSection7 = true; end;
	local bSection8 = false;
	if WindowManager.callSafeControlUpdate(self, "abilityname_ability_8", bReadOnly) then bSection8 = true; end;

    divider1.setVisible(bSection1);
	divider2.setVisible(bSection2);
	divider3.setVisible(bSection3);
	divider4.setVisible(bSection4);
	divider5.setVisible(bSection5);
	divider5.setVisible(bSection6);
	divider5.setVisible(bSection7);
	divider5.setVisible(bSection8);

    WindowManager.callSafeControlUpdate(self, "abilityname", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "keywords", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "cost", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "class", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "subclass", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "abilitytype", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "abilitylevel", bReadOnly);

    WindowManager.callSafeControlUpdate(self, "abilityname_ability_2", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_2", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_2", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "abilityname_ability_3", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_3", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_3", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "abilityname_ability_4", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_4", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_4", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "abilityname_ability_5", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_5", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_5", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "abilityname_ability_6", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_6", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_6", bReadOnly);

	WindowManager.callSafeControlUpdate(self, "abilityname_ability_7", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_7", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_7", bReadOnly);
	
	WindowManager.callSafeControlUpdate(self, "abilityname_ability_8", bReadOnly);
    WindowManager.callSafeControlUpdate(self, "keywords_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "type_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "distance_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "target_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "characteristic_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier1_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier2_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "tier3_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "trigger_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "effect_8", bReadOnly);
	WindowManager.callSafeControlUpdate(self, "special_8", bReadOnly);

	
end
