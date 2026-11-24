--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function addAncestry(nodeChar, sRecord, tData)
	local rAdd = CharBuildDropManager.helperBuildAddStructure(nodeChar, "reference_ancestry", sRecord, tData);
	CharAncestryManager.helperResolveAncestryOnAncestryDrop(rAdd);
end
function addAncestry(nodeChar, sRecord, tData)
	local rAdd = CharBuildDropManager.helperBuildAddStructure(nodeChar, "reference_subancestry", sRecord, tData);
	CharAncestryManager.helperResolveAncestryOnAncestryDrop(rAdd);
end
function addAncestryTrait(nodeChar, sRecord, tData)
	local rAdd = CharBuildDropManager.helperBuildAddStructure(nodeChar, "reference_racialtrait", sRecord, tData);
	CharAncestryManager.helperAddAncestryTraitMain(rAdd);
end

function helperResolveAncestryOnAncestryDrop(rAdd)
	if not rAdd then
		return;
	end
	local tOptions = CharAncestryManager.getAncestryOptions(rAdd.nodeSource, rAdd.bSource2024);
	if #tOptions == 0 then
		CharAncestryManager.helperAddAncestry(rAdd);
		return;
	end

	if #tOptions == 1 then
		-- Automatically select only ancestry
		rAdd.sAncestryPath = tOptions[1].linkrecord;
		CharAncestryManager.helperAddAncestry(rAdd);
		return;
	end

	local tDialogData = {
		title = Interface.getString("char_build_title_selectancestry"),
		msg = Interface.getString("char_build_message_selectancestry"),
		options = tOptions,
		callback = CharAncestryManager.callbackResolveAncestryOnAncestryDrop,
		custom = rAdd,
	};
	DialogManager.requestSelectionDialog(tDialogData);
end
function callbackResolveAncestryOnAncestryDrop(_, rAdd, tSelectionLinks)
	if not tSelectionLinks or (#tSelectionLinks ~= 1) then
		CharManager.outputUserMessage("char_error_addancestry");
		return;
	end
	rAdd.sAncestryPath = tSelectionLinks[1].linkrecord;
	CharAncestryManager.helperAddAncestry(rAdd);
end
function helperResolveAncestryOnAncestryDrop(rAdd)
	if not rAdd then
		return;
	end
	local sAncestryName, nodeAncestry = CharAncestryManager.getAncestryFromAncestry(rAdd.sSourceName, rAdd.bSource2024);
	if not nodeAncestry or ((sAncestryName or "") == "") then
		ChatManager.SystemMessageResource("char_error_missingancestryfromancestry");
		return;
	end

	local rAncestryAdd = {
		nodeSource = nodeAncestry,
		sSourceClass = "reference_ancestry",
		sSourceName = sAncestryName,
		nodeChar = rAdd.nodeChar,
		sCharName = rAdd.sCharName,
		sAncestryPath = DB.getPath(rAdd.nodeSource),
	};
	CharAncestryManager.helperAddAncestry(rAncestryAdd);
end

function getAncestryOptions(nodeAncestry)
	if not nodeAncestry then
		return {};
	end
	local bSource2024 = (DB.getValue(nodeAncestry, "version", "") == "2024");
	if not bSource2024 and (DB.getValue(nodeAncestry, "ignoresubancestry", 0) == 1) then
		return {};
	end

	local sAncestryName = StringManager.trim(DB.getValue(nodeAncestry, "name", ""));
	if sAncestryName == "" then
		return {};
	end

	local tAncestryFilters = {
		{ sField = "ancestry", sValue = sAncestryName, bIgnoreCase = true, },
		{ sField = "version", sValue = (bSource2024 and "2024" or ""), },
	};
	if bSource2024 then
		return RecordManager.getRecordOptionsByFilter("ancestry_subancestry", tAncestryFilters, true);
	end

	local tOptions = {};
	RecordManager.callForEachRecordByFilter("ancestry_subancestry", tAncestryFilters, CharAncestryManager.helperGetAncestryExternalAncestryOption, tOptions);
	if not bSource2024 then
		local tAncestryFilters = {
			{ sField = "name", sValue = sAncestryName, bIgnoreCase = true, },
			{ sField = "version", sValue = (bSource2024 and "2024" or ""), },
		};
		RecordManager.callForEachRecordByFilter("ancestry", tAncestryFilters, CharAncestryManager.helperGetAncestryEmbeddedAncestryOption, tOptions);
	end
	table.sort(tOptions, function(a,b) return a.text < b.text; end);
	return tOptions;
end
function helperGetAncestryExternalAncestryOption(node, tOptions)
	local sName = StringManager.trim(DB.getValue(node, "name", ""));
	if sName ~= "" then
		table.insert(tOptions, { text = sName, linkclass = "reference_subancestry", linkrecord = DB.getPath(node), });
	end
end
function helperGetAncestryEmbeddedAncestryOption(nodeAncestry, tOptions)
	for _,node in ipairs(DB.getChildList(nodeAncestry, "subancestrys")) do
		local sName = StringManager.trim(DB.getValue(node, "name", ""));
		if sName ~= "" then
			table.insert(tOptions, { text = sName, linkclass = "reference_subancestry", linkrecord = DB.getPath(node), });
		end
	end
end

function getAncestryFromAncestry(sAncestryName, bSource2024)
	local tOptions = {};

	local tAncestryFilters = {
		{ sField = "name", sValue = sAncestryName, bIgnoreCase = true, },
		{ sField = "version", sValue = (bSource2024 and "2024" or ""), },
	};
	local nodeExternalAncestry = RecordManager.findRecordByFilter("ancestry_subancestry", tAncestryFilters);
	if nodeExternalAncestry then
		local tAncestryFilters = {
			{ sField = "name", sValue = DB.getValue(nodeExternalAncestry, "ancestry", ""), bIgnoreCase = true, },
			{ sField = "version", sValue = (bSource2024 and "2024" or ""), },
		};
		RecordManager.callForEachRecordByFilter("ancestry", tAncestryFilters, CharAncestryManager.helperGetAncestryFromAncestryDirect, tOptions);
	elseif not bSource2024 then
		RecordManager.callForEachRecord("ancestry", CharAncestryManager.helperGetAncestryFromAncestryEmbedded, tOptions, sAncestryName, bSource2024);
	end

	if #tOptions > 0 then
		local sAncestryName = StringManager.trim(DB.getValue(tOptions[1], "name", ""));
		return sAncestryName, tOptions[1];
	end

	return "", nil;
end
function helperGetAncestryFromAncestryDirect(node, tOptions)
	if (DB.getValue(node, "version", "") ~= "2024") and (DB.getValue(node, "ignoresubancestry", 0) == 1) then
		return;
	end
	table.insert(tOptions, node);
end
function helperGetAncestryFromAncestryEmbedded(node, tOptions, sAncestryName, bSource2024)
	local bRecord2024 = (DB.getValue(node, "version", "") == "2024");
	if bRecord2024 ~= bSource2024 then
		return;
	end
	if not bRecord2024 and (DB.getValue(node, "ignoresubancestry", 0) == 1) then
		return;
	end

	local sAncestryNameLower = StringManager.simplify(sAncestryName);
	for _,nodeAncestry in ipairs(DB.getChildList(node, "subancestrys")) do
		if StringManager.simplify(DB.getValue(nodeAncestry, "name", "")) == sAncestryNameLower then
			table.insert(tOptions, node);
		end
	end
end

function helperAddAncestry(rAdd)
	CharAncestryManager.helperAddAncestryMain(rAdd);
	CharAncestryManager.helperAddAncestry(rAdd);
end
function helperAddAncestryMain(rAdd)
	if not rAdd then
		return;
	end

	-- Notification
	ChatManager.SystemMessageResource("char_abilities_message_ancestryadd", rAdd.sSourceName, rAdd.sCharName);

	-- Set name and link
	DB.setValue(rAdd.nodeChar, "ancestry", "string", rAdd.sSourceName);
	DB.setValue(rAdd.nodeChar, "ancestrylink", "windowreference", "reference_ancestry", DB.getPath(rAdd.nodeSource));
	DB.setValue(rAdd.nodeChar, "ancestryname", "string", rAdd.sSourceName);
	DB.setValue(rAdd.nodeChar, "ancestryversion", "string", DB.getValue(rAdd.nodeSource, "version", ""));
	DB.setValue(rAdd.nodeChar, "subancestrylink", "windowreference", "", "");

	CharAncestryManager.helperAddAncestryMainStats(rAdd);

	-- Add ancestry traits
	for _,v in ipairs(DB.getChildList(rAdd.nodeSource, "traits")) do
		CharAncestryManager.addAncestryTrait(rAdd.nodeChar, DB.getPath(v), { bWizard = rAdd.bWizard });
	end
end
function helperAddAncestryMainStats(rAdd)
	if not rAdd or rAdd.bWizard then
		return;
	end

	if rAdd.bSource2024 then
		CharBuildDropManager.handleSizeField2024(rAdd);
		CharBuildDropManager.handleSpeedField2024(rAdd);
		CharBuildDropManager.handleAncestryLanguage2024(rAdd);
	end
end
function helperAddAncestry(rAdd)
	if not rAdd or ((rAdd.sAncestryPath or "") == "") then
		return;
	end
	local nodeAncestry = DB.findNode(rAdd.sAncestryPath);
	if not nodeAncestry then
		ChatManager.SystemMessageResource("char_error_missingancestry");
		return;
	end

	local sAncestryName = DB.getValue(nodeAncestry, "name", "");

	-- Notification
	ChatManager.SystemMessageResource("char_abilities_message_ancestryadd", sAncestryName, rAdd.sCharName);

	-- Update ancestry name and ancestry link
	if sAncestryName:match(rAdd.sSourceName) then
		DB.setValue(rAdd.nodeChar, "ancestry", "string", sAncestryName);
	else
		DB.setValue(rAdd.nodeChar, "ancestry", "string", string.format("%s (%s)", rAdd.sSourceName, sAncestryName));
	end
	DB.setValue(rAdd.nodeChar, "subancestrylink", "windowreference", "reference_subancestry", rAdd.sAncestryPath);
	DB.setValue(rAdd.nodeChar, "subancestryname", "string", sAncestryName);
	DB.setValue(rAdd.nodeChar, "subancestryversion", "string", DB.getValue(nodeAncestry, "version", ""));

	-- Add ancestry traits
	for _,v in ipairs(DB.getChildList(nodeAncestry, "traits")) do
		CharAncestryManager.addAncestryTrait(rAdd.nodeChar, DB.getPath(v), { bWizard = rAdd.bWizard });
	end
end

function getAncestryPowerGroupByName(sAncestry)
	return Interface.getString("char_ancestry_powergroup"):format(sAncestry or "");
end
function getTraitAncestryName(rAdd)
	local s = DB.getValue(rAdd.nodeSource, "...ancestry", "");
	if s ~= "" then
		return s;
	end
	return DB.getValue(rAdd.nodeSource, "...name", "");
end
function getTraitSpellGroup(rAdd)
	return Interface.getString("char_spell_powergroup"):format(CharAncestryManager.getTraitAncestryName(rAdd));
end
function getTraitPowerGroup(rAdd)
	return CharAncestryManager.getAncestryPowerGroupByName(CharAncestryManager.getTraitAncestryName(rAdd));
end

function helperAddAncestryTraitMain(rAdd)
	CharBuildDropManager.addFeature(rAdd);
end
function checkAncestryTraitSkipAdd(rAdd)
	if rAdd.bSource2024 then
		if CharWizardData.tBuildOptionsNoAdd2024[rAdd.sSourceType] then
			return true;
		end
	else
		if CharWizardData.tBuildOptionsNoAdd2014[rAdd.sSourceType] then
			return true;
		end
		if rAdd.bWizard then
			if CharWizardData.aAncestryTraitNoAdd[rAdd.sSourceType] then
				return true;
			end
			if CharWizardData.aAncestrySpecialSpeed[rAdd.sSourceType] then
				return true;
			end
		end
	end
	return false;
end
function addAncestryTraitStandard(rAdd)
	local nodeTraitList = DB.createChild(rAdd.nodeChar, "traitlist");
	if not nodeTraitList then
		return nil;
	end

	local nodeNewTrait = DB.createChildAndCopy(nodeTraitList, rAdd.nodeSource);
	if not nodeNewTrait then
		return nil;
	end
	DB.setValue(nodeNewTrait, "locked", "number", 1);

	ChatManager.SystemMessageResource("char_abilities_message_traitadd", rAdd.sSourceName, rAdd.sCharName);
	return nodeNewTrait;
end
function checkAncestryTraitSpecialHandling(rAdd)
	if not rAdd then
		return true;
	end

	if rAdd.bSource2024 then
		return CharAncestryManager.helperCheckAncestryTraitSpecialHandling2024(rAdd);
	else
		return CharAncestryManager.helperCheckAncestryTraitSpecialHandling2014(rAdd);
	end
end
function helperCheckAncestryTraitSpecialHandling2024(rAdd)
	if not rAdd.bWizard then
		if rAdd.sSourceType == "versatile" then
			CharAncestryManager.helperAddAncestryTraitVersatileDrop2024(rAdd);
			return true;
		end
	end

	if rAdd.sSourceType == "darkvision" or rAdd.sSourceType == "enhanceddarkvision" then
		CharAncestryManager.helperAddAncestryTraitDarkvisionDrop(rAdd);
	elseif rAdd.sSourceType == "enhancedspeed" then
		CharAncestryManager.helperAddAncestryTraitEnhancedSpeedDrop(rAdd);
	elseif rAdd.sSourceType == "dwarventoughness" then
		CharAncestryManager.applyDwarvenToughness(rAdd.nodeChar, true);
	else
		return false;
	end
	return true;
end
function helperCheckAncestryTraitSpecialHandling2014(rAdd)
	if rAdd.sSourceType == "abilityscoreincrease" then
		CharAncestryManager.helperAddAncestryTraitAbilityIncreaseDrop2014(rAdd);
	elseif rAdd.sSourceType == "size" then
		CharAncestryManager.helperAddAncestryTraitSizeDrop2014(rAdd);
	elseif rAdd.sSourceType == "speed" then
		CharAncestryManager.helperAddAncestryTraitSpeedDrop2014(rAdd);
	elseif rAdd.sSourceType == "fleetoffoot" then
		CharAncestryManager.helperAddAncestryTraitEnhancedSpeedDrop(rAdd);
	elseif rAdd.sSourceType == "darkvision" or rAdd.sSourceType == "superiordarkvision" then
		CharAncestryManager.helperAddAncestryTraitDarkvisionDrop(rAdd);
	elseif rAdd.sSourceType == "languages" then
		CharAncestryManager.helperAddAncestryTraitLanguagesDrop2014(rAdd);
	elseif rAdd.sSourceType == "extralanguage" then
		CharBuildDropManager.pickLanguage(rAdd.nodeChar, nil, 1, { bWizard = rAdd.bWizard, bSource2024 = rAdd.bSource2024, });
	elseif rAdd.sSourceType == "catsclaws" then
		CharAncestryManager.helperAddAncestryTraitCatsClaws2014(rAdd);
	elseif rAdd.sSourceType == "stonecunning" then
		-- Note: Bypass due to false positive in skill proficiency detection
	elseif rAdd.sSourceType == "dwarventoughness" then
		CharAncestryManager.applyDwarvenToughness(rAdd.nodeChar, true);
	else
		if CharArmorManager.isNaturalArmorTrait(rAdd.sSourceName) then
			CharArmorManager.calcItemArmorClass(rAdd.nodeChar);
		end
		return false;
	end
	return true;
end

function helperAddAncestryTraitDarkvisionDrop(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end
	CharManager.addSense(rAdd.nodeChar, "Darkvision", rAdd.sSourceText:match("%d+"));
end
function helperAddAncestryTraitEnhancedSpeedDrop(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end
	local sSpeed = rAdd.sSourceText:match("increases to (%d+) feet");
	CharManager.setSpeed(rAdd.nodeChar, sSpeed)
end
function helperAddAncestryTraitAbilityIncreaseDrop2014(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end

	local tBase, tAbilitySelect = CharAncestryManager.helperParseAncestryAbilityIncrease2014(rAdd.sSourceText);
	CharBuildDropManager.pickAbilities2014(rAdd.nodeChar, tBase, tAbilitySelect);
end
function helperParseAncestryAbilityIncrease2014(s)
	if not s then
		return {}, {};
	end

	s = s:lower();

	local tBase = {};
	if s:match("your ability scores each increase") then
		for _,sAbility in pairs(DataCommon.abilities) do
			tBase[sAbility] = 1;
		end
		return tBase, {};
	end

	local sAbility1, sAbility2, sIncrease = s:match("your (%w+) and (%w+) scores increase by (%d+)");
	if not sAbility1 then
		sAbility1, sAbility2, sIncrease = s:match("your (%w+) and (%w+) scores both increase by (%d+)");
	end
	if sAbility1 then
		local nIncrease = tonumber(sIncrease) or 0;
		if StringManager.contains(DataCommon.abilities, sAbility1) then
			tBase[sAbility1] = nIncrease;
		end
		if StringManager.contains(DataCommon.abilities, sAbility2) then
			tBase[sAbility2] = nIncrease;
		end
	else
		for sAbility1, sIncrease in s:gmatch("your (%w+) score increases by (%d+)") do
			if StringManager.contains(DataCommon.abilities, sAbility1) then
				tBase[sAbility1] = tonumber(sIncrease) or 0;
			end
		end
		for sAbility1, sDecrease in s:gmatch("your (%w+) score is reduced by (%d+)") do
			if StringManager.contains(DataCommon.abilities, sAbility1) then
				tBase[sAbility1] = (tonumber(sDecrease) or 0) * -1;
			end
		end
	end

	local tAbilitySelect = {};
	sIncrease = s:match("two different ability scores of your choice increase by (%d+)")
	if sIncrease then
		local nAbilityAdj = tonumber(sIncrease) or 1;
		table.insert(tAbilitySelect, { nPicks = 2, nAbilityAdj = nAbilityAdj });
	end
	sIncrease = s:match("one ability score of your choice increases by (%d+)");
	if sIncrease then
		local nAbilityAdj = tonumber(sIncrease) or 1;
		table.insert(tAbilitySelect, { nAbilityAdj = nAbilityAdj });
	end
	sIncrease = s:match("one other ability score of your choice increases by (%d+)");
	if sIncrease then
		local nAbilityAdj = tonumber(sIncrease) or 1;
		table.insert(tAbilitySelect, { nAbilityAdj = nAbilityAdj, bOther = true });
	end
	sIncrease = s:match("two other ability scores of your choice increase by (%d+)");
	if sIncrease then
		local nAbilityAdj = tonumber(sIncrease) or 1;
		table.insert(tAbilitySelect, { nPicks = 2, nAbilityAdj = nAbilityAdj, bOther = true });
	end

	sAbility1, sAbility2, sIncrease = s:match("either your (%w+) or your (%w+) increases by (%d+)");
	if sAbility1 then
		local tAbilities = {};
		if StringManager.contains(DataCommon.abilities, sAbility1) then
			table.insert(tAbilities, StringManager.capitalize(sAbility1));
		end
		if StringManager.contains(DataCommon.abilities, sAbility2) then
			table.insert(tAbilities, StringManager.capitalize(sAbility2));
		end
		if #tAbilities > 0 then
			local nAbilityAdj = tonumber(sIncrease) or 1;
			table.insert(tAbilitySelect, { tAbilities = tAbilities, nAbilityAdj = nAbilityAdj });
		end
	end

	return tBase, tAbilitySelect;
end
function helperAddAncestryTraitSizeDrop2014(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end

	local sSize = rAdd.sSourceText:match("[Yy]our size is (%w+)");
	CharManager.setSize(rAdd.nodeChar, sSize);
end
function helperAddAncestryTraitSpeedDrop2014(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end

	local nSpeed, tSpecial = CharAncestryManager.helperParseAncestrySpeed2014(rAdd.sSourceText);

	CharManager.setSpeed(rAdd.nodeChar, nSpeed);
	for k,v in pairs(tSpecial) do
		CharManager.addSpecialMove(rAdd.nodeChar, k, v);
	end
end
function helperParseAncestrySpeed2014(s)
	if (s or "") == "" then
		return 30, {};
	end

	local sSpeed = s:lower();
	local nSpeed = 30;
	local tSpecial = {};

	local sWalkSpeed = sSpeed:match("walking speed is (%d+) feet");
	if not sWalkSpeed then
		sWalkSpeed = sSpeed:match("land speed is (%d+) feet");
	end
	if sWalkSpeed then
		nSpeed = tonumber(sWalkSpeed) or 30;
	end

	local sSwimSpeed = sSpeed:match("swimming speed of (%d+) feet");
	if sSwimSpeed then
		tSpecial["Swim"] = sSwimSpeed;
	elseif sWalkSpeed and sSpeed:match("you have a swimming speed equal to your walking speed") then
		tSpecial["Swim"] = nSpeed;
	end

	local sFlySpeed = sSpeed:match("flying speed of (%d+) feet");
	if sFlySpeed then
		tSpecial["Fly"] = sFlySpeed;
	elseif sSpeed:match("you have a flying speed equal to your walking speed") then
		tSpecial["Fly"] = nSpeed;
	end

	local sClimbSpeed = sSpeed:match("climbing speed of (%d+) feet");
	if sClimbSpeed then
		tSpecial["Climb"] = sClimbSpeed;
	elseif sSpeed:match("you have a climbing speed equal to your walking speed") then
		tSpecial["Climb"] = nSpeed;
	end

	local sBurrowSpeed = sSpeed:match("burrowing speed of (%d+) feet");
	if sBurrowSpeed then
		tSpecial["Burrow"] = sBurrowSpeed;
	elseif sSpeed:match("you have a burrowing speed equal to your walking speed") then
		tSpecial["Burrow"] = nSpeed;
	end

	return nSpeed, tSpecial;
end
function helperAddAncestryTraitLanguagesDrop2014(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end

	local sLanguages = rAdd.sSourceText:match("You can speak, read, and write ([^.]+)");
	if not sLanguages then
		sLanguages = rAdd.sSourceText:match("You can read and write ([^.]+)");
	end
	if not sLanguages then
		return;
	end

	sLanguages = sLanguages:gsub("and ", ",");
	sLanguages = sLanguages:gsub("one extra language of your choice", "Choice");
	sLanguages = sLanguages:gsub("one other language of your choice", "Choice");
	-- EXCEPTION - Kenku - Languages - Volo
	sLanguages = sLanguages:gsub(", but you.*$", "");

	for s in sLanguages:gmatch("([^,]+)") do
		CharManager.addLanguage(rAdd.nodeChar, s);
	end
end
function helperAddAncestryTraitCatsClaws2014(rAdd)
	if not CharBuildDropManager.helperBuildGetText(rAdd) then
		return;
	end

	local sClimbSpeed = rAdd.sSourceText:match("you have a climbing speed of (%d+) feet");
	if not sClimbSpeed then
		return;
	end
	CharManager.addSpecialMove(rAdd.nodeChar, "Climb", sClimbSpeed);
end
function helperAddAncestryTraitVersatileDrop2024(rAdd)
	local tOptions = RecordManager.getRecordOptionsByStringI("feat", "category", "Origin", true);
	CharBuildDropManager.pickFeat(rAdd.nodeChar, tOptions, 1, { bWizard = rAdd.bWizard, bSource2024 = rAdd.bSource2024, });
end

function applyDwarvenToughness(nodeChar, bInitialAdd)
	-- Add extra hit points
	local nAddHP = 1;
	if bInitialAdd then
		nAddHP = CharManager.getLevel(nodeChar);
	end

	local nHP = GameManager.getRecordFieldValue(nodeChar, "hptotal", 0);
	GameManager.setRecordFieldValue(nodeChar, "hptotal", "number", nHP + nAddHP);

	ChatManager.SystemMessageResource("char_abilities_message_hpaddtrait", StringManager.capitalizeAll(CharManager.TRAIT_DWARVEN_TOUGHNESS), DB.getValue(nodeChar, "name", ""), nAddHP);
end
