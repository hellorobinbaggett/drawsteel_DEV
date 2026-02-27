--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	setColor(ColorManager.getButtonTextColor());
	if Session.IsHost then
		registerMenuItem(Interface.getString("ct_menu_initmenu"), "turn", 7);
		registerMenuItem(Interface.getString("ct_menu_initreset"), "pointer_circle", 7, 4);

		registerMenuItem(Interface.getString("ct_menu_itemdelete"), "delete", 3);
		registerMenuItem(Interface.getString("ct_menu_itemdeletenonfriendly"), "delete", 3, 1);
		registerMenuItem(Interface.getString("ct_menu_itemdeleteall"), "delete", 3, 2);

		registerMenuItem(Interface.getString("ct_menu_effectdelete"), "hand", 5);
		registerMenuItem(Interface.getString("ct_menu_effectdeleteall"), "pointer_circle", 5, 7);
	end
end

function onMenuSelection(selection, subselection)
	if Session.IsHost then
		if selection == 7 then
			if subselection == 4 then
				CombatManagerDS.resetInit();
			end
		elseif selection == 3 then
			if subselection == 1 then
				CombatManagerDS.deleteNonFaction("friend");
                CombatManagerDS.deleteFaction("foe");
			end
			if subselection == 2 then
				CombatManagerDS.deleteFaction("foe");
				CombatManagerDS.deleteFaction("friend");
			end
		elseif selection == 5 then
			if subselection == 7 then
				CombatManager.resetCombatantEffects();
			end
		end
	end
end
