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

(*DBG:char md5[] = "1a6145f8ed23171ff10195a9bb403369";*)
(*DBG:/**)
(*DBG: * This file is part of OpenPLC Runtime*)
(*DBG: **)
(*DBG: * Copyright (C) 2023 Autonomy, GP Orcullo*)
(*DBG: * Based on the work by GP Orcullo on Beremiz for uC*)
(*DBG: **)
(*DBG: * This program is free software; you can redistribute it and/or*)
(*DBG: * modify it under the terms of the GNU General Public License*)
(*DBG: * as published by the Free Software Foundation; either version 2*)
(*DBG: * of the License, or (at your option) any later version.*)
(*DBG: **)
(*DBG: * This program is distributed in the hope that it will be useful,*)
(*DBG: * but WITHOUT ANY WARRANTY; without even the implied warranty of*)
(*DBG: * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the*)
(*DBG: * GNU General Public License for more details.*)
(*DBG: **)
(*DBG: * You should have received a copy of the GNU General Public License*)
(*DBG: * along with this program; If not, see <http://www.gnu.org/licenses/>.*)
(*DBG: **)
(*DBG: */*)
(*DBG:*)
(*DBG:#include <stdbool.h>*)
(*DBG:*)
(*DBG:#include "iec_types_all.h"*)
(*DBG:#include "POUS.h"*)
(*DBG:*)
(*DBG:#define SAME_ENDIANNESS      0*)
(*DBG:#define REVERSE_ENDIANNESS   1*)
(*DBG:*)
(*DBG:uint8_t endianness;*)
(*DBG:*)
(*DBG:*)
(*DBG:extern PROGRAM0 RES0__INSTANCE0;*)
(*DBG:*)
(*DBG:static const struct {*)
(*DBG:    void *ptr;*)
(*DBG:    __IEC_types_enum type;*)
(*DBG:} debug_vars[] = {*)
(*DBG:    {&(RES0__INSTANCE0.L_T1), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.IPU1_STATE), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.S_PU1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.S_PU2), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU1_LOWLEVEL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU1_HIGHLEVEL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU2_LOWLEVEL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU2_HIGHLEVEL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.FIRSTSCAN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.HTOL), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU1_COMMAND), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PU2_COMMAND), BOOL_ENUM},*)
(*DBG:};*)
(*DBG:*)
(*DBG:#define VAR_COUNT               12*)
(*DBG:*)
(*DBG:uint16_t get_var_count(void)*)
(*DBG:{*)
(*DBG:    return VAR_COUNT;*)
(*DBG:}*)
(*DBG:*)
(*DBG:size_t get_var_size(size_t idx)*)
(*DBG:{*)
(*DBG:    if (idx >= VAR_COUNT)*)
(*DBG:    {*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case INT_ENUM:*)
(*DBG:        return sizeof(INT);*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return sizeof(BOOL);*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return sizeof(REAL);*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void *get_var_addr(size_t idx)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case INT_ENUM:*)
(*DBG:        return (void *)&((__IEC_INT_t *) ptr)->value;*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return (void *)&((__IEC_BOOL_t *) ptr)->value;*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return (void *)&((__IEC_REAL_t *) ptr)->value;*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void force_var(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    if (forced) {*)
(*DBG:        size_t var_size = get_var_size(idx);*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case INT_ENUM: {*)
(*DBG:            memcpy(&((__IEC_INT_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_INT_t *) ptr)->value = *((INT *) val);*)
(*DBG:            ((__IEC_INT_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case BOOL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_BOOL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_BOOL_t *) ptr)->value = *((BOOL *) val);*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case REAL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_REAL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_REAL_t *) ptr)->value = *((REAL *) val);*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    } else {*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case INT_ENUM:*)
(*DBG:            ((__IEC_INT_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case BOOL_ENUM:*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case REAL_ENUM:*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void swap_bytes(void *ptr, size_t size) *)
(*DBG:{*)
(*DBG:    uint8_t *bytePtr = (uint8_t *)ptr;*)
(*DBG:    size_t i;*)
(*DBG:    for (i = 0; i < size / 2; ++i) *)
(*DBG:    {*)
(*DBG:        uint8_t temp = bytePtr[i];*)
(*DBG:        bytePtr[i] = bytePtr[size - 1 - i];*)
(*DBG:        bytePtr[size - 1 - i] = temp;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void trace_reset(void)*)
(*DBG:{*)
(*DBG:    for (size_t i=0; i < VAR_COUNT; i++) *)
(*DBG:    {*)
(*DBG:        force_var(i, false, 0);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_trace(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    if (idx >= 0 && idx < VAR_COUNT) *)
(*DBG:    {*)
(*DBG:        if (endianness == REVERSE_ENDIANNESS)*)
(*DBG:        {*)
(*DBG:            // Aaaaarghhhh... Stupid AVR is Big Endian.*)
(*DBG:            swap_bytes(val, get_var_size(idx));*)
(*DBG:        }*)
(*DBG:*)
(*DBG:        force_var(idx, forced, val);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_endianness(uint8_t value)*)
(*DBG:{*)
(*DBG:    if (value == SAME_ENDIANNESS || value == REVERSE_ENDIANNESS)*)
(*DBG:    {*)
(*DBG:        endianness = value;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)