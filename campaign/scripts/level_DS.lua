function onValueChanged()
    local nodeWin = window.getDatabaseNode();
    local nExperience = DB.getValue(nodeWin, "xptitle");
    local nLevel = DB.getValue(nodeWin, "levelnumbertitle");

    DB.setValue(nodeWin, "levelnumbertitle", "number", 1);

    -- Max Level is 10
    if(nExperience >= 16) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 2);
    end
    if(nExperience >= 32) then  
        DB.setValue(nodeWin, "levelnumbertitle", "number", 3);
    end
    if(nExperience >= 48) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 4);
    end
    if(nExperience >= 64) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 5);
    end
    if(nExperience >= 80) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 6);
    end
    if(nExperience >= 96) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 7);
    end
    if(nExperience >= 112) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 8);
    end
    if(nExperience >= 128) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 9);
    end
    if(nExperience > 143) then
        DB.setValue(nodeWin, "levelnumbertitle", "number", 10);
    end
end