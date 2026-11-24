--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

--
--	Data
--

function getCareerRecord()
	local tCareer = CharWizardManager.getCareerData();
	return tCareer.career;
end
function getCareerNode()
	local sRecord = CharWizardCareerManager.getCareerRecord();
	if (sRecord or "") == "" then
		return nil;
	end
	return DB.findNode(sRecord);
end
function setCareerRecord(v)
	local nodeRecord;
	if type(v) == "databasenode" then
		nodeRecord = v;
	elseif type(v) == "string" then
		nodeRecord = DB.findNode(v);
	end
	if not nodeRecord then
		CharWizardManager.clearCareerData();
		return;
	end

	local tCareer = CharWizardManager.getCareerData();
	local bIs2024 = (DB.getValue(nodeRecord, "version", "") == "2024");
	tCareer.career = DB.getPath(nodeRecord);
	tCareer.bIs2024 = bIs2024;

	if bIs2024 then
		CharWizardCareerManager.handleCareerEquipmentKit2024();
	else
		CharWizardCareerManager.handleCareerEquipmentKit2014();
	end

	CharWizardKitManager.onEquipmentPageUpdate();

	CharWizardManager.updateAlerts();
end
function isCareer2024()
	local tCareer = CharWizardManager.getCareerData();
	return tCareer.bIs2024;
end

function handleCareerEquipmentKit2024()
	local tCareer = CharWizardManager.getCareerData();
	local nodeEquipment = DB.createChild(DB.findNode(tCareer.career), "equipmentlist");

	local tOptions = {};
	for _,nodeOption in ipairs(DB.getChildList(nodeEquipment)) do
		local tItems = {};
		local nWealth = DB.getValue(nodeOption, "wealth", 0);
		if nWealth > 0 then
			tItems.wealth = nWealth;
		end

		tItems.items = {};
		for _,nodeItem in ipairs(DB.getChildList(nodeOption, "items")) do
			local nCount = DB.getValue(nodeItem, "count", 0);
			table.insert(tItems.items, { item = nodeItem, count = nCount });
		end

		table.insert(tOptions, tItems);
	end

	CharWizardCareerManager.setCareerStartingKitOptions(tOptions);
end
function handleCareerEquipmentKit2014()
	local tCareer = CharWizardManager.getCareerData();
	local sEquipment = DB.getValue(DB.findNode(tCareer.career), "equipment", "");

	local nGold = CharWizardCareerManager.parseCareerGold2014(sEquipment);
	CharWizardCareerManager.setCareerStartingGold(nGold);

	local tInnate, tChoices = CharWizardCareerManager.parseCareerEquipmentKitItems2014(sEquipment);
	CharWizardCareerManager.setCareerStartingKitItems(tInnate);
	CharWizardCareerManager.setCareerStartingKitOptions(tChoices);
end
function parseCareerGold2014(s)
	local tSplitKit = StringManager.split(s, ",");
	for _,vItem in pairs(tSplitKit) do
		local tText = { "pouch containing", "purse containing", "(%d+) gp" };
		for _,sMatch in ipairs(tText) do
			if vItem:match(sMatch) then
				return tonumber(vItem:match("(%d+) gp"));
			end
		end
	end

	return 0;
end
function parseCareerEquipmentKitItems2014(s)
	local tItems = {};
	local tChoices = {};

	local tSplitKit = StringManager.split(s, ",");
	for _,vItem in pairs(tSplitKit) do
		local tInnate = {};

		-- Clothes
		if vItem:match("common clothes") or vItem:match("commoner's clothes") then
			table.insert(tInnate, "clothes, common");
		elseif vItem:match("traveler's clothes") then
			table.insert(tInnate, "clothes, traveler's");
		elseif vItem:match("fine clothes") then
			table.insert(tInnate, "clothes, fine");
		elseif vItem:match("vestments") then
			table.insert(tInnate, "clothes, vestments");
		elseif vItem:match("costume") then
			table.insert(tInnate, "clothes, costume");
		end

		-- Items
		local tSimple = { "blanket", "block and tackle", "book", "carpenter's tools",
			"crowbar", "dagger", "disguise kit", "emblem", "fishing tackle", "forgery kit",
			"healer's kit", "herbalism kit", "hammer", "horn", "incense", "manacles",
			"poisoner's kit", "pouch", "robe", "staff", "shovel", "tent", "tinderbox",
			"torch",
		};
		for _,v in ipairs(tSimple) do
			if vItem:match(v) then
				table.insert(tInnate, v);
			end
		end

		if vItem:match("belaying pin") then
			table.insert(tInnate, "club");
		end
		if vItem:match("bullseye lantern") then
			table.insert(tInnate, "lantern, bullseye");
		end
		if vItem:match("ink") then
			table.insert(tInnate, "ink (1-ounce bottle)");
		end
		if vItem:match("iron pot") then
			table.insert(tInnate, "pot, iron");
		end
		if vItem:match("miner's pick") then
			table.insert(tInnate, "pick, miner's");
		end
		if vItem:match("parchment") then
			table.insert(tInnate, "parchment (one sheet)");
		end
		if vItem:match("pen ") or vItem:match("quill") or vItem == "pen" then
			table.insert(tInnate, "ink pen");
		end
		if vItem:match("silk rope") then
			table.insert(tInnate, "rope, silk (50 Feet)");
		end

		for _,v in ipairs(tInnate) do
			local tItemFilters = {
				{ sField = "name", sValue = v, bIgnoreCase = true, },
				{ sField = "version", sValue = "", },
			};
			local nodeItem = RecordManager.findRecordByFilter("item", tItemFilters);
			if nodeItem then
				table.insert(tItems, { item = nodeItem, count = 1 });
			end
		end

		-- Choices
		if vItem:match("set of bone dice or deck of cards") or vItem:match("gaming set") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "gaming set" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(tChoices, aChoicesLocal);
		end

		if vItem:match("artisan") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "artisan's tools" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(tChoices, aChoicesLocal);
		end

		if vItem:match("holy symbol") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "holy symbol" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end

			table.insert(tChoices, aChoicesLocal);
		end

		if vItem:match("musical instrument") then
			local tMappings = LibraryData.getMappings("item");
			local aChoicesLocal = {};
			for _,sMapping in ipairs(tMappings) do
				for _,vGlobalItem in pairs(DB.getChildrenGlobal(sMapping)) do
					local sMatch = StringManager.trim(DB.getValue(vGlobalItem, "subtype", ""));
					local sProperties = StringManager.trim(DB.getValue(vGlobalItem, "properties", ""))
					local bMagic = sProperties:match("magic");

					if sMatch:lower() == "musical instrument" and not bMagic then
						table.insert(aChoicesLocal, { item = vGlobalItem, count = 1 });
					end
				end
			end
			table.insert(tChoices, aChoicesLocal);
		end
	end

	return tItems, tChoices
end

function getCareerStartingGold()
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return 0;
	end
	return tCareer.careerwealth or 0;
end
function setCareerStartingGold(nWealth)
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return;
	end
	tCareer.careerwealth = nWealth;
end
function getCareerStartingKitItems()
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return {};
	end
	return tCareer.careeritems or {};
end
function setCareerStartingKitItems(tCareerItems)
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return;
	end
	tCareer.careeritems = nil;
	tCareer.careeritems = tCareerItems;
end
function getCareerStartingKitOptions()
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return {};
	end

	return tCareer.careeritemchoices or {};
end
function setCareerStartingKitOptions(tCareerOptions)
	local tCareer = CharWizardManager.getCareerData();
	if not tCareer then
		return;
	end
	tCareer.careeritemchoices = nil;
	tCareer.careeritemchoices = tCareerOptions;
end
function setCareerFeat(s)
	local tCareer = CharWizardManager.getCareerData();
	tCareer.feat = s;
end
function setCareerFeatPath(sPath)
	local tCareer = CharWizardManager.getCareerData();
	tCareer.featpath = sPath;
end
function addCareerAbilityIncreases(sAbility, nMod)
	if ((sAbility or "") == "") then
		return;
	end
	local tCareer = CharWizardManager.getCareerData();

	tCareer.abilityincrease = tCareer.abilityincrease or {};
	for _,v in ipairs(tCareer.abilityincrease) do
		if v.ability:lower() == sAbility:lower() then
			v.mod = v.mod + nMod;
			return;
		end
	end
	table.insert(tCareer.abilityincrease, { ability = sAbility, mod = nMod } );
end
function clearCareerAbilityIncreases()
	local tCareer = CharWizardManager.getCareerData();
	tCareer.abilityincrease = {};
end
function setCareerBaseSkills(tSkills)
	local tCareer = CharWizardManager.getCareerData();
	tCareer.skill = {};
	for _,v in pairs(tSkills) do
		table.insert(tCareer.skill, v);
	end
end
function addCareerSkillChoice(s)
	if (s or "") == "" then
		return;
	end
	local tCareer = CharWizardManager.getCareerData();
	tCareer.skillchoice = tCareer.skillchoice or {};
	if StringManager.contains(tCareer.skillchoice, s) then
		return;
	end
	table.insert(tCareer.skillchoice, s);
end
function clearCareerSkillChoice()
	local tCareer = CharWizardManager.getCareerData();
	tCareer.skillchoice = {};
end
function setCareerBaseTools(tTools)
	local tCareer = CharWizardManager.getCareerData();
	tCareer.toolprof = {};
	for _,v in pairs(tTools) do
		table.insert(tCareer.toolprof, v);
	end
end
function addCareerToolChoice(s)
	if (s or "") == "" then
		return;
	end
	local tCareer = CharWizardManager.getCareerData();
	tCareer.toolprofchoice = tCareer.toolprofchoice or {};
	if StringManager.contains(tCareer.toolprofchoice, s) then
		return;
	end
	table.insert(tCareer.toolprofchoice, s);
end
function clearCareerToolChoice()
	local tCareer = CharWizardManager.getCareerData();
	tCareer.toolprofchoice = {};
end
function setCareerBaseLanguages(tLanguages)
	local tCareer = CharWizardManager.getCareerData();
	tCareer.language = {};
	for _,v in pairs(tLanguages) do
		table.insert(tCareer.language, v);
	end
end
function addCareerLanguageChoice(s)
	if (s or "") == "" then
		return;
	end
	local tCareer = CharWizardManager.getCareerData();
	tCareer.languagechoice = tCareer.languagechoice or {};
	if StringManager.contains(tCareer.languagechoice, s) then
		return;
	end
	table.insert(tCareer.languagechoice, s);
end
function clearCareerLanguageChoice()
	local tCareer = CharWizardManager.getCareerData();
	tCareer.languagechoice = {};
end

--
--	Window
--

function processCareer(w)
	local _, sRecord = w.shortcut.getValue();
	CharWizardCareerManager.setCareerRecord(sRecord);

	local wCareer = CharWizardManager.getWizardCareerWindow();
	wCareer.sub_careerselection.setVisible(false);
	wCareer.button_changecareer.setVisible(true);
	wCareer.list_features.setVisible(true);
	wCareer.career_select_header.setValue(DB.getValue(DB.findNode(sRecord), "name", ""):upper());

	CharWizardCareerManager.updateCareerFeatures();

	CharWizardManager.updateAlerts();
end
function resetCareer()
	CharWizardManager.clearCareerData();
	CharWizardKitManager.onEquipmentPageUpdate();

	local wCareer = CharWizardManager.getWizardCareerWindow();
	wCareer.sub_careerselection.setVisible(true);
	wCareer.button_changecareer.setVisible(false);
	wCareer.list_features.setVisible(false);
	wCareer.list_features.closeAll();
	wCareer.career_select_header.setValue();

	CharWizardKitManager.onCareerClear();

	CharWizardAbilitiesManager.updateAbilities();
	CharWizardDecisionManager.refreshOverallDecisions();
	CharWizardManager.updateAlerts();
end

function updateCareerFeatures()
	local nodeCareer = CharWizardCareerManager.getCareerNode();
	if not nodeCareer then
		return;
	end
	local bIs2024 = CharWizardCareerManager.isCareer2024();

	CharWizardCareerManager.handleCareerAbilities(nodeCareer, bIs2024);
	CharWizardCareerManager.handleCareerSkills(nodeCareer, bIs2024);
	CharWizardCareerManager.handleCareerTools(nodeCareer, bIs2024);
	CharWizardCareerManager.handleCareerLanguages(nodeCareer, bIs2024);
	CharWizardCareerManager.handleCareerFeat(nodeCareer, bIs2024);
	CharWizardCareerManager.handleCareerFeatures(nodeCareer, bIs2024);
end
function handleCareerAbilities(nodeCareer, bIs2024)
	if not nodeCareer or not bIs2024 then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	local s = DB.getValue(nodeCareer, "abilities", "");
	if s == "" then
		return;
	end

	local w2 = wCareer.list_features.createWindow();
	w2.feature.setValue("Abilities");
	w2.feature_desc.setValue(s);
	CharWizardDecisionManager.createDecision(w2, { sDecisionType = "asicareeroption", });
end
function handleCareerSkills(nodeCareer, bIs2024)
	if not nodeCareer then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	local s = DB.getValue(nodeCareer, "skill", "");
	if s == "" then
		return;
	end
	local w2 = wCareer.list_features.createWindow();
	w2.feature.setValue("Skill");
	w2.feature_desc.setValue(s);

	local tBase, tOptions, nPicks = CharBuildManager.parseSkillsField(s, bIs2024);

	CharWizardCareerManager.setCareerBaseSkills(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardCareerManager.addCareerSkillChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w2, { sDecisionType = "skill", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("skill");
	CharWizardDecisionManager.refreshExpertiseDecision();
end
function handleCareerTools(nodeCareer, bIs2024)
	if not nodeCareer then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	local s = DB.getValue(nodeCareer, "tool", "");
	if s == "" then
		return;
	end

	local w2 = wCareer.list_features.createWindow();
	w2.feature.setValue("Proficiency");
	w2.feature_desc.setValue(s);

	local tBase, tOptions, nPicks = CharBuildManager.parseToolsField(s, bIs2024);

	CharWizardCareerManager.setCareerBaseTools(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardCareerManager.addCareerToolChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w2, { sDecisionType = "toolprof", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("toolprof");
end
function handleCareerLanguages(nodeCareer, bIs2024)
	if not nodeCareer or bIs2024 then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	local s = DB.getValue(nodeCareer, "languages", "");
	if s == "" then
		return;
	end

	local w2 = wCareer.list_features.createWindow();
	w2.feature.setValue("Languages");
	w2.feature_desc.setValue(s);

	local tBase, tOptions, nPicks = CharBuildManager.parseLanguagesField(s, bIs2024);

	CharWizardCareerManager.setCareerBaseLanguages(tBase);

	if nPicks >= #tOptions then
		for _,v in ipairs(tOptions) do
			CharWizardCareerManager.addCareerLanguageChoice(v);
		end
	else
		CharWizardDecisionManager.createDecisions(w2, { sDecisionType = "language", nPicks = nPicks, tOptions = tOptions, });
	end

	CharWizardDecisionManager.refreshOverallDecision("language");
end
function handleCareerFeat(nodeCareer, bIs2024)
	if not nodeCareer then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	local s = DB.getValue(nodeCareer, "feat", "");
	if s ~= "" then
		local w2 = wCareer.list_features.createWindow();
		w2.feature.setValue("Feat");
		w2.feature_desc.setValue(s);
		CharWizardCareerManager.setCareerFeat(s);
		return;
	end

	if bIs2024 then
		local w2 = wCareer.list_features.createWindow();
		w2.feature.setValue("Feat");
		w2.feature_desc.setVisible(false);
		CharWizardDecisionManager.createDecision(w2, { sDecisionType = "feat", sDecisionClass = "decision_sub_careerfeat_choice", });
	end
end
function handleCareerFeatures(nodeCareer, bIs2024)
	if not nodeCareer or not bIs2024 then
		return;
	end
	local wCareer = CharWizardManager.getWizardCareerWindow();
	if not wCareer then
		return;
	end

	for _,nodeFeature in pairs(DB.getChildren(nodeCareer, "features")) do
		local w2 = wCareer.list_features.createWindow();
		w2.feature.setValue(DB.getValue(nodeFeature, "name", ""));
		w2.shortcut.setValue("reference_careerfeature", DB.getPath(nodeFeature));
		w2.feature_desc.setValue(DB.getValue(nodeFeature, "text", ""));
	end
end

--
-- Decisions
--

local _bUpdatingDecision = false;
function processCareerDecision(w)
	if _bUpdatingDecision then
		return;
	end
	_bUpdatingDecision = true;

	local sDecisionType = w.decisiontype.getValue();
	if sDecisionType == "asicareeroption" then
		CharWizardCareerManager.processCareerDecisionASIOption(w);
	elseif sDecisionType == "asicareer" then
		CharWizardCareerManager.processCareerDecisionASI(w);
	elseif sDecisionType == "skill" then
		CharWizardCareerManager.processCareerDecisionSkill(w);
	elseif sDecisionType == "language" then
		CharWizardCareerManager.processCareerDecisionLanguage(w);
	elseif sDecisionType == "toolprof" then
		CharWizardCareerManager.processCareerDecisionTool(w);
	end

	_bUpdatingDecision = false;

	CharWizardManager.updateAlerts();
end
function processCareerDecisionASIOption(wDecision)
	local wFeature = wDecision.windowlist.window;
	CharWizardCareerManager.clearCareerAbilityIncreases();

	for _,w in pairs(wDecision.windowlist.getWindows()) do
		if w.decisiontype.getValue() == "asicareer" then
			w.close();
		end
	end

	local tAbilities = {};
	local nodeCareer = CharWizardCareerManager.getCareerNode();
	if nodeCareer then
		tAbilities = CharBuildManager.parseAbilitiesFromString(DB.getValue(nodeCareer, "abilities", ""));
	end

	local sDecisionChoice = wDecision.decision_choice.getValue():lower();
	if sDecisionChoice:match("option 1") then
		if #tAbilities > 1 then
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 2, tOptions = tAbilities, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, tOptions = tAbilities, });
		elseif #tAbilities == 1 then
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 2, tOptions = { tAbilities[1] }, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, });
		else
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 2, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, });
		end
	else
		if #tAbilities > 3 then
			CharWizardDecisionManager.createDecisions(wFeature, { sDecisionType = "asicareer", nAdj = 1, nPicks = 3, tOptions = tAbilities, });
		elseif #tAbilities == 3 then
			CharWizardCareerManager.addCareerAbilityIncreases(tAbilities[1], 1);
			CharWizardCareerManager.addCareerAbilityIncreases(tAbilities[2], 1);
			CharWizardCareerManager.addCareerAbilityIncreases(tAbilities[3], 1);
		elseif #tAbilities == 2 then
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, tOptions = { tAbilities[1] }, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, tOptions = { tAbilities[2] }, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, });
		elseif #tAbilities == 1 then
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, tOptions = { tAbilities[1] }, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, });
			CharWizardDecisionManager.createDecision(wFeature, { sDecisionType = "asicareer", nAdj = 1, });
		else
			CharWizardDecisionManager.createDecisions(wFeature, { sDecisionType = "asicareer", nAdj = 1, nPicks = 3, });
		end
	end

	CharWizardAbilitiesManager.updateAbilities();
end
function processCareerDecisionASI(wDecision)
	CharWizardCareerManager.clearCareerAbilityIncreases();

	local tAbilityMap = CharWizardDecisionManager.processAbilityDecision(wDecision, true);
	for sAbility,nMod in pairs(tAbilityMap) do
		CharWizardCareerManager.addCareerAbilityIncreases(sAbility, nMod);
	end

	CharWizardAbilitiesManager.updateAbilities();
end
function processCareerDecisionSkill(wDecision)
	CharWizardCareerManager.clearCareerSkillChoice();

	local tMap = CharWizardDecisionManager.processSkillDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardCareerManager.addCareerSkillChoice(s);
	end

	CharWizardDecisionManager.refreshExpertiseDecision();
end
function processCareerDecisionLanguage(wDecision)
	CharWizardCareerManager.clearCareerLanguageChoice();

	local tMap = CharWizardDecisionManager.processLanguageDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardCareerManager.addCareerLanguageChoice(s);
	end
end
function processCareerDecisionTool(wDecision)
	CharWizardCareerManager.clearCareerToolChoice();

	local tMap = CharWizardDecisionManager.processToolProfDecision(wDecision);
	for _,s in pairs(tMap) do
		CharWizardCareerManager.addCareerToolChoice(s);
	end
end

function onAddFeatCareerButton(wFeat)
	local sFeat = wFeat.name.getValue();
	local sFeatClass, sFeatPath = wFeat.shortcut.getValue();

	CharWizardCareerManager.setCareerFeatPath(sFeatPath);

	local wDecision = wFeat.windowlist.window.parentcontrol.window;
	wDecision.choice.setValue(sFeat);
	wDecision.choice.setVisible(true);
	wDecision.choicelink.setValue(sFeatClass, sFeatPath);
	wDecision.button_modify.setVisible(true);
	wDecision.sub_decision_choice.setVisible(false);
	wDecision.checkOutstandingDecisions();

	CharWizardManager.updateAlerts();
end
function resetCareerDecisionFeat(wDecision)
	CharWizardCareerManager.setCareerFeatPath();

	wDecision.choice.setValue();
	wDecision.choicelink.setValue();
	wDecision.button_modify.setVisible(false);
	wDecision.sub_decision_choice.setVisible(true);
	WindowManager.callInnerWindowFunction(wDecision, "buildFeats");

	CharWizardManager.updateAlerts();
end
