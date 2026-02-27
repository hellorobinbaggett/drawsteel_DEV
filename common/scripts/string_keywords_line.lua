-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- TAKEN FROM PATHFINDER RULESET

local parsed = false;
local rkeywords = {};

local hoverKeyword = nil;
local clickKeyword = nil;

local sKeywordType = "";
local creatureAbility = false;

function onInit()
	if super and super.onInit then
		super.onInit();
	end
	
	if keywordtype then
		-- Get the keyword type from the window XML.
		sKeywordType = keywordtype[1]:lower();
	else
		-- try to get the keyword type from elsewhere.
		-- Assume that we're in a grouped list at this point?
		local nodekeywords = getDatabaseNode();
		if nodekeywords then
--			GlobalDebug.consoleObjects("string_keywords_line.lua - onInit. nodekeywords = ", nodekeywords);
			-- The following works for items.  TODO - What about feats and spells?
			sKeywordType = DB.getValue(nodekeywords, "..type", ""):lower();
		elseif getName() == "weaponkeywords" then
			sKeywordType = "Weapon";
		end
	end
--	GlobalDebug.consoleObjects("string_keywords_line.lua - onInit.  sKeywordType = " .. sKeywordType);
end

function onValueChanged()
    WindowManager.callOuterWindowFunction(window, "onSummaryChanged");
	if super and super.onValueChanged then
		super.onValueChanged();
	end
	parsed = false;
end

function setKeywordType(sNewKeywordType)
	if sNewKeywordType then
		sKeywordType = sNewKeywordType:lower();
	end
end

function onHover(oncontrol)
	if dragging then
		return;
	end

	-- Reset selection when the cursor leaves the control
	if not oncontrol then
		-- Clear hover tracking
		hoverKeyword = nil;
		
		-- Clear any selections
		setSelectionPosition(0);
	end
end

function onHoverUpdate(x, y)
	-- If we're typing or dragging, then exit
	if dragging then
		return;
	end
	
	local skeywords = getValue();
	
--	skeywords = string.gsub(skeywords, "\n", ", ");
	
	-- sGlobalDebug.consoleObjects("onHoverUpdate - control name, skeywords = ", getName(), skeywords);
	
	local nkeywordsStart, nkeywordsEnd, sAbilitykeywords;
	
	if keywordlookup and keywordlookup[1] == "creatureability" then
		nkeywordsStart, nkeywordsEnd, sAbilitykeyword = string.find(skeyword, "%((.+)%)");	
	end
	
	if nkeywordStart and sAbilitykeyword then
		setCursorPosition(nkeywordEnd + 1);
		setSelectionPosition(nkeywordStart);
		setHoverCursor("hand");	
	elseif skeyword ~= "" then	
		if getName() == "keyword" or getName() == "combination_keyword" or getName() == "weaponkeyword" then 
			-- The control is a keyword field - highlight the whole field
			setCursorPosition(skeyword:len() + 1);
			setSelectionPosition(1);
			setHoverCursor("hand");			
		elseif getName() == "name" then
			-- We don't have any keyword, just the ability title.  Clear any highight and cursor change.
			setSelectionPosition(0);		
		end
	end

end

function onClickDown(button, x, y)
	-- Suppress default processing to support dragging
	clickKeyword = hoverKeyword;
	return true;
end
function onClickRelease(button, x, y)
	-- Enable edit mode on mouse release
	setFocus();	
	local n = getIndexAt(x, y);
	
	setSelectionPosition(n);
	setCursorPosition(n);
	return true;
end

function actionkeyword(draginfo, rkeyword)
	local nodeRecord = window.getDatabaseNode();

	local skeyword = getValue():lower();
	
	local nkeywordStart, nkeywordEnd, sAbilitykeyword;
	
	if keywordlookup and keywordlookup[1] == "creatureability" then
		nkeywordStart, nkeywordEnd, sAbilitykeyword = string.find(skeyword, "%((.+)%)");	
	end
	
	if nkeywordStart and sAbilitykeyword then
		-- Remove brackets if we have a creature ability keyword string.
		skeyword = sAbilitykeyword:gsub("[%(%)]", "");
	end

	skeyword = string.gsub(skeyword, "\n", ", ");	
	
	local akeyword = {};
	if string.find(skeyword, ",") then	
		akeyword = StringManager.split(skeyword, ",", true);
	else
		akeyword = StringManager.split(skeyword, " ", true)
	end
	
	local aKeywordNodes = ManagerGetRefData.getKeywordNodes(recordNode, akeyword, sKeywordType);
	if #aKeywordNodes > 0 then
		local windowKeywordlist = Interface.openWindow("keyword_ref_list", nodeRecord);
		-- GlobalDebug.consoleObjects("Opened keyword_ref_list window.  Instance = ", windowKeywordlist);
		windowKeywordlist.populatekeywordList(nodeRecord, sKeywordType, aKeywordNodes);
	end
	
	return true;
end

function getKeywordNodes(recordNode, aKeywordNames, sKeywordType)
	local aKeywordNodes = { };
	for k, v in pairs(aKeywordNames) do	
		if v then
			local sKeywordName = v;
			
			-- Remove any dice from the entry - such as Deadly 1d12 or Fatal 1d10
			local nStarts, nEnds, sKeywordWithoutDice = string.find(sKeywordName, "([%a%s%-]*)%s*%(?%+?%d*d%d+%)?$");
			if sKeywordWithoutDice and sKeywordWithoutDice ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithoutDice);
			end
			
			-- Remove any single digits from the entry - such as "additive 1"
			local sKeywordWithoutDigit = string.match(sKeywordName, "([%a%s%-]*)%s*%d$");
			if (sKeywordWithoutDigit or "") ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithoutDigit);
			end			
			
			-- check for Thrown XX ft. - replace with just Thrown.
			local nStarts, nEnds, sKeywordWithDistance = string.find(sKeywordName, "([%a%s%-]*)%s*%(?%d*%s*ft.%)?$");
			if sKeywordWithDistance and sKeywordWithDistance ~= "" then
				sKeywordName = StringManager.trim(sKeywordWithDistance);
			end

			-- check for Versatile <damage type> - replace with just Versatile.
			if string.find(sKeywordName, "^versatile") then
				sKeywordName = "versatile";
			end		

			local keywordMatchNode = nil;

			-- Get keyword node from the campaign and reference database with a matching keywordtype.
			local aDataMap = { "keyword", "reference.keyword" };
			keywordMatchNode = getKeywordRecordGlobally(sKeywordName, sKeywordType, aDataMap); 

			-- If we don't have a match ith the type then get keyword node from the campaign and reference database with a blank keywordtype.
			if not keywordMatchNode and sKeywordType ~= "" then
				keywordMatchNode = getKeywordRecordGlobally(sKeywordName, "", aDataMap);
			end			
			
			if keywordMatchNode then
				table.insert(aKeywordNodes, keywordMatchNode);
			end
		end	
	end
	
	return aKeywordNodes;
end

function getKeywordRecordGlobally(sKeywordName, sKeywordType, aDataMap)
	-- Get record nodes from the database paths in aDataMap
	local recordMatchNode = nil;
	
	for k, topLevelNodeName in pairs(aDataMap) do
		local recordNodes = DB.getChildrenGlobal(topLevelNodeName); 
		for k, recordNode in pairs(recordNodes) do
			local recordCheckName = StringManager.trim(DB.getValue(recordNode, "name", ""):lower());
			local sNodeKeywordType = DB.getValue(keywordNode, "keywordtype", ""):lower();
			if recordCheckName == sKeywordName:lower() and sKeywordType:lower() == sNodeKeywordType then
				recordMatchNode = recordNode;
				break;
			end
		end	
		if recordMatchNode ~= nil then
			break;
		end
	end
	
	return recordMatchNode;
end

function onDoubleClick(x, y)
	return actionkeyword(nil, nil);
end
