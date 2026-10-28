--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerResultHandler("charwizardwealthroll", CharWizardKitManager.onWealthRoll);
end
--
--	STARTING KIT UI
--

function onEquipmentPageUpdate()
	CharWizardKitManager.onKitUpdate();
	CharWizardKitManager.onWealthUpdate();
end

function getWizardKitKitWindow()
	local wEquipment = CharWizardManager.getWizardKitWindow();
	if not wEquipment then
		return nil;
	end
	return wEquipment.sub_kit_startingkit.subwindow;
end
function getWizardKitWealthWindow()
	local wEquipment = CharWizardManager.getWizardKitWindow();
	if not wEquipment then
		return nil;
	end
	return wEquipment.sub_kit_startingwealth.subwindow;
end

function onCareerClear()
	CharWizardKitManager.onCareerKitClear();
	CharWizardKitManager.onCareerWealthClear();
end
function onClassClear()
	CharWizardKitManager.onClassKitClear();
	CharWizardKitManager.onClassWealthClear();
	CharWizardKitManager.onRolledWealthClear();
end

function updateKitVisibility()
	local wEquipment = CharWizardManager.getWizardKitWindow();
	if not wEquipment then
		return;
	end

	local bShowKits = CharWizardClassManager.isStartingClass2024() or (CharWizardManager.getStartingGold() == 0);
	wEquipment.sub_kit_startingkit.setVisible(bShowKits);
end

--
--	KIT
--

function onKitUpdate()
	CharWizardKitManager.onCareerKitUpdate();
	CharWizardKitManager.onClassKitUpdate();
end

function onCareerKitUpdate()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end

	if wEquipmentKit.careerkit_items.isEmpty() then
		CharWizardKitManager.helperUpdateCareerKitItems(wEquipmentKit);
	end
	local tCareerOptions = CharWizardCareerManager.getCareerStartingKitOptions();
	if (wEquipmentKit.list_careerkit.getWindowCount() == 0) and (#tCareerOptions > 0) then
		if CharWizardCareerManager.isCareer2024() then
			local wChoices = wEquipmentKit.list_careerkit.createWindow();
			wChoices.type.setValue("Choice");
			wChoices.type.setVisible(true);
			wChoices.setData2024(tCareerOptions, "career");
			wChoices.alert.setVisible(true);
		else
			for i = 1, #tCareerOptions do
				local wChoices = wEquipmentKit.list_careerkit.createWindow();
				wChoices.type.setValue("Choice #" .. i);
				wChoices.type.setVisible(true);
				wChoices.setData(tCareerOptions[i], "career");
				wChoices.alert.setVisible(true);
			end
		end
	end
end
function helperUpdateCareerKitItems(wEquipmentKit)
	if not wEquipmentKit then
		return;
	end

	local tCareerItems = CharWizardCareerManager.getCareerStartingKitItems();
	local tItems = {};
	for _,v in ipairs(tCareerItems) do
		local sName = DB.getValue(v.item, "name", "");
		local nCount = DB.getValue(v.item, "count", 0);
		local sItem;
		if nCount > 1 then
			sItem = ("%s %s"):format(nCount, sName);
		else
			sItem = ("%s"):format(sName);
		end
		table.insert(tItems, sItem);
	end

	wEquipmentKit.careerkit_items.setValue(table.concat(tItems, ", "));
end
function resetCareerKitItems()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end
	wEquipmentKit.careerkit_items.setValue("");
end
function onCareerKitClear()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end
	wEquipmentKit.careerkit_items.setValue("");
	wEquipmentKit.list_careerkit.closeAll();
end

function onClassKitUpdate()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end

	local tClassOptions = CharWizardClassManager.getStartingKitOptions();
	if wEquipmentKit.classkit_items.isEmpty() and CharWizardManager.hasClasses() then
		CharWizardKitManager.helperUpdateClassKitItems(wEquipmentKit);
	end
	if (wEquipmentKit.list_classkit.getWindowCount() == 0) and (#tClassOptions > 0) then
		if CharWizardClassManager.isStartingClass2024() then
			local wChoices = wEquipmentKit.list_classkit.createWindow();
			wChoices.type.setValue("Choice");
			wChoices.type.setVisible(true);
			wChoices.setData2024(tClassOptions, "class");
			wChoices.alert.setVisible(true);
		else
			for i = 1, #tClassOptions do
				local wChoices = wEquipmentKit.list_classkit.createWindow();
				wChoices.type.setValue("Choice #" .. i);
				wChoices.type.setVisible(true);
				wChoices.setData(tClassOptions[i], "class");
				wChoices.alert.setVisible(true);
			end
		end
	end
end
function helperUpdateClassKitItems(wEquipmentKit)
	if not wEquipmentKit then
		return;
	end

	local bIs2024 = CharWizardClassManager.isStartingClass2024();
	local tItems = {};
	for _,v in ipairs(CharWizardClassManager.getStartingKitItems()) do
		local sName;
		local nCount;
		if bIs2024 then
			sName = DB.getValue(v.item, "name", "");
			nCount = DB.getValue(v.item, "count", 0);
		else
			sName = DB.getValue(v.item, "name", "");
			nCount = v.count;
		end
		local sItem;
		if nCount > 1 then
			sItem = ("%s %s"):format(nCount, sName);
		else
			sItem = ("%s"):format(sName);
		end
		table.insert(tItems, sItem);
	end

	wEquipmentKit.classkit_items.setValue(table.concat(tItems, ", "));
end
function resetClassKitItems()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end
	wEquipmentKit.classkit_items.setValue("");
end
function onClassKitClear()
	local wEquipmentKit = CharWizardKitManager.getWizardKitKitWindow();
	if not wEquipmentKit then
		return;
	end
	wEquipmentKit.classkit_items.setValue("");
	wEquipmentKit.list_classkit.closeAll();
end

function processKitSelection(w)
	local bIs2024;
	if w.windowlist.window.windowlist.getName() == "list_careerkit" then
		bIs2024 = CharWizardCareerManager.isCareer2024();
	else
		bIs2024 = CharWizardClassManager.isStartingClass2024();
	end
	if bIs2024 then
		CharWizardKitManager.processKitSelection2024(w);
	else
		CharWizardKitManager.processKitSelection2014(w);
	end

	w.windowlist.window.selection.setValue(w.name.getValue());
	w.windowlist.window.button_modify.setVisible(true);
	w.windowlist.setVisible(false);

	CharWizardKitManager.onEquipmentPageUpdate();
	CharWizardManager.updateAlerts();
end
function processKitSelection2024(w)
	local sKitType = WindowManager.callOuterWindowFunction(w, "getKitType");
	local tOptions = WindowManager.callOuterWindowFunction(w, "getAllRecords");
	local nChoice = 0;
	for k,v in ipairs({ "A", "B", "C" }) do
		local sName = w.name.getValue();
		if sName:match("^" .. v) then
			nChoice = k;
			break;
		end
	end

	local tItems = tOptions[nChoice].tOption.items;
	local nWealth = tOptions[nChoice].tOption.wealth;
	if sKitType == "class" then
		if tItems and next(tItems) then
			CharWizardClassManager.setStartingKitItems(tItems);
		end
		if nWealth then
			CharWizardClassManager.setStartingGold(nWealth);
		end
	end
	if sKitType == "career" then
		if tItems and next(tItems) then
			CharWizardCareerManager.setCareerStartingKitItems(tItems);
		end
		if nWealth then
			CharWizardCareerManager.setCareerStartingGold(nWealth);
		end
	end
end
function processKitSelection2014(w)
	local sKitType = WindowManager.callOuterWindowFunction(w, "getKitType");
	local _,sItemRecord = w.link.getValue();
	local tItems = {};
	if sKitType == "class" then
		tItems = CharWizardClassManager.getStartingKitItems();
	end
	if sKitType == "career" then
		tItems = CharWizardCareerManager.getCareerStartingKitItems();
	end

	local bHandled = false;
	local tFinalItems = {};
	for _,v in ipairs(tItems) do
		if DB.getPath(v.item) == sItemRecord then
			v.count = v.count + 1;
			bHandled = true;
		end
		table.insert(tFinalItems, v);
	end
	if not bHandled then
		table.insert(tFinalItems, { item = DB.findNode(sItemRecord), count = 1 });
	end

	if sKitType == "class" then
		CharWizardKitManager.resetClassKitItems();
		CharWizardClassManager.setStartingKitItems(tFinalItems);
	end
	if sKitType == "career" then
		CharWizardKitManager.resetCareerKitItems();
		CharWizardCareerManager.setCareerStartingKitItems(tFinalItems);
	end

	w.windowlist.window.selectionlink.setValue(sItemRecord);
end

function resetKitSelection(w)
	local bIs2024 = WindowManager.callOuterWindowFunction(w, "is2024");
	if bIs2024 then
		CharWizardKitManager.resetKitSelection2024(w)
	else
		CharWizardKitManager.resetKitSelection2014(w)
	end

	w.selection.setValue();
	w.selectionlink.setValue();
	w.button_modify.setVisible(false);

	w.list.setVisible(true);
	ListManager.refreshDisplayList(w);

	CharWizardKitManager.onEquipmentPageUpdate();
	CharWizardManager.updateAlerts();
end
function resetKitSelection2024(w)
	local sKitType = w.getKitType();
	if sKitType == "career" then
		CharWizardCareerManager.setCareerStartingKitItems();
		CharWizardCareerManager.setCareerStartingGold();
		CharWizardKitManager.onCareerWealthClear();
		CharWizardKitManager.resetCareerKitItems();
	end
	if sKitType == "class" then
		CharWizardClassManager.clearStartingKitItems();
		CharWizardClassManager.setStartingGold();
		CharWizardKitManager.onClassWealthClear();
		CharWizardKitManager.resetClassKitItems();
	end
end
function resetKitSelection2014(w)
	local sKitType = w.getKitType();
	local sItemRecord = w.selectionlink.getValue();
	local tItems = {};
	if sKitType == "class" then
		tItems = CharWizardClassManager.getStartingKitItems();
	end
	if sKitType == "career" then
		tItems = CharWizardCareerManager.getCareerStartingKitItems();
	end

	local tFinalItems = {};
	for _,v in ipairs(tItems) do
		if DB.getPath(v.item) == sItemRecord then
			if v.count > 1 then
				v.count = v.count - 1;
				table.insert(tFinalItems, v);
			end
		else
			table.insert(tFinalItems, v);
		end
	end

	if sKitType == "class" then
		CharWizardKitManager.resetClassKitItems();
		CharWizardClassManager.setStartingKitItems(tFinalItems);
	end
	if sKitType == "career" then
		CharWizardKitManager.resetCareerKitItems();
		CharWizardCareerManager.setCareerStartingKitItems(tFinalItems);
	end
end

--
--	WEALTH
--

local _bUpdateWealth = false;
function onWealthUpdate()
	if _bUpdateWealth then
		return;
	end
	_bUpdateWealth = true;

	CharWizardKitManager.onRolledWealthUpdate();
	CharWizardKitManager.onClassWealthUpdate();
	CharWizardKitManager.onCareerWealthUpdate();
	CharWizardKitManager.updateTotalWealth();

	CharWizardManager.updateAlerts();

	_bUpdateWealth = false;
end

function onRolledWealthUpdate()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end

	local bShow = CharWizardManager.hasClasses() and not CharWizardClassManager.isStartingClass2024();

	wEquipmentWealth.rolledwealth_label.setVisible(bShow);
	wEquipmentWealth.rolledwealth.setVisible(bShow);
	wEquipmentWealth.button_rolledwealth.setVisible(bShow);
	wEquipmentWealth.string_rolledwealth.setVisible(bShow);
	wEquipmentWealth.button_rolledwealth_clear.setVisible(bShow);

	if not bShow then
		wEquipmentWealth.string_rolledwealth.setValue();
		wEquipmentWealth.rolledwealth.setValue(0);
	else
		if wEquipmentWealth.string_rolledwealth.isEmpty() and CharWizardManager.hasClasses() then
			local sRoll = CharWizardClassManager.getStartingWealthRoll();
			if (sRoll or "") ~= "" then
				wEquipmentWealth.string_rolledwealth.setValue(sRoll);
			end
		end
	end
	CharWizardKitManager.updateKitVisibility();
end
function setRolledWealth(n)
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end
	wEquipmentWealth.rolledwealth.setValue(n);
end
function onRolledWealthClear()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end
	wEquipmentWealth.rolledwealth.setValue(0);
	wEquipmentWealth.string_rolledwealth.setValue("");
end
function onRolledWealthChanged(n)
	CharWizardManager.setStartingGold(n);
	CharWizardKitManager.onWealthUpdate();
end

function onCareerWealthUpdate()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end

	local bShow = (CharWizardManager.getStartingGold() == 0) and CharWizardManager.hasCareer();

	wEquipmentWealth.careerwealth_label.setVisible(bShow);
	wEquipmentWealth.careergold.setVisible(bShow);

	if not bShow then
		wEquipmentWealth.careergold.setValue(0);
	elseif wEquipmentWealth.careergold.getValue() == 0 then
		wEquipmentWealth.careergold.setValue(CharWizardCareerManager.getCareerStartingGold());
	end
end
function onCareerWealthClear()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end
	wEquipmentWealth.careergold.setValue(0);
end
function onCareerWealthChanged()
	CharWizardKitManager.onWealthUpdate();
end

function onClassWealthUpdate()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end

	local bShow = (CharWizardManager.getStartingGold() == 0) and CharWizardManager.hasClasses();

	wEquipmentWealth.classwealth_label.setVisible(bShow);
	wEquipmentWealth.classgold.setVisible(bShow);

	if not bShow then
		wEquipmentWealth.classgold.setValue(0);
	elseif wEquipmentWealth.classgold.getValue() == 0 then
		wEquipmentWealth.classgold.setValue(CharWizardClassManager.getStartingGold());
	end
end
function onClassWealthClear()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end
	wEquipmentWealth.classgold.setValue(0);
end
function onClassWealthChanged()
	CharWizardKitManager.onWealthUpdate();
end

function handleWealthRoll()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end

	local rRoll = {
		sType = "charwizardwealthroll",
		sDesc = "[STARTING WEALTH GENERATION]",
		aDice = { expr = wEquipmentWealth.string_rolledwealth.getValue():gsub("[xX]", "*"), },
		nMod = 0
	};
	ActionsManager.actionDirect(nil, "charwizardwealthroll", { rRoll }, {{}});
	return true
end
function onWealthRoll(rSource, _, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);

	CharWizardKitManager.setRolledWealth(ActionsManager.total(rRoll));
	return true;
end
function handleWealthRollClear()
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not wEquipmentWealth then
		return;
	end
	wEquipmentWealth.rolledwealth.setValue(0);
end

function setDefaultCurrencies(w)
	local tKit = CharWizardManager.getKitData();
	tKit.currency = tKit.currency or {};

	local bEdit = w.getName():match("edit");
	for _,v in pairs(CurrencyManager.getCurrencies()) do
		local wNewCurrency = w.createWindow();
		wNewCurrency.name.setValue(v);

		if not bEdit then
			table.insert(tKit.currency, { name = v, count = 0, edit = 0 });
		end
	end
end

function updateTotalWealth()
	local tKit = CharWizardManager.getKitData();
	local wEquipmentWealth = CharWizardKitManager.getWizardKitWealthWindow();
	if not tKit or not wEquipmentWealth then
		return;
	end

	local nRolledGold = wEquipmentWealth.rolledwealth.getValue();
	local nClassGold = wEquipmentWealth.classgold.getValue();
	local nCareerGold = wEquipmentWealth.careergold.getValue();
	for _,wCurrency in ipairs(wEquipmentWealth.currencylist.getWindows()) do
		local sCurrency = wCurrency.name.getValue();
		for _,vCurrency in pairs(tKit.currency or {}) do
			if vCurrency.name == sCurrency then
				local nTotal = vCurrency.edit or 0;
				if sCurrency == "GP" then
					if nRolledGold > 0 then
						nTotal = nTotal + nRolledGold;
					else
						nTotal = nTotal + nClassGold + nCareerGold;
					end
				end
				vCurrency.count = nTotal;
				wCurrency.amount.setValue(nTotal);
				break;
			end
		end
	end
end
local _bUpdateEditCurrency = false;
function updateEditWealthAmount(sCurrency, nCurrency)
	if _bUpdateEditCurrency then
		return;
	end
	_bUpdateEditCurrency = true;
	local tKit = CharWizardManager.getKitData();
	for _,v in pairs(tKit.currency or {}) do
		if v.name == sCurrency then
			v.edit = nCurrency;
			CharWizardKitManager.updateTotalWealth();
			break;
		end
	end
	_bUpdateEditCurrency = false;
end
