function onInit()
    local nBestStat = 0;

    local nodeWin = window.getDatabaseNode();
    local nMight = DB.getValue(nodeWin, "MGT");
    local nAgility = DB.getValue(nodeWin, "AGL");
    local nReason = DB.getValue(nodeWin, "REA");
    local nIntuition = DB.getValue(nodeWin, "INU");
    local nPresence = DB.getValue(nodeWin, "PRS");

    if(nMight > nBestStat) then
        nBestStat = nMight;
    end
    if(nAgility > nBestStat) then
        nBestStat = nAgility;
    end
    if(nReason > nBestStat) then
        nBestStat = nReason;
    end
    if(nIntuition > nBestStat) then
        nBestStat = nIntuition;
    end
    if(nPresence > nBestStat) then
        nBestStat = nPresence;
    end

    local Strong = nBestStat;
    local Average = math.floor(nBestStat - 1);
    local Weak = math.floor(nBestStat - 2);

    setValue(Strong);
end

function onDoubleClick()
    local nBestStat = 0;

    local nodeWin = window.getDatabaseNode();
    local nMight = DB.getValue(nodeWin, "MGT");
    local nAgility = DB.getValue(nodeWin, "AGL");
    local nReason = DB.getValue(nodeWin, "REA");
    local nIntuition = DB.getValue(nodeWin, "INU");
    local nPresence = DB.getValue(nodeWin, "PRS");

    if(nMight > nBestStat) then
        nBestStat = nMight;
    end
    if(nAgility > nBestStat) then
        nBestStat = nAgility;
    end
    if(nReason > nBestStat) then
        nBestStat = nReason;
    end
    if(nIntuition > nBestStat) then
        nBestStat = nIntuition;
    end
    if(nPresence > nBestStat) then
        nBestStat = nPresence;
    end

    local Strong = nBestStat;
    local Average = math.floor(nBestStat - 1);
    local Weak = math.floor(nBestStat - 2);

    setValue(Strong);
end
