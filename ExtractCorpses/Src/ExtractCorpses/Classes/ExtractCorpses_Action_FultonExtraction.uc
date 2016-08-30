// This is an Unreal Script
//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor.
//-----------------------------------------------------------
class ExtractCorpses_Action_FultonExtraction extends X2Action;

var private XComGameStateContext_Falling FallingContext;
var private XComGameState_Unit NewUnitState;


var private XComWorldData WorldData;
var private vector Force, Hit;



function Init(const out VisualizationTrack InTrack)
{
	super.Init( InTrack );
	WorldData = `XWORLD;

	NewUnitState = XComGameState_Unit(InTrack.StateObject_NewState);
}


function CompleteAction()
{
	super.CompleteAction();
	//`CAMERASTACK.RemoveCamera(FallingCamera);//RAM - disable until more testing
}

//------------------------------------------------------------------------------------------------
simulated state Executing
{
	simulated event EndState( name nmNext )
	{
		if (IsTimedOut()) // just in case something went wrong, get the pawn into the proper state
		{
			UnitPawn.EndRagDoll( );
		}
	}

Begin:


	Force.Z = 100000;
	UnitPawn.ApplyImpulseToPhysicsActor(UnitPawn, Force, Hit);

	Sleep(4.0f); // let them ragdoll for a bit, for effect.

	CompleteAction();
}


defaultproperties
{
	TimeoutSeconds = 10.0f
}