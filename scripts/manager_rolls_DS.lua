function saveRoll(rMessage, rRoll)

	if rRoll.aDice[1].result > 5 then
		rMessage.text = tostring(rMessage.text) .. " Success! [Effect Ends]";
		-- remove condition
	else
		rMessage.text = tostring(rRoll.sDesc) .. " Failure [Effect Continues]";
	end
	
	return rMessage;
end