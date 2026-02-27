-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end
function VisDataCleared()
	update();
end
function InvisDataAdded()
	update();
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);

	local bSection1 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "impressionscore", bReadOnly) then bSection1 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "impressionscore", bReadOnly, true);
	end
	-- divider.setVisible(bSection1);

	local bSection2 = false;
	if Session.IsHost then
		if WindowManager.callSafeControlUpdate(self, "motivations", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "pitfalls", bReadOnly) then bSection2 = true; end;
		if WindowManager.callSafeControlUpdate(self, "outcomes", bReadOnly) then bSection2 = true; end;
	else
		WindowManager.callSafeControlUpdate(self, "motivations", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "pitfalls", bReadOnly, true);
		WindowManager.callSafeControlUpdate(self, "outcomes", bReadOnly, true);
	end
end
