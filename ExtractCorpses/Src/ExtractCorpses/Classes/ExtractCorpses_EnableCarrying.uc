class ExtractCorpses_EnableCarrying extends UIScreenListener
	dependson(XComContentManager, X2CharacterTemplateManager)
	config(ExtractCorpses);

var const config array<name> CarryableCharacterTemplates;

event OnInit(UIScreen Screen)
{
	UpdateCharacterArchetypes();
}

static function UpdateCharacterArchetypes()
{
	local X2CharacterTemplateManager Manager;
	local name CharTemplate;

	Manager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	`log("ExtractCorpses :: Updating Character Templates for Carrying");
	foreach default.CarryableCharacterTemplates(CharTemplate) {
		`log("  - " @ CharTemplate);
		UpdateCharacterForCarrying(Manager.FindCharacterTemplate(CharTemplate));
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