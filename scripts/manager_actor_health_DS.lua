-- Standard detailed health statuses
STATUS_HEALTHY = "Unscathed"; -- 0% Wounded
STATUS_LIGHT = "Light"; -- <25% Wounded
STATUS_MODERATE = "Winded"; -- <50% Wounded
STATUS_HEAVY = "Winded"; -- <75% Wounded
STATUS_CRITICAL = "Dying"; -- <100% Wounded
STATUS_DEAD = "Dead"; -- >=100% Wounded

function onInit()
	ActorManager_DS.initActorHealth();
end

function initActorHealth()
	ActorHealthManager.registerStatusHealthColor(ActorHealthManager.STATUS_UNCONSCIOUS, ColorManager.getUIColor("health_dyingordead"));

	ActorHealthManager.getWoundPercent = ActorManager5E.getWoundPercent;
end

function getWoundPercent(v)
	local rActor = ActorManager.resolveActor(v);

	local nHP = 0;
	local nWounds = 0;
	local nDeathSaveFail = 0;

	local nodeCT = ActorManager.getCTNode(rActor);
	if nodeCT then
		nHP = math.max(DB.getValue(nodeCT, "hptotal", 0), 0);
		nWounds = math.max(DB.getValue(nodeCT, "current", 0), 0);
	elseif ActorManager.isPC(rActor) then
		local nodePC = ActorManager.getCreatureNode(rActor);
		if nodePC then
			nHP = math.max(DB.getValue(nodePC, "hp.total", 0), 0);
			nWounds = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
		end
	end

	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end

	local sStatus;
	if nPercentWounded >= 1 then
		if nDeathSaveFail >= 3 then
			sStatus = ActorHealthManager.STATUS_DEAD;
		else
			sStatus = ActorHealthManager.STATUS_DYING;
		end
	else
		sStatus = ActorHealthManager.getDefaultStatusFromWoundPercent(nPercentWounded);
	end

	return nPercentWounded, sStatus;
end

function getPCSheetWoundColor(nodePC)
	local nHP = 0;
	local nWounds = 0;
	if nodePC then
		nHP = math.max(DB.getValue(nodePC, "hp.total", 0), 0);
		nWounds = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
	end

	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end

	local sColor = ColorManager.getHealthColor(nPercentWounded, false);
	return sColor;
end

function getDefaultStatusFromWoundPercent(nPercentWounded)
	local sStatus;
	if nPercentWounded <= 0 then
		sStatus = ActorHealthManager.STATUS_CRITICAL;
	elseif nPercentWounded >= 1 then
		sStatus = ActorHealthManager.STATUS_CRITICAL;
	else
		local bDetailedStatus = OptionsManager.isOption("WNDC", "detailed");

		if bDetailedStatus then
			if nPercentWounded >= .75 then
				sStatus = ActorHealthManager.STATUS_HEAVY;
			elseif nPercentWounded >= .5 then
				sStatus = ActorHealthManager.STATUS_HEAVY;
			elseif nPercentWounded >= .1 then
				sStatus = ActorHealthManager.STATUS_LIGHT;
			elseif nPercentWounded >= -.5 then
				sStatus = ActorHealthManager.STATUS_CRITICAL;
			elseif nPercentWounded < -.5
				sStatus = ActorHealthManager.STATUS_DEAD
			end
		else
			if nPercentWounded >= .5 then
				sStatus = ActorHealthManager.STATUS_SIMPLE_HEAVY;
			else
				sStatus = ActorHealthManager.STATUS_SIMPLE_WOUNDED;
			end
		end
	end
	return sStatus;
end

function getWoundPercent(v)
	local rActor = ActorManager.resolveActor(v);

	local nHP = 0;
	local nWounds = 0;
	local nDeathSaveFail = 0;

	local nodeCT = ActorManager.getCTNode(rActor);
	if nodeCT then
		nHP = math.max(DB.getValue(nodeCT, "hptotal", 0), 0);
		nWounds = math.max(DB.getValue(nodeCT, "wounds", 0), 0);
		nDeathSaveFail = DB.getValue(nodeCT, "deathsavefail", 0);
	elseif ActorManager.isPC(rActor) then
		local nodePC = ActorManager.getCreatureNode(rActor);
		if nodePC then
			nHP = math.max(DB.getValue(nodePC, "hp.total", 0), 0);
			nWounds = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
			nDeathSaveFail = DB.getValue(nodePC, "hp.deathsavefail", 0);
		end
	end

	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end

	local sStatus;
	if nPercentWounded >= 1 then
		if nDeathSaveFail >= 3 then
			sStatus = ActorHealthManager.STATUS_DEAD;
		else
			sStatus = ActorHealthManager.STATUS_DYING;
		end
	else
		sStatus = ActorHealthManager.getDefaultStatusFromWoundPercent(nPercentWounded);
	end

	return nPercentWounded, sStatus;
end

function getPCSheetWoundColor(nodePC)
	local nHP = 0;
	local nWounds = 0;
	if nodePC then
		nHP = math.max(DB.getValue(nodePC, "hp.total", 0), 0);
		nWounds = math.max(DB.getValue(nodePC, "stamina.current", 0), 0);
	end

	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end

	local sColor = ColorManager.getHealthColor(nPercentWounded, false);
	return sColor;
end

function isDyingOrDead(rActor)
	local _, sStatus = ActorHealthManager.getWoundPercent(rActor);
	return ActorHealthManager.isDyingOrDeadStatus(sStatus);
end
function isDyingOrDeadStatus(sStatus)
	return ((sStatus == ActorHealthManager.STATUS_DYING) or
			(sStatus == ActorHealthManager.STATUS_DEAD) or
			(sStatus == ActorHealthManager.STATUS_DESTROYED));
end
