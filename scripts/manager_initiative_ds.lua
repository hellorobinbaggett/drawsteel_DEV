function initiativeRoll(rMessage, rRoll)

	if rRoll.aDice[1].result > 5 then
		rMessage.text = tostring(rMessage.text) .. " Heroes go first!";
	else
		rMessage.text = tostring(rRoll.sDesc) .. " Monsters go first!";
	end
	
	return rMessage;
end