function getKeywordValues(vNode)
	local sKeywords = DB.getValue(vNode, "keywords_name", ""):lower();
	local aFilterValues = {};
	
	-- TODO - further refine the gsub calls below to strip out other suffixes - e.g. B, P or S.
	
	if sKeywords ~= "" then
		-- Remove any numerical keyword suffixes to leave the base keyword - e.g. Additive 1 -> Additive
		sKeywords = string.gsub(sKeywords, " %d+", "");
		-- Remove" ft."
		sKeywords = string.gsub(sKeywords, " %sft%.", "");
		sKeywords = StringManager.titleCase(sKeywords);
		aFilterValues = StringManager.split(sKeywords, " ,", true);
	end
	
	if #aFilterValues > 0 then
		return aFilterValues;
	else
		return Interface.getString("library_recordtype_filter_empty");
	end
end

aRecordOverrides = {
	-- CoreRPG overrides
	["npc"] = {
		bExport = true,
		bID = true,
		aDataMap = { "npc", "reference.npcs" },
		sListDisplayClass = "masterindexitem_id",
		-- sRecordDisplayClass = "npc",
		aGMEditButtons = { "button_add_npc_import" },
		aCustom = {
			tWindowMenu = { ["left"] = { "chat_speak" } },
		},
		aCustomFilters = {
			["Level"] = { sField = "level_name" },
			["Keywords"] = { sField = "keywords_name", fGetValue = getKeywordValues },
			["Role"] = { sField = "role_name" },
			["Organization"] = { sField = "organization_name" },
		},
	},
	["ancestry"] = {
		bExport = true,
		aDataMap = { "ancestry", "reference.ancestries" },
	},
	["class"] = {
		bExport = true,
		aDataMap = { "class", "reference.classes" },
	},
	-- ["feat"] = {
	-- 	nExport = 3,
	-- 	aDataMap = { "feat", "reference.features" },
	-- },

	-- new record types
	["ability"] = {
		sSidebarCategory = "create",
		bExport = true,
		aDataMap = { "ability", "reference.abilities" },
		aCustomFilters = {
			["Class"] = { sField = "class" },
			["Cost"] = { sField = "ability_cost" },
			["Cost Type"] = { sField = "ability_cost_string" },
			["Level"] = { sField = "ability_level" },
			["Ability Type"] = { sField = "abilitytype" },
		},
	},
	["item"] = {
		sSidebarCategory = "create",
		bExport = true,
		aDataMap = { "item", "reference.items" },
		aCustomFilters = {
			["Type"] = { sField = "type" },
			["Echelon"] = { sField = "echelon" },
		},
	},
	["kit"] = {
		sSidebarCategory = "create",
		bExport = true,
		aDataMap = { "kit", "reference.kit" },
	},
	-- TODO: implement careers
	["career"] = {
		sSidebarCategory = "create",
		bExport = true,
		aDataMap = { "career", "reference.career" },
	},
};

aListViews = {
	["ability"] = {
		["byclass"] = {
			aColumns = {
				{ sName = "ability_cost", sType = "basicnumber", sHeadingRes = "ability_grouped_label_cost", nWidth=50 },
				{ sName = "name", sType = "basicstring", sHeadingRes = "ability_grouped_label_name", nWidth=350 },
			},
			aFilters = {},
			aGroups = { { sDBField = "class" } },
			aGroupValueOrder = {},
		},
		["byancestry"] = {
			aColumns = {
				{ sName = "ability_cost", sType = "basicnumber", sHeadingRes = "ability_grouped_label_cost", nWidth=50 },
				{ sName = "name", sType = "basicstring", sHeadingRes = "ability_grouped_label_name", nWidth=350 },
			},
			aFilters = {},
			aGroups = { { sDBField = "ancestry" } },
			aGroupValueOrder = {},
		},
	},
	["npc"] = {
		["bylevel"] = {
			aColumns = {
				{ sName = "level_name", sType = "basicnumber", sHeadingRes = "npc_grouped_label_cost", nWidth=50 },
				{ sName = "name", sType = "basicstring", sHeadingRes = "npc_grouped_label_name", nWidth=350 },
			},
			aFilters = {},
			aGroups = { { sDBField = "level_name" } },
			aGroupValueOrder = {},
		},
		["byrole"] = {
			aColumns = {
				{ sName = "level_name", sType = "basicnumber", sHeadingRes = "npc_grouped_label_cost", nWidth=50 },
				{ sName = "name", sType = "basicstring", sHeadingRes = "npc_grouped_label_name", nWidth=350 },
			},
			aFilters = {},
			aGroups = { { sDBField = "role_name" } },
			aGroupValueOrder = {},
		}
	},
	["item"] = {
		["byechelon"] = {
			aColumns = {
				{ sName = "name", sType = "basicnumber", sHeadingRes = "npc_grouped_label_echelon", nWidth=400 },
			},
			aFilters = {},
			aGroups = { { sDBField = "echelon" } },
			aGroupValueOrder = {},
		},
		["bytype"] = {
			aColumns = {
				{ sName = "name", sType = "basicstring", sHeadingRes = "ability_label_type", nWidth=400 },
			},
			aFilters = {},
			aGroups = { { sDBField = "type" } },
			aGroupValueOrder = {},
		}
	},
};

function onInit()
	LibraryData.overrideRecordTypes(aRecordOverrides);
	LibraryData.setRecordViews(aListViews);
	LibraryData.setRecordTypeInfo("vehicle", nil);
end