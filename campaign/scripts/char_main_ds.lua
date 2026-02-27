

function onValueChanged()
	window.onHealthChanged();
end

function onHealthChanged()
	stamina.setColor(getPCSheetWoundColor(getDatabaseNode()));
end

function getPCSheetWoundColor(nodePC)
	local nMaxStamina = 0;
	local nCurrentStamina = 0;
	if nodePC then
		nMaxStamina = math.max(DB.getValue(nodePC, "stamina.max", 0), 0);
		nCurrentStamina = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
	end

	local sColor = "630000";

	local nWindedValue = nMaxStamina / 2;
	local nLowHealth = nMaxStamina / 6;
	
	if nCurrentStamina > nWindedValue then
		sColor = "1a6313";
	end

	if nWindedValue > nCurrentStamina and nCurrentStamina > nLowHealth then
		sColor = "a37800";
	end

	return sColor;
end