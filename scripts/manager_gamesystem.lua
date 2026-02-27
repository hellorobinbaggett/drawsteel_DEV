--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = true },
	["table"] = { },
	["powerroll"] = { sTargeting = "each" },
	["save"] = { sTargeting = "each" },
	["death"] = { bUseModStack = true },
	["death_auto"] = { },
	["damage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
    ["effect"] = { sIcon = "action_effect", sTargeting = "all" },
};

targetactions = {
	"cast",
	"powersave",
	"attack",
	"damage",
	"heal",
	"effect"
};

currencyDefault = "GP";

function onInit()
	DiceManager.setDefaultDisabledDesktopDice({ "d4", "d8", "d12", "d20", });

	-- Languages
	languages = {
		-- Human languages
		[Interface.getString("language_value_uvalic")] = "",
        [Interface.getString("language_value_higaran")] = "Dynastic",
        [Interface.getString("language_value_oaxuatl")] = "",
        [Interface.getString("language_value_khemaric")] = "Hieroglyphs",
        [Interface.getString("language_value_khoursirian")] = "",
        [Interface.getString("language_value_phaedran")] = "",
        [Interface.getString("language_value_riojan")] = "",
        [Interface.getString("language_value_vanric")] = "",
        [Interface.getString("language_value_vaslorian")] = "",
        -- Standard languages
        [Interface.getString("language_value_anjali")] = "Infernal",
        [Interface.getString("language_value_axiomatic")] = "Cybertronian",
        [Interface.getString("language_value_caelian")] = "",
        [Interface.getString("language_value_filliaric")] = "Filliaric",
        [Interface.getString("language_value_thefirstlanguage")] = "Primordial",
        [Interface.getString("language_value_hyrallic")] = "Quenya",
        [Interface.getString("language_value_illyvric")] = "Drow",
        [Interface.getString("language_value_kalliak")] = "Dwarven",
        [Interface.getString("language_value_kethaic")] = "Draconic",
        [Interface.getString("language_value_khelt")] = "Celestial",
        [Interface.getString("language_value_khoursirian")] = "",
        [Interface.getString("language_value_highkuric")] = "Norse",
        [Interface.getString("language_value_lowkuric")] = "Norse",
        [Interface.getString("language_value_mindspeech")] = "invisible",
        [Interface.getString("language_value_protoctholl")] = "Draconic",
        [Interface.getString("language_value_szetch")] = "Drow",
        [Interface.getString("language_value_tholl")] = "Draconic",
        [Interface.getString("language_value_urollialic")] = "Abyssal",
        [Interface.getString("language_value_variac")] = "Drow",
        [Interface.getString("language_value_vastariax")] = "Draconic",
        [Interface.getString("language_value_vhoric")] = "Norse",
        [Interface.getString("language_value_voll")] = "Timescape",
        [Interface.getString("language_value_yllyric")] = "Celestial",
        [Interface.getString("language_value_zahariax")] = "Cybertronian",
        [Interface.getString("language_value_zaliac")] = "Dwarven",

		-- Exotic languages
		[Interface.getString("language_value_ananjali")] = "Infernal",
        [Interface.getString("language_value_high_rhyvian")] = "Quenya",
        [Interface.getString("language_value_khamish")] = "",
        [Interface.getString("language_value_kheltivari")] = "",
        [Interface.getString("language_value_low_rhyvian")] = "Quenya",
        [Interface.getString("language_value_old_variac")] = "",
        [Interface.getString("language_value_phorialtic")] = "",
        [Interface.getString("language_value_rallarian")] = "",
        [Interface.getString("language_value_ullorvic")] = "",

	};

    languagefonts = {
		["Common"] = "Common",
		["Abyssal"] = "Abyssal",
		["Arabian"] = "Arabian",
		["Celestial"] = "Celestial",
		["Cuneiform"] = "Cuneiform",
		["Cybertronian"] = "Cybertronian",
		["Dovakhiin"] = "Dovakhiin",
		["Draconic"] = "Draconic",
		["Drow"] = "Drow",
		["Dwarven"] = "Dwarven",
		["Dynastic"] = "Dynastic",
		["Elven"] = "Elven",
		["Esoteric"] = "Esoteric",
		["Hieroglyphs"] = "Hieroglyphs",
		["Hindi"] = "Hindi",
		["Infernal"] = "Infernal",
		["Invisible"] = "invisible",
		["Metal"] = "Metal",
		["Norse"] = "Norse",
		["Primordial"] = "Primordial",
		["Quenya"] = "Quenya",
		["Runes"] = "Runes",
		["Timescape"] = "Timescape"
	}	
    
	languagestandard = {
		Interface.getString("language_value_caelian"),

	};
end

function getCharSelectDetailHost(nodeChar)
	local sValue = "";
	local nLevel = DB.getValue(nodeChar, "level", 0);
	if nLevel > 0 then
		sValue = "Level " .. math.floor(nLevel*100)*0.01;
	end
	return sValue;
end

function requestCharSelectDetailClient()
	return "name,#level";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], "Level " .. math.floor(vDetails[2]*100)*0.01;
end

function getPregenCharSelectDetail(nodePregenChar)
	return CharManager.getClassSummary(nodePregenChar);
end

function getDistanceUnitsPerGrid()
	return 1;
end