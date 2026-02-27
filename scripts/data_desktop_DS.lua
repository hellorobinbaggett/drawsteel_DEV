--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	-- registerPublicNodes
	SPECIAL_MSGTYPE_REFRESHDESTINYCHITS_GM = "refreshdestinychits_gm";
	if Session.IsHost then
		DB.createNode("StoryPointPCchit").setPublic(true);
		DB.createNode("StoryPointGMchit").setPublic(true);
		-- PartyVehicleManager.buildPartySharedVehicles();
	end
	local msgOOB = {};
	msgOOB.type = SPECIAL_MSGTYPE_REFRESHDESTINYCHITS_GM;
	Comm.deliverOOBMessage(msgOOB);
end

-- Shown in Modifiers window
-- NOTE: Set strings for "modifier_category_*" and "modifier_label_*"
_tModifierWindowPresets =
{
	{
		sCategory = "attack",
		tPresets =
		{
			"ATT_OPP",
			"DEF_COVER",
			"",
			"DEF_SCOVER",
		},
	},
	{
		sCategory = "damage",
		tPresets = {
			"DMG_CRIT",
			"DMG_MAX",
			"",
			"DMG_HALF",
		}
	},
};
_tModifierExclusionSets =
{
	{ "DEF_COVER", "DEF_SCOVER" },
};
