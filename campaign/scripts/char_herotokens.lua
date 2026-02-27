function onInit()
    setValue(DB.getValue(nodeHeroToken, "herotoken"));
end

function onValueChanged()
    local nodeWin = window.getDatabaseNode();
    local node = DB.getChild(nodeWin, "...");
    local nCurrent = DB.getValue(nodeWin, "herotokens");

    local nodeHeroToken = DB.createChild(node, "herotoken", "number");
    DB.setValue(nodeHeroToken, "herotoken", "number", nCurrent);
    setValue(DB.getValue(nodeHeroToken, "herotoken"));
end