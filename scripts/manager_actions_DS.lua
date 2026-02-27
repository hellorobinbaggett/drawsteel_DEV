-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ImageManager.addStandardDropHandlers();
	Interface.addKeyedEventHandler("onWindowOpened", "imagewindow", ImageManager.onWindowOpened);
end


-- Drop handling

function addStandardDropHandlers()
	ActionsManager_DS.registerDropCallback("token", ActionsManager_DS.onImageTokenDrop);
end

local _tDropCallbacks = {};
function registerDropCallback(sDropType, fn)
	UtilityManager.registerKeyCallback(_tDropCallbacks, sDropType, fn);
end

function onImageCTFactionDrop(cImage, x, y, draginfo)
	return CombatManagerDS.handleFactionDropOnImage(draginfo, cImage, x, y);
end

function onImageShortcutDrop(cImage, x, y, draginfo)
	if (draginfo.getTokenData() or "") ~= "" then
		return ActionsManager_DS.onImageTokenDrop(cImage, x, y, draginfo);
	end
end

function onImageTokenDrop(cImage, x, y, draginfo)
	local sClass,sRecord = draginfo.getShortcutData();
	if ((sClass or "") == "") or ((sRecord or "") == "") then
		return;
	end
	x, y = cImage.snapToGrid(x, y);

	local sRecordType = ActorManager.getRecordType(sRecord);
	if not CombatRecordManager.hasRecordTypeCallback(sRecordType) then
		return;
	end

	local nodeCT = CombatManagerDS.getCTFromNode(sRecord);
	if nodeCT then
		local tokenMap = CombatManagerDS.addTokenFromCT(cImage.getDatabaseNode(), nodeCT, x, y);
		CombatManagerDS.replaceCombatantToken(nodeCT, tokenMap);
	else
		local tCustom = {
			sClass = sClass,
			sRecord = sRecord,
			sToken = draginfo.getTokenData(),
			tPlacement = {
				imagelink = DB.getPath(cImage.getDatabaseNode()),
				imagex = x,
				imagey = y,
			},
			draginfo = draginfo,
		};
		CombatRecordManager.onRecordTypeEvent(sRecordType, tCustom);
	end

	return true;
end




function encodeDesktopMods(rRoll)
	local nMod = 0;
	
	if ModifierManager.getKey("EDGE") then
		nMod = 2;
        rRoll.sDesc = rRoll.sDesc .. " [Edge]";
	end
	if ModifierManager.getKey("BANE") then
		nMod = -2;
        rRoll.sDesc = rRoll.sDesc .. " [Bane]";
	end
	if ModifierManager.getKey("DOUBLEEDGE") then
        rRoll.sDesc = rRoll.sDesc .. " [Double Edge]";
	end
	if ModifierManager.getKey("DOUBLEBANE") then
        rRoll.sDesc = rRoll.sDesc .. " [Double Bane]";
	end
	if ModifierManager.getKey("SKILL") then
		nMod = nMod + 2;
        rRoll.sDesc = rRoll.sDesc .. " [Skill]";
	end
	
	if nMod == 0 then
		return;
	end
	
	rRoll.nMod = rRoll.nMod + nMod;
	rRoll.sDesc = rRoll.sDesc .. string.format(" [%+d]", nMod);
end

function createActionMessage(rSource, rRoll)
	-- Build the basic message to deliver
	-- Debug.chat(rRoll.sUser);
	-- Debug.chat(rSource);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
	rMessage.type = rRoll.sType;
	rMessage.text = rRoll.sDesc;
	rMessage.dice = rRoll.aDice;
	rMessage.diemodifier = rRoll.nMod;
	rMessage.diceskipexpr = rRoll.diceskipexpr;

	-- For power rolls
	rMessage = PowerRollManager.powerRoll(rMessage, rRoll);

	-- For initiative rolls
	if string.match(rMessage.text, "Initiative Roll:") then
		rMessage = InitiativeManager.initiativeRoll(rMessage, rRoll);
	end

	-- For saving throws
	if string.match(rMessage.text, "Saving Throw:") then
		rMessage = RollManager_DS.saveRoll(rMessage, rRoll);
	end

	-- For resource rolls
	if string.match(rMessage.text, "Heroic Resource:") then	
		rMessage = ResourceManager.resourceRoll(rMessage, rRoll);
	end
	
	-- Check to see if this roll should be secret (GM or dice tower tag)
	if rRoll.bSecret then
		rMessage.secret = true;
		if rRoll.bTower then
			rMessage.icon = "dicetower_icon";
		end
	elseif Session.IsHost and OptionsManager.isOption("REVL", "off") then
		rMessage.secret = true;
	end
	
	return rMessage;
end

function applyModifiers(rSource, rTarget, rRoll, bSkipModStack)
	if rRoll.aDice.expr == "2d10" then
		ActionsManager_DS.encodeDesktopMods(rRoll);
	end
	
	local bAddModStack = ActionsManager.doesRollHaveDice(rRoll);
	if bSkipModStack then
		bAddModStack = false;
	elseif GameSystem.actions[rRoll.sType] then
		bAddModStack = GameSystem.actions[rRoll.sType].bUseModStack;
	end

	local fMod = aModHandlers[rRoll.sType];
	if fMod then
		local bReturn = fMod(rSource, rTarget, rRoll);
		if bReturn ~= true then
			rRoll.aDice.expr = nil;
		end
	end

	if bAddModStack then
		local bDescNotEmpty = (rRoll.sDesc ~= "");
		local sStackDesc, nStackMod = ModifierStack.getStack(bDescNotEmpty);
		
		if sStackDesc ~= "" then
			if bDescNotEmpty then
				rRoll.sDesc = rRoll.sDesc .. " [" .. sStackDesc .. "]";
			else
				rRoll.sDesc = sStackDesc;
			end
		end
		rRoll.nMod = rRoll.nMod + nStackMod;
	end
	
	return bAddModStack;
end

function performAction(draginfo, rActor, rRoll)

	if not rRoll then
		return;
	end

	if Session.IsHost and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end

	ActionsManager_DS.performMultiAction(draginfo, rActor, rRoll.sType, { rRoll });
end

function performMultiAction(draginfo, rActor, sType, rRolls)
	if not rRolls or #rRolls < 1 then
		return false;
	end

	if draginfo then
		ActionsManager.encodeActionForDrag(draginfo, rActor, sType, rRolls);
	else
		ActionsManager.actionDirect(rActor, sType, rRolls);
	end
	return true;
end