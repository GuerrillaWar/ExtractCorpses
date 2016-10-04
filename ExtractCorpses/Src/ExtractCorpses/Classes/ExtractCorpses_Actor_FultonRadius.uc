class ExtractCorpses_Actor_FultonRadius extends Actor;

var StaticMeshComponent	        RangeIndicator;                     //Indicates fulton range

simulated function AttachRangeIndicator(float fDiameter, StaticMesh kMesh, vector vPosition)
{
	RangeIndicator.SetStaticMesh(kMesh);
	RangeIndicator.SetScale(fDiameter / 512.0f);    // 512 is the size of the ring static mesh
	RangeIndicator.SetTranslation(vPosition);
	RangeIndicator.SetHidden(false);
}

simulated function DetachRangeIndicator()
{
	RangeIndicator.SetHidden(true);
}


defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=RangeIndicatorMeshComponent
		HiddenGame=true
		bOwnerNoSee=false
		CastShadow=false
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false
		bAcceptsDecals=false
		bAcceptsStaticDecals=false
		bAcceptsDynamicDecals=false
		bAcceptsLights=false
		//TranslucencySortPriority=1000
	End Object
	Components.Add(RangeIndicatorMeshComponent)
	RangeIndicator=RangeIndicatorMeshComponent
}