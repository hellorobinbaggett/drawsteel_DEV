--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

OOB_MSGTYPE_ENDTURN = "endturn";
OOB_MSGTYPE_INITSWAP = "initiative_swap";
OOB_MSGTYPE_GONE = "gone";

CT_MAIN_PATH = "combattracker";
CT_COMBATANT_PATH = "combattracker.list_heroes.*";
CT_COMBATANT_PARENT = "combattracker.list_heroes";
CT_LIST = "combattracker.list_heroes";
CT_ROUND = "combattracker.round";

local _bTrackersInit = false;

function onTabletopInit()
	CombatManagerHeroes.registerStandardCombatHotKeys();

	OOBManager.registerOOBMsgHandler(CombatManagerHeroes.OOB_MSGTYPE_ENDTURN, CombatManagerHeroes.handleEndTurn);
	OOBManager.registerOOBMsgHandler(CombatManagerHeroes.OOB_MSGTYPE_INITSWAP, CombatManagerHeroes.handleInitSwap);

	CombatManagerHeroes.initTrackers();

	if Session.IsHost then
		CombatManagerHeroes.initPlayerRecordTypes();
		OptionsManager.registerCallback("TPTY", CombatManagerHeroes.onOptionTokenPartyVisionMoveChanged);
		OptionsManager.registerCallback("TFOW", CombatManagerHeroes.onOptionTokenFOWChanged);
	end
end

local _bInitHotKey = false;
function registerStandardCombatHotKeys()
	if _bInitHotKey then
		return;
	end

	Interface.addKeyedEventHandler("onHotkeyActivated", "combattrackernextactor", CombatManagerHeroes.onHotKeyNextActor);
	Interface.addKeyedEventHandler("onHotkeyActivated", "combattrackernextround", CombatManagerHeroes.onHotKeyNextRound);

	_bInitHotKey = true;
end
function onHotKeyNextActor()
	CombatManagerHeroes.nextTurn();
	return true;
end
function onHotKeyNextRound()
	CombatManagerHeroes.nextRound(1);
	return true;
end

function onOptionTokenPartyVisionMoveChanged()
	for _,v in ipairs(CombatManagerHeroes.getAllCombatantNodes()) do
		TokenManager.updateVisibility(v);
		TokenManager.updateFaction(DB.createChild(v, "friendfoe"));
	end
end
function onOptionTokenFOWChanged()
	for _,v in ipairs(CombatManagerHeroes.getAllCombatantNodes()) do
		TokenManager.updateFaction(DB.createChild(v, "friendfoe"));
	end
end

--
-- MULTIPLE COMBAT TRACKER SUPPORT
--

local _tTrackers = {};
function setTracker(sKey, tData)
	if not sKey or not tData or not tData.sTrackerPath or not tData.sCombatantParentPath or not tData.sCombatantPath then
		return;
	end
	_tTrackers[sKey] = tData;
end
function getTrackerKeys()
	local tResults = {};
	for k,_ in pairs(_tTrackers) do
		table.insert(tResults, k);
	end
	return tResults;
end
function getTrackerPath(sKey)
	if _tTrackers[sKey or ""] then
		return _tTrackers[sKey or ""].sTrackerPath;
	end
	return CombatManagerHeroes.CT_LIST;
end
function getTrackerCombatantPath(sKey)
	if _tTrackers[sKey or ""] then
		return _tTrackers[sKey or ""].sCombatantPath;
	end
	return CombatManagerHeroes.CT_COMBATANT_PATH;
end
function getTrackerSort(sKey)
	if _tTrackers[sKey or ""] then
		return _tTrackers[sKey or ""].fSort or CombatManagerHeroes.sortfuncSimple;
	end
	return CombatManagerHeroes.sortfuncSimple;
end
function getTrackerCleanup(sKey)
	if _tTrackers[sKey or ""] then
		return _tTrackers[sKey or ""].fCleanup;
	end
	return nil;
end

function getTrackerKeyFromCT(v)
	if not v then
		return "";
	end
	local sPath = CombatManagerHeroes.resolvePath(v);
	if not sPath then
		return "";
	end
	for k,tTrackerData in pairs(_tTrackers) do
		if UtilityManager.doesPathStartWith(sPath, tTrackerData.sTrackerPath) then
			return k;
		end
	end
	return "";
end
function isTrackerCT(v)
	if not v then
		return false;
	end
	local sPath = CombatManagerHeroes.resolvePath(v);
	if not sPath then
		return false;
	end
	for _,tTrackerData in pairs(_tTrackers) do
		if UtilityManager.doesPathStartWith(sPath, tTrackerData.sTrackerPath) then
			return true;
		end
	end
	return false;
end

function initTrackers()
	local tData = {
		sTrackerPath = CombatManagerHeroes.CT_LIST,
		sCombatantParentPath = CombatManagerHeroes.CT_COMBATANT_PARENT,
		sCombatantPath = CombatManagerHeroes.CT_COMBATANT_PATH,
		fSort = CombatManagerHeroes.getCustomSort() or CombatManagerHeroes.sortfuncSimple,
		fCleanup = CombatManagerHeroes.deleteCleanup,
	};
	CombatManagerHeroes.setTracker("", tData);

	for _,tTrackerData in pairs(_tTrackers) do
		DB.addHandler(tTrackerData.sCombatantPath, "onDelete", CombatManagerHeroes.onDeleteCombatantEvent);
		DB.addHandler(tTrackerData.sCombatantParentPath, "onChildDeleted", CombatManagerHeroes.onPostDeleteCombatantEvent);
		DB.addHandler(DB.getPath(tTrackerData.sCombatantPath, "effects"), "onDelete", CombatManagerHeroes.onPreDeleteCombatantEffectEvent);
		DB.addHandler(DB.getPath(tTrackerData.sCombatantPath, "effects"), "onChildAdded", CombatManagerHeroes.onAddCombatantEffectEvent);
		DB.addHandler(DB.getPath(tTrackerData.sCombatantPath, "effects"), "onChildDeleted", CombatManagerHeroes.onDeleteCombatantEffectEvent);
	end

	_bTrackersInit = true;

	CombatManagerHeroes.helperInitCombatantFieldHandlers();
	CombatManagerHeroes.helperInitCombatantEffecFieldHandlers();
end

--
-- COMBATANT HANDLERS
-- NOTE: Combatant list/count handler is single linked, combat event handlers are multi-linked, and field handlers are unmanaged (ruleset code must add/remove)
--

local fCustomGetCombatantNodes = nil;
function setCustomGetCombatantNodes(fn)
	fCustomGetCombatantNodes = fn;
end

-- NOTE: Pre-delete events are only triggered when removing combatants through UI
local aCustomPreDeleteCombatantHandlers = {};
function setCustomPreDeleteCombatantHandler(fn)
	table.insert(aCustomPreDeleteCombatantHandlers, fn);
end
function removeCustomPreDeleteCombatantHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomPreDeleteCombatantHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomPreDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onPreDeleteCombatantEvent(nodeCT)
	for _,fn in ipairs(aCustomPreDeleteCombatantHandlers) do
		if fn(nodeCT) then
			return true;
		end
	end
	return false;
end

local aCustomDeleteCombatantHandlers = {};
function setCustomDeleteCombatantHandler(fn)
	table.insert(aCustomDeleteCombatantHandlers, fn);
end
function removeCustomDeleteCombatantHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEvent(nodeCT)
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantHandlers) do
		if fCustomDelete(nodeCT) then
			return true;
		end
	end
	return false;
end

local aCustomPostDeleteCombatantHandlers = {};
function setCustomPostDeleteCombatantHandler(fn)
	table.insert(aCustomPostDeleteCombatantHandlers, fn);
end
function removeCustomPostDeleteCombatantHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomPostDeleteCombatantHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomPostDeleteCombatantHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onPostDeleteCombatantEvent()
	for _,fn in ipairs(aCustomPostDeleteCombatantHandlers) do
		fn();
	end
end

local aCustomAddCombatantEffectHandlers = {};
function setCustomAddCombatantEffectHandler(fn)
	table.insert(aCustomAddCombatantEffectHandlers, fn);
end
function removeCustomAddCombatantEffectHandler(fn)
	for kCustomAdd,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd == fn then
			table.remove(aCustomAddCombatantEffectHandlers, kCustomAdd);
			return true;
		end
	end
	return false;
end
function onAddCombatantEffectEvent(nodeEffectList, nodeEffect)
	for _,fCustomAdd in ipairs(aCustomAddCombatantEffectHandlers) do
		if fCustomAdd(DB.getParent(nodeEffectList), nodeEffect) then
			return true;
		end
	end
	return false;
end

local _tPreDeleteCombatEffectHandlers = {};
function setCustomPreDeleteCombatantEffectHandler(fn)
	table.insert(_tPreDeleteCombatEffectHandlers, fn);
end
function removeCustomPreDeleteCombatantEffectHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(_tPreDeleteCombatEffectHandlers) do
		if fCustomDelete == fn then
			table.remove(_tPreDeleteCombatEffectHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onPreDeleteCombatantEffectEvent(nodeEffect)
	for _,fCustomDelete in ipairs(_tPreDeleteCombatEffectHandlers) do
		if fCustomDelete(nodeEffect) then
			return true;
		end
	end
	return false;
end

local aCustomDeleteCombatantEffectHandlers = {};
function setCustomDeleteCombatantEffectHandler(fn)
	table.insert(aCustomDeleteCombatantEffectHandlers, fn);
end
function removeCustomDeleteCombatantEffectHandler(fn)
	for kCustomDelete,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete == fn then
			table.remove(aCustomDeleteCombatantEffectHandlers, kCustomDelete);
			return true;
		end
	end
	return false;
end
function onDeleteCombatantEffectEvent(nodeEffectList)
	if type(nodeEffectList) ~= "databasenode" then
		return false;
	end
	local nodeCT = DB.getChild(nodeEffectList, "..");
	for _,fCustomDelete in ipairs(aCustomDeleteCombatantEffectHandlers) do
		if fCustomDelete(nodeCT) then
			return true;
		end
	end
	return false;
end

function addCombatantFieldChangeHandler(sField, sEvent, fn)
	CombatManagerHeroes.addKeyedCombatantFieldChangeHandler("", sField, sEvent, fn);
end
function addKeyedCombatantFieldChangeHandler(sKey, sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperAddCombatantFieldChangeHandler(sKey, sField, sEvent, fn);
	else
		CombatManagerHeroes.addDelayedSingleFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
function addAllCombatantFieldChangeHandler(sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperAddAllCombatantFieldChangeHandler(sField, sEvent, fn);
	else
		CombatManagerHeroes.addDelayedAllFieldChangeHandler(sField, sEvent, fn);
	end
end
function removeCombatantFieldChangeHandler(sField, sEvent, fn)
	CombatManagerHeroes.removeKeyedCombatantFieldChangeHandler("", sField, sEvent, fn);
end
function removeKeyedCombatantFieldChangeHandler(sKey, sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperRemoveCombatantFieldChangeHandler(sKey, sField, sEvent, fn);
	else
		CombatManagerHeroes.removeDelayedSingleFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
local _tSingleFieldChangeHandler = {};
local _tAllFieldChangeHandler = {};
function addDelayedSingleFieldChangeHandler(sKey, sField, sEvent, fn)
	table.insert(_tSingleFieldChangeHandler, { sKey = sKey, sField = sField, sEvent = sEvent, fn = fn } );
end
function addDelayedAllFieldChangeHandler(sField, sEvent, fn)
	table.insert(_tAllFieldChangeHandler, { sField = sField, sEvent = sEvent, fn = fn } );
end
function removeDelayedSingleFieldChangeHandler(sKey, sField, sEvent, fn)
	for k,v in ipairs(_tSingleFieldChangeHandler) do
		if (v.sKey == sKey) and (v.sField == sField) and (v.sEvent == sEvent) and (v.fn == fn) then
			table.remove(_tSingleFieldChangeHandler, k);
			break;
		end
	end
end
function removeDelayedAllFieldChangeHandler(sField, sEvent, fn)
	for k,v in ipairs(_tAllFieldChangeHandler) do
		if (v.sField == sField) and (v.sEvent == sEvent) and (v.fn == fn) then
			table.remove(_tAllFieldChangeHandler, k);
			break;
		end
	end
end
function helperInitCombatantFieldHandlers()
	for _,v in ipairs(_tAllFieldChangeHandler) do
		CombatManagerHeroes.helperAddAllCombatantFieldChangeHandler(v.sField, v.sEvent, v.fn);
	end
	_tAllFieldChangeHandler = {};
	for _,v in ipairs(_tSingleFieldChangeHandler) do
		CombatManagerHeroes.helperAddCombatantFieldChangeHandler(v.sKey, v.sField, v.sEvent, v.fn);
	end
	_tSingleFieldChangeHandler = {};
end
function helperAddCombatantFieldChangeHandler(sKey, sField, sEvent, fn)
	DB.addHandler(DB.getPath(CombatManagerHeroes.getTrackerCombatantPath(sKey), sField), sEvent, fn);
end
function helperAddAllCombatantFieldChangeHandler(sField, sEvent, fn)
	for _,sKey in ipairs(CombatManagerHeroes.getTrackerKeys()) do
		CombatManagerHeroes.helperAddCombatantFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
function helperRemoveCombatantFieldChangeHandler(sKey, sField, sEvent, fn)
	DB.removeHandler(DB.getPath(CombatManagerHeroes.getTrackerCombatantPath(sKey), sField), sEvent, fn);
end

function addCombatantEffectFieldChangeHandler(sField, sEvent, fn)
	CombatManagerHeroes.addKeyedCombatantEffectFieldChangeHandler("", sField, sEvent, fn);
end
function addKeyedCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperAddCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn);
	else
		CombatManagerHeroes.addDelayedSingleEffectFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
function addAllCombatantEffectFieldChangeHandler(sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperAddAllCombatantEffectFieldChangeHandler(sField, sEvent, fn);
	else
		CombatManagerHeroes.addDelayedAllEffectFieldChangeHandler(sField, sEvent, fn);
	end
end
function removeCombatantEffectFieldChangeHandler(sField, sEvent, fn)
	CombatManagerHeroes.removeKeyedCombatantEffectFieldChangeHandler("", sField, sEvent, fn);
end
function removeKeyedCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	if _bTrackersInit then
		CombatManagerHeroes.helperRemoveCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn);
	else
		CombatManagerHeroes.removeDelayedSingleEffectFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
local _tSingleEffectFieldChangeHandler = {};
local _tAllEffectFieldChangeHandler = {};
function addDelayedSingleEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	table.insert(_tSingleEffectFieldChangeHandler, { sKey = sKey, sField = sField, sEvent = sEvent, fn = fn } );
end
function addDelayedAllEffectFieldChangeHandler(sField, sEvent, fn)
	table.insert(_tAllEffectFieldChangeHandler, { sField = sField, sEvent = sEvent, fn = fn } );
end
function removeDelayedSingleEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	for k,v in ipairs(_tSingleEffectFieldChangeHandler) do
		if (v.sKey == sKey) and (v.sField == sField) and (v.sEvent == sEvent) and (v.fn == fn) then
			table.remove(_tSingleEffectFieldChangeHandler, k);
			break;
		end
	end
end
function removeDelayedAllEffectFieldChangeHandler(sField, sEvent, fn)
	for k,v in ipairs(_tAllEffectFieldChangeHandler) do
		if (v.sField == sField) and (v.sEvent == sEvent) and (v.fn == fn) then
			table.remove(_tAllEffectFieldChangeHandler, k);
			break;
		end
	end
end
function helperInitCombatantEffecFieldHandlers()
	for _,v in ipairs(_tAllEffectFieldChangeHandler) do
		CombatManagerHeroes.helperAddAllCombatantEffectFieldChangeHandler(v.sField, v.sEvent, v.fn);
	end
	_tAllEffectFieldChangeHandler = {};
	for _,v in ipairs(_tSingleEffectFieldChangeHandler) do
		CombatManagerHeroes.helperAddCombatantEffectFieldChangeHandler(v.sKey, v.sField, v.sEvent, v.fn);
	end
	_tSingleEffectFieldChangeHandler = {};
end
function helperAddCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	DB.addHandler(DB.getPath(CombatManagerHeroes.getTrackerCombatantPath(sKey), "effects.*", sField), sEvent, fn);
end
function helperAddAllCombatantEffectFieldChangeHandler(sField, sEvent, fn)
	for _,sKey in ipairs(CombatManagerHeroes.getTrackerKeys()) do
		CombatManagerHeroes.helperAddCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn);
	end
end
function helperRemoveCombatantEffectFieldChangeHandler(sKey, sField, sEvent, fn)
	DB.removeHandler(DB.getPath(CombatManagerHeroes.getTrackerCombatantPath(sKey), "effects.*", sField), sEvent, fn);
end

--
-- MULTI HANDLERS
-- NOTE: Handlers added here will all be called in the order they were added.
--

local aCustomRoundStart = {};
function setCustomRoundStart(fRoundStart)
	table.insert(aCustomRoundStart, fRoundStart);
end
function onRoundStartEvent(nCurrent)
	if #aCustomRoundStart > 0 then
		for _,fCustomRoundStart in ipairs(aCustomRoundStart) do
			fCustomRoundStart(nCurrent);
		end
	end
end

local aCustomTurnStart = {};
function setCustomTurnStart(fTurnStart)
	table.insert(aCustomTurnStart, fTurnStart);
end
function onTurnStartEvent(nodeCT)
	if #aCustomTurnStart > 0 then
		for _,fCustomTurnStart in ipairs(aCustomTurnStart) do
			fCustomTurnStart(nodeCT);
		end
	end
end

local aCustomTurnEnd = {};
function setCustomTurnEnd(fTurnEnd)
	table.insert(aCustomTurnEnd, fTurnEnd);
end
function onTurnEndEvent(nodeCT)
	if #aCustomTurnEnd > 0 then
		for _,fCustomTurnEnd in ipairs(aCustomTurnEnd) do
			fCustomTurnEnd(nodeCT);
		end
	end
end

local aCustomInitChange = {};
function setCustomInitChange(fInitChange)
	table.insert(aCustomInitChange, fInitChange);
end
function onInitChangeEvent(nodeOldCT, nodeNewCT)
	if #aCustomInitChange > 0 then
		for _,fCustomInitChange in ipairs(aCustomInitChange) do
			fCustomInitChange(nodeOldCT, nodeNewCT);
		end
	end
end

local aCustomCombatReset = {};
function setCustomCombatReset(fCombatReset)
	table.insert(aCustomCombatReset, fCombatReset);
end
function onCombatResetEvent()
	if #aCustomCombatReset > 0 then
		for _,fCustomCombatReset in ipairs(aCustomCombatReset) do
			fCustomCombatReset();
		end
	end
end

--
-- SINGLE HANDLERS
-- NOTE: Setting these handlers will override previous handlers
--

local _fnCustomSort = nil;
function setCustomSort(fn)
	_fnCustomSort = fn;
end
function getCustomSort()
	return _fnCustomSort;
end
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
function onSortCompare(node1, node2)
	return not CombatManagerHeroes.getTrackerSort("")(node1, node2);
end
function onTrackerSortCompare(sKey, node1, node2)
	return not CombatManagerHeroes.getTrackerSort(sKey)(node1, node2);
end

local _fnInitSwapPlayerAllow = nil;
function getCustomInitSwapPlayerAllow()
	return _fnInitSwapPlayerAllow;
end
function setCustomInitSwapPlayerAllow(fn)
	_fnInitSwapPlayerAllow = fn;
end

--
-- GENERAL
--

function createCombatantNode(sKey)
	local sListPath = CombatManagerHeroes.getTrackerPath(sKey);
	DB.createNode(sListPath);
	return DB.createChild(sListPath);
end
function getCombatantNodes(sKey, sRecordType)
	if fCustomGetCombatantNodes then
		return fCustomGetCombatantNodes(sKey, sRecordType);
	end
	local sListPath = CombatManagerHeroes.getTrackerPath(sKey);
	if (sRecordType or "") == "" then
		return DB.getChildren(sListPath);
	else
		local tResult = {};
		for _,v in pairs(DB.getChildren(sListPath)) do
			if CombatManagerHeroes.isRecordType(v, sRecordType) then
				tResult[DB.getName(v)] = v;
			end
		end
		return tResult;
	end
end
function getAllCombatantNodes(sRecordType)
	local tResults = {};
	for _,sKey in ipairs(CombatManagerHeroes.getTrackerKeys()) do
		local tCombatants = CombatManagerHeroes.getCombatantNodes(sKey, sRecordType);
		for _,v in pairs(tCombatants) do
			table.insert(tResults, v);
		end
	end
	return tResults;
end

function getActiveCT(sKey, sRecordType)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey, sRecordType)) do
		if DB.getValue(v, "active", 0) == 1 then
			return v;
		end
	end
	return nil;
end

function getCTFromNode(vNode)
	-- Get path name desired
	local sNode = CombatManagerHeroes.resolvePath(vNode);
	if not sNode then
		return nil;
	end

	for _,sKey in ipairs(CombatManagerHeroes.getTrackerKeys()) do
		local tCombatants = CombatManagerHeroes.getCombatantNodes(sKey);

		-- Check for exact CT match
		for _,v in pairs(tCombatants) do
			if DB.getPath(v) == sNode then
				return v;
			end
		end

		-- Otherwise, check for link match
		for _,v in pairs(tCombatants) do
			local _,sRecord = DB.getValue(v, "link", "", "");
			if sRecord == sNode then
				return v;
			end
		end
	end

	return nil;
end
function getCTFromTokenRef(vContainer, nId)
	local sContainerNode = CombatManagerHeroes.resolvePath(vContainer);
	if not sContainerNode then
		return nil;
	end

	for _,sKey in ipairs(CombatManagerHeroes.getTrackerKeys()) do
		for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
			local sCTContainerName = DB.getValue(v, "tokenrefnode", "");
			local nCTId = tonumber(DB.getValue(v, "tokenrefid", "")) or 0;
			if (sCTContainerName == sContainerNode) and (nCTId == nId) then
				return v;
			end
		end
	end

	return nil;
end
function getCTFromToken(token)
	if not token then
		return nil;
	end

	local nodeContainer = token.getContainerNode();
	local nID = token.getId();

	return CombatManagerHeroes.getCTFromTokenRef(nodeContainer, nID);
end

function getTokenFromCT(vEntry)
	local nodeCT = CombatManagerHeroes.resolveNode(vEntry);
	if not nodeCT then
		return nil;
	end
	return Token.getToken(DB.getValue(nodeCT, "tokenrefnode", ""), DB.getValue(nodeCT, "tokenrefid", ""));
end
function getFactionFromCT(vEntry)
	local nodeCT = CombatManagerHeroes.resolveNode(vEntry);
	if not nodeCT then
		return nil;
	end
	return DB.getValue(nodeCT, "friendfoe", "");
end
function getTokenVisibilityFromCT(vEntry)
	local nodeCT = CombatManagerHeroes.resolveNode(vEntry);
	if not nodeCT then
		return true;
	end
	return (DB.getValue(nodeCT, "tokenvis", 0) == 1);
end

function getCurrentUserCT(sKey)
	local nodeActive = CombatManagerHeroes.getActiveCT(sKey);
	if Session.IsHost then
		return nodeActive;
	end

	-- If active identity is owned, then use that one
	if nodeActive then
		if CombatManagerHeroes.isOwnedPlayerCT(nodeActive) then
			return nodeActive;
		end
	end

	-- Otherwise, use active identity (if any)
	local sID = User.getCurrentIdentity();
	if sID then
		return CombatManagerHeroes.getCTFromNode("charsheet." .. sID);
	end

	return nil;
end

function openMap(vNode)
	local nodeCT = CombatManagerHeroes.getCTFromNode(vNode);
	if not nodeCT then
		return false;
	end
	return CombatManagerHeroes.centerOnToken(nodeCT, true);
end
function centerOnToken(nodeCT, bOpen)
	if not Session.IsHost and not CombatManagerHeroes.isOwnedPlayerCT(nodeCT) then
		return false;
	end
	return ImageManager.centerOnToken(CombatManagerHeroes.getTokenFromCT(nodeCT), bOpen);
end
function selectToken(nodeCT)
	if not Session.IsHost and not CombatManagerHeroes.isOwnedPlayerCT(nodeCT) then
		return false;
	end
	return ImageManager.selectToken(CombatManagerHeroes.getTokenFromCT(nodeCT));
end

function isCTHidden(vEntry)
	local nodeCT = CombatManagerHeroes.resolveNode(vEntry);
	if not nodeCT then
		return false;
	end

	if CombatManagerHeroes.getFactionFromCT(nodeCT) == "friend" then
		return false;
	end
	if CombatManagerHeroes.getTokenVisibilityFromCT(nodeCT) then
		return false;
	end
	return true;
end

function onInitSwap(nodeSourceCT, nodeTargetCT)
	if not nodeSourceCT or not nodeTargetCT then
		return;
	end
	if not Session.IsHost then
		if not CombatManagerHeroes.isOwnedPlayerCT(nodeSourceCT) then
			return;
		end
		if CombatManagerHeroes.getFactionFromCT(nodeSourceCT) ~= CombatManagerHeroes.getFactionFromCT(nodeTargetCT) then
			return;
		end
	end
	CombatManagerHeroes.notifyInitSwap(nodeSourceCT, nodeTargetCT);
end
function notifyInitSwap(nodeSourceCT, nodeTargetCT)
	local msgOOB = {};
	msgOOB.type = CombatManagerHeroes.OOB_MSGTYPE_INITSWAP;
	msgOOB.nIsHost = Session.IsHost and 1 or 0;
	msgOOB.sSourceNode = DB.getPath(nodeSourceCT);
	msgOOB.sTargetNode = DB.getPath(nodeTargetCT);
	Comm.deliverOOBMessage(msgOOB, "");
end
function handleInitSwap(msgOOB)
	CombatManagerHeroes.performInitSwap(DB.findNode(msgOOB.sSourceNode), DB.findNode(msgOOB.sTargetNode), (tonumber(msgOOB.nIsHost) == 1));
end
function performInitSwap(nodeSourceCT, nodeTargetCT, bHost)
	if not nodeSourceCT or not nodeTargetCT then
		return;
	end

	local nSourceInit = DB.getValue(nodeSourceCT, "initresult", 0);
	local nTargetInit = DB.getValue(nodeTargetCT, "initresult", 0);
	if nSourceInit == nTargetInit then
		return;
	end

	DB.setValue(nodeSourceCT, "initresult", "number", nTargetInit);
	DB.setValue(nodeTargetCT, "initresult", "number", nSourceInit);

	local nodeActive = CombatManagerHeroes.getActiveCT();
	if nodeActive == nodeSourceCT then
		CombatManagerHeroes.requestActivation(nodeTargetCT);
		CombatManagerHeroes.onTurnStartEvent(nodeTargetCT);
	elseif nodeActive == nodeTargetCT then
		CombatManagerHeroes.requestActivation(nodeSourceCT);
		CombatManagerHeroes.onTurnStartEvent(nodeSourceCT);
	end

	local msg = {
		font = "narratorfont",
		text = string.format(Interface.getString("message_initswap"), ActorManager.getDisplayName(nodeSourceCT), ActorManager.getDisplayName(nodeTargetCT)),
		secret = bHost;
	};
	Comm.deliverChatMessage(msg);
end

--
-- COMBAT TRACKER SORT
--
-- NOTE: Lua sort function expects the opposite boolean value compared to built-in FG sorting
--

function sortfuncSimple(node1, node2)
	return DB.getPath(node1) < DB.getPath(node2);
end
function sortfuncStandard(node1, node2)
	local bHost = Session.IsHost;
	local sOptCTSI = OptionsManager.getOption("CTSI");

	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");

	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");

	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end

	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return DB.getPath(node1) < DB.getPath(node2);
end
function sortfuncDnD(node1, node2)
	local bHost = Session.IsHost;
	local sOptCTSI = OptionsManager.getOption("CTSI");

	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");

	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");

	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end

			nValue1 = DB.getValue(node1, "init", 0);
			nValue2 = DB.getValue(node2, "init", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end

	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return DB.getPath(node1) < DB.getPath(node2);
end
function getSortedCombatantList(sKey)
	local aEntries = {};
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
		table.insert(aEntries, v);
	end
	if #aEntries > 0 then
		table.sort(aEntries, CombatManagerHeroes.getTrackerSort(sKey));
	end
	return aEntries;
end

--
-- TURN FUNCTIONS
--

function handleEndTurn(msgOOB)
	local nodeActive = CombatManagerHeroes.getActiveCT();
	if nodeActive then
		local _,sRecord = DB.getValue(nodeActive, "link", "", "");
		if (sRecord ~= "") then
			if DB.getOwner(sRecord) == msgOOB.user then
				CombatManagerHeroes.nextActor();
			end
		end
	end
end
function notifyEndTurn()
	local msgOOB = {};
	msgOOB.type = CombatManagerHeroes.OOB_MSGTYPE_ENDTURN;
	msgOOB.user = Session.UserName;

	Comm.deliverOOBMessage(msgOOB, "");
end

-- Handle turn notification (including bell ring based on option)
function showTurnMessage(nodeEntry, bActivate, bSkipBell)
	if not Session.IsHost then
		return;
	end

	local rActor = ActorManager.resolveActor(nodeEntry);
	local sName = ActorManager.getDisplayName(rActor);
	local sFaction = ActorManager.getFaction(rActor);

	local msgGM = {font = "narratorfont", icon = "turn_flag"};
	msgGM.text = string.format("[%s] %s", Interface.getString("combat_tag_turn"), sName);

	local msgPlayer = {font = "narratorfont", icon = "turn_flag"};
	msgPlayer.text = msgGM.text;

	if OptionsManager.isOption("RSHE", "on") then
		if sFaction == "friend" then
			local sEffects = EffectManager.getEffectsString(nodeEntry, true);
			if sEffects ~= "" then
				msgPlayer.text = msgPlayer.text .. " - [" .. sEffects .. "]";
			end
		end
		local sEffectsGM = EffectManager.getEffectsString(nodeEntry, false);
		if sEffectsGM ~= "" then
			msgGM.text = msgGM.text .. " - [" .. sEffectsGM .. "]";
		end
	end

	-- local sOptRSHT = OptionsManager.getOption("RSHT");
	-- local bShowPlayerMessage = bActivate and not CombatManagerHeroes.isCTHidden(nodeEntry) and ((sOptRSHT == "all") or ((sOptRSHT == "on") and (sFaction == "friend")));
	local bShowPlayerMessage = bActivate and not CombatManagerHeroes.isCTHidden(nodeEntry);

	msgGM.secret = not bShowPlayerMessage;
	Comm.addChatMessage(msgGM);

	if bShowPlayerMessage then
		local aUsers = User.getActiveUsers();
		if #aUsers > 0 then
			Comm.deliverChatMessage(msgPlayer, aUsers);
		end
	end
	if not bSkipBell and OptionsManager.isOption("RING", "on") then
		local nodeActor = ActorManager.getCreatureNode(rActor);
		if nodeActor then
			local sOwner = DB.getOwner(nodeActor);
			if (sOwner or "") ~= "" then
				User.ringBell(sOwner);
			end
		end
	end
end
function requestActivation(nodeEntry, bSkipBell)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end
	ChatIdentityManager.clearCombatantIdentity();

	if nodeEntry then
		DB.setValue(nodeEntry, "active", "number", 1);
		CombatManagerHeroes.showTurnMessage(nodeEntry, true, bSkipBell);
		ChatIdentityManager.addCombatantIdentity(nodeEntry);
	end
end
function isActorToSkipTurn(nodeEntry)
	local rActor = ActorManager.resolveActor(nodeEntry);
	if EffectManager.hasEffect(rActor, "SKIPTURN") then
		return true;
	end

	local sFaction = ActorManager.getFaction(rActor);
	if sFaction == "friend" then
		return false;
	else
		local bSkipDeadEnemy = OptionsManager.isOption("CTSD", "on");
		if bSkipDeadEnemy then
			if ActorHealthManager.isDyingOrDead(rActor) then
				return true;
			end
		end
	end

	local bSkipHidden = OptionsManager.isOption("CTSH", "on");
	if bSkipHidden and CombatManagerHeroes.isCTHidden(nodeEntry) then
		return true;
	end

	return false;
end
function nextActor(bSkipBell, bNoRoundAdvance)
	if not Session.IsHost then
		return;
	end

	local aEntries = CombatManagerHeroes.getSortedCombatantList();

	local nodeActive = CombatManagerHeroes.getActiveCT();
	local nIndexActive = 0;

	local nodeNext = nil;
	local nIndexNext = 0;

	-- Determine the next actor
	if #aEntries > 0 then
		if nodeActive then
			for i = 1,#aEntries do
				if aEntries[i] == nodeActive then
					nIndexActive = i;
					break;
				end
			end
		end
		for i = nIndexActive + 1, #aEntries do
			if not CombatManagerHeroes.isActorToSkipTurn(aEntries[i]) then
				nIndexNext = i;
				break;
			end
		end
		if nIndexNext > nIndexActive then
			nodeNext = aEntries[nIndexNext];
			for i = nIndexActive + 1, nIndexNext - 1 do
				CombatManagerHeroes.showTurnMessage(aEntries[i], false);
			end
		end
	end

	-- If next actor available, advance effects, activate and start turn
	if nodeNext then
		-- End turn for current actor
		if nodeActive then
			CombatManagerHeroes.onTurnEndEvent(nodeActive);
		end

		-- Process effects in between current and next actors
		if nodeActive then
			CombatManagerHeroes.onInitChangeEvent(nodeActive, nodeNext);
		else
			CombatManagerHeroes.onInitChangeEvent(nil, nodeNext);
		end

		-- Start turn for next actor
		CombatManagerHeroes.requestActivation(nodeNext, bSkipBell);
		CombatManagerHeroes.onTurnStartEvent(nodeNext);
	elseif not bNoRoundAdvance then
		for i = nIndexActive + 1, #aEntries do
			CombatManagerHeroes.showTurnMessage(aEntries[i], false);
		end
		CombatManagerHeroes.nextRound(1);
	end
end
function nextRound(nRounds)
	if not Session.IsHost then
		return;
	end

	local nodeActive = CombatManagerHeroes.getActiveCT();
	local nCurrent = DB.getValue(CombatManagerHeroes.CT_ROUND, 0);

	-- If current actor, then advance based on that
	local nStartCounter = 1;
	local aEntries = CombatManagerHeroes.getSortedCombatantList();
	if nodeActive then
		DB.setValue(nodeActive, "active", "number", 0);
		ChatIdentityManager.clearCombatantIdentity();

		local bFastTurn = false;
		for i = 1,#aEntries do
			if aEntries[i] == nodeActive then
				bFastTurn = true;
				CombatManagerHeroes.onTurnEndEvent(nodeActive);
			elseif bFastTurn then
				CombatManagerHeroes.onTurnStartEvent(aEntries[i]);
				CombatManagerHeroes.onTurnEndEvent(aEntries[i]);
			end
		end

		CombatManagerHeroes.onInitChangeEvent(nodeActive);

		nStartCounter = nStartCounter + 1;
		
		CombatManagerHeroes.deleteNonFaction("friend");
        CombatManagerHeroes.deleteFaction("friend");
        CombatManagerHeroes.deleteFaction("foe");

		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = string.format("[%s %d]", Interface.getString("combat_tag_round"), nCurrent);
		Comm.deliverChatMessage(msg);
	end
	for _ = nStartCounter, nRounds do
		for i = 1,#aEntries do
			CombatManagerHeroes.onTurnStartEvent(aEntries[i]);
			CombatManagerHeroes.onTurnEndEvent(aEntries[i]);
		end

		CombatManagerHeroes.onInitChangeEvent();

		-- Announce round
		nCurrent = nCurrent + 1;
		local msg = {font = "narratorfont", icon = "turn_flag"};
		msg.text = string.format("[%s %d]", Interface.getString("combat_tag_round"), nCurrent);
		Comm.deliverChatMessage(msg);
	end

	-- Update round counter
	DB.setValue(CombatManagerHeroes.CT_ROUND, "number", nCurrent);

	-- Custom round start callback (such as per round initiative rolling)
	CombatManagerHeroes.onRoundStartEvent(nCurrent);

	-- Check option to see if we should advance to first actor or stop on round start
	if OptionsManager.isOption("RNDS", "off") then
		local bSkipBell = (nRounds > 1);
		if #aEntries > 0 then
			CombatManagerHeroes.nextActor(bSkipBell, true);
		end
	end
end
function nextTurn()
	if Session.IsHost then
		CombatManagerHeroes.nextActor();
	else
		CombatManagerHeroes.notifyEndTurn();
	end
end

function onEntryActivationChanged(nodeEntry)
	if not nodeEntry then
		return;
	end
	local bActive = (DB.getValue(nodeEntry, "active", 0) == 1);
	if bActive then
		local sOptCMAT = OptionsManager.getOption("CMAT");
		if sOptCMAT == "on" then
			CombatManagerHeroes.centerOnToken(nodeEntry, false);
		elseif sOptCMAT == "select" then
			CombatManagerHeroes.selectToken(nodeEntry);
		end
	end
end

--
-- ADD FUNCTIONS
--

function stripCreatureNumber(s)
	if not s then
		return s;
	end
	local nStarts, _, sNumber = string.find(s, " ?(%d+)$");
	if nStarts then
		return string.sub(s, 1, nStarts - 1), sNumber;
	end
	return s;
end
function randomName(sBaseName)
	return CombatManagerHeroes.getRandomName("", sBaseName);
end
function getRandomName(sKey, sBaseName)
	local aNames = {};
	local nCombatantCount = 0;
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
		local sName = DB.getValue(v, "name", "");
		if sName ~= "" then
			table.insert(aNames, DB.getValue(v, "name", ""));
		end
		nCombatantCount = nCombatantCount + 1;
	end

	local nRandomRange = nCombatantCount * 2;
	local sNewName = sBaseName;
	local nSuffix;
	local bContinue = true;
	while bContinue do
		bContinue = false;
		nSuffix = math.random(nRandomRange);
		sNewName = sBaseName .. " " .. nSuffix;
		if StringManager.contains(aNames, sNewName) then
			bContinue = true;
		end
	end

	return sNewName, nSuffix;
end

--
-- RESET FUNCTIONS
--
function resetOrder()
	-- De-activate all entries
	for _,v in pairs(CombatManagerDS.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end

	-- Clear GM identity additions (based on option)
	ChatIdentityManager.clearCombatantIdentity();

	-- Reset the round counter
	DB.setValue(CombatManagerDS.CT_LIST, "number", 0);

	CombatManagerDS.onCombatResetEvent();
end
function resetInit()
	-- De-activate all entries
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0);
	end

	-- Clear GM identity additions (based on option)
	ChatIdentityManager.clearCombatantIdentity();

	-- Reset the round counter
	DB.setValue(CombatManagerHeroes.CT_ROUND, "number", 1);

	CombatManagerHeroes.onCombatResetEvent();
end
function resetCombatantEffects(sKey)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
		DB.deleteChildren(v, "effects");
	end
end

--
-- GENERAL ITERATION FUNCTIONS
--

function callForEachCombatant(fn, ...)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes()) do
		fn(v, ...);
	end
end
function callForEachCombatantEffect(fn, ...)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes()) do
		EffectManager.startDelayedUpdates();
		for _,nodeEffect in pairs(DB.getChildList(v, "effects")) do
			fn(nodeEffect, ...);
		end
		EffectManager.endDelayedUpdates();
	end
end

--
-- COMMON RULESET SPECIFIC FUNCTIONS
--

function rollTypeInit(sType, fRollCombatantEntryInit, ...)
	local tCombatantNodesToRoll = {};

	-- Calculate which combatants to roll initiative for
	for _,nodeCT in pairs(CombatManagerHeroes.getCombatantNodes()) do
		local bRoll = true;
		if sType then
			local rActor = ActorManager.resolveActor(nodeCT);
			if sType == "pc" then
				if not ActorManager.isPC(rActor) then
					bRoll = false;
				end
			elseif not ActorManager.isRecordType(rActor, sType) then
				bRoll = false;
			end
		end
		if bRoll then
			table.insert(tCombatantNodesToRoll, nodeCT);
		end
	end

	-- Reset all entries to default "empty" value for initiative
	-- Must reset all before rolling to support initiative grouping
	for _,nodeCT in ipairs(tCombatantNodesToRoll) do
		DB.setValue(nodeCT, "initresult", "number", -10000);
	end
	-- Then, roll all initiatives
	for _,nodeCT in ipairs(tCombatantNodesToRoll) do
		fRollCombatantEntryInit(nodeCT, ...);
	end
end
function rollStandardEntryInit(tInit)
	if not tInit or not tInit.nodeEntry then
		return;
	end

	-- For PCs, we always roll unique initiative
	if CombatManagerHeroes.isPlayerCT(tInit.nodeEntry) then
		CombatManagerHeroes.helperRollEntryInit(tInit);
		return;
	end

	-- For NPCs, if NPC init option is not group, then roll unique initiative
	local sOptINIT = OptionsManager.getOption("INIT");
	if sOptINIT ~= "group" then
		CombatManagerHeroes.helperRollEntryInit(tInit);
		return;
	end

	-- For NPCs with group option enabled

	-- Get the entry's database node name and creature name
	local sStripName = CombatManagerHeroes.stripCreatureNumber(DB.getValue(tInit.nodeEntry, "name", ""));
	if sStripName == "" then
		CombatManagerHeroes.helperRollEntryInit(tInit);
		return;
	end

	-- Iterate through list looking for other creatures with same name
	tInit.nInitMatch = nil;
	local sEntryFaction = DB.getValue(tInit.nodeEntry, "friendfoe", "");
	for _,nodeCT in pairs(CombatManagerHeroes.getCombatantNodes()) do
		if DB.getName(nodeCT) ~= DB.getName(tInit.nodeEntry) then
			if DB.getValue(nodeCT, "friendfoe", "") == sEntryFaction then
				local sTemp = CombatManagerHeroes.stripCreatureNumber(DB.getValue(nodeCT, "name", ""));
				if sTemp == sStripName then
					local nChildInit = DB.getValue(nodeCT, "initresult", 0);
					if nChildInit ~= -10000 then
						tInit.nInitMatch = nChildInit;
					end
				end
			end
		end
	end

	-- If we found similar creatures, then match the initiative of the last one found; otherwise, roll
	CombatManagerHeroes.helperRollEntryInit(tInit);
end
function helperRollEntryInit(tInit)
	if not tInit or not tInit.nodeEntry then
		return;
	end
	if tInit.nInitMatch then
		DB.setValue(tInit.nodeEntry, "initresult", "number", tInit.nInitMatch);
		return;
	end

	tInit.nTotal = CombatManagerHeroes.helperRollRandomInit(tInit);
	DB.setValue(tInit.nodeEntry, "initresult", "number", tInit.nTotal);

	local rMessage = {
		font = "systemfont",
		icon = "portrait_gm_token",
		type = "init",
		text = string.format("[%s] %s", Interface.getString("action_init_tag"), DB.getValue(tInit.nodeEntry, "name", "")),
		diemodifier = tInit.nTotal,
		diceskipexpr = true,
		secret = true,
	};
	if (tInit.sSuffix or "") ~= "" then
		rMessage.text = string.format("%s %s", rMessage.text, tInit.sSuffix);
	end
	Comm.addChatMessage(rMessage);
end
function helperRollRandomInit(tInit)
	if not tInit then
		return math.random(20);
	end
	if tInit.fnRollRandom then
		return tInit.fnRollRandom(tInit);
	end
	return math.random(tInit.nDie or 20) + (tInit.nMod or 0);
end

function resetStandardInit()
	CombatManagerHeroes.callForEachCombatant(CombatManagerHeroes.resetCombatantInit);
end
function resetCombatantInit(nodeCT)
	DB.setValue(nodeCT, "initresult", "number", 0);
end

--
-- COMBAT TRACKER SUPPORT
--

function resolveNode(v)
	if type(v) == "string" then
		return DB.findNode(v);
	elseif type(v) == "databasenode" then
		return v;
	end
	return nil;
end
function resolvePath(v)
	if type(v) == "string" then
		return v;
	elseif type(v) == "databasenode" then
		return DB.getPath(v);
	end
	return nil;
end

local _tPlayerRecordTypes = { "charsheet" };
function addPlayerRecordType(sRecordType)
	for _,s in ipairs(_tPlayerRecordTypes) do
		if s == sRecordType then
			return;
		end
	end
	table.insert(_tPlayerRecordTypes, sRecordType);
end
function removePlayerRecordType(sRecordType)
	for k,s in ipairs(_tPlayerRecordTypes) do
		if s == sRecordType then
			table.remove(_tPlayerRecordTypes, k);
			return;
		end
	end
end
function initPlayerRecordTypes()
	if not Session.IsHost then
		return;
	end
	for _,s in ipairs(_tPlayerRecordTypes) do
		local sRootMapping = RecordDataManager.getDataPathRoot(s);
		if sRootMapping then
			DB.addHandler(DB.getPath(sRootMapping, "*"), "onDelete", CombatManagerHeroes.onPlayerRecordDelete);
		end
	end
end
function onPlayerRecordDelete(v)
	local nodeCT = CombatManagerHeroes.getCTFromNode(v);
	if nodeCT then
		DB.setValue(nodeCT, "link", "windowreference", "", "");
	end
end

function isPlayerCT(v)
	local sRecordType = CombatManagerHeroes.getRecordType(CombatManagerHeroes.resolveNode(v));
	return StringManager.contains(_tPlayerRecordTypes, sRecordType);
end
function isOwnedPlayerCT(v)
	local nodeCT = CombatManagerHeroes.resolveNode(v);
	if CombatManagerHeroes.isPlayerCT(nodeCT) then
		local _,sRecord = DB.getValue(nodeCT, "link", "", "");
		if DB.isOwner(sRecord) then
			return true;
		end
	end
	return false;
end

function getRecordType(nodeCT)
	if not nodeCT then
		return "";
	end
	return RecordDataManager.getRecordTypeFromDisplayClass(DB.getValue(nodeCT, "link", ""));
end
function isRecordType(nodeCT, s)
	return (CombatManagerHeroes.getRecordType(nodeCT) == s);
end
function isActive(nodeCT)
	if not nodeCT then
		return false;
	end
	return (DB.getValue(nodeCT, "active", 0) == 1);
end

function handleCTTokenPressed(nodeCT)
	if not nodeCT then
		return false;
	end

	if Session.IsHost then
		-- CTRL + left click to target CT entry with active CT entry
		if Input.isControlPressed() then
			local nodeActive = CombatManagerHeroes.getActiveCT(CombatManagerHeroes.getTrackerKeyFromCT(nodeCT));
			TargetingManager.notifyToggleTarget(nodeActive, nodeCT);
		-- All other left clicks will toggle activation outline for linked token (if any)
		else
			local tokenMap = CombatManagerHeroes.getTokenFromCT(nodeCT);
			if tokenMap then
				tokenMap.setActive(not tokenMap.isActive());
			end
		end
	else
		-- CTRL + left click to target CT entry with active CT (if owned) or active identity
		if Input.isControlPressed() then
			TargetingManager.toggleClientCTTarget(nodeCT);
		end
	end

	return true;
end
function handleCTTokenDoubleClick(nodeCT)
	if not nodeCT then
		return false;
	end

	CombatManagerHeroes.openMap(nodeCT);
	return true;
end
function handleCTTokenWheel(nodeCT, notches)
	if not nodeCT then
		return false;
	end

	TokenManager.onWheelCT(nodeCT, notches);
	return true;
end
function handleCTTokenDragStart(nodeCT, draginfo)
	if not nodeCT or not draginfo then
		return false;
	end
	local sToken = DB.getValue(nodeCT, "token", "");
	if sToken == "" then
		sToken = DB.getValue(nodeCT, "token3Dflat", "");
	end
	if sToken == "" then
		return false;
	end

	local nSpace = DB.getValue(nodeCT, "space");
	TokenManager.setDragTokenUnits(nSpace);

	draginfo.setType("token");
	draginfo.setTokenData(sToken);
	local sClass, sRecord = DB.getValue(nodeCT, "link", "", "");
	if sRecord == "" then
		sRecord = DB.getPath(nodeCT);
	end
	draginfo.setShortcutData(sClass, sRecord);
	return true;
end
function handleCTTokenDragEnd(nodeCT, draginfo)
	if not nodeCT or not draginfo then
		return false;
	end

	TokenManager.endDragTokenWithUnits();

	local _,tokenMap = draginfo.getTokenData();
	if tokenMap then
		CombatManagerHeroes.replaceCombatantToken(nodeCT, tokenMap);
	end
	return true;
end
function handleCTTokenDrop(nodeCT, draginfo)
	if not nodeCT then
		return false;
	end

	local sToken, tokenMap = draginfo.getTokenData();
	if (sToken or "") == "" then
		return;
	end

	DB.setValue(nodeCT, "token", "token", sToken);
	CombatManagerHeroes.replaceCombatantToken(nodeCT, tokenMap);
	return true;
end

function handleCTInitDragStart(nodeCT, draginfo)
	if not nodeCT or not draginfo then
		return false;
	end

	if not Session.IsHost then
		if not CombatManagerHeroes.isOwnedPlayerCT(nodeCT) then
			return false;
		end
		local fn = CombatManagerHeroes.getCustomInitSwapPlayerAllow();
		if not fn then
			return false;
		end
		if not fn(nodeCT) then
			return false;
		end
	end

	draginfo.setType("initiative_swap");
	draginfo.setIcon("drag_targeting");
	draginfo.setShortcutData("ct_entry", DB.getPath(nodeCT));
	return true;
end

function addTokenFromCT(vImage, nodeCT, x, y)
	if not vImage or not nodeCT then
		return nil;
	end

	local sToken = DB.getValue(nodeCT, "token", "");
	local sToken3DFlat = DB.getValue(nodeCT, "token3Dflat", "");
	if (sToken == "") and (sToken3DFlat == "") then
		return nil;
	end

	local tAdd = { asset = sToken, asset3Dflat = sToken3DFlat, x = x, y = y };
	TokenManager.setDragTokenUnits(DB.getValue(nodeCT, "space"));
	local tokenMap = Token.addToken(vImage, tAdd);
	TokenManager.endDragTokenWithUnits();

	return tokenMap;
end
function handleFactionDropOnImage(draginfo, imagecontrol, x, y)
	if not Session.IsHost then
		return;
	end

	-- Get faction records, and fill unassigned slots
	local sFaction = draginfo.getStringData();
	local tFactionData = CombatFormationManager.getFactionFormationRecords(sFaction);
	CombatFormationManager.fillFactionFormationSlots(sFaction, tFactionData, "column3");

	-- Place on map at calculated positions
	local nodeImage = imagecontrol.getDatabaseNode();
	local nCenterX, nCenterY = imagecontrol.snapToGrid(x, y);
	local nGridSize = imagecontrol.getGridSize();
	for _,v in ipairs(tFactionData) do
		local tAddPos = v.tSlotPos or { x = 0, y = 0 };
		local tokenMap = CombatManagerHeroes.addTokenFromCT(nodeImage, v.nodeCT, nCenterX + (nGridSize * tAddPos.x), nCenterY + (nGridSize * -tAddPos.y));
		if tokenMap then
			CombatManagerHeroes.replaceCombatantToken(v.nodeCT, tokenMap);
		end
	end

	return true;
end
function replaceCombatantToken(nodeCT, newTokenInstance)
	local oldTokenInstance = CombatManagerHeroes.getTokenFromCT(nodeCT);
	if oldTokenInstance then
		if oldTokenInstance ~= newTokenInstance then
			if not newTokenInstance then
				local nodeContainerOld = oldTokenInstance.getContainerNode();
				if nodeContainerOld then
					local x,y = oldTokenInstance.getPosition();
					local nFacing = oldTokenInstance.getOrientation();
					newTokenInstance = CombatManagerHeroes.addTokenFromCT(nodeContainerOld, nodeCT, x, y);
					newTokenInstance.setOrientation(nFacing);
				end
			end
			oldTokenInstance.delete();
		end
	elseif newTokenInstance then
		local nodeContainer = newTokenInstance.getContainerNode()
		local x,y = newTokenInstance.getPosition();
		local nFacing = newTokenInstance.getOrientation();
		local finalTokenInstance = CombatManagerHeroes.addTokenFromCT(nodeContainer, nodeCT, x, y);
		finalTokenInstance.setOrientation(nFacing);
		newTokenInstance.delete();
		newTokenInstance = finalTokenInstance;
	end

	TokenManager.linkToken(nodeCT, newTokenInstance);
	TokenManager.updateVisibility(nodeCT);
	TargetingManager.updateTargetsFromCT(nodeCT, newTokenInstance);
end
function onTokenDelete(tokenMap)
	local nodeCT = CombatManagerHeroes.getCTFromToken(tokenMap);
	if nodeCT then
		DB.setValue(nodeCT, "tokenrefnode", "string", "");
		DB.setValue(nodeCT, "tokenrefid", "string", "");
	end
end

function deleteFaction(sFaction)
	CombatManagerHeroes.deleteFactionFromTracker("", sFaction)
end
function deleteFactionFromTracker(sKey, sFaction)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
		if DB.getValue(v, "friendfoe", "") == sFaction then
			CombatManagerHeroes.deleteCombatant(v);
		end
	end
end
function deleteNonFaction(sFaction)
	CombatManagerHeroes.deleteNonFactionFromTracker("", sFaction);
end
function deleteNonFactionFromTracker(sKey, sFaction)
	for _,v in pairs(CombatManagerHeroes.getCombatantNodes(sKey)) do
		if DB.getValue(v, "friendfoe", "") ~= sFaction then
			CombatManagerHeroes.deleteCombatant(v);
		end
	end
end

function deleteCombatant(v)
	CombatManagerHeroes.onPreDeleteCombatantEvent(v);

	local fCleanup = CombatManagerHeroes.getTrackerCleanup(CombatManagerHeroes.getTrackerKeyFromCT(v));
	if fCleanup then
		fCleanup(v);
	end

	DB.deleteNode(v);
end
function deleteCleanup(v)
	-- Clear any effects first, so that saves aren't triggered when initiative advanced
	DB.deleteChildren(v, "effects");

	-- Clear NPC wounds, so that ruleset turn end dying checks aren't triggered when initiative advanced
	if not CombatManagerHeroes.isPlayerCT(v) and DB.getChild(v, "wounds") then
		DB.setValue(v, "wounds", "number", 0);
	end

	-- Move to the next actor, if this CT entry is active
	if CombatManagerHeroes.isActive(v) then
		CombatManagerHeroes.nextActor();
	end
end

-- DEPRECATED - 2025-03 (Short Release)

function addGMIdentity(nodeCT)
	ChatIdentityManager.addCombatantIdentity(nodeCT);
end
function clearGMIdentity()
	ChatIdentityManager.clearCombatantIdentity();
end
