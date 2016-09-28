// This is an Unreal Script
class ExtractCorpses_Ability_DeployFultonHarness extends X2Ability
	config(ExtractCorpses);

var float FULTON_EXTRACT_RANGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateDeployFultonHarness());
	return Templates;
}


static function X2AbilityTemplate CreateDeployFultonHarness()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Condition_UnitProperty      TargetCondition, ShooterCondition;
	local ExtractCorpses_Condition_IsFultonable		FultonableCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2AbilityCharges              Charges;
	local X2AbilityCost_Charges         ChargeCost;

	local ExtractCorpses_X2AbilityPassiveAOE_ShowFultonRadii	PassiveAOEStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DeployFultonHarness');

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = class'ExtractCorpses_Item_FultonHarness'.default.FultonCharges;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	PassiveAOEStyle = new class'ExtractCorpses_X2AbilityPassiveAOE_ShowFultonRadii';
	Template.AbilityPassiveAOEStyle = PassiveAOEStyle;

	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	Template.AddShooterEffectExclusions();

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;               
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = false;     
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = default.FULTON_EXTRACT_RANGE;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	FultonableCondition = new class'ExtractCorpses_Condition_IsFultonable';            
	Template.AbilityTargetConditions.AddItem(FultonableCondition);

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.IconImage = "img:///ExtractCorpses_Assets.UIPerk_FultonExtract";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STABILIZE_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;

	Template.ActivationSpeech = 'StabilizingAlly';

	Template.BuildNewGameStateFn = DeployFultonHarness_BuildGameState;
	Template.BuildVisualizationFn = DeployFultonHarness_BuildVisualization;

	return Template;
}

simulated function XComGameState DeployFultonHarness_BuildGameState( XComGameStateContext Context )
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit Target_OriginalState, Target_NewState;	
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect BleedOutEffect;
	local XComGameState_Item       SourceWeapon, SourceWeapon_NewState;
	local XComGameState_BaseObject SourceObject_OriginalState;
	local XComGameState_BaseObject SourceObject_NewState;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	//Build the new game state and context
	NewGameState = History.CreateNewGameState(true, Context);	
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	AbilityTemplate = AbilityState.GetMyTemplate();	
	SourceObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID);
	SourceWeapon = AbilityState.GetSourceWeapon();
	SourceObject_NewState = NewGameState.CreateStateObject(SourceObject_OriginalState.Class, AbilityContext.InputContext.SourceObject.ObjectID);
	NewGameState.AddStateObject(SourceObject_NewState);
	if (SourceWeapon != none)
	{
		SourceWeapon_NewState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', SourceWeapon.ObjectID));
		NewGameState.AddStateObject(SourceWeapon_NewState);
	}

	if (AbilityContext.InputContext.PrimaryTarget.ObjectID != 0)
	{
		Target_OriginalState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		Target_NewState = XComGameState_Unit(NewGameState.CreateStateObject(Target_OriginalState.Class, Target_OriginalState.ObjectID));

		//Trigger this ability here so that any the EvacActivated event is triggered before UnitRemovedFromPlay
		`XEVENTMGR.TriggerEvent('EvacActivated', AbilityState, Target_NewState, NewGameState); 
		`XEVENTMGR.TriggerEvent('ExtractActivated', AbilityState, Target_NewState, NewGameState); 
		
		Target_NewState.bBodyRecovered = true;
		Target_NewState.RemoveStateFromPlay();

		`XEVENTMGR.TriggerEvent( 'UnitRemovedFromPlay', Target_NewState, Target_NewState, NewGameState );			
		`XEVENTMGR.TriggerEvent( 'UnitEvacuated', Target_NewState, Target_NewState, NewGameState );			

		`XWORLD.ClearTileBlockedByUnitFlag(Target_NewState);
			
		if (Target_NewState.IsBleedingOut())
		{
			//  cleanse the effect so the unit is rendered unconscious
			BleedOutEffect = Target_NewState.GetUnitAffectedByEffectState(class'X2StatusEffects'.default.BleedingOutName);
			BleedOutEffect.RemoveEffect(NewGameState, NewGameState, true);

			// Achievement: Evacuate a soldier whose bleed-out timer is still running
			if (Target_NewState.IsAlive() && Target_NewState.IsPlayerControlled())
			{
				`ONLINEEVENTMGR.UnlockAchievement(AT_EvacRescue);
			}

		}
		NewGameState.AddStateObject(Target_NewState);
	}
	AbilityTemplate.ApplyCost(AbilityContext, AbilityState, SourceObject_NewState, SourceWeapon_NewState, NewGameState);	

	//Return the game state we have created
	return NewGameState;
}

simulated function DeployFultonHarness_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameStateHistory          History;
	local XComGameState_Unit            GameStateUnit;
	local VisualizationTrack            EmptyTrack;
	local VisualizationTrack            BuildTrack;


	History = `XCOMHISTORY;

	//Build tracks for each evacuating unit
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', GameStateUnit)
	{
		if (!GameStateUnit.bRemovedFromPlay)
			continue;

		//Start their track
		BuildTrack = EmptyTrack;
		BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(GameStateUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(GameStateUnit.ObjectID);
		BuildTrack.TrackActor = History.GetVisualizer(GameStateUnit.ObjectID);

		class'ExtractCorpses_Action_FultonExtraction'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()); 
		//class'X2Action_RemoveUnit'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext());

		//Add track to vis block
		OutVisualizationTracks.AddItem(BuildTrack);
	}
	//****************************************************************************************
}

defaultproperties
{
	FULTON_EXTRACT_RANGE=288;
}