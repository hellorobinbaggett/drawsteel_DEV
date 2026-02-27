function testRoll(rMessage, rRoll)

    -- set crit threshold for power roll
	local nCritThreshold = 19;

	-- check to see if any edge/bane desktop buttons are pressed
	ActionsManager_DS.encodeDesktopMods(rRoll);

	-- check if the roll has the [TEST] 

	-- if 2d10 are rolled, it is a power roll.
	if rRoll.aDice.expr == "2d10" then
		local powerRollTotal = rRoll.aDice[1].result + rRoll.aDice[2].result;	
		local powerRollTotalMod = ActionsManager.total(rRoll);

		-- write in chat what tier result it is
		if powerRollTotalMod <= 11 then
			rMessage.text = "Power Roll: TIER 1\n" .. tostring(rRoll.sDesc);
		elseif powerRollTotalMod >= 17 then
			rMessage.text = "Power Roll: TIER 3\n" .. tostring(rRoll.sDesc);
		elseif powerRollTotalMod == powerRollTotalMod then
			rMessage.text = "Power Roll: TIER 2\n" .. tostring(rRoll.sDesc);
		end

		-- check for double edges
		if string.match(rRoll.sDesc, "Double Edge") then
			if powerRollTotalMod <= 11 then
				rMessage.text = "Power Roll: TIER 2\n" .. tostring(rRoll.sDesc);
			elseif powerRollTotalMod >= 17 then
				rMessage.text = "Power Roll: TIER 3\n" .. tostring(rRoll.sDesc);
			elseif powerRollTotalMod == powerRollTotalMod then
				rMessage.text = "Power Roll: TIER 3\n" .. tostring(rRoll.sDesc);
			end
		end

		-- check for double banes
		if string.match(rRoll.sDesc, "Double Bane") then
			if powerRollTotalMod <= 11 then
				rMessage.text = "Power Roll: TIER 1\n" .. tostring(rRoll.sDesc);
			elseif powerRollTotalMod >= 17 then
				rMessage.text = "Power Roll: TIER 2\n" .. tostring(rRoll.sDesc);
			elseif powerRollTotalMod == powerRollTotalMod then
				rMessage.text = "Power Roll: TIER 1\n" .. tostring(rRoll.sDesc);
			end
		end

		-- check for critical hits and natural 20s
		if powerRollTotal == nCritThreshold then
			rMessage.text = tostring(rMessage.text) .. "\n[CRITICAL]";
		end
		-- natural 20s are always Tier 3 no matter what modifiers or banes present
		if powerRollTotal > nCritThreshold then
			rMessage.text = tostring(rRoll.sDesc) .. "\nPower Roll: Automatic TIER 3\n[CRITICAL]\n[NATURAL 20]";
		end

	end
	
	return rMessage;
end