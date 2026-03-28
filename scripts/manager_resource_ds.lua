function onValueChanged()
    local nodeWin = window.getDatabaseNode();
    local nCurrent = DB.getValue(nodeWin, "classresource");
    return;
end

function resourceRoll(rMessage, rRoll)
	local classResource = rRoll.nCurrent;
	local result = ActionsManager.total(rRoll);
	local sCharSheetID = rRoll.sCharSheetID;
	local newTotal = (classResource + result);
	local nodey = DB.findNode( sCharSheetID )
	
	WindowManager.callSafeControlUpdate(self, "classresource", bReadOnly);
	DB.setValue(nodey, "classresource", "number", newTotal);

	return rMessage;
end

function action(draginfo)
    local nodeWin = window.getDatabaseNode();
	local sCharSheetID = DB.getPath(nodeWin);
	local charSheetID = DB.findNode(sCharSheetID);
	local className = DB.getValue(nodeWin, "classtitle");
	local characterName = DB.getValue(nodeWin, "name");
	local classresource_current = DB.getValue(nodeWin, "classresource");
	local classresource_currentpath = DB.getChild(nodeWin, "classresource");
	local classresource_name = DB.getValue(nodeWin, "classresource_label");

	if (className == "Censor") or (className == "Elementalist" ) or (className == "Null") or (className == "Tactician") then
		newTotal = (classresource_current + 2);
		DB.setValue(nodeWin, "classresource", "number", newTotal);
		ChatManager.SystemMessageResource("char_emptylist_resource", tostring(characterName), tostring(classresource_name));
    	local rRoll = ActionsManager.performAction(draginfo, rActor, rRoll);
		return true;
	end

	-- for other classes, roll a d3
	local node = window.getDatabaseNode();
    local rRoll = {
        sType = "dice",
        sDesc = "Heroic Resource:",
        aDice = { "d3" },
		nMod = 0,
		nCurrent = classresource_current,
		nResource = classresource_currentpath,
		sCharSheetID = sCharSheetID,
		sResourceName = classresource_name
    };
    local rRoll = ActionsManager.performAction(draginfo, rActor, rRoll);
	
    return true;
end

function onDragStart(button, x, y, draginfo)
    return action(draginfo);
end

function onButtonPress()
    return action();
end