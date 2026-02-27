function onButtonPress()
    local nodeWin = window.getDatabaseNode();
    local nExperience = DB.getValue(nodeWin, "xptitle");
    local nLevel = DB.getValue(nodeWin, "levelnumbertitle");
    local nVictories = DB.getValue(nodeWin, "victories");
    local nMaxStamina = DB.getValue(nodeWin, "stamina.max");
    local nRecoveries = DB.getValue(nodeWin, "recoverycurrent");
    local nMaxRecoveries = DB.getValue(nodeWin, "recoverymax");
    local sHeroName = DB.getValue(nodeWin, "name");
    local nTotal = 0;

    ChatManager.SystemMessageResource("char_emptylist_respite", tostring(sHeroName));

    -- Convert Victories into XP
    nTotal = nExperience + nVictories;
    DB.setValue(nodeWin, "xptitle", "number", nTotal);
    DB.setValue(nodeWin, "victories", "number", 0);
    -- Remove any resources, and regain recoveries
    DB.setValue(nodeWin, "recoverycurrent", "number", nMaxRecoveries);
    DB.setValue(nodeWin, "surges", "number", 0);
    DB.setValue(nodeWin, "classresource", "number", 0);

    -- Check if level went up
    local nNewLevel = DB.getValue(nodeWin, "levelnumbertitle");
    if(nNewLevel > nLevel) then
        ChatManager.SystemMessageResource("char_emptylist_levelup", tostring(sHeroName), tostring(nNewLevel));

        -- TODO: automatically drag and drop class onto character sheet
        -- find class
    end

    -- Heal stamina and remove all conditions
    DB.setValue(nodeWin, "stamina.current", "number", nMaxStamina);

    -- IF level up

    -- if finished, deliver message

end