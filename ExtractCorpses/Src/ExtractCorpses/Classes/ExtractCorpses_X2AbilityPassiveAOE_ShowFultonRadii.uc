class ExtractCorpses_X2AbilityPassiveAOE_ShowFultonRadii extends X2AbilityPassiveAOEStyle config(ExtractCorpses);

var private transient array<ExtractCorpses_Actor_FultonRadius> RangeIndicators;
var private transient StaticMesh FultonMesh;
var private transient ExtractCorpses_Condition_IsFultonable FultonableCondition;
var private transient X2Condition_Visibility        MeleeVisibilityCondition;

var private config bool bShowFriendlyUnits;
var private config bool bShowCivilians;

function SetupAOEActor(const XComGameState_Ability Ability)
{
	
	local X2AbilityTemplate AbilityTemplate;
	local X2Condition Condition;
	
	//Don't allow duplicates.
	DestroyAOEActor();

	if (FultonMesh == none)
	{
		FultonMesh = StaticMesh(DynamicLoadObject("ExtractCorpses_Assets.Meshes.RadiusRing_Fulton", class'StaticMesh'));
	}

	// get the up-to-date fultonable condition
	// i can't just validate using all the conditions because of the range...
	AbilityTemplate = Ability.GetMyTemplate();
	foreach AbilityTemplate.AbilityTargetConditions(Condition)
	{
		if (Condition.IsA('ExtractCorpses_Condition_IsFultonable'))
		{
			FultonableCondition = ExtractCorpses_Condition_IsFultonable(Condition);
		}
	}
}

function DestroyAOEActor()
{
	local ExtractCorpses_Actor_FultonRadius Act;

	foreach RangeIndicators(Act)
	{
		Act.Destroy();
	}
}



function DrawAOETiles(const XComGameState_Ability Ability, const vector Location)
{
	local float FultonWorldRadius;
	local XComGameState_Unit SourceUnit, Unit;
	local StateObjectReference Player;
	local XComGameStateHistory History;

	local X2Condition Cond;
	local array<X2Condition> Conds;

	local ExtractCorpses_Actor_FultonRadius RadiusActor;
	local bool ShouldDraw;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));
	Player = SourceUnit.ControllingPlayer;
	
	// require squad visibility
	Cond = default.MeleeVisibilityCondition;
	Conds.AddItem(Cond);

	FultonWorldRadius = class'ExtractCorpses_Ability_DeployFultonHarness'.default.FULTON_EXTRACT_RANGE;

	foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		
		// not on removed units
		if( Unit.bRemovedFromPlay )
		{
			continue;
		}

		ShouldDraw = class'X2TacticalVisibilityHelpers'.static.GetTargetIDVisibleForPlayer(Unit.ObjectID, Player.ObjectID, Conds);

		// only for fultonable units
		ShouldDraw = ShouldDraw && Unit.ObjectID != SourceUnit.ObjectID && FultonableCondition.MeetsConditionWithSource(Unit, SourceUnit) == 'AA_Success';
		// only for enemies unless the friendly unit is dead OR configured
		ShouldDraw = ShouldDraw && (!(Unit.IsFriendlyUnit(SourceUnit) && Unit.IsAbleToAct()) || bShowFriendlyUnits);
		// not for civilians unless configured
		ShouldDraw = ShouldDraw && (!Unit.IsCivilian() || bShowCivilians);
		if (ShouldDraw)
		{
			RadiusActor = `BATTLE.spawn(class'ExtractCorpses_Actor_FultonRadius');
			RadiusActor.AttachRangeIndicator(2 * FultonWorldRadius, FultonMesh, `XWORLD.GetPositionFromTileCoordinates(Unit.TileLocation));
			RangeIndicators.AddItem(RadiusActor);
		}
	}
}

defaultproperties
{
	bShowFriendlyUnits=true;

	Begin Object Class=X2Condition_Visibility Name=FultonMeleeVisibilityCondition
		bRequireGameplayVisible=true
		bVisibleToAnyAlly=true
	End Object
	MeleeVisibilityCondition = FultonMeleeVisibilityCondition;
}