PROGRAM program0
  VAR_INPUT
    L_T1 : REAL;
    iPU1_State : INT := 10;
  END_VAR
  VAR_OUTPUT
    S_PU1 : BOOL;
    S_PU2 : BOOL;
  END_VAR
  VAR
    PU1_LowLevel : REAL := 4.0;
    PU1_HighLevel : REAL := 6.3;
    PU2_LowLevel : REAL := 1.0;
    PU2_HighLevel : REAL := 4.5;
    FirstScan : BOOL := TRUE;
    Htol : REAL := 0.0005;
    PU1_Command : BOOL;
    PU2_Command : BOOL;
  END_VAR

  (* =================================================================== *)
    (* INITIALIZATION LOGIC - Run once to set a safe startup state.      *)
    (* =================================================================== *)
    IF FirstScan THEN
        FirstScan := FALSE;
        
        (* Start with pumps OFF *)
        PU1_Command := FALSE;
        PU2_Command := FALSE;
        
        (* Initialize FSM to OFF state *)
        iPU1_State := 10;
    END_IF;


    (* =================================================================== *)
    (* MAIN CONTROL LOGIC - Runs every PLC scan.                         *)
    (* =================================================================== *)

    (* ----------------------------------------------------------------- *)
    (* FSM CONTROL - PUMP PU1 (2-State Latching)                         *)
    (* ----------------------------------------------------------------- *)
    CASE iPU1_State OF

        (* STATE 10: OFF - Waiting for level to drop *)
        10:
            PU1_Command := FALSE; (* Action: Turn OFF *)
            
            (* Transition: L_T1 drops below low level *)
            IF L_T1 <= (PU1_LowLevel + Htol) THEN
                iPU1_State := 20; (* Transition to ON state *)
            END_IF;

        (* STATE 20: ON - Waiting for level to rise *)
        20:
            PU1_Command := TRUE; (* Action: Turn ON *)
            
            (* Transition: L_T1 rises above high level *)
            IF L_T1 >= (PU1_HighLevel + Htol) THEN
                iPU1_State := 10; (* Transition to OFF state *)
            END_IF;

        (* Default/Error Handling *)
        ELSE
            (* Reset to a safe state if an invalid state number is encountered *)
            iPU1_State := 10; 
            PU1_Command := FALSE;
            
    END_CASE;


    (* ----------------------------------------------------------------- *)
    (* SEQUENTIAL IF/ELSIF CONTROL - PUMP PU2 (Latching)                 *)
    (* This logic remains in the original format.                        *)
    (* ----------------------------------------------------------------- *)
    
    (* Logic from .INP: LINK PU2 OPEN IF NODE T1 BELOW 1 *)
    IF L_T1 <= (PU2_LowLevel + Htol) THEN
        PU2_Command := TRUE;  (* Turn ON *)
        
    (* Logic from .INP: LINK PU2 CLOSED IF NODE T1 ABOVE 4.5 *)
    ELSIF L_T1 >= (PU2_HighLevel + Htol) THEN
        PU2_Command := FALSE; (* Turn OFF *)
        
    (* ELSE: PU2_Command keeps its previous value (latching). *)
    END_IF;


    (* ----------------------------------------------------------------- *)
    (* MAP LOGIC TO PHYSICAL OUTPUTS                                     *)
    (* ----------------------------------------------------------------- *)

    S_PU1 := PU1_Command;
    S_PU2 := PU2_Command;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : program0;
  END_RESOURCE
END_CONFIGURATION