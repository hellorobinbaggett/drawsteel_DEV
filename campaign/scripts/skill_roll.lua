function action(draginfo)
    local nodeWin = window.getDatabaseNode();
    
    local skilled = DB.getValue(nodeWin, "skill.prof");
    local characteristic = DB.getValue(nodeWin, "skill.characteristic.button");

    -- If you have this skill, add a +2 to the roll
    if (skilled == 0) then
        skilledMod = "0";
    end
    if (skilled == 1) then
        skilledMod = "2";
    end

    -- add the characteristic that is chosed for the skill
    characteristicMod = 0;
    -- MGT
    if (characteristic == 1) then
        characteristicMod = DB.getValue(nodeWin, "MGT");
    end
    -- AGL
    if (characteristic == 2) then
        characteristicMod = DB.getValue(nodeWin, "AGL");
    end
    -- REA
    if (characteristic == 3) then
        characteristicMod = DB.getValue(nodeWin, "REA");
    end
    -- INU
    if (characteristic == 4) then
        characteristicMod = DB.getValue(nodeWin, "INU");
    end
    -- PRS
    if (characteristic == 5) then
        characteristicMod = DB.getValue(nodeWin, "PRS");
    end

    local abilityName = DB.getValue(nodeWin, "skill.alchemy", "");

    local rActor = ActorManager.resolveActor(window.getDatabaseNode());
    local nodePC = ActorManager.getCreatureNode(rActor);

    local rRoll = { 
        sType = "dice", 
        sDesc = "" .. abilityName .. "", 
        aDice = { "d10", "d10" },
        nMod = skilledMod + characteristicMod,
        t1 = DB.getValue(nodeWin, "tier1"),
        t2 = DB.getValue(nodeWin, "tier2"),
        t3 = DB.getValue(nodeWin, "tier3");
    };
    ActionsManager_DS.encodeDesktopMods(rRoll);
    ActionsManager.performAction(draginfo, rActor, rRoll);
    return true;
end

function onDragStart(button, x, y, draginfo)
    return action(draginfo);
end

function onButtonPress()
    return action();
end