-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Purpose - to provide standard functions to get reference records based off the record name.  For example: feat = "Half-Elf"
-- Originally created for the Playtest of Pathfinder 2.0

-- TAKEN FROM PATHFINDER RULESET

function getFeat(sFeatName, sKeyword)
	-- Matches a feat from the FG databases - uses the name and an optional trait to match a unique feat.
	-- Checks the campaign database first, then all open modules if no match made in the campaign db.
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getFeat - searching for sFeatName, sKeyword = ", sFeatName, sKeyword);
	if not sFeatName or sFeatName == "" then
		return nil;	
	end
	if not sKeyword then
		sKeyword = "";
	end
	-- Get feat nodes from the campaign database.
	-- Note, this also gets records from the "feats" node in a module.
	local featMatchNode = nil;
	local featNodes = DB.getChildrenGlobal("feat");	
	if featNodes then
		for _, featNode in pairs(featNodes) do
			local featCheckName = StringManager.trim(DB.getValue(featNode, "name", ""):lower());
			local featCheckKeywords = StringManager.trim(DB.getValue(featNode, "traits", ""):lower());
			if featCheckName == sFeatName:lower() and string.find(featCheckKeywords, sKeyword:lower()) then
				featMatchNode = featNode;
				break;
			end
		end
	end
	
	-- If can't find in the campaign database, search globally (in modules).
	if featMatchNode == nil then
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getFeat.  Didn't find feat in campaign database.  Trying modules.");
		local featReferenceNodes = DB.getChildrenGlobal("reference.feats")
		if featReferenceNodes then
			for _,featNode in pairs(featReferenceNodes) do
				local featCheckName = StringManager.trim(DB.getValue(featNode, "name", ""):lower());
				local featCheckKeywords = StringManager.trim(DB.getValue(featNode, "traits", ""):lower());				
				if featCheckName == sFeatName:lower() and string.find(featCheckKeywords, sKeyword:lower()) then				
					featMatchNode = featNode;
					break;
				end
			end	
		end
	end
	
	if featMatchNode then
		-- GlobalDebug.consoleString("ManagerGetRefData.getFeat - found feat = " .. DB.getPath(featMatchNode));
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getFeat - did not find feat in campaign database or loaded modules.");
	end
	
	return featMatchNode;
end

function getHeritages(sAncestryName)
	-- GlobalDebug.consoleString("ManagerGetRefData.getHeritages - searching for heritage name = " .. sAncestryName);
	-- Get heritage nodes from the campaign database.
	local heritageMatchNode = nil;
	
	local matchedHeritageNodes = {};	
	
	local aDataMap = { "lookupdata", "reference.lookupdata" };
	local sHeritageRecordClass = "reference_lookupdata";	
	
	for k, topLevelNodeName in pairs(aDataMap) do
	
		local lookupdataNodes = DB.getChildrenGlobal(topLevelNodeName);
		
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - topLevelNodeName = ", topLevelNodeName);		
		
		-- Get all heritages that match the ancestry name in the campaign database
		if lookupdataNodes then
			for k, lookupdataNode in pairs(lookupdataNodes) do
				if DB.getValue(lookupdataNode, "lookupdatatype", "") == "Heritage" then
					local ancestryCheckName = StringManager.trim(DB.getValue(lookupdataNode, "category", ""):lower());
					if ancestryCheckName == sAncestryName:lower() then
						local sHeritageName = StringManager.trim(DB.getValue(lookupdataNode, "name", ""));
						table.insert(matchedHeritageNodes, { text = sHeritageName, linkclass = sHeritageRecordClass, linkrecord = DB.getPath(lookupdataNode) } );
						-- heritageMatchNode = heritageNode;
						--break;
					end
				end
			end
		end	
	end
	
	-- Now add versatile heritages at the end of the list
	sVersatileHeritageName = "Versatile Heritage";
	
	for k, topLevelNodeName in pairs(aDataMap) do
	
		local lookupdataNodes = DB.getChildrenGlobal(topLevelNodeName);
		
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - topLevelNodeName = ", topLevelNodeName);
		
		-- Get all heritages that match the ancestry name in the campaign database
		if lookupdataNodes then
			for k, lookupdataNode in pairs(lookupdataNodes) do
				if DB.getValue(lookupdataNode, "lookupdatatype", "") == "Heritage" then
					local ancestryCheckName = StringManager.trim(DB.getValue(lookupdataNode, "category", ""):lower());
					if ancestryCheckName == sVersatileHeritageName:lower() then
						local sHeritageName = StringManager.trim(DB.getValue(lookupdataNode, "name", ""));
						-- For ancestries other than human, show half-elf and half-orc as uncommon versatile heritages
						if sAncestryName:lower() ~= "human" and (sHeritageName:lower() == "half-elf" or sHeritageName:lower() == "half-orc") then
							sHeritageName = sHeritageName .. " (uncommon heritage)";
						end
						table.insert(matchedHeritageNodes, { text = sHeritageName, linkclass = sHeritageRecordClass, linkrecord = DB.getPath(lookupdataNode) } );
						-- heritageMatchNode = heritageNode;
						--break;
					end
				end
			end
		end	
	end	
	
	-- Now search globally (in reference modules).
--	local lookupdataReferenceNodes = DB.getChildrenGlobal("reference.lookupdata");
--	
--	-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - lookupdataReferenceNodes = ", lookupdataReferenceNodes);
--	
--	if lookupdataReferenceNodes then
--		for k, lookupdataNode in pairs(lookupdataReferenceNodes) do
--			if DB.getValue(lookupdataNode, "lookupdatatype", "") == "Heritage" then
--				local ancestryCheckName = StringManager.trim(DB.getValue(lookupdataNode, "category", ""):lower());
--				if ancestryCheckName == sAncestryName:lower() then
--					local sHeritageName = StringManager.trim(DB.getValue(lookupdataNode, "name", ""));
--					table.insert(matchedHeritageNodes, { text = sHeritageName, linkclass = sHeritageRecordClass, linkrecord = DB.getPath(lookupdataNode) } );
--					-- heritageMatchNode = heritageNode;
--					--break;
--				end	
--			end
--		end	
--	end

	-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - found matchedHeritageNodes = ", matchedHeritageNodes);
	
	return matchedHeritageNodes;
end

function getRecordFromModule(sRecordName, sModuleName, aDataMap)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getRecordFromModule - searching for sRecordName, sModuleName, aDataMap = ", sRecordName, sModuleName, aDataMap);
	
	if (sRecordName or "") == "" or (sModuleName or "") == "" then
		return nil;
	end

	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	
	for _, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = DB.getChildList(topLevelNodeName .. "@" .. sModuleName); 
		for _, recordNode in ipairs(recordNodes) do
			local recordCheckName = StringManager.trim(DB.getValue(recordNode, "name", ""):lower());
			if recordCheckName == sRecordName:lower() then
				recordMatchNode = recordNode;
				break;
			end
		end	
		if recordMatchNode ~= nil then
			break;
		end
	end
	
	if recordMatchNode then
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordFromModule - found record = " .. DB.getPath(recordMatchNode));
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordFromModule - did not find record in campaign database or loaded modules.");
	end
	
	return recordMatchNode;
end

-- Returns first sRecordName match of the record across DB and open modules. 
function getRecordGlobally(sRecordName, aDataMap)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getRecordGlobally - searching for sRecordName, aDataMap = ", sRecordName, aDataMap);
	
	sRecordName = StringManager.trim(sRecordName):lower();

	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	
	for k, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = DB.getChildrenGlobal(topLevelNodeName); 
		for k, recordNode in pairs(recordNodes) do
			local recordCheckName = StringManager.trim(DB.getValue(recordNode, "name", ""):lower());
			if recordCheckName == sRecordName then
				recordMatchNode = recordNode;
				break;
			end
		end	
		if recordMatchNode ~= nil then
			break;
		end
	end
	
	if recordMatchNode then
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordGlobally - found record = " .. DB.getPath(recordMatchNode));
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordGlobally - did not find record in campaign database or loaded modules.");
	end
	
	return recordMatchNode;
end

-- Returns all records that match sRecordName across DB and open modules.
-- If bCheckCoreFirst is set then just the core rules module will be checked.
-- sExistingKeywords not currently used here.
function getAllRecordsGlobally(sRecordName, aDataMap, sExistingKeywords, bCheckCoreFirst)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - searching for sRecordName, aDataMap, sExistingKeywords, bCheckCoreFirst = ", sRecordName, aDataMap, sExistingKeywords, bCheckCoreFirst);
	
	sRecordName = StringManager.trim(GameSystem.removeActionSymbols(sRecordName):lower());

	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	local aRecordMatches = {};	
	for k, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = nil;
--		if bCheckCoreFirst then
--			local sCorePath = topLevelNodeName .. "@" .. aSourceModuleNames[1].name;	-- Currently hard coded to the first module - should be core rules.
--			recordNodes = DB.getChildren(sCorePath);
--			-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - sCorePath = ", sCorePath);
--		else
			recordNodes = DB.getChildrenGlobal(topLevelNodeName);
			-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - #recordNodes = ", #recordNodes);
--		end
		for k, recordNode in pairs(recordNodes) do
			local recordCheckName = StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(recordNode, "name", ""):lower()));
			if recordCheckName == sRecordName then
				table.insert(aRecordMatches, DB.getPath(recordNode));
			end
		end	
	end
	
	if #aRecordMatches > 0 then
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - found records = ", aRecordMatches);
		if #aRecordMatches > 1 and bCheckCoreFirst then
			-- Source modules to check - get list of modules from the desktop data client "Pathfinder Second Edition Core" module list.
			local aSourceModuleNames = {}
			for _, tModuleList in pairs(DesktopPFRPG._tDataModuleSets["client"]) do
				if tModuleList.name == "Pathfinder Second Edition Core" then
					for _, sModuleListName in pairs(tModuleList.modules) do
						table.insert(aSourceModuleNames, sModuleListName);
					end
					break;
				end
			end
			-- Get a list of matching records against the core book names
			-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - aSourceModuleNames = ", aSourceModuleNames);
			local tCoreMatchedRecords = {};
			for _, rSourceModule in pairs(aSourceModuleNames) do
				local sSourceModuleName = "@" .. rSourceModule.name;
				for _, sMatchedNodeName in pairs(aRecordMatches) do
					if string.find(sMatchedNodeName, sSourceModuleName) then
						-- GlobalDebug.consoleObjects("ManagerGetRefData.getAllRecordsGlobally - filtered rulebook record = ", sMatchedNodeName);
						table.insert(tCoreMatchedRecords, sMatchedNodeName);
					end
				end
			end
			if #tCoreMatchedRecords > 0 then
--				if #tCoreMatchedRecords > 1 then
--					-- Try to match on traits
--					sExistingKeywords = GameSystem.convertKeywordSeparators(sExistingKeywords:lower());
--					for _, sMatchedNodeName in pairs(tCoreMatchedRecords) do
--						local sMatchKeywords = DB.getValue(DB.getPath(DB.findNode(sMatchedNodeName), "traits"), "");
--						if GameSystem.convertKeywordSeparators(sMatchKeywords:lower()) == sExistingKeywords then
--							return { sMatchedNodeName };
--						end
--					end
--				else
					return tCoreMatchedRecords;
--				end				
			end			
		end
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getAllRecordsGlobally - did not find any records in campaign database or loaded modules.");
	end
	
	return aRecordMatches;
end

function getTieredDataRecordsGlobally(sRecordName, aDataMap, sDataChildName)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getTieredDataRecordsGlobally - starting.  sRecordName, aDataMap, sDataChildName = ", sRecordName, aDataMap, sDataChildName);
	
	sRecordName = StringManager.trim(GameSystem.removeActionSymbols(sRecordName):lower());

	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	local aRecordMatches = {};
	
	for _, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = DB.getChildrenGlobal(topLevelNodeName); 
		for _, recordNode in pairs(recordNodes) do
			for _, nodeFeature in pairs(DB.getChildList(recordNode, sDataChildName)) do
				local recordCheckName = StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(nodeFeature, "name", ""):lower()));
--				local recordCheckName = StringManager.trim(DB.getValue(nodeFeature, "name", ""):lower());
				if recordCheckName == sRecordName then
					table.insert(aRecordMatches, DB.getPath(nodeFeature));
				end
			end
		end	
	end
	
	if #aRecordMatches > 0 then
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getTieredDataRecordsGlobally - found records = ", aRecordMatches);
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getTieredDataRecordsGlobally - did not find any records in campaign database or loaded modules.");
	end
	
	return aRecordMatches;	
end

function getRecordFromKeywords(aRecordNodes, sKeywords)	
	sKeywords = GameSystem.convertKeywordSeparators(sKeywords);
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getRecordFromKeywords - starting. aRecordNodes, sKeywords = ", aRecordNodes, sKeywords);
	
	for _, sNodeRecord in pairs(aRecordNodes) do
		local sRecordKeywords = DB.getValue(DB.getPath(DB.findNode(sNodeRecord), "traits"), ""):lower();
		if GameSystem.convertKeywordSeparators(sRecordKeywords) == sKeywords then
			-- GlobalDebug.consoleObjects("ManagerGetRefData.getRecordFromKeywords - found a match!  sNodeRecord = ", sNodeRecord);
			return sNodeRecord;		
		end
	end
	
	return nil;
end

-- Return the first lookupdata record to match the sRecordName and sLookupDataType
-- sLookupDataCategory and sLookupDataSubCategory are optional.  If sLookupDataSubCategory is used there must also be a sLookupDataCategory value.
-- nPartialNameMatch - will try to do a partial name match if there isn't a complete name match.
function getLookupDataRecordGlobally(sRecordName, sLookupDataType, sLookupDataCategory, sLookupDataSubCategory, nPartialNameMatch)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getLookupDataRecordGlobally - searching for sRecordName, sLookupDataType, sLookupDataCategory = ", sRecordName, sLookupDataType, sLookupDataCategory);
	
	sRecordName = StringManager.trim(GameSystem.removeActionSymbols(sRecordName:lower()));

	local aDataMap = { "lookupdata", "reference.lookupdata" };
	local bMatchCategory = (sLookupDataCategory or "") ~= "";
	local bMatchSubCategory = (sLookupDataSubCategory or "") ~= "";
	
	sLookupDataType = StringManager.trim(GameSystem.removeActionSymbols(sLookupDataType:lower()));
	if bMatchCategory then
		sLookupDataCategory = sLookupDataCategory:lower();
	end
	if bMatchSubCategory then
		sLookupDataSubCategory = sLookupDataSubCategory:lower();
	end	
	
	local aNamesToFind = { sRecordName };
	local nLoops = 1;
	if nPartialNameMatch then
		table.insert(aNamesToFind, GameSystem.replaceRegularExpressionChars(sRecordName));
		nLoops = 2;
	end
	
	local recordMatchNode = nil;	
	-- Step through twice - the second time we'll try for a partial match if we don't get a complete match in the first loop.
	for i = 1, nLoops do
		-- Get record nodes from the database paths in aDataMap
		local sNameToFind = aNamesToFind[i];
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getLookupDataRecordGlobally - checking for name. i, sNameToFind = ", i, sNameToFind);	
		for k, topLevelNodeName in pairs(aDataMap) do
			local recordNodes = DB.getChildrenGlobal(topLevelNodeName); 
			for k, recordNode in pairs(recordNodes) do
				if sLookupDataType == StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(recordNode, "lookupdatatype", ""):lower())) then
					local bMatch = false;
					if bMatchCategory then
						if sLookupDataCategory == StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(recordNode, "category", ""):lower())) then
							if bMatchSubCategory then
								if sLookupDataSubCategory == StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(recordNode, "subcategory", ""):lower())) then
									bMatch = true;
								end
							else
								bMatch = true;
							end
						end
					else
						bMatch = true;
					end				
					if bMatch then
						local recordCheckName = StringManager.trim(GameSystem.removeActionSymbols(DB.getValue(recordNode, "name", "")):lower());
						if i == 1 then
							if recordCheckName == sNameToFind then
								recordMatchNode = recordNode;
								break;
							end						
						else
							if string.find(recordCheckName, sNameToFind) then
								recordMatchNode = recordNode;
								break;
							end
						end
					end
				end
			end	
			if recordMatchNode ~= nil then
				break;
			end
		end
		if recordMatchNode ~= nil then
			break;
		end		
	end
	
	if recordMatchNode then
		-- GlobalDebug.consoleString("ManagerGetRefData.getLookupDataRecordGlobally - found record = " .. DB.getPath(recordMatchNode));
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getLookupDataRecordGlobally - did not find record in campaign database or loaded modules.");
	end
	
	return recordMatchNode;
end

-- Used to add lookup data features to a list (targetlist)
function addLookupDataFeatures(nodeChar, lookupDataNode, nodeTargetList)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.addLookupDataFeatures - nodeChar, lookupDataNode, nodeTargetList = ", nodeChar, lookupDataNode, nodeTargetList);
	if not nodeChar or not lookupDataNode or not nodeTargetList then
		return false;
	end
	
	local nCharLevel = DB.getValue(nodeChar, "level", 1);
	if nCharLevel == 0 then
		nCharLevel = 1;
	end	
	-- GlobalDebug.consoleObjects("ManagerGetRefData.addLookupDataFeatures - nCharLevel = ", nCharLevel);	
	
	local sLookupDataAutomation = DB.getValue(lookupDataNode, "automation", "");
	local bAutomationAppliedAllRecords = true;
	if DB.getChildCount(lookupDataNode, "lookupdata_features") == 0 and sLookupDataAutomation == "" then	
		bAutomationAppliedAllRecords = false;
	end
	
	for _, nodeFeature in ipairs(DB.getChildList(lookupDataNode, "lookupdata_features")) do
		local nFeatureLevel = DB.getValue(nodeFeature, "level", 1);
		-- If a record of the same name already exists on the PC don't add it.
		-- Only add features of the current PC level or lower.
		if not CharManager.hasKeyword(nodeChar, DB.getValue(nodeFeature, "name", "")) and nFeatureLevel <= nCharLevel then
			local sClass = nil;
			local sRecord = nil;
			local sLinkName = nil;
			
			local nodeEntry = DB.createChild(nodeTargetList);
			DB.setValue(nodeEntry, "name", "string", DB.getValue(nodeFeature, "name", ""));
			DB.setValue(nodeEntry, "source", "string", DB.getValue(nodeFeature, "category", ""));
			DB.setValue(nodeEntry, "text", "formattedtext", DB.getValue(nodeFeature, "text", ""));			
			DB.setValue(nodeEntry, "locked", "number", 1);
			DB.setValue(nodeEntry, "automation", "string", DB.getValue(nodeFeature, "automation", ""));

			if DB.getChildCount(nodeFeature, "activities") > 0 then
				local nodeFeatureActivities = DB.getChild(nodeFeature, "activities");
				local nodeEntryActivities = DB.createChild(nodeEntry, "activities");
				if nodeFeatureActivities and nodeEntryActivities then
					DB.copyNode(nodeFeatureActivities, nodeEntryActivities);
					PCActivitiesManager.addLinkedActivities(nodeChar, nodeEntry, "referenceracialtrait");
				end
			end
			
			-- Add the level that the feature was applied.  Used to aid manual feat retraining.
			local level = DB.getValue(nodeChar, "level", 1);
			if level == 0 then
				level = 1;
			end
			DB.setValue(nodeEntry, "level_applied", "number", level);			
			
			-- GlobalDebug.consoleObjects("ManagerGetRefData.addLookupDataFeatures - calling GameSystem.applyAutomation. nodeChar, nodeEntry, nodeEntry.name = ", nodeChar, nodeEntry, DB.getValue(nodeEntry, "name", ""));
			local automationApplied = GameSystem.applyAutomation(nodeChar, nodeEntry);
			local sFormat = Interface.getString("char_message_lookupadd");
			if automationApplied == "notvalid" then
				sFormat = Interface.getString("char_message_lookupadd_notvalid");
				local sMsg = string.format(sFormat, DB.getValue(nodeFeature, "name", ""), DB.getValue(nodeChar, "name", ""));
				ChatManager.SystemMessage(sMsg);
				ChargenTracker.addTextToLog(nodeChar, sMsg);
				bAutomationAppliedAllRecords = false;
				-- Delete the new feat entry as the feat automation is invalid.
				--DB.deleteNode(nodeEntry);
				--return;
			-- Should hidden be handled elsewhere?  For lookup data features we want to report that the overall feature was added, even if some of the automation entries don't specifically report to the chargen log.
			elseif automationApplied == "yes" or automationApplied == "hidden" then
				sFormat = Interface.getString("char_message_lookupadd_with_automation");
			elseif automationApplied == "unable" then
				sFormat = Interface.getString("char_message_lookupadd_automation_unable");	
				bAutomationAppliedAllRecords = false;
			elseif StringManager.startsWith(automationApplied, "message|") then
				-- We have a custom message
				local sMessageName = string.match(automationApplied, "message|(.*)");
				if sMessageName and sMessageName ~= "" then
					sFormat = Interface.getString(sMessageName);
				end					
			else
				bAutomationAppliedAllRecords = false;
				-- TODO - get the shortcut information based off the nodeTargetList type.
				sClass, sRecord = DB.getValue(nodeEntry, "shortcut", "", "");
				sLinkName = DB.getValue(nodeEntry, "name", "");				
			end	

			local sMsg = string.format(sFormat, DB.getValue(nodeFeature, "name", ""), DB.getValue(nodeChar, "name", ""));
			ChargenTracker.addTextToLog(nodeChar, sMsg,  sClass, sRecord, sLinkName);		
		end
	end
	
	return bAutomationAppliedAllRecords;
end


function showConditionLookupData(sConditionName, bSupressNotFoundMessage)

	if sConditionName and sConditionName ~= "" then
		-- Remove "Efects: " from any condition - this would be the first on the line.
		sConditionName = string.gsub(sConditionName, "[Ee]ffects: ", "");
		-- Remove any value indicator text - e.g. Clumsy:1 = Clumsy
		sConditionName = string.gsub(sConditionName, ": ?%d?", "");
		if sConditionName == "PERS" then
			sConditionName = "Persistent damage";
		end
		local conditionLookupDataNode = getLookupDataRecordGlobally(sConditionName, "Condition");
		if conditionLookupDataNode then
			Interface.openWindow("reference_lookupdata", conditionLookupDataNode);
			return true;
		else
			if not bSupressNotFoundMessage then
				-- Indicate in chat window that data wasn't found - and to open the core rules module!
				sFormat = Interface.getString("message_effect_conditions_lookup_notfound");
				sMsg = string.format(sFormat, sConditionName);					
				ChatManager.SystemMessage(sMsg);			
			end
		end
	end

end

function showEffectLookupData(sConditionName, bSupressNotFoundMessage)

	if sConditionName and sConditionName ~= "" then
		-- Remove any value indicator text - e.g. Clumsy:1 = Clumsy
		sConditionName = string.gsub(sConditionName, ": ?%d", "");
		local conditionLookupDataNode = getLookupDataRecordGlobally(sConditionName, "Effect");
		if conditionLookupDataNode then
			Interface.openWindow("reference_lookupdata", conditionLookupDataNode);
			return true;
		else
			if not bSupressNotFoundMessage then
				-- Indicate in chat window that data wasn't found - and to open the core rules module!
				sFormat = Interface.getString("message_effect_conditions_lookup_notfound");
				sMsg = string.format(sFormat, sConditionName);					
				ChatManager.SystemMessage(sMsg);			
			end
		end
	end

end

-- Using old method of getting heritages from the hieritage data.  Now uses lookupdata.  See getHeritages function above.
function getHeritages_old(sAncestryName)
	-- GlobalDebug.consoleString("ManagerGetRefData.getHeritages - searching for heritage name = " .. sAncestryName);
	-- Get heritage nodes from the campaign database.
	local heritageMatchNode = nil;
	local heritageNodes = DB.getChildrenGlobal("heritage");
	
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - heritageNodes = ", heritageNodes);
	
	local matchedHeritageNodes = {};
	local sHeritageRecordClass = "reference_heritage";
	
	-- Get all heritages that match the ancestry name in the campaign database
	if heritageNodes then
		for k, heritageNode in pairs(heritageNodes) do
			local ancestryCheckName = StringManager.trim(DB.getValue(heritageNode, "ancestryname", ""):lower());
			if ancestryCheckName == sAncestryName:lower() then
				local sHeritageName = StringManager.trim(DB.getValue(heritageNode, "name", ""));
				table.insert(matchedHeritageNodes, { text = sHeritageName, linkclass = sHeritageRecordClass, linkrecord = DB.getPath(heritageNode) } );
				-- heritageMatchNode = heritageNode;
				--break;
			end
		end
	end
	
	-- Now search globally (in reference modules).
	local heritageReferenceNodes = DB.getChildrenGlobal("reference.heritages");
	
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - heritageReferenceNodes = ", heritageReferenceNodes);
	
	if heritageReferenceNodes then
		for k, heritageNode in pairs(heritageReferenceNodes) do
			local ancestryCheckName = StringManager.trim(DB.getValue(heritageNode, "ancestryname", ""):lower());
			if ancestryCheckName == sAncestryName:lower() then
				local sHeritageName = StringManager.trim(DB.getValue(heritageNode, "name", ""));
				table.insert(matchedHeritageNodes, { text = sHeritageName, linkclass = sHeritageRecordClass, linkrecord = DB.getPath(heritageNode) } );
				-- heritageMatchNode = heritageNode;
				--break;
			end		
		end	
	end

	-- GlobalDebug.consoleObjects("ManagerGetRefData.getHeritages - found matchedHeritageNodes = ", matchedHeritageNodes);
	
	return matchedHeritageNodes;
end

-- Keyword double-click lookup functions

function getKeywordNodes(recordNode, aKeywordNames, sKeywordType)
	---- GlobalDebug.consoleObjects("ManagerGetRefData.getKeywordNodes - recordNode, aKeywordNames, sKeywordType = ", recordNode, aKeywordNames, sKeywordType);
	
	if not sKeywordType then
		sKeywordType = "";
	end
	
	local aKeywordNodes = { };
	
	for k, v in pairs(aKeywordNames) do	
		if v then
			local sKeywordName = v;
			
			-- Remove any dice from the entry - such as Deadly 1d12 or Fatal 1d10
			local nStarts, nEnds, sKeywordWithoutDice = string.find(sKeywordName, "([%a%s%-]*)%s*%(?%+?%d*d%d+%)?$");	
			---- GlobalDebug.consoleObjects("Double-click - sKeywordName, sKeywordWithoutDice = ", sKeywordName, sKeywordWithoutDice);				
			if sKeywordWithoutDice and sKeywordWithoutDice ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithoutDice);
			end
			
			-- Remove any single digits from the entry - such as "additive 1"
			local sKeywordWithoutDigit = string.match(sKeywordName, "([%a%s%-]*)%s*%d$");
			---- GlobalDebug.consoleObjects("Double-click - sKeywordName, sKeywordWithoutDigit = ", sKeywordName, sKeywordWithoutDigit);		
			if (sKeywordWithoutDigit or "") ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithoutDigit);
			end				
			
			local nStarts, nEnds, sKeywordWithDistance = string.find(sKeywordName, "([%a%s%-]*)%s*%d*%s*ft.$");
			---- GlobalDebug.consoleObjects("Double-click - sKeywordWithDistance (ft.) = ", sKeywordWithDistance);	
			if sKeywordWithDistance and sKeywordWithDistance ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithDistance);
			end			
			
			-- check for {trait} XX feet - replace with just {trait}.
			local nStarts, nEnds, sKeywordWithDistance = string.find(sKeywordName, "([%a%s%-]*)%s*%d*%s*feet$");
			---- GlobalDebug.consoleObjects("Double-click - sKeywordWithDistance (feet) = ", sKeywordWithDistance);				
			if sKeywordWithDistance and sKeywordWithDistance ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithDistance);
			end
			
			-- check attached to ...
			local sKeywordWithAttached = string.match(sKeywordName, "^(attached) to .*");
			-- GlobalDebug.consoleObjects("Double-click - sKeywordWithAttached = ", sKeywordWithAttached);				
			if (sKeywordWithAttached or "") ~= "" then
				sKeywordName = sKeywordWithAttached;
			end			
			
			-- check for Versatile <damage type> - replace with just Versatile.
			if string.find(sKeywordName, "^versatile") then
				sKeywordName = "versatile";
			end	
			
			-- The following aren't really traits but are added to provide useful weapon lookup data.
			-- Check for range increment... and replace with just range
			if string.find(sKeywordName, "^range ") then
				sKeywordName = "range";
			end			
			-- Check for reload X and replace with just reload
			if string.find(sKeywordName, "^reload ") then
				sKeywordName = "reload";
			end		
			
			-- GlobalDebug.consoleObjects("Double-click - sKeywordName = ", sKeywordName);	

			local traitMatchNode = nil;

			-- Get trait node from the campaign and reference database with a matching traittype.
			local aDataMap = { "trait", "reference.traits" };
			traitMatchNode = getKeywordRecordGlobally(sKeywordName, sKeywordType, aDataMap); 

			-- If we don't have a match with the trait type then get trait node from the campaign and reference database with a blank traittype.
			if not traitMatchNode and sKeywordType ~= "" then
				traitMatchNode = getKeywordRecordGlobally(sKeywordName, "", aDataMap);
			end			
			
			if traitMatchNode then
				-- Check we don't already have this trait - introduced with Guns & Gears combination weapons - which can have the same trait twice.
				local bAddKeywordNode = true;
				local sKeywordMatchNodeName = DB.getPath(traitMatchNode);
				for _, nodeKeyword in pairs(aKeywordNodes) do
					if DB.getPath(nodeKeyword) == sKeywordMatchNodeName then
						bAddKeywordNode = false;
						break;
					end
				end
				if bAddKeywordNode then
					table.insert(aKeywordNodes, traitMatchNode);
				end
			
				--Interface.openWindow("reference_trait", traitMatchNode);

			end
		end	
	end
	
	return aKeywordNodes;
end

function getKeywordRecordGlobally(sKeywordName, sKeywordType, aDataMap)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getRecordGlobally - searching for sRecordName, aDataMap = ", sKeywordName, sKeywordType, aDataMap);

	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	
	for k, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = DB.getChildrenGlobal(topLevelNodeName); 
		for k, recordNode in pairs(recordNodes) do
			local recordCheckName = StringManager.trim(DB.getValue(recordNode, "name", ""):lower());
			local sNodeKeywordType = DB.getValue(traitNode, "traittype", ""):lower();
			if recordCheckName == sKeywordName:lower() and sKeywordType:lower() == sNodeKeywordType then
				recordMatchNode = recordNode;
				break;
			end
		end	
		if recordMatchNode ~= nil then
			break;
		end
	end
	
	if recordMatchNode then
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordGlobally - found record = " .. DB.getPath(recordMatchNode));
	else
		-- GlobalDebug.consoleString("ManagerGetRefData.getRecordGlobally - did not find record in campaign database or loaded modules.");
	end
	
	return recordMatchNode;
end

function getChoiceLookupData(sDataType, sCategoryName, sSubCategory)
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getChoiceLookupData.  sDataType, sCategoryName, sSubCategory = ", sDataType, sCategoryName, sSubCategory);
	-- Get class lookup data nodes from the campaign database.
	
	local matchedNodes = {};	
	
	local aDataMap = { "lookupdata", "reference.lookupdata" };
	local sRecordClass = "reference_lookupdata";	
	
	for k, topLevelNodeName in pairs(aDataMap) do
	
		local lookupdataNodes = DB.getChildrenGlobal(topLevelNodeName);
		
		-- GlobalDebug.consoleObjects("ManagerGetRefData.getChoiceLookupData - topLevelNodeName = ", topLevelNodeName);		
		
		-- Get all heritages that match the ancestry name in the campaign database
		if lookupdataNodes then
			for k, lookupdataNode in pairs(lookupdataNodes) do
				if DB.getValue(lookupdataNode, "lookupdatatype", ""):lower() == sDataType:lower() then
					local classCheckName = StringManager.trim(DB.getValue(lookupdataNode, "category", ""):lower());
					local subcategoryCheckName = StringManager.trim(DB.getValue(lookupdataNode, "subcategory", ""):lower());
					if classCheckName == sCategoryName:lower() and subcategoryCheckName == sSubCategory:lower() then
						local sRecordName = StringManager.trim(DB.getValue(lookupdataNode, "name", ""));
						table.insert(matchedNodes, { text = sRecordName, linkclass = sRecordClass, linkrecord = DB.getPath(lookupdataNode) } );
					end
				end
			end
		end	
	end
	
	-- GlobalDebug.consoleObjects("ManagerGetRefData.getChoiceLookupData - found matchedNodes = ", matchedNodes);
	
	return matchedNodes;
end

