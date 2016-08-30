// This is an Unreal Script
class ExtractCorpses_TacticalCleanup extends XComGameState_BaseObject;

var bool bRegistered;

function RegisterToListen()
{
	local Object ThisObj;
	ThisObj = self;

	if (!bRegistered)
	{
		`log("ExtractCorpses_TacticalCleanup :: TacticalEventListener Loaded");
		bRegistered = true;
		`XEVENTMGR.RegisterForEvent(ThisObj, 'TacticalGameEnd', CleanupTacticalGame, ELD_OnStateSubmitted, , , true);
	}
	else
	{
		`log("ExtractCorpses_TacticalCleanup :: Listener already present");
	}
}

function EventListenerReturn CleanupTacticalGame(Object EventData, Object EventSource, XComGameState GivenGameState, name EventID)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_BattleData BattleData;
	local XComGameState_HeadquartersXCom XComHQ;
	local int LootIndex;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Unit UnitState;
	local LootResults PendingAutoLoot;
	local Name LootTemplateName;
	local array<Name> RolledLoot;

	History = `XCOMHISTORY;
	`log("ExtractCorpses :: Recovering Evacced Enemy Corpses");
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Cleanup Tactical Mission Loot");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);

	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	// only process evacced corpses if tactical objectives are incomplete
	if( !BattleData.AllTacticalObjectivesCompleted() )
	{
		// recover all dead aliens & advent that were evacced

		ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
		foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
		{
			if( UnitState.IsAdvent() || UnitState.IsAlien() )
			{
				if ( UnitState.bBodyRecovered ) {
					class'X2LootTableManager'.static.GetLootTableManager().RollForLootCarrier(UnitState.GetMyTemplate().Loot, PendingAutoLoot);
					if( PendingAutoLoot.LootToBeCreated.Length > 0 )
					{
						foreach PendingAutoLoot.LootToBeCreated(LootTemplateName)
						{
							ItemTemplate = ItemTemplateManager.FindItemTemplate(LootTemplateName);
							RolledLoot.AddItem(ItemTemplate.DataName);
						}

					}
					PendingAutoLoot.LootToBeCreated.Remove(0, PendingAutoLoot.LootToBeCreated.Length);
					PendingAutoLoot.AvailableLoot.Remove(0, PendingAutoLoot.AvailableLoot.Length);
				}
			}
		}
	}

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	for( LootIndex = 0; LootIndex < RolledLoot.Length; ++LootIndex )
	{
		`log(" - " @ String(RolledLoot[LootIndex]));
		// create the loot item
		ItemState = ItemTemplateManager.FindItemTemplate(
			RolledLoot[LootIndex]).CreateInstanceFromTemplate(NewGameState);
		NewGameState.AddStateObject(ItemState);

		// assign the XComHQ as the new owner of the item
		ItemState.OwnerStateObject = XComHQ.GetReference();

		// add the item to the HQ's inventory of loot items
		XComHQ.PutItemInInventory(NewGameState, ItemState, true);
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}