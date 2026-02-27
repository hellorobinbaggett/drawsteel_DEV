--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onFilter(w)
	if super and super.onFilter then
		if not super.onFilter(w) then
			return false;
		end
	end

	local nodeCT = w.getDatabaseNode();
	local bShow;
	if flag_heroes then
		bShow = (ActorManager.isPC(nodeCT) and not ActorManager_DS.isInitSet(nodeCT));
	elseif flag_monsters then
		bShow = (not ActorManager.isPC(nodeCT) and not ActorManager_DS.isInitSet(nodeCT));
	else
		bShow = ActorManager_DS.isInitSet(nodeCT);
	end
	return bShow;
end
