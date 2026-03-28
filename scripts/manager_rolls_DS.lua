function saveRoll(rMessage, rRoll)

	-- if rActor has elf_feature then
	-- 	local DC = 4;
	-- else
		local DC = 5;
	-- end

	if rRoll.aDice[1].result > DC then
		rMessage.text = tostring(rMessage.text) .. " Success! [Effect Ends]";
		-- remove condition
	else
		rMessage.text = tostring(rRoll.sDesc) .. " Failure [Effect Continues]";
	end
	
	return rMessage;
end