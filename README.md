# Extract Corpses

Extracted from the Guerrilla War mod, this mod allows you to carry & evac corpses.

Animations and flags are updated dynamically, so this mod can support pretty much any
humanoid Enemy Type, even those provided by other mods.
Most of them will be automatically be picked up by the CharacterGroupName,
but you can add your own ones (and individual Templates too.)

```
[ExtractCorpses.ExtractCorpses_EnableCarrying]
+CarryableCharacterGroups="AdventCaptain"
+CarryableCharacterGroups="AdventMEC"
+CarryableCharacterGroups="AdventTrooper"
; ...and so on...
+CarryableCharacterTemplates="Sectoid"
```

In addition there is a Fulton Harness for extracting bodies ala MGS, which does
not require an Evac Zone.

```
[ExtractCorpses.ExtractCorpses_Item_FultonHarness]
FultonCharges=2
FultonSupplyCost=35
FultonBlackMarketCost=15
```
