-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


function onInit()
	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);
end

function onMenuSelection(selection)
	if selection == 5 then
		self.addEntry(true);
	end
end

function onListChanged()
	self.update();
	self.updateContainers();
end

function update()
	local bEditMode = (window.inventorylist_iedit.getValue() == 1);
	if window.idelete_header then
		window.idelete_header.setVisible(bEditMode);
	end
	for _,w in ipairs(getWindows()) do
		w.idelete.setVisible(bEditMode);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if w then
		if bFocus then
			w.name.setFocus();
		end
		w.count.setValue(1);
	end
	return w;
end

local _sortLocked = false;
function setSortLock(isLocked)
	_sortLocked = isLocked;
end
function onSortCompare(w1, w2)
	if _sortLocked then
		return false;
	end
	return ItemManager.onInventorySortCompare(w1, w2);
end

function updateContainers()
	ItemManager.onInventorySortUpdate(self);
end

function onDrop(x, y, draginfo)
	return ItemManager.handleAnyDrop(window.getDatabaseNode(), draginfo);
end
