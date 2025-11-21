PROGRAM program0
  VAR_INPUT
    L_T1 : REAL;
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
  END_IF;


  (* =================================================================== *)
  (* MAIN CONTROL LOGIC - Runs every PLC scan.                         *)
  (* =================================================================== *)

  (* --- PUMP PU1 SIMPLE CONTROL --- *)
  (* This is "latching" logic. It holds its state until a setpoint is crossed. *)

  (* Logic from .INP: LINK PU1 OPEN IF NODE T1 BELOW 4 *)
  IF L_T1 <= (PU1_LowLevel + Htol) THEN
      PU1_Command := TRUE;  (* Turn ON *)
      
  (* Logic from .INP: LINK PU1 CLOSED IF NODE T1 ABOVE 6.3 *)
  ELSIF L_T1 >= (PU1_HighLevel + Htol) THEN
      PU1_Command := FALSE; (* Turn OFF *)
      
  (* IF L_T1 is between 4.0 and 6.3, PU1_Command just keeps its previous value. *)
  END_IF;


  (* --- PUMP PU2 SIMPLE CONTROL --- *)

  (* Logic from .INP: LINK PU2 OPEN IF NODE T1 BELOW 1 *)
  IF L_T1 <= (PU2_LowLevel + Htol) THEN
      PU2_Command := TRUE;  (* Turn ON *)
      
  (* Logic from .INP: LINK PU2 CLOSED IF NODE T1 ABOVE 4.5 *)
  ELSIF L_T1 >= (PU2_HighLevel + Htol) THEN
      PU2_Command := FALSE; (* Turn OFF *)
      
  (* IF L_T1 is between 1.0 and 4.5, PU2_Command keeps its previous value. *)
  END_IF;


  (* --- MAP LOGIC TO PHYSICAL OUTPUTS --- *)
  (* This writes your internal decisions to the output "mailboxes" *)

  S_PU1 := PU1_Command;
  S_PU2 := PU2_Command;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : program0;
  END_RESOURCE
END_CONFIGURATION
