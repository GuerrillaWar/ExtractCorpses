class ExtractCorpses_EnableCarrying extends UIScreenListener
	dependson(XComContentManager, X2CharacterTemplateManager)
	config(ExtractCorpses);

var const config array<name> CarryableCharacterTemplates;
var const config array<name> CarryableCharacterGroups;

event OnInit(UIScreen Screen)
{
	UpdateCharacterArchetypes();
}

static function UpdateCharacterArchetypes()
{
	local X2CharacterTemplateManager Manager;
	local name CharTemplateName;
	local X2DataTemplate IterTemplate;
	local X2CharacterTemplate CharTemplate;

	Manager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	`log("ExtractCorpses :: Updating Character Templates for Carrying");
	foreach default.CarryableCharacterTemplates(CharTemplateName) {
		`log("  - " @ CharTemplateName);
		UpdateCharacterForCarrying(Manager.FindCharacterTemplate(CharTemplateName));
	}

	foreach Manager.IterateTemplates(IterTemplate, none)
	{
		CharTemplate = X2CharacterTemplate(IterTemplate);

		if (default.CarryableCharacterGroups.Find(CharTemplate.CharacterGroupName) != -1 &&
			default.CarryableCharacterTemplates.Find(CharTemplate.DataName) == -1)
		{
			`log("  - " @ CharTemplate.DataName @ " from " @ CharTemplate.CharacterGroupName);
			UpdateCharacterForCarrying(CharTemplate);
		}
	}
}

static function UpdateCharacterForCarrying(X2CharacterTemplate Template)
{
	local string ArchetypeIdentifier;
	local XComAlienPawn APawn;
	local XComContentManager ContentMgr;
	ContentMgr = `CONTENT;

	Template.bCanBeCarried = true;
	class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().AddCharacterTemplate(Template, true);

	foreach Template.strPawnArchetypes(ArchetypeIdentifier)
	{
		`log("  -- " @ ArchetypeIdentifier);
		APawn = XComAlienPawn(ContentMgr.RequestGameArchetype(ArchetypeIdentifier));
		APawn.CarryingUnitAnimSets.AddItem(AnimSet'Soldier_ANIM.Anims.AS_Carry');
		APawn.BeingCarriedAnimSets.AddItem(AnimSet'Soldier_ANIM.Anims.AS_Body');
	}
}

defaultproperties
{
	ScreenClass = class'UIMessageMgr';
}  