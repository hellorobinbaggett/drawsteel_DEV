function powerRoll(rMessage, rRoll)
    -- set crit threshold for power roll
	local nCritThreshold = 19;
	local heroResource = DB.getChild(CharSheetID, "classresource");
	local sCharSheetID = DB.getPath(DB.getChild(nodeWin, '...'));
    local CharSheetID = DB.findNode(sCharSheetID);

	-- check to see if any edge/bane desktop buttons are pressed
	ActionsManager_DS.encodeDesktopMods(rRoll);

	-- check if ability uses resources

	if rRoll.t1 == nill then
		rRoll.t1 = "";
	end
	if rRoll.t2 == nill then
		rRoll.t2 = "";
	end
	if rRoll.t3 == nill then
		rRoll.t3 = "";
	end
	if rRoll.effect == nill then
		rRoll.effect = "";
	end

	if rRoll.aDice[2] then
	-- if 2d10 are rolled, we need to check if it's a critical hit.
		if string.match(rRoll.aDice[1].type, "d10") then
			if string.match(rRoll.aDice[2].type, "d10") then
				-- get the total after any modifications
				local powerRollTotal = rRoll.aDice[1].result + rRoll.aDice[2].result;
				local powerRollTotalMod = ActionsManager.total(rRoll);

				-- write in chat what tier result it is
				if powerRollTotalMod <= 11 then
					rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 1: \n" .. tostring(rRoll.t1) .. "\n\n" .. tostring(rRoll.effect);
				elseif powerRollTotalMod >= 17 then
					rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 3: \n" .. tostring(rRoll.t3) .. "\n\n" .. tostring(rRoll.effect);
				elseif powerRollTotalMod == powerRollTotalMod then
					rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 2: \n" .. tostring(rRoll.t2) .. "\n\n" .. tostring(rRoll.effect);
				end

				-- check for double edges
				if string.match(rRoll.sDesc, "Double Edge") then
					if powerRollTotalMod <= 11 then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 2: \n" .. tostring(rRoll.t2) .. "\n\n" .. tostring(rRoll.effect);
					elseif powerRollTotalMod >= 17 then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 3: \n" .. tostring(rRoll.t3) .. "\n\n" .. tostring(rRoll.effect);
					elseif powerRollTotalMod == powerRollTotalMod then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 3: \n" .. tostring(rRoll.t3) .. "\n\n" .. tostring(rRoll.effect);
					end
				end

				-- check for double baness
				if string.match(rRoll.sDesc, "Double Bane") then
					if powerRollTotalMod <= 11 then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 1: \n" .. tostring(rRoll.t1) .. "\n" .. tostring(rRoll.effect);
					elseif powerRollTotalMod >= 17 then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 2: \n" .. tostring(rRoll.t2) .. "\n" .. tostring(rRoll.effect);
					elseif powerRollTotalMod == powerRollTotalMod then
						rMessage.text = tostring(rRoll.sDesc) .. "\nTIER 1: \n" .. tostring(rRoll.t1) .. "\n" .. tostring(rRoll.effect);
					end
				end

				-- check for critical hits
				if powerRollTotal >= nCritThreshold then
					rMessage.text = tostring(rRoll.sDesc) .. "\nCRITICAL HIT: \n" .. tostring(rRoll.t3) .. "\n\n" .. tostring(rRoll.effect);
				end
				-- natural 20s are always Tier 3 no matter what modifiers or banes present
				-- if powerRollTotal > nCritThreshold then
				-- 	rMessage.text = tostring(rRoll.sDesc) .. "\nPower Roll: Automatic TIER 3\n[CRITICAL]\n[NATURAL 20]";
				-- end
			end
		end
	end
	
	return rMessage;
end