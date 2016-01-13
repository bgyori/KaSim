(**
  * print_bdu_analysis.ml
  * openkappa
  * Jérôme Feret & Ly Kim Quyen, projet Abstraction, INRIA Paris-Rocquencourt
  * 
  * Creation: 2015, the 28th of October
  * Last modification: 
  * 
  * Print relations between sites in the BDU data structures
  * 
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et   
  * en Automatique.  All rights reserved.  This file is distributed     
  * under the terms of the GNU Library General Public License *)

open Printf
open Remanent_parameters_sig
open Cckappa_sig
open Bdu_analysis_type
open Fifo

let warn parameters mh message exn default =
  Exception.warn parameters mh (Some "BDU fixpoint iteration") message exn
    (fun () -> default)  

let trace = false

(************************************************************************************)
(*syntactic contact map*)

(*let print_contact_map_aux parameter error handler_kappa result =
  Int2Map_CM_Syntactic.Map.iter (fun set1 set2 ->
    Set_triple.Set.iter (fun (agent1, site1, state1) ->
      Set_triple.Set.iter (fun (agent2, site2, state2) ->
        let error, agent_string1 =
          Handler.string_of_agent parameter error handler_kappa agent1
        in
        let error, site_string1 =
          Handler.string_of_site_contact_map parameter error handler_kappa agent1 site1
        in
        let error, state_string1 =
          Handler.string_of_state parameter error handler_kappa agent1 site1 state1
        in
        let error, agent_string2 =
          Handler.string_of_agent parameter error handler_kappa agent2
        in
        let error, site_string2 =
          Handler.string_of_site_contact_map parameter error handler_kappa agent2 site2
        in
        let error, state_string2 =
          Handler.string_of_state parameter error handler_kappa agent2 site2 state2
        in
        fprintf stdout "agent_type:%i:%s@site_type:%i:%s:state:%i(%s)--agent_type':%i:%s@site_type':%i:%s:state':%i(%s)\n"
          agent1 agent_string1 site1 site_string1 state1 state_string1
          agent2 agent_string2 site2 site_string2 state2 state_string2
      ) set2
    )set1
  ) result    

let print_contact_map parameter error handler_kappa result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "(Syntactic) Contact map and initital state:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "Sites are annotated with the id of binding type:\n";
  let error =
    print_contact_map_aux
      parameter
      error
      handler_kappa
      result
  in
  error*)

(************************************************************************************)
(*dynamic contact map full information*)

let print_contact_map_full_aux parameter error handler_kappa result =
  Int2Map_CM_state.Map.iter (fun (agent1, site1, state1) set ->
    Set_triple.Set.iter (fun (agent2, site2, state2) ->
      let error, agent_string1 =
        Handler.string_of_agent parameter error handler_kappa agent1
      in
      let error, site_string1 =
        Handler.string_of_site_contact_map parameter error handler_kappa agent1 site1
      in
      let error, state_string1 =
        Handler.string_of_state parameter error handler_kappa agent1 site1 state1
      in
      let error, agent_string2 =
        Handler.string_of_agent parameter error handler_kappa agent2
      in
      let error, site_string2 =
        Handler.string_of_site_contact_map parameter error handler_kappa agent2 site2
      in
      let error, state_string2 =
        Handler.string_of_state parameter error handler_kappa agent2 site2 state2
      in
      fprintf stdout "agent_type:%i:%s@site_type:%i:%s:state:%i(%s)--agent_type':%i:%s@site_type':%i:%s:state':%i(%s)\n" 
        agent1 agent_string1 
        site1 site_string1 
        state1 state_string1
        agent2 agent_string2 
        site2 site_string2
        state2 state_string2
    ) set
  ) result

let print_contact_map_full parameter error handler_kappa result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "(Full) Contact map and initital state:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "Sites are annotated with the id of binding type:\n";
  let error =
    print_contact_map_full_aux
      parameter
      error
      handler_kappa
      result
  in
  error

(************************************************************************************)
(*print init map*)

(*let print_init_map_aux parameter error handler_kappa result =
  Int2Map_CM_Syntactic.Map.iter 
    (fun set1 set2 ->
      Set_triple.Set.iter (fun (agent_type, site_type, state) ->
        Set_triple.Set.iter (fun (agent_type', site_type', state') ->
          fprintf stdout "agent_type:%i:site_type:%i:state:%i - > agent_type':%i:site_type':%i:state':%i\n"
            agent_type site_type state
            agent_type' site_type' state'
        ) set2
      ) set1
    ) result

let print_init_map parameter error handler_kappa result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    " Contact map in the initital state:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "Sites are annotated with the id of binding type:\n";
  let error =
    print_init_map_aux
      parameter
      error
      handler_kappa
      result
  in
  error*)

(************************************************************************************)
(*syntactic contact map and init map*)

let print_syn_map_aux parameter error handler_kappa result =
  Int2Map_CM_Syntactic.Map.iter 
    (fun set1 set2 ->
      Set_triple.Set.iter (fun (agent_type, site_type, state) ->
        let error, agent_string =
          Handler.string_of_agent parameter error handler_kappa agent_type
        in
        let error, site_string =
          Handler.string_of_site_contact_map
            parameter error handler_kappa agent_type site_type
        in
        let error, state_string =
          Handler.string_of_state parameter error handler_kappa agent_type site_type state
        in
        Set_triple.Set.iter (fun (agent_type', site_type', state') ->
          let error, agent_string' =
            Handler.string_of_agent parameter error handler_kappa agent_type'
          in
          let error, site_string' =
            Handler.string_of_site_contact_map
              parameter error handler_kappa agent_type' site_type'
          in
          let error, state_string' =
            Handler.string_of_state parameter error handler_kappa 
              agent_type' site_type' state'
          in
          fprintf stdout "agent_type:%i:%s:site_type:%i:%s:state:%i(%s) - > agent_type':%i:%s:site_type':%i:%s:state':%i(%s)\n"
            agent_type agent_string
            site_type site_string
            state state_string
            agent_type' agent_string'
            site_type' site_string'
            state' state_string'
        ) set2
      ) set1
    ) result

let print_syn_map parameter error handler_kappa result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "(Syntactic) Contact map and initital state:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "Sites are annotated with the id of binding type:\n";
  let error =
    print_syn_map_aux
      parameter
      error
      handler_kappa
      result
  in
  error

(************************************************************************************)
(*update (c) function*)

let print_covering_classes_modification_aux parameter error handler_kappa compiled result =
  Int2Map_CV_Modif.Map.iter
    ( fun (agent_type, y) (_, s2) ->
      let error, agent_string =
        Handler.string_of_agent parameter error handler_kappa agent_type
      in
      let _ =
        fprintf parameter.log
          "agent_type:%i:%s:covering_class_id:%i:@set of rule_id:\n" 
          agent_type agent_string y
      in
      Site_map_and_set.Set.iter
        (fun rule_id ->
        (*mapping rule_id of type int to string*)
          let error, rule_id_string =
            Handler.string_of_rule parameter error handler_kappa
              compiled rule_id
          in
          fprintf parameter.log "%s\n" rule_id_string
        ) s2
    ) result

let print_covering_classes_modification parameter error handler_kappa compiled result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "List of rules to awake when the state of a site is modified and tested:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  print_covering_classes_modification_aux
    parameter
    error
    handler_kappa
    compiled
    result
    
(************************************************************************************)
(*update(c'), when discovered a bond for the first time*)

let print_covering_classes_side_effects parameter error handler_kappa compiled result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "List of rules to awake when the state of a site is modified and tested and side effects:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  print_covering_classes_modification_aux
    parameter
    error
    handler_kappa
    compiled
    result

(************************************************************************************)
(*Final update function*)

let print_covering_classes_update_full parameter error handler_kappa compiled result =
  fprintf (Remanent_parameters.get_log parameter)
    "\n------------------------------------------------------------\n";
  fprintf (Remanent_parameters.get_log parameter)
    "Final list of rules to awake when the state of a site is modified and tested and side effects:\n";
  fprintf (Remanent_parameters.get_log parameter)
    "------------------------------------------------------------\n";
  print_covering_classes_modification_aux
    parameter
    error
    handler_kappa
    compiled
    result

(************************************************************************************)
(*main print*)

let print_result_dynamic parameter error handler_kappa compiled result =
  let _ =
    fprintf (Remanent_parameters.get_log parameter)
      "============================================================\n";
    fprintf (Remanent_parameters.get_log parameter) "* BDU Analysis:\n";
    fprintf (Remanent_parameters.get_log parameter)
      "============================================================\n";
    fprintf (Remanent_parameters.get_log parameter) 
      "\n** Dynamic information:\n";
    (*------------------------------------------------------------------------------*)
    let _ =
      print_contact_map_full
        parameter
        error
        handler_kappa
        result.store_contact_map_full
    in
    (*------------------------------------------------------------------------------*)
    let _ =
      print_syn_map
        parameter
        error
        handler_kappa
        result.store_syn_contact_map_full
    in
    (*------------------------------------------------------------------------------*)
    let _ =
      print_covering_classes_modification
        parameter
        error
        handler_kappa
        compiled
        result.store_covering_classes_modification_update
    in
    (*------------------------------------------------------------------------------*)
    let _ =
      print_covering_classes_side_effects
        parameter
        error
        handler_kappa
        compiled
        result.store_covering_classes_modification_side_effects
    in
    (*------------------------------------------------------------------------------*)
    let _ =
      print_covering_classes_update_full
        parameter
        error
        handler_kappa
        compiled
        result.store_covering_classes_modification_update_full
    in
    error
  in
  error
