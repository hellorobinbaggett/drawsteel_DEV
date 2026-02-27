function getReadOnlyStateHidden(vNode)
	if not DB.isOwner(vNode) then
		return true;
	end
	if DB.isReadOnly(vNode) then
		return true;
	end
	return WindowManager.getLockedStateHidden(vNode);
end
function getLockedStateHidden(vNode)
	local nDefault = 1;
	local bLocked = (DB.getValue(DB.getPath(vNode, "locked"), nDefault) ~= 0);
	return bLocked;
end