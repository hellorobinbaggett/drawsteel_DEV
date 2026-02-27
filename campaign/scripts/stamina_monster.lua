function onValueChanged()
    local nodeWin = window.getDatabaseNode();
    local nCurrent = DB.getValue(nodeWin, "stamina.current");
    local nMax = DB.getValue(nodeWin, "stamina.max");
    local nWinded = nMax / 2;
    local nDead = 0;
    
    if(nCurrent > nMax) then
        setValue(nMax);
    end
    if(nCurrent < 0) then
        setValue(0);
    end
    window.onHealthChanged();
end


