function calcBattleEV(nodeBattle)

	local sTargetNPCList = LibraryData.getCustomData("battle", "npclist") or "npclist";
	local numberOfHeroes = CombatManagerDS.tablelength(aHeroes);
	local nXP = 0;
	for _, vNPCItem in ipairs(DB.getChildList(nodeBattle, sTargetNPCList)) do
		local _,sRecord = DB.getValue(vNPCItem, "link", "", "");
		if sRecord ~= "" then
			local nodeNPC = DB.findNode(sRecord);
			if nodeNPC then
				nXP = nXP + (DB.getValue(vNPCItem, "count", 0) * DB.getValue(nodeNPC, "ev", 0));
			else
				local sMsg = string.format(Interface.getString("battle_error_missingnpclink"), DB.getValue(vNPCItem, "name", ""));
			end
		end
	end

	local aEntries = CombatManager.getSortedCombatantList();
    local sTargetNPCList = LibraryData.getCustomData("battle", "npclist") or "npclist";
	local aHeroes = {};
	local aVictories = {};
	for i,v in pairs(aEntries) do
		local count = 0;
		
		if CombatManager.getFactionFromCT(v) == "friend" then
			--count number of heroes
			count = count + 1;
			table.insert(aHeroes, count);
		end
	end
	Debug.chat(aHeroes);
	local numberOfHeroes = CombatManagerDS.tablelength(aHeroes);
    local EV = 0;
    local bonusEV = 0;
    local avgLevel = 0;
    for i,v in pairs(aHeroes) do
        --get the PC Node
		local nodePC = ActorManager.getCreatureNode(v);
 
		--grab victories from each PC
		local level = DB.getParent(nodePC, "level");

        avgLevel = avgLevel + level; -- issue with level being nil
        -- notes: I think it's because this is looking at record_char_main
        -- and level is in record_char_DS
        if(level == 1) then
            ES = ES + 6;
        elseif(level == 2) then
            ES = ES + 8;
        elseif(level == 3) then
            ES = ES + 10;
        elseif(level == 4) then
            ES = ES + 12;
        elseif(level == 5) then
            ES = ES + 14;
        elseif(level == 6) then
            ES = ES + 16;
        elseif(level == 7) then
            ES = ES + 18;
        elseif(level == 8) then
            ES = ES + 20;
        elseif(level == 9) then
            ES = ES + 22;
        elseif(level == 10) then
            ES = ES + 24;
        else
            Debug.chat("ERROR");
        end 
	end

    avgLevel = math.floor(avgLevel / numberOfHeroes);
    if(avgLevel == 1) then
        bonusEV = bonusEV + 6;
    elseif(avgLevel == 2) then
        bonusEV = bonusEV + 8;
    elseif(avgLevel == 3) then
        bonusEV = bonusEV + 10;
    elseif(avgLevel == 4) then
        bonusEV = bonusEV + 12;
    elseif(avgLevel == 5) then
        bonusEV = bonusEV + 14;
    elseif(avgLevel == 6) then
        bonusEV = bonusEV + 16;
    elseif(avgLevel == 7) then
        bonusEV = bonusEV + 18;
    elseif(avgLevel == 8) then
        bonusEV = bonusEV + 20;
    elseif(avgLevel == 9) then
        bonusEV = bonusEV + 22;
    elseif(avgLevel == 10) then
        bonusEV = bonusEV + 24;
    else
        Debug.chat("ERROR");
    end 

    local trivial = EV - math.floor(bonusEV * 1);
    local easy = totalEV;
    local standard = math.floor(bonusEV * 1) + EV;
    local hard = math.floor(bonusEV * 3) + EV;

    if (nXP <= hard) and (nXP >= standard) then
        DB.setValue(nodeBattle, "difficulty_name", "string", "Hard");
		Debug.chat("Hard");
    elseif (nXP <= standard) and (nXP >= trivial) then
        DB.setValue(nodeBattle, "difficulty_name", "string", "Standard");
		Debug.chat("Standard");
    elseif (nXP <= trivial) then
        DB.setValue(nodeBattle, "difficulty_name", "string", "Trivial");
		Debug.chat("Trivial");
    elseif (nXP <= easy) and (nXP <= trivial) then
        DB.setValue(nodeBattle, "difficulty_name", "string", "Easy");
		Debug.chat("Easy");
    else
        DB.setValue(nodeBattle, "difficulty_name", "string", "Extreme");
		Debug.chat("Extreme");
    end
end