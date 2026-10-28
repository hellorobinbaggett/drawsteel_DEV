--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	self.buildCareers();
	self.buildFilters();
end

local _tCareers = {};
local _tModules = {};
function getAllCareers()
	return _tCareers;
end
function getAllModules()
	return _tModules;
end
function clearRecords()
	_tCareers = {};
	_tModules = {};
	list.closeAll();
end
function buildRecords()
	self.clearRecords();
	RecordManager.callForEachRecord("career", self.addListRecord);
end
function buildCareers()
	self.buildRecords();

	for k,v in pairs(self.getAllCareers()) do
		if self.helperFilterCheck(v) then
			self.addDisplayListItem(k, v);
		end
	end
end
function addListRecord(vNode)
	local rRecord = {};
	rRecord.vNode = vNode;
	rRecord.sDisplayName = DB.getValue(vNode, "name", "");
	rRecord.sDisplayNameLower = rRecord.sDisplayName:lower();

	rRecord.sModuleName = DB.getModule(vNode);
	rRecord.sModule = ModuleManager.getModuleDisplayName(rRecord.sModuleName);
	if (DB.getValue(vNode, "version", "") ~= "2024") then
		local sLegacySuffix = Interface.getString("suffix_legacy");
		if not StringManager.endsWith(rRecord.sModule, sLegacySuffix) then
			rRecord.sModule = string.format("%s %s", rRecord.sModule, sLegacySuffix);
		end
	end

	local tCareers = self.getAllCareers();
	tCareers[rRecord.sDisplayNameLower] = tCareers[rRecord.sDisplayNameLower] or {};
	table.insert(tCareers[rRecord.sDisplayNameLower], rRecord);

	self.getAllModules()[rRecord.sModule] = true;
end
function addDisplayListItem(_, tCareer)
	if #(tCareer or {}) == 0 then
		return;
	end
	local sCareer = tCareer[1].sDisplayName;
	if not sCareer then
		return;
	end

	local wCareer = list.createWindow();
	wCareer.button_select.setVisible(true);
	wCareer.name.setValue(sCareer);

	local tModules = {};
	local tOrderedModules = {};
	for _,v in ipairs(tCareer) do
		local nOrder;
		for k2,v2 in ipairs(CharWizardData.module_order_2024) do
			if v.sModuleName == v2 then
				nOrder = k2;
				break
			else
				for _,v3 in ipairs(CharWizardData.module_order_2014) do
					if v.sModuleName == v3 then
						nOrder = k2 + 1;
						break
					end
				end
			end
		end
		local bModule = self.moduleFilterCheck(v);
		local bString = self.stringFilterCheck(v);
		if bModule and bString then
			if nOrder then
				table.insert(tOrderedModules, nOrder, v.sModule);
			else
				table.insert(tModules, v.sModule);
			end
		end
	end

	local tFinalModules = {};
	for _,v in pairs(tModules) do
		table.insert(tFinalModules, v);
	end
	for _,v in pairs(tOrderedModules) do
		table.insert(tFinalModules, v);
	end
	wCareer.module.addItems(tFinalModules);
	wCareer.module.setVisible(true);

	if #tFinalModules == 1 then
		wCareer.module.setComboBoxReadOnly(true);
		wCareer.module.setFrame(nil);
	end

	wCareer.module.setValue(tFinalModules[1]);
end

local _sComboFilter = "";
local _sFilter = "";
function onFilterChanged()
	local sSourceFilter = filter_source.getValue():lower();
	local sNameFilter = filter_name.getValue():lower();
	if sSourceFilter == _sComboFilter and sNameFilter == _sFilter then
		return;
	end

	_sComboFilter = sSourceFilter;
	_sFilter = sNameFilter;
	self.buildCareers();
end
function buildFilters()
	filter_name.setValue("");

	filter_source.clear();
	filter_source.add("");
	for k,_ in pairs(self.getAllModules()) do
		filter_source.add(k);
	end
end
function helperFilterCheck(tCareer)
	local bModule = false;
	local bString = false;

	for _,v in ipairs(tCareer) do
		if self.moduleFilterCheck(v) then
			bModule = true;
		end
		if self.stringFilterCheck(v) then
			bString = true;
		end
	end

	if bModule and bString then
		return true
	end

	return false
end
function moduleFilterCheck(tCareerEntry)
	local bAdd = false;
	if _sComboFilter == "" then
		return true;
	end
	if _sComboFilter == tCareerEntry.sModule:lower() then
		bAdd = true;
	end

	return bAdd;
end
function stringFilterCheck(tCareerEntry)
	local bAdd = false;
	if _sFilter == "" then
		return true;
	end

	for _,v in ipairs(StringManager.split(_sFilter:lower(), ",", true)) do
		if tCareerEntry.sDisplayNameLower:match(v) then
			bAdd = true;
		end
	end

	return bAdd;
end
