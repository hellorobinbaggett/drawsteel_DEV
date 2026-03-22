-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_ROUND_NOTIFY = "notify_round";
OOB_MSGTYPE_TURN_NOTIFY = "notify_turn";

OOB_MSGTYPE_ATTACK_NOTIFY = "notify_attack";
OOB_MSGTYPE_DAMAGE_NOTIFY = "notify_damage";
OOB_MSGTYPE_SAVE_NOTIFY = "notify_save";

function onInit()
	CombatManager.setCustomRoundStart(OverlayCombatManager.notifyRoundStart);
	CombatManager.setCustomTurnStart(OverlayCombatManager.notifyTurnStart);

	GameManager.addEventFunction("onActionPostTargeting", OverlayCombatManager.handleTargeting);
	GameManager.addEventFunction("onAttackPostResolve", OverlayCombatManager.notifyAttack);
	GameManager.addEventFunction("onDamagePostResolve", OverlayCombatManager.notifyDamage);
	GameManager.addEventFunction("onSavePostResolve", OverlayCombatManager.notifySave);

	OOBManager.registerOOBMsgHandler(OverlayCombatManager.OOB_MSGTYPE_ROUND_NOTIFY, OverlayCombatManager.handleRoundNotify);
	OOBManager.registerOOBMsgHandler(OverlayCombatManager.OOB_MSGTYPE_ATTACK_NOTIFY, OverlayCombatManager.handleAttackNotify);
	OOBManager.registerOOBMsgHandler(OverlayCombatManager.OOB_MSGTYPE_DAMAGE_NOTIFY, OverlayCombatManager.handleDamageNotify);
	OOBManager.registerOOBMsgHandler(OverlayCombatManager.OOB_MSGTYPE_SAVE_NOTIFY, OverlayCombatManager.handleSaveNotify);
end

function notifyRoundStart(n)
	local msgOOB = {
		type = OverlayCombatManager.OOB_MSGTYPE_ROUND_NOTIFY,
		nRound = n,
	};
	Comm.deliverOOBMessage(msgOOB);
end
function handleRoundNotify(msgOOB)
	local tOverlayData = {
		sOption = "TOAST_TURN",
		sText = string.format(Interface.getString("combat_toast_text_round"), msgOOB.nRound or 0);
	};
	OverlayManager.showFullScreenMessage(tOverlayData);
end
function notifyTurnStart(nodeActor, bNewRound)
	if bNewRound then
		return;
	end

	local msgOOB = {
		type = OverlayCombatManager.OOB_MSGTYPE_TURN_NOTIFY,
		sActorNode = DB.getPath(nodeActor),
	};
	Comm.deliverOOBMessage(msgOOB);
end
function handleTurnNotify(msgOOB)
	local rActor = ActorManager.resolveActor(msgOOB.sActorNode);
	if not Session.IsHost and not ActorManager.isVisible(rActor) then
		return;
	end

	local tOverlayData = {
		sOption = "TOAST_TURN",
		sToastType = "info",
		sTitle = Interface.getString("combat_toast_title_turn"),
		sText = string.format(Interface.getString("combat_toast_text_turn"), ActorManager.getDisplayName(rActor)),
	};
	OverlayManager.showToastMessage(tOverlayData);
end

function notifyAttack(rSource, rTarget, rRoll)
	if not rTarget or not rRoll or ((rRoll.sResult or "") == "") then
		return;
	end

	local msgOOB = {
		type = OverlayCombatManager.OOB_MSGTYPE_ATTACK_NOTIFY,
		sSourceNode = ActorManager.getCreatureNodeName(rSource),
		sTargetNode = ActorManager.getCreatureNodeName(rTarget),
		sResult = rRoll.sResult,
	};
	Comm.deliverOOBMessage(msgOOB);
end
function handleAttackNotify(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);

	if not OverlayActionManager.batchNotify(rSource, rTarget, "attack", msgOOB) then
		OverlayCombatManager.performAttackNotify(rSource, rTarget, msgOOB);
	end
end
function performAttackNotifyBatch(rSource, tActions)
	OverlayCombatManager.handleAttackNotifyBatchToken(rSource, tActions);
	OverlayCombatManager.handleAttackNotifyBatchToast(rSource, tActions);
end
function performAttackNotify(rSource, rTarget, tData)
	OverlayCombatManager.handleAttackNotifyToken(rSource, rTarget, tData);
	OverlayCombatManager.handleAttackNotifyToast(rSource, rTarget, tData);
end
function handleAttackNotifyBatchToken(rSource, tActions)
	OverlayCombatManager.helperAttackNotifyToken(rSource, tActions);
end
function handleAttackNotifyToken(rSource, rTarget, tData)
	OverlayCombatManager.helperAttackNotifyToken(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperAttackNotifyToken(rSource, tActions)
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			OverlayManager.showTokenIconTraverse(rSource, tAction.rTarget, { sIcon = "attack-token-traverse", });
			OverlayManager.showTokenIconTraverseResult(tAction.rTarget, { sIcon = "action_attack_" .. (tAction.tData.sResult or ""), sText = Interface.getString("combat_result_attack_" .. (tAction.tData.sResult or "")), });
		end
	end
end
function handleAttackNotifyBatchToast(rSource, tActions)
	OverlayCombatManager.helperAttackNotifyToast(rSource, tActions);
end
function handleAttackNotifyToast(rSource, rTarget, tData)
	OverlayCombatManager.helperAttackNotifyToast(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperAttackNotifyToast(rSource, tActions)
	local tToastText = {};

	local sAttack = rSource and string.format(Interface.getString("combat_toast_text_attack"), ActorManager.getDisplayName(rSource));
	if (sAttack or "") ~= "" then
		table.insert(tToastText, sAttack);
	end

	local sToastType = nil;
	local sToastIcon = nil;
	local tResults = {};
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and tAction.rTarget and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			local tResult = tResults[tAction.tData.sResult or ""] or {};
			table.insert(tResult, ActorManager.getDisplayName(tAction.rTarget));
			tResults[tAction.tData.sResult or ""] = tResult;

			local sResultToastType = (((tAction.tData.sToastType or "") ~= "") and tAction.tData.sToastType) or (StringManager.contains({ "hit", "crit", }, tAction.tData.sResult) and "success" or "failure");
			if (sToastType or "") == "" then
				sToastType = sResultToastType;
			elseif sToastType ~= sResultToastType then
				sToastType = "info";
			end
			local sResultToastIcon = (((tAction.tData.sToastIcon or "") ~= "") and tAction.tData.sToastIcon) or ("action_attack_" .. (tAction.tData.sResult or ""));
			if (sToastIcon or "") == "" then
				sToastIcon = sResultToastIcon;
			elseif sToastIcon ~= sResultToastIcon then
				sToastIcon = "action_attack";
			end
		end
	end

	local tResultOrder = OverlayCombatManager.getAttackResultOrder();
	for _, sResult in ipairs(tResultOrder) do
		if tResults[sResult] then
			local sResultText = string.format("<font name=\"toast-bold\">%s:</font> %s", Interface.getString("combat_result_attack_" .. sResult), table.concat(tResults[sResult], ", "));
			table.insert(tToastText, sResultText);
		end
	end
	for sResult, tResult in pairs(tResults) do
		if not StringManager.contains(tResultOrder, sResult) then
			local sResultText = string.format("<font name=\"toast-bold\">%s:</font> %s", Interface.getString("combat_result_attack_" .. sResult), table.concat(tResults[sResult], ", "));
			table.insert(tToastText, sResultText);
		end
	end

	local tOverlayData = {
		sOption = "TOAST_COMBAT",
		sToastType = sToastType or "info",
		sIcon = sToastIcon or "action_attack",
		sTitle = Interface.getString("combat_toast_title_attack"),
		sText = table.concat(tToastText, "\r"),
	};
	OverlayManager.showToastMessage(tOverlayData);
end

local _tAttackResultOrder = { "crit", "raise", "hit", "miss", "fumble", "critfail", "block", "dodge", };
function getAttackResultOrder()
	return _tAttackResultOrder;
end
function setAttackResultOrder(t)
	_tAttackResultOrder = t or {};
end

function notifyDamage(rSource, rTarget, rRoll)
	if not rTarget or not rRoll then
		return;
	end

	local msgOOB = {
		type = OverlayCombatManager.OOB_MSGTYPE_DAMAGE_NOTIFY,
		sSourceNode = ActorManager.getCreatureNodeName(rSource),
		sTargetNode = ActorManager.getCreatureNodeName(rTarget),
		sType = rRoll.sType,
		nTotal = rRoll.nTotal,
		tResults = rRoll.tResults,
	};
	UtilityManager.simplifyEncode(msgOOB, "tResults");
	Comm.deliverOOBMessage(msgOOB);
end
function handleDamageNotify(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);

	UtilityManager.simplifyDecode(msgOOB, "tResults");
	OverlayCombatManager.handleDamageNotifySetup(rSource, rTarget, msgOOB);

	if not OverlayActionManager.batchNotify(rSource, rTarget, "damage", msgOOB) then
		OverlayCombatManager.performDamageNotify(rSource, rTarget, msgOOB);
	end
end
function handleDamageNotifySetup(_, _, tData)
	if not tData then
		return;
	end

	-- Remove special/property damage types for showing notifications
	local tRemap = {};
	for sKey, tResult in pairs(tData.tResults or {}) do
		local tKey = StringManager.split(sKey, ",", true);
		local tNewKey = {};
		for _,sSplit in ipairs(tKey) do
			if ActionCore.isBasicDamageType(sSplit) then
				table.insert(tNewKey, sSplit);
			end
		end
		if #tKey ~= #tNewKey then
			tRemap[sKey] = table.concat(tNewKey, ",");
		end
	end
	for sKey, sNewKey in pairs(tRemap) do
		if tData.tResults[sNewKey] then
			tData.tResults[sNewKey].nTotal = (tData.tResults[sNewKey].nTotal or 0) + (tData.tResults[sKey].nTotal or 0);
			tData.tResults[sNewKey].nBase = (tData.tResults[sNewKey].nBase or 0) + (tData.tResults[sKey].nBase or 0);
			tData.tResults[sNewKey].nResist = (tData.tResults[sNewKey].nResist or 0) + (tData.tResults[sKey].nResist or 0);
			tData.tResults[sNewKey].nVulnerable = (tData.tResults[sNewKey].nVulnerable or 0) + (tData.tResults[sKey].nVulnerable or 0);
		else
			tData.tResults[sNewKey] = tData.tResults[sKey];
		end
		tData.tResults[sKey] = nil;
	end

	-- Prepare icons/colors/position for each damage type
	local i = 0;
	for sKey, tResult in pairs(tData.tResults or {}) do
		tResult.nSlot = i;
		tResult.sIcon = ActionDamageCore.getDamageTypeIcon(sKey);
		tResult.sColor = ActionDamageCore.getDamageTypeColor(sKey);
		i = i + 1;
	end
end
function performDamageNotifyBatch(rSource, tActions)
	OverlayCombatManager.handleDamageNotifyBatchToken(rSource, tActions);
	OverlayCombatManager.handleDamageNotifyBatchToast(rSource, tActions);
end
function performDamageNotify(rSource, rTarget, tData)
	OverlayCombatManager.handleDamageNotifyToken(rSource, rTarget, tData);
	OverlayCombatManager.handleDamageNotifyToast(rSource, rTarget, tData);
end
function handleDamageNotifyBatchToken(rSource, tActions)
	OverlayCombatManager.helperDamageNotifyToken(rSource, tActions);
end
function handleDamageNotifyToken(rSource, rTarget, tData)
	OverlayCombatManager.helperDamageNotifyToken(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperDamageNotifyToken(rSource, tActions)
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			for sKey,tResult in pairs(tAction.tData.tResults or {}) do
				OverlayManager.showTokenIconDamage(tAction.rTarget, tResult);
			end
		end
	end
end
function handleDamageNotifyBatchToast(rSource, tActions)
	OverlayCombatManager.helperDamageNotifyToast(rSource, tActions);
end
function handleDamageNotifyToast(rSource, rTarget, tData)
	OverlayCombatManager.helperDamageNotifyToast(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperDamageNotifyToast(rSource, tActions)
	local tToastText = {};

	local sToastIcon = nil;
	local sToastIconColor = nil;
	local tDamageTotal = {};
	local tTargets = {};
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			if tAction.rTarget then
				table.insert(tTargets, ActorManager.getDisplayName(tAction.rTarget));
			end

			for sKey,tResult in pairs(tAction.tData.tResults or {}) do
				if (sToastIcon or "") == "" then
					sToastIcon = tResult.sIcon;
					sToastIconColor = tResult.sColor;
				elseif sToastIcon ~= tResult.sIcon then
					sToastIcon = ActionDamageCore.getDamageTypeIcon("");
					sToastIconColor = ActionDamageCore.getDamageTypeColor("");
				end

				tDamageTotal[sKey] = (tDamageTotal[sKey] or 0) + (tResult.nTotal or 0);
			end
		end
	end
	local tDamageTypeText = {};
	for sKey, nDamage in pairs(tDamageTotal) do
		if nDamage > 0 then
			local sTypeText = (sKey ~= "") and sKey or "untyped";
			table.insert(tDamageTypeText, string.format("<font color=%s>%d %s</font>", ActionDamageCore.getDamageTypeColor(sKey), nDamage, sTypeText));
		end
	end
	local sDamageTypes = table.concat(tDamageTypeText, ", ");

	if rSource then
		local sDamage = string.format(Interface.getString("combat_toast_text_damage"), ActorManager.getDisplayName(rSource), sDamageTypes);
		table.insert(tToastText, sDamage);
	else
		table.insert(tToastText, sDamageTypes);
	end

	if #tTargets > 0 then
		local sResultText = string.format("<font name=\"toast-bold\">%s:</font> %s", Interface.getString("combat_result_damage"), table.concat(tTargets, ", "));
		table.insert(tToastText, sResultText);
	end

	local tOverlayData = {
		sOption = "TOAST_COMBAT",
		sToastType = "failure",
		sIcon = sToastIcon or ActionDamageCore.getDamageTypeIcon(""),
		sIconColor = sToastIconColor or ActionDamageCore.getDamageTypeColor(""),
		sTitle = Interface.getString("combat_toast_title_damage"),
		sText = table.concat(tToastText, "\r"),
	};
	OverlayManager.showToastMessage(tOverlayData);
end

--	tData.sType = "save", "stabilization"
-- 	if sType == "save" then
--		tData.sSaveType = nil (standard), "death", "concentration", "systemshock"
-- 	if tData.sSaveType == nil or ""
-- 		tData.sResult = "success", "critsuccess", "failure", "critfailure", "half_success" (half damage on success), "none" (evaded/avoided), "half_failure" (evasion/avoidance failed roll)
--		(PF2) tData.sResult = "success", "failure", "none_failure", "none_success", "half_failure", "half_success", "double_failure", "double_success"
-- 	if tData.sSaveType == "death" or tData.sType = "stabilization"
-- 		tData.sResult = "success", "failure", "critsuccess", "critfailure"
-- 	if tData.sSaveType == "concentration" or tData.sType = "concentration"
-- 		tData.sResult = "success", "failure"
-- 	if tData.sSaveType == "systemshock"
-- 		tData.sResult = "success", "failure"
--
--	Possible Results
-- 			"success", "failure", 
-- 			"critsuccess" (13A/4E/5E/3.5E)
-- 			"critfailure" (5E/3.5E)
-- 			"none" (avoid damage - 2E/3.5E/5E)
-- 			"half_success" (half damage on success - 2E/3.5E/5E/PF2)
-- 			"half_failure" (half damage on failure - 2E/3.5E/5E/PF2)
-- 			"none_success" (PF2)
-- 			"none_failure" (PF2)
-- 			"double_success" (PF2)
-- 			"double_failure" (PF2)
--
--	SUCCESS = "success", "critsuccess", "half_success", "none_success", "double_success", "none",
--	FAILURE = "failure", "critfailure", "half_failure", "none_failure", "double_failure",
-- 
function notifySave(rActor, rOrigin, rRoll)
	if not rActor or not rRoll or ((rRoll.sResult or "") == "") then
		return;
	end

	local msgOOB = {
		type = OverlayCombatManager.OOB_MSGTYPE_SAVE_NOTIFY,
		sSourceNode = ActorManager.getCreatureNodeName(rOrigin),
		sTargetNode = ActorManager.getCreatureNodeName(rActor),
		sType = rRoll.sType,
		sSaveType = rRoll.sSaveType,
		sResult = rRoll.sResult,
	};
	Comm.deliverOOBMessage(msgOOB);
end
function handleSaveNotify(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);

	if not OverlayActionManager.batchNotify(rSource, rTarget, "save", msgOOB) then
		OverlayCombatManager.performSaveNotify(rSource, rTarget, msgOOB);
	end
end
function performSaveNotifyBatch(rSource, tActions)
	OverlayCombatManager.handleSaveNotifyBatchToken(rSource, tActions);
	OverlayCombatManager.handleSaveNotifyBatchToast(rSource, tActions);
end
function performSaveNotify(rSource, rTarget, tData)
	OverlayCombatManager.handleSaveNotifyToken(rSource, rTarget, tData);
	OverlayCombatManager.handleSaveNotifyToast(rSource, rTarget, tData);
end
function handleSaveNotifyBatchToken(rSource, tActions)
	OverlayCombatManager.helperSaveNotifyToken(rSource, tActions);
end
function handleSaveNotifyToken(rSource, rTarget, tData)
	OverlayCombatManager.helperSaveNotifyToken(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperSaveNotifyToken(rSource, tActions)
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			-- OverlayManager.showTokenIconTraverse(rSource, tAction.rTarget, { sIcon = "token-save", });
			if ((tAction.tData.sResult or "") == "critsuccess") then
				OverlayManager.showTokenIconQuick(tAction.rTarget, { sIcon = "action_save_success_crit", sText = Interface.getString("combat_result_save_success_crit"), });
			elseif ((tAction.tData.sResult or "") == "critfailure") then
				OverlayManager.showTokenIconQuick(tAction.rTarget, { sIcon = "action_save_failure_crit", sText = Interface.getString("combat_result_save_failure_crit"), });
			elseif (tAction.tData.sResult or ""):match("success") or ((tAction.tData.sResult or "") == "none") then
				OverlayManager.showTokenIconQuick(tAction.rTarget, { sIcon = "action_save_success", sText = Interface.getString("combat_result_save_success"), });
			else
				OverlayManager.showTokenIconQuick(tAction.rTarget, { sIcon = "action_save_failure", sText = Interface.getString("combat_result_save_failure"), });
			end
		end
	end
end
function handleSaveNotifyBatchToast(rSource, tActions)
	OverlayCombatManager.helperSaveNotifyToast(rSource, tActions);
end
function handleSaveNotifyToast(rSource, rTarget, tData)
	OverlayCombatManager.helperSaveNotifyToast(rSource, { { rTarget = rTarget, tData = tData, }, });
end
function helperSaveNotifyToast(rSource, tActions)
	local tToastText = {};

	local sToastType = nil;
	local sToastIcon = nil;
	local tResults = {};
	for _, tAction in ipairs(tActions or {}) do
		if tAction.tData and ActionsManager.getShowResult(rSource, tAction.rTarget) then
			local bSuccess = ((tAction.tData.sResult or ""):match("success") or ((tAction.tData.sResult or "") == "none"));
			local sKey = bSuccess and "success" or "failure";

			local tResult = tResults[sKey] or {};
			table.insert(tResult, ActorManager.getDisplayName(tAction.rTarget));
			tResults[sKey] = tResult;

			local sResultToastType = (((tAction.tData.sToastType or "") ~= "") and tAction.tData.sToastType) or sKey;
			if (sToastType or "") == "" then
				sToastType = sResultToastType;
			elseif sToastType ~= sResultToastType then
				sToastType = "info";
			end
			local sResultToastIcon = (((tAction.tData.sToastIcon or "") ~= "") and tAction.tData.sToastIcon) or ("action_save_" .. sKey);
			if (sToastIcon or "") == "" then
				sToastIcon = sResultToastIcon;
			elseif sToastIcon ~= sResultToastIcon then
				sToastIcon = "action_save";
			end
		end
	end

	local tResultOrder = OverlayCombatManager.getSaveResultOrder();
	for _, sResult in ipairs(tResultOrder) do
		if tResults[sResult] then
			local sResultText = string.format("<font name=\"toast-bold\">%s:</font> %s", Interface.getString("combat_result_save_" .. sResult), table.concat(tResults[sResult], ", "));
			table.insert(tToastText, sResultText);
		end
	end
	for sResult, tResult in pairs(tResults) do
		if not StringManager.contains(tResultOrder, sResult) then
			local sResultText = string.format("<font name=\"toast-bold\">%s:</font> %s", Interface.getString("combat_result_save_" .. sResult), table.concat(tResults[sResult], ", "));
			table.insert(tToastText, sResultText);
		end
	end

	local tOverlayData = {
		sOption = "TOAST_COMBAT",
		sToastType = sToastType or "info",
		sIcon = sToastIcon or "action_save",
		sTitle = Interface.getString("combat_toast_title_save"),
		sText = table.concat(tToastText, "\r"),
	};
	OverlayManager.showToastMessage(tOverlayData);
end

local _tSaveResultOrder = { "success", "failure", };
function getSaveResultOrder()
	return _tSaveResultOrder;
end
function setSaveResultOrder(t)
	_tSaveResultOrder = t or {};
end
