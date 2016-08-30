# Extract Corpses

Extracted from the Guerrilla War mod, this mod allows you to carry & evac corpses.

Animations and flags are updated dynamically, so this mod can support pretty much any
humanoid Enemy Type, even those provided by other mods, so long as you add the
Character Template for that enemy type to the config.

```
[ExtractCorpses.ExtractCorpses_EnableCarrying]
+CarryableCharacterTemplates="AdvCaptainM1"
+CarryableCharacterTemplates="AdvCaptainM2"
+CarryableCharacterTemplates="AdvCaptainM3"
; ...and so on...
```

In addition there is a Fulton Harness for extracting bodies ala MGS, which does
not require an Evac Zone.

```
[ExtractCorpses.ExtractCorpses_Item_FultonHarness]
FultonCharges=2
FultonSupplyCost=35
FultonBlackMarketCost=15
```
