class X2DownloadableContentInfo_ExtractCorpses extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
	`log("ExtractCorpses :: Present And Correct");
}

static function UpdateTemplates()
{
	class'ExtractCorpses_EnableCarrying'.static.UpdateCharacterArchetypes();
}

static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local ExtractCorpses_TacticalCleanup EndMissionListener;

	`log("ExtractCorpses :: Ensuring presence of tactical game state listeners");
	
	EndMissionListener = ExtractCorpses_TacticalCleanup(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'ExtractCorpses_TacticalCleanup', true));

	if (EndMissionListener == none)
	{
		EndMissionListener = ExtractCorpses_TacticalCleanup(NewGameState.CreateStateObject(class'ExtractCorpses_TacticalCleanup'));
		NewGameState.AddStateObject(EndMissionListener);
	}

	EndMissionListener.RegisterToListen();
}