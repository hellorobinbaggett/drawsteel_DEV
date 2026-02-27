--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	super.onInit();
	self.onHealthChanged();
end

function onFactionChanged()
	super.onFactionChanged();

	local bFriend = (friendfoe.getValue() == "friend");
	link.setVisible(bFriend);
	sta_max.setVisible(bFriend);
	sta_curr.setVisible(bFriend);
end

function onHealthChanged()
	sta_curr.setColor(getPCSheetWoundColor(getDatabaseNode()));
end
function getPCSheetWoundColor(nodePC)
	local nMaxStamina = math.max(DB.getValue(nodePC, "stamina.max", 0), 0);
	local nCurrentStamina = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);

	local nWindedValue = nMaxStamina / 2;
	if nCurrentStamina > nWindedValue then
		return "1a6313";
	elseif nCurrentStamina > 0 then
		return "a37800";
	end
	return "630000";
end
