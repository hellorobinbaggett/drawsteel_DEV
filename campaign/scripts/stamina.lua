function onValueChanged()
    local nodeWin = window.getDatabaseNode();
    local nCurrent = DB.getValue(nodeWin, "stamina.current");
    local nMax = DB.getValue(nodeWin, "stamina.max");
    local nWinded = DB.getValue(nodeWin, "hp.winded");
    local nDead = (0 - nWinded);
    local nRecovery = DB.getValue(nodeWin, "recoverycurrent");
    local nMaxRecovery = DB.getValue(nodeWin, "recoverymax");
    -- handle stamina
    if(nCurrent > nMax) then
        setValue(nMax);
    end
    -- handle recoveries
    if(nRecovery > nMaxRecovery) then
        setValue(nMaxRecovery);
    end

    if(nCurrent < nDead) then
        setValue(nDead);
    end

    onHealthChanged();
end

function onHealthChanged()
    setColor(getPCSheetWoundColor());
end

function getPCSheetWoundColor()
    local nodeWin = window.getDatabaseNode();
    local nCurrent = DB.getValue(nodeWin, "stamina.current");
    local nMax = DB.getValue(nodeWin, "stamina.max");
    local nWinded = nMax / 2;
    local nDead = (0 - nWinded);

    local sColor = "630000";

    if nCurrent <= nDead then
        sColor = "120909";
    end

    if nCurrent > nWinded then
        sColor = "1a6313";
    end

    if nWinded >= nCurrent and nCurrent > 0 then
        sColor = "a37800";
    end

    return sColor;
end