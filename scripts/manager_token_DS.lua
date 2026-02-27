--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	TokenManager.addDefaultHealthFeatures(nil, {"hptotal", "hptemp", "wounds", "deathsavefail"});

	TokenManager.addEffectTagIconConditional("IF", TokenManager_DS.handleIFEffectTag);
	TokenManager.addEffectTagIconSimple("IFT", "");
	TokenManager.addEffectTagIconBonus(DataCommon.bonuscomps);
	TokenManager.addEffectTagIconSimple(DataCommon.othercomps);
	TokenManager.addEffectConditionIcon(DataCommon.condcomps);
	TokenManager.addDefaultEffectFeatures(nil, EffectManager_DS.parseEffectComp);
end

function handleIFEffectTag(rActor, nodeEffect, vComp)
	return EffectManager_DS.checkConditional(rActor, nodeEffect, vComp.remainder);
end
