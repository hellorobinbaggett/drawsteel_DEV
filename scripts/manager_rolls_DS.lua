function saveRoll(rMessage, rRoll)

	-- use save override value if it is populated
	if (rRoll.nDC == 0) then
		local DC = 6;

		if rRoll.aDice[1].result >= DC then
			rMessage.text = tostring(rMessage.text) .. " Success! [Effect Ends]";
			-- remove condition
		else
			rMessage.text = tostring(rRoll.sDesc) .. " Failure [Effect Continues]";
		end
		
		return rMessage;
	else
		local DC = rRoll.nDC
		
		if rRoll.aDice[1].result >= DC then
			rMessage.text = tostring(rMessage.text) .. " Success! [Effect Ends]";
			-- remove condition
		else
			rMessage.text = tostring(rRoll.sDesc) .. " Failure [Effect Continues]";
		end
		
		return rMessage;
	end
end