// This is an Unreal Script
class ExtractCorpses_Item_FultonHarness extends X2Item config(ExtractCorpses);

var const config int FultonCharges;
var const config int FultonSupplyCost;
var const config int FultonBlackMarketCost;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateFultonHarness());
	return Items;
}

static function X2DataTemplate CreateFultonHarness()
{
	local X2WeaponTemplate Template;
	local ArtifactCost Resources;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'FultonHarness');
	Template.ItemCat = 'tech';
	Template.WeaponCat = 'utility';

	Template.InventorySlot = eInvSlot_Utility;
	Template.StowedLocation = eSlot_RearBackPack;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Medkit";
	Template.EquipSound = "StrategyUI_Medkit_Equip";

	Template.iClipSize = default.FultonCharges;
	Template.iRange = 2;
	Template.bMergeAmmo = true;

	Template.Abilities.AddItem('DeployFultonHarness');

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ChargesLabel, , default.FultonCharges); // TODO: Make the label say charges
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , 2);

	Template.GameArchetype = "WP_Medikit.WP_Medikit";

	Template.CanBeBuilt = true;
	Template.TradingPostValue = default.FultonBlackMarketCost;
	Template.PointsToComplete = 0;
	Template.Tier = 0;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.FultonSupplyCost;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}