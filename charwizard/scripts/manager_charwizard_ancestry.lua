--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

--
--	Data
--

function getAncestryRecord()
	local tAncestry = CharWizardManager.getAncestryData();
	return tAncestry.ancestry;
end
function getAncestryNode()
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return nil;
	end
	return DB.findNode(sRecord);
end
function setAncestryRecord(sRecord)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.ancestry = sRecord;
	if ((sRecord or "") ~= "") then
		tAncestry.bIs2024 = (DB.getValue(DB.findNode(sRecord), "version", "") == "2024");
	else
		tAncestry.bIs2024 = nil;
	end
	CharWizardManager.updateAlerts();
end
function getAncestryRecord()
	local tAncestry = CharWizardManager.getAncestryData();
	return tAncestry.ancestry;
end
function setAncestryRecord(sRecord)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.ancestry = sRecord;
end
function isAncestry2024()
	local tAncestry = CharWizardManager.getAncestryData();
	return tAncestry.bIs2024;
end
function getAncestryName()
	local tAncestry = CharWizardManager.getAncestryData();
	if (tAncestry.ancestry or "") == "" then
		return "";
	end
	return DB.getValue(DB.findNode(tAncestry.ancestry), "name", "");
end
function getAncestryDisplayName()
	local tAncestry = CharWizardManager.getAncestryData();
	if (tAncestry.ancestry or "") == "" then
		return "";
	end
	local sAncestry = DB.getValue(DB.findNode(tAncestry.ancestry), "name", "");
	if (tAncestry.ancestry or "") == "" then
		return sAncestry:upper();
	end
	local sAncestry = DB.getValue(DB.findNode(tAncestry.ancestry), "name", "");
	return string.format("%s (%s)", sAncestry:upper(), sAncestry);
end
function setAncestrySize(s)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.size = s;
end
function setAncestrySpeed(n)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.speed = n;
end
function addAncestrySpecialMove(s, vDist)
	local nDist = math.max(tonumber(vDist) or 0, 0);
	if ((s or "") == "") then
		return;
	end

	local tAncestry = CharWizardManager.getAncestryData();
	local tSplit = StringManager.splitByPattern(tAncestry.speedspecial, ",", true);

	if nDist == 0 then
		if StringManager.contains(tSplit, s) then
			return;
		end
		table.insert(tSplit, s);
	else
		local sNewMove = string.format("%s %d", s, nDist);
		local sPatternMove = string.format("^%s %%d+$", s);
		local bPatternMatch = false;
		for k,s in ipairs(tSplit) do
			local sPatternMatch = s:match(sPatternMove);
			if sPatternMatch then
				if (tonumber(sPatternMatch) or 0) >= nDist then
					return;
				end
				tSplit[k] = sNewMove;
				bPatternMatch = true;
				break;
			end
		end
		if not bPatternMatch then
			table.insert(tSplit, sNewMove);
		end
	end

	tAncestry.speedspecial = table.concat(tSplit, ", ");
end
function setAncestryDarkvision(n)
	local tAncestry = CharWizardManager.getAncestryData();
	if tAncestry.darkvision and (n < tAncestry.darkvision) then
		return;
	end
	tAncestry.darkvision = n;
end
function addAncestryAbilityIncreases(sAbility, nMod)
	if ((sAbility or "") == "") then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.abilityincrease = tAncestry.abilityincrease or {};
	for _,v in ipairs(tAncestry.abilityincrease) do
		if v.ability:lower() == sAbility:lower() then
			v.mod = v.mod + nMod;
			return;
		end
	end
	table.insert(tAncestry.abilityincrease, { ability = sAbility, mod = nMod } );
end
function clearAncestryAbilityIncreases()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.abilityincrease = {};
end
function setAncestryBaseSkills(tSkills)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.skill = tAncestry.skill or {};
	for _,v in pairs(tSkills) do
		table.insert(tAncestry.skill, v);
	end
end
function addAncestrySkillChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.skillchoice = tAncestry.skillchoice or {};
	if StringManager.contains(tAncestry.skillchoice, s) then
		return;
	end
	table.insert(tAncestry.skillchoice, s);
end
function clearAncestrySkillChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.skillchoice = {};
end
function setAncestryBaseLanguages(tLanguages)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.language = tAncestry.language or {};
	for _,v in pairs(tLanguages) do
		table.insert(tAncestry.language, v);
	end
end
function addAncestryLanguageChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.languagechoice = tAncestry.languagechoice or {};
	if StringManager.contains(tAncestry.languagechoice, s) then
		return;
	end
	table.insert(tAncestry.languagechoice, s);
end
function clearAncestryLanguageChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.languagechoice = {};
end
function setAncestryBaseArmorProficiencies(tProfs)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.armorprof = {};
	for _,v in pairs(tProfs) do
		table.insert(tAncestry.armorprof, v);
	end
end
function addAncestryArmorProficiencyChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.armorprofchoice = tAncestry.armorprofchoice or {};
	if StringManager.contains(tAncestry.armorprofchoice, s) then
		return;
	end
	table.insert(tAncestry.armorprofchoice, s);
end
function clearAncestryArmorProficiencyChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.armorprofchoice = {};
end
function setAncestryBaseWeaponProficiencies(tProfs)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.weaponprof = {};
	for _,v in pairs(tProfs) do
		table.insert(tAncestry.weaponprof, v);
	end
end
function addAncestryWeaponProficiencyChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.weaponprofchoice = tAncestry.weaponprofchoice or {};
	if StringManager.contains(tAncestry.weaponprofchoice, s) then
		return;
	end
	table.insert(tAncestry.weaponprofchoice, s);
end
function clearAncestryWeaponProficiencyChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.weaponprofchoice = {};
end
function setAncestryBaseToolProficiencies(tProfs)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.toolprof = {};
	for _,v in pairs(tProfs) do
		table.insert(tAncestry.toolprof, v);
	end
end
function addAncestryToolProficiencyChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.toolprofchoice = tAncestry.toolprofchoice or {};
	if StringManager.contains(tAncestry.toolprofchoice, s) then
		return;
	end
	table.insert(tAncestry.toolprofchoice, s);
end
function clearAncestryToolProficiencyChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.toolprofchoice = {};
end

function addAncestryBaseFeat(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.feats = tAncestry.feats or {};
	table.insert(tAncestry.feats, s);
end
function addAncestryChoiceFeatPath(sPath)
	if (sPath or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.featpaths = tAncestry.featpaths or {};
	table.insert(tAncestry.featpaths, sPath);
end
function removeAncestryChoiceFeatPath(sPath)
	if (sPath or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	for k,v in ipairs(tAncestry.featpaths or {}) do
		if v == sPath then
			table.remove(tAncestry.featpaths, k);
			return;
		end
	end
end

function setAncestrySpellAbility(sAbility)
	local tAncestry = CharWizardManager.getAncestryData();
	if not sAbility then
		tAncestry.spellability = nil;
		return;
	end
	sAbility = sAbility:lower();
	local tAncestry = CharWizardManager.getAncestryData();
	if StringManager.contains(DataCommon.abilities, sAbility) then
		tAncestry.spellability = sAbility;
	else
		tAncestry.spellability = nil;
	end
end
function setAncestryBaseSpells(tSpells)
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.spell = tAncestry.spell or {};
	for _,s in pairs(tSpells) do
		table.insert(tAncestry.spell, s);
	end
end
function addAncestrySpellChoice(s)
	if (s or "") == "" then
		return;
	end
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.spellchoice = tAncestry.spellchoice or {};
	if StringManager.contains(tAncestry.spellchoice, s) then
		return;
	end
	table.insert(tAncestry.spellchoice, s);
end
function clearAncestrySpellChoice()
	local tAncestry = CharWizardManager.getAncestryData();
	tAncestry.spellchoice = {};
end

--
--	Windows
--

function processAncestry(w)
	local _,sRecord = w.shortcut.getValue();

	CharWizardAncestryManager.setAncestryRecord(sRecord);

	local sAncestry = DB.getValue(DB.findNode(sRecord), "name", "");

	local wAncestry = CharWizardManager.getWizardAncestryWindow();
	wAncestry.sub_ancestryselection.setVisible(false);
	wAncestry.button_changeancestry.setVisible(true);
	wAncestry.list_features.setVisible(true);
	wAncestry.ancestry_selection_list.setVisible(true);
	wAncestry.ancestry_selection_header.setVisible(true);
	wAncestry.ancestry_select_header.setValue(sAncestry:upper());

	CharWizardAncestryManager.updateAncestryFields(wAncestry.list_features);
	CharWizardAncestryManager.updateAncestryTraits(wAncestry.list_features);
	CharWizardAncestryManager.setupAncestries(wAncestry.ancestry_selection_list);
	CharWizardManager.updateAlerts();
end
function resetAncestry()
	CharWizardManager.clearAncestryData();

	local wAncestry = CharWizardManager.getWizardAncestryWindow();
	wAncestry.sub_ancestryselection.setVisible(true);
	wAncestry.button_changeancestry.setVisible(false);
	wAncestry.list_features.setVisible(false);
	wAncestry.list_features.closeAll();
	wAncestry.ancestry_selection_list.setVisible(false);
	wAncestry.ancestry_selection_list.closeAll();
	wAncestry.ancestry_selection_header.setVisible(false);
	wAncestry.button_changeancestry.setVisible(false);
	wAncestry.ancestry_select_header.setValue(Interface.getString("charwizard_label_ancestryselection"));

	CharWizardAbilitiesManager.updateAbilities();
	CharWizardDecisionManager.refreshOverallDecisions();
	CharWizardManager.updateAlerts();
end

--
-- Ancestries
--

function collectAncestries()
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return {};
	end

	local tFinalAncestries = {};
	local tAncestries = CharAncestryManager.getAncestryOptions(DB.findNode(sRecord));
	for _,v in ipairs(tAncestries) do
		if not tFinalAncestries[v.text] then
			tFinalAncestries[v.text] = {};
		end

		v.sModule = ModuleManager.getModuleDisplayName(v.sModuleName);
		if StringManager.contains(CharWizardData.module_order_2014, v.sModuleName) then
		local sLegacySuffix = Interface.getString("suffix_legacy");
			if not StringManager.endsWith(v.sModule, sLegacySuffix) then
				v.sModule = string.format("%s %s", v.sModule, sLegacySuffix);
			end
		end

		table.insert(tFinalAncestries[v.text], v);
	end

	return tFinalAncestries;
end
function setupAncestries(w)
	local tAncestries = CharWizardAncestryManager.collectAncestries();
	local nCount = 0;
	for k,v in pairs(tAncestries) do
		nCount = nCount + 1;

		local wAncestry = w.createWindow();
		wAncestry.button_select.setVisible(true);
		wAncestry.name.setValue(k);
		wAncestry.module.setVisible(true);

		local tModules = {};
		for k2,v2 in ipairs(v) do
			local nOrder;
			for k3,v3 in ipairs(CharWizardData.module_order_2024) do
				if v2.sModuleName == v3 then
					nOrder = k2;
					break
				else
					for _,v4 in ipairs(CharWizardData.module_order_2014) do
						if v2.sModuleName == v4 then
							nOrder = k3 + 1;
							break
						end
					end
				end
			end
			if nOrder then
				table.insert(tModules, nOrder, v2.sModule);
			else
				table.insert(tModules, v2.sModule);
			end
		end

		local tFinalModules = {};
		for _,v in pairs(tModules) do
			table.insert(tFinalModules, v);
		end
		wAncestry.module.addItems(tFinalModules);
		wAncestry.module.setVisible(true);

		if #tFinalModules == 1 then
			wAncestry.module.setComboBoxReadOnly(true);
			wAncestry.module.setFrame(nil);
		end

		wAncestry.module.setValue(tFinalModules[1]);
	end

	w.window.ancestry_selection_header.setVisible(nCount > 0);
	w.setVisible(nCount > 0);
end
function processAncestry(w)
	local _,sRecord = w.shortcut.getValue();

	CharWizardAncestryManager.setAncestryRecord(sRecord);

	local wAncestry = CharWizardManager.getWizardAncestryWindow();
	wAncestry.ancestry_selection_list.setVisible(false);
	wAncestry.ancestry_select_header.setValue(CharWizardAncestryManager.getAncestryDisplayName());
	wAncestry.ancestry_selection_header.setVisible(false);
	wAncestry.button_changeancestry.setVisible(true);

	CharWizardAncestryManager.updateAncestryTraits(wAncestry.list_features, true);
end
function resetAncestry(w)
	CharWizardAncestryManager.clearAncestryTraits(w);
	CharWizardAncestryManager.setAncestryRecord(nil);

	local wAncestry = CharWizardManager.getWizardAncestryWindow();
	wAncestry.button_changeancestry.setVisible(false);
	wAncestry.ancestry_selection_header.setVisible(true);
	wAncestry.ancestry_selection_list.setVisible(true);
	wAncestry.ancestry_select_header.setValue(CharWizardAncestryManager.getAncestryDisplayName());

	for _,v in pairs(w.list_features.getWindows()) do
		for _,v2 in pairs(v.list_decisions.getWindows()) do
			if v2.decisiontype.getValue() ~= "asiancestryoption" then
				CharWizardAncestryManager.processAncestryDecision(v2);
			end
		end
	end

	CharWizardAbilitiesManager.updateAbilities();
	CharWizardDecisionManager.refreshOverallDecisions();
	CharWizardManager.updateAlerts();
end

--
--	Fields
--

function updateAncestryFields(w)
	if CharWizardAncestryManager.isAncestry2024() then
		CharWizardAncestryManager.handleAncestrySizeField2024(w);
		CharWizardAncestryManager.handleAncestrySpeedField2024(w);
		CharWizardAncestryManager.handleAncestryLanguage2024(w);
	end
end
function handleAncestrySizeField2024(w)
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return {};
	end

	local sSize = DB.getValue(DB.findNode(sRecord), "size", "");
	local tOptions = CharBuildManager.parseSizesFromString(sSize);
	if #tOptions > 1 then
		local w2 = w.createWindow();
		w2.feature.setValue(Interface.getString("race_label_size"));
		w2.feature_desc.setValue(sSize);

		local w3 = CharWizardDecisionManager.createDecision(w2, { sDecisionType = "size", });
		for _,v in pairs(tOptions) do
			w3.decision_choice.add(v);
		end
	else
		CharWizardAncestryManager.setAncestrySize(tOptions[1]);
	end
end
function handleAncestrySpeedField2024()
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return {};
	end

	local sSpeed = DB.getValue(DB.findNode(sRecord), "speed", ""):match("%d+");
	CharWizardAncestryManager.setAncestrySpeed(tonumber(sSpeed) or 30);
end
function handleAncestryLanguage2024(w)
	local w2 = w.createWindow();
	w2.feature.setValue(Interface.getString("charwizard_label_languages"));
	w2.feature_desc.setValue(Interface.getString("charwizard_message_languages"));

	local tBase, tOptions, nPicks = CharBuildManager.getAncestryLanguages2024()

	CharWizardAncestryManager.setAncestryBaseLanguages(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestryLanguageChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w2, { sDecisionType = "language", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("language");
end

--
-- Traits
--

function clearAncestryTraits()
	local tAncestryTraits = {};
	CharWizardAncestryManager.collectAncestryTraits(tAncestryTraits);

	local tTraits = {};
	for _,v in pairs(tAncestryTraits) do
		tTraits[v.ancestrytrait] = true;
	end

	local wAncestry = CharWizardManager.getWizardAncestryWindow();
	for _,v in ipairs(wAncestry.list_features.getWindows()) do
		local _,sRecord = v.shortcut.getValue();
		if tTraits[sRecord] then
			v.close();
		end
	end
end
function updateAncestryTraits(w, bAncestry)
	local tAncestryTraits = {};
	if bAncestry then
		CharWizardAncestryManager.collectAncestryTraits(tAncestryTraits);
	else
		CharWizardAncestryManager.collectAncestryTraits(tAncestryTraits);
	end

	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local bAbilityScore = false;
	for kTrait,vTrait in pairs(tAncestryTraits) do
		local sParseText = StringManager.trim(DB.getText(DB.findNode(vTrait.ancestrytrait), "text", ""));

		local w2 = w.createWindow();
		w2.feature.setValue(kTrait);
		w2.shortcut.setValue("reference_racialtrait", vTrait.ancestrytrait);
		w2.feature_desc.setValue(DB.getValue(DB.findNode(vTrait.ancestrytrait), "text", ""));

		local sTraitType = StringManager.simplify(kTrait):gsub(StringManager.simplify(Interface.getString("library_recordtype_single_race_subrace")) .. "$", "");
		if bIs2024 then
			if sTraitType == "darkvision" then
				local sDarkVision = sParseText:match("(%d+)");
				if sDarkVision then
					CharWizardAncestryManager.setAncestryDarkvision(tonumber(sDarkVision) or 60);
				end
			elseif sTraitType == "enhanceddarkvision" then
				local sDarkVision = sParseText:match("(%d+)");
				if sDarkVision then
					CharWizardAncestryManager.setAncestryDarkvision(tonumber(sDarkVision) or 120);
				end
			else
				if CharWizardData.tBuildOptionsSpecialSpeed2024[sTraitType] then
					CharWizardAncestryManager.handleAncestrySpeedTrait(w2, sParseText, true);
				end
				if CharWizardData.tBuildOptionsSkill2024[sTraitType] then
					CharWizardAncestryManager.handleAncestrySkills(w2, sTraitType, sParseText);
				end
				if CharWizardData.tBuildOptionsProficiency2024[sTraitType] then
					CharWizardAncestryManager.handleAncestryProficiencies(w2, sTraitType, sParseText);
				end
				if CharWizardData.tBuildOptionsSpells2024[sTraitType] then
					CharWizardAncestryManager.handleAncestrySpells(w2, sTraitType, sParseText);
				end
				if CharWizardData.tBuildOptionsFeats2024[sTraitType] then
					CharWizardAncestryManager.handleAncestryFeat(w2, sTraitType, sParseText);
				end
			end
		else
			if sTraitType:match("abilityscoreincrease") then
				CharWizardAncestryManager.handleAbilityScoreInc(w2, sParseText);
				bAbilityScore = true;
			elseif sTraitType:match("size") then
				CharWizardAncestryManager.handleAncestrySizeTrait(w2, sParseText);
			elseif sTraitType:match("speed") then
				CharWizardAncestryManager.handleAncestrySpeedTrait(w2, sParseText, false);
			elseif sTraitType == "variabletrait" then
				CharWizardDecisionManager.createDecision(w2, { sDecisionType = "variabletrait", });
			elseif sTraitType == "darkvision" then
				local sDarkVision = sParseText:match("(%d+)");
				if sDarkVision then
					CharWizardAncestryManager.setAncestryDarkvision(tonumber(sDarkVision) or 60);
				end
			elseif sTraitType == "superiordarkvision" then
				local sDarkVision = sParseText:match("(%d+)");
				if sDarkVision then
					CharWizardAncestryManager.setAncestryDarkvision(tonumber(sDarkVision) or 120);
				end
			elseif sTraitType == "feat" then
				CharWizardAncestryManager.handleAncestryFeat(w2, sTraitType, sParseText);
			else
				if CharWizardData.aRaceSpecialSpeed[sTraitType] then
					CharWizardAncestryManager.handleAncestrySpeedTrait(w2, sParseText, true);
				end
				if CharWizardData.aRaceSkill[sTraitType] then
					CharWizardAncestryManager.handleAncestrySkills(w2, sTraitType, sParseText);
				end
				if CharWizardData.aRaceProficiency[sTraitType] then
					CharWizardAncestryManager.handleAncestryProficiencies(w2, sTraitType, sParseText);
				end
				if CharWizardData.aRaceLanguages[sTraitType] then
					CharWizardAncestryManager.handleAncestryLanguages(w2, sTraitType, sParseText);
				end
				if CharWizardData.aRaceSpells[sTraitType] then
					CharWizardAncestryManager.handleAncestrySpells(w2, sTraitType, sParseText);
				end
			end
		end
	end

	if not bIs2024 and not bAbilityScore and not bAncestry then
		CharWizardAncestryManager.handleMissingAncestryASI(w);
	end

	CharWizardManager.updateAlerts();
end
function handleMissingAncestryASI(w)
	local w2 = w.createWindow();
	w2.feature.setValue("Ability Score Increase");
	w2.shortcut.setValue();
	w2.feature_desc.setValue();

	CharWizardDecisionManager.createDecision(w2, { sDecisionType = "asiancestryoption", });
end
function collectAncestryTraits(tAncestryTraits)
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return;
	end
	for _,v in pairs(DB.getChildren(DB.findNode(sRecord), "traits")) do
		local sTrait = DB.getValue(v, "name", "");
		if sTrait:lower() ~= "subrace" then
			tAncestryTraits[sTrait] = { ancestrytrait = DB.getPath(v), };
		end
	end
end
function collectAncestryTraits(tAncestryTraits)
	local sRecord = CharWizardAncestryManager.getAncestryRecord();
	if (sRecord or "") == "" then
		return;
	end
	for _,v in pairs(DB.getChildren(DB.findNode(sRecord), "traits")) do
		local sTrait = DB.getValue(v, "name", "");
		sTrait = string.format("%s (%s)", sTrait, Interface.getString("library_recordtype_single_race_subrace"));
		tAncestryTraits[sTrait] = { ancestrytrait = DB.getPath(v), };
	end
end

function handleAbilityScoreInc(w, s)
	w.feature_desc.setValue(s);

	if s:lower():match("alternatively") then
		CharWizardAncestryManager.helperAncestryAbilityScoreGeneric2014(w);
	else
		CharWizardAncestryManager.helperAncestryAbilityScoreSpecific2014(w, s);
	end
end
-- Handle generic ability score option choices (+2/+1 or +1 x3)
function helperAncestryAbilityScoreGeneric2014(w)
	CharWizardDecisionManager.createDecision(w, { sDecisionType = "asiancestryoption", });
end
-- Due to Tasha's rules, set up decisions for every ability increase
function helperAncestryAbilityScoreSpecific2014(w, s)
	local tBase, tAbilitySelect = CharAncestryManager.helperParseAncestryAbilityIncrease2014(s);

	CharWizardAncestryManager.clearAncestryAbilityIncreases();

	local tBaseWindows = {};
	for sAbility, nAbilityAdj in pairs(tBase) do
		tBaseWindows[sAbility] = CharWizardDecisionManager.createDecision(w, { sDecisionType = "asiancestry", nAdj = nAbilityAdj });
	end
	for _,v in pairs(tAbilitySelect) do
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "asiancestry", nAdj = v.nAbilityAdj or 1, nPicks = v.nPicks });
	end
	for sAbility, wDecision in pairs(tBaseWindows) do
		wDecision.decision_choice.setListValue(StringManager.capitalize(sAbility));
	end

	CharWizardAbilitiesManager.updateAbilities();
end

function handleAncestrySizeTrait(w, s)
	local tChoices, sSize = CharWizardAncestryManager.parseAncestrySizeTrait(s);
	if next(tChoices) then
		local w2 = CharWizardDecisionManager.createDecision(w, { sDecisionType = "size", });
		for _,v in pairs(tChoices) do
			w2.decision_choice.add(StringManager.capitalize(v));
		end
	else
		CharWizardAncestryManager.setAncestrySize(sSize);
	end
end
function handleAncestrySpeedTrait(_, s)
	local nSpeed, tSpecial = CharAncestryManager.helperParseAncestrySpeed2014(s);

	CharWizardAncestryManager.setAncestrySpeed(nSpeed);
	for k,v in ipairs(tSpecial) do
		CharWizardAncestryManager.addAncestrySpecialMove(k, v);
	end
end

function handleAncestrySkills(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitSkills(sTrait, s, bIs2024);

	CharWizardAncestryManager.setAncestryBaseSkills(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestrySkillChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "skill", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("skill");
	CharWizardDecisionManager.refreshExpertiseDecision();
end
function handleAncestryProficiencies(w, sTrait, s)
	CharWizardAncestryManager.handleAncestryArmorProficiencies(w, sTrait, s);
	CharWizardAncestryManager.handleAncestryWeaponProficiencies(w, sTrait, s);
	CharWizardAncestryManager.handleAncestryToolProficiencies(w, sTrait, s);
end
function handleAncestryArmorProficiencies(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitArmorProf(sTrait, s, bIs2024)

	CharWizardAncestryManager.setAncestryBaseArmorProficiencies(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestryArmorProficiencyChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "armorprof", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("armorprof");
end
function handleAncestryWeaponProficiencies(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitWeaponProf(sTrait, s, bIs2024)

	CharWizardAncestryManager.setAncestryBaseWeaponProficiencies(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestryWeaponProficiencyChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "weaponprof", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("weaponprof");
end
function handleAncestryToolProficiencies(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitToolProf(sTrait, s, bIs2024)

	CharWizardAncestryManager.setAncestryBaseToolProficiencies(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestryToolProficiencyChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "toolprof", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("toolprof");
end
function handleAncestryLanguages(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitLanguages(sTrait, s, bIs2024)

	CharWizardAncestryManager.setAncestryBaseLanguages(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestryLanguageChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "language", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("language");
end
function handleAncestrySpells(w, sTrait, s)
	local bIs2024 = CharWizardAncestryManager.isAncestry2024();
	local tBase, tOptions, nPicks = CharBuildManager.getAncestryTraitSpells(sTrait, s, bIs2024);

	CharWizardAncestryManager.setAncestryBaseSpells(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardAncestryManager.addAncestrySpellChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w, { sDecisionType = "spell", nPicks = nPicks, tOptions = tOptions, });
	end

	local sAbility = s:match("(%a+) is your spellcasting ability");
	if sAbility then
		CharWizardAncestryManager.setAncestrySpellAbility(sAbility);
	end
end
function handleAncestryFeat(w, _, s)
	local bChoice, tFeats, _, _ = CharWizardAncestryManager.parseAncestryFeats(s);
	for _,v in ipairs(tFeats) do
		CharWizardAncestryManager.addAncestryBaseFeat(v.name);
	end

	if bChoice then
		CharWizardDecisionManager.createDecision(w, { sDecisionType = "feat", sDecisionClass = "decision_sub_ancestryfeat_choice", });
		w.alert.setVisible(true);
	end
end

--
--	Parsing
--

function parseAncestrySizeTrait(s)
	local sSizeText = s:lower();
	local tChoices = {};
	local sSize = nil;

	if sSizeText:match("choice") then
		table.insert(tChoices, "small");
		table.insert(tChoices, "medium");
	else
		sSize = sSizeText:match("your size is (%w+)");
		if not sSize then
			sSize = sSizeText:match("you are (%w+)");
		end
		if not sSize then
			sSize = "Medium";
		end
	end

	return tChoices, sSize;
end
function parseAncestryFeats(s)
	if not s then
		return false, {}, {}, 0;
	end
	s = s:lower();

	local sFeatText = s:match("you gain one feat of your choice");
	if not sFeatText then
		sFeatText = s:match("you gain an [%w%s]+ of your choice");
	end
	if not sFeatText then
		return false, {}, {}, 0;
	end

	local bChoice = false;
	local tAncestryFeats = {};
	local tChoiceFeats = {};
	local nChoices = 1;

	local tAvailableFeats = CharBuildManager.getFeatNames(false);
	local aSortAvailableFeats = {};
	for _,v in pairs(tAvailableFeats) do
		aSortAvailableFeats[v] = "";
	end

	if sFeatText:match("choice") or sFeatText:match("choose") then
		if sFeatText:match("choice: ([^.]+)") or sFeatText:match("feats: ([^.]+)") then
			local sChoiceFeats = sFeatText:match("choice: ([^.]+)");

			if not sChoiceFeats then
				sChoiceFeats = sFeatText:match("feats: ([^.]+)");
			end

			if sChoiceFeats then
				sChoiceFeats = sChoiceFeats:gsub("and ", "");
				sChoiceFeats = sChoiceFeats:gsub("or ", "");

				local aWords = StringManager.split(sChoiceFeats, ",")
				for _,sWord in pairs(aWords) do
					local sFeatLower = StringManager.trim(sWord):lower();
					if aSortAvailableFeats[sFeatLower] then
						table.insert(tChoiceFeats, sWord);
					end
					if sWord == "two" then
						nChoices = 2;
					end
				end
			end
		else
			if sFeatText:match("of your choice") then
				if sFeatText:match("two ") then
					nChoices = 2;
				end
			end
		end

		bChoice = true;
	else
		sFeatText = sFeatText:gsub(" and ", " ")

		local aWords = StringManager.split(sFeatText, " ")
		for _,t in pairs(aWords) do
			if aSortAvailableFeats[t] then
				table.insert(tAncestryFeats, t);
			end
		end
	end

	if not bChoice then
		return bChoice, tAncestryFeats, nil, nChoices;
	end

	local aFinalFeats = {};
	for _,v in pairs(tAvailableFeats) do
		table.insert(aFinalFeats, v);
	end

	if #tChoiceFeats > 0 then
		local aFinalChoiceFeats = {};
		for _,v in pairs(tChoiceFeats) do
			v = StringManager.trim(v);
			if StringManager.contains(aFinalFeats, v) then
				table.insert(aFinalChoiceFeats, v);
			end
		end

		return bChoice, tAncestryFeats, aFinalChoiceFeats, nChoices;
	end
	return bChoice, tAncestryFeats, aFinalFeats, nChoices;
end

--
--	Decisions
--

local _bUpdatingDecision = false;
function processAncestryDecision(w)
	if _bUpdatingDecision then
		return
	end
	_bUpdatingDecision = true;

	local sDecisionType = w.decisiontype.getValue();
	if sDecisionType == "asiancestryoption" then
		CharWizardAncestryManager.processAncestryDecisionASIOption(w);
	elseif sDecisionType == "asiancestry" then
		CharWizardAncestryManager.processAncestryDecisionASI(w);
	elseif sDecisionType == "skill" then
		CharWizardAncestryManager.processAncestryDecisionSkill(w);
	elseif sDecisionType == "armorprof" then
		CharWizardAncestryManager.processAncestryDecisionArmorProficiency(w);
	elseif sDecisionType == "weaponprof" then
		CharWizardAncestryManager.processAncestryDecisionWeaponProficiency(w);
	elseif sDecisionType == "toolprof" then
		CharWizardAncestryManager.processAncestryDecisionToolProficiency(w);
	elseif sDecisionType == "language" then
		CharWizardAncestryManager.processAncestryDecisionLanguage(w);
	elseif sDecisionType == "feat" then
		CharWizardAncestryManager.processAncestryDecisionFeat(w);
	elseif sDecisionType == "spell" then
		CharWizardAncestryManager.processAncestryDecisionSpell(w);
	elseif sDecisionType == "variabletrait" then
		CharWizardAncestryManager.processAncestryDecisionVariableTrait(w);
	elseif sDecisionType == "size" then
		CharWizardManager.setSize(w.decision_choice.getValue());
	end

	_bUpdatingDecision = false;

	CharWizardManager.updateAlerts();
end
function processAncestryDecisionASIOption(wDecision)
	local wFeature = wDecision.windowlist.window;
	CharWizardAncestryManager.clearAncestryAbilityIncreases();

	for _,w in pairs(wDecision.windowlist.getWindows()) do
		if w.decisiontype.getValue() == "asiancestry" then
			w.close();
		end
	end

	local tAbilities = {};
	for _,v in pairs(DataCommon.abilities) do
		table.insert(tAbilities, StringManager.capitalize(v));
	end

	local sDecisionChoice = wDecision.decision_choice.getValue():lower();
	if sDecisionChoice:match("option 1") then
		CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asiancestry", nAdj = 2, tOptions = tAbilities });
		CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asiancestry", nAdj = 1, tOptions = tAbilities });
	else
		CharWizardDecisionManager.createDecisions(wFeature, { sDecisionType = "asiancestry", nAdj = 1, nPicks = 3, tOptions = tAbilities });
	end

	CharWizardAbilitiesManager.updateAbilities();
end
function processAncestryDecisionASI(wDecision)
	CharWizardAncestryManager.clearAncestryAbilityIncreases();

	local tAbilityMap = CharWizardDecisionManager.processAbilityDecision(wDecision, true);
	for sAbility,nMod in pairs(tAbilityMap) do
		CharWizardAncestryManager.addAncestryAbilityIncreases(sAbility, nMod);
	end

	CharWizardAbilitiesManager.updateAbilities();
end
function processAncestryDecisionSkill(wDecision)
	CharWizardAncestryManager.clearAncestrySkillChoice();

	local tMap = CharWizardDecisionManager.processSkillDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestrySkillChoice(s);
	end

	CharWizardDecisionManager.refreshExpertiseDecision();
end
function processAncestryDecisionArmorProficiency(wDecision)
	CharWizardAncestryManager.clearAncestryArmorProficiencyChoice();

	local tMap = CharWizardDecisionManager.processArmorProfDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestryArmorProficiencyChoice(s);
	end
end
function processAncestryDecisionWeaponProficiency(wDecision)
	CharWizardAncestryManager.clearAncestryWeaponProficiencyChoice();

	local tMap = CharWizardDecisionManager.processWeaponProfDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestryWeaponProficiencyChoice(s);
	end
end
function processAncestryDecisionToolProficiency(wDecision)
	CharWizardAncestryManager.clearAncestryToolProficiencyChoice();

	local tMap = CharWizardDecisionManager.processToolProfDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestryToolProficiencyChoice(s);
	end
end
function processAncestryDecisionLanguage(wDecision)
	CharWizardAncestryManager.clearAncestryLanguageChoice();

	local tMap = CharWizardDecisionManager.processLanguageDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestryLanguageChoice(s);
	end
end
function processAncestryDecisionVariableTrait(wDecision)
	local sDecisionChoice = wDecision.decision_choice.getValue():lower();
	if sDecisionChoice:match("darkvision") then
		CharWizardAncestryManager.setAncestryDarkvision(60);
		CharWizardAncestryManager.clearAncestrySkillChoice();
		for _,w in pairs(wDecision.windowlist.getWindows()) do
			if w.decisiontype.getValue() == "skill" then
				w.close();
			end
		end
	else
		CharWizardDecisionManager.createDecision(wDecision.windowlist.window, { sDecisionType = "skill", tOptions = CharBuildManager.getSkillNames()  });
	end

	CharWizardDecisionManager.refreshOverallDecision("skill");
end
function processAncestryDecisionSpell(wDecision)
	CharWizardAncestryManager.clearAncestrySpellChoice();

	local tMap = CharWizardDecisionManager.processSpellDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardAncestryManager.addAncestrySpellChoice(s);
	end
end

function processAncestryDecisionFeat(wSelection)
	local sFeat = wSelection.name.getValue();
	local sFeatClass, sFeatPath = wSelection.shortcut.getValue();

	CharWizardAncestryManager.addAncestryChoiceFeatPath(sFeatPath);

	local wDecision = wSelection.windowlist.window.parentcontrol.window;
	wDecision.choice.setValue(sFeat);
	wDecision.choicelink.setValue(sFeatClass, sFeatPath);
	wDecision.button_modify.setVisible(true);
	wDecision.sub_decision_choice.setVisible(false);
	wDecision.checkOutstandingDecisions();

	CharWizardManager.updateAlerts();
end
function resetAncestryDecisionFeat(wDecision)
	local _,sFeatPath = wDecision.choicelink.getValue();

	CharWizardAncestryManager.removeAncestryChoiceFeatPath(sFeatPath);

	wDecision.choice.setValue();
	wDecision.choicelink.setValue();
	wDecision.button_modify.setVisible(false);
	wDecision.sub_decision_choice.setVisible(true);
	WindowManager.callInnerWindowFunction(wDecision, "buildFeats");

	CharWizardManager.updateAlerts();
end
