(**
  * remanent_state.ml
  * openkappa
  * Jérôme Feret, projet Abstraction/Antique, INRIA Paris-Rocquencourt
  *
  * Creation: June, the 25th of 2016
  * Last modification: June, the 25th of 2016
  * *
  *
  * Copyright 2010,2011 Institut National de Recherche en Informatique et
  * en Automatique.  All rights reserved.  This file is distributed
  * under the terms of the GNU Library General Public License *)

type init = Compil of ((string Location.annot) * Ast.port list, Ast.mixture, string, Ast.rule) Ast.compil | Files of string list
type accuracy_level = Low | Medium | High | Full

module AccuracySetMap =
  SetMap.Make
    (struct
      type t = accuracy_level
      let compare a b =
        match
          a,b
        with
        | Low,Low -> 0
        | Low,_ -> -1
        | _,Low -> 1
        | Medium,Medium -> 0
        | Medium,_ -> -1
        | _,Medium -> 1
        | High, High -> 0
        | High,_ -> -1
        | _,High -> 1
        | Full,Full -> 0

      let print f = function
        | Full -> Format.fprintf f "Full"
        | High -> Format.fprintf f "High"
        | Medium -> Format.fprintf f "Medium"
        | Low -> Format.fprintf f "Low"
    end)

module AccuracyMap = AccuracySetMap.Map


type compilation = ((string Location.annot) * Ast.port list, Ast.mixture, string, Ast.rule) Ast.compil

type refined_compilation = (Ckappa_sig.agent, Ckappa_sig.mixture, string, Ckappa_sig.direction * Ckappa_sig.mixture Ckappa_sig.rule) Ast.compil

type quark_map = Quark_type.quarks

type rule_id = int
type var_id =  int


type influence_node =
  | Rule of rule_id
  | Var of var_id

module InfluenceNodeSetMap =
  SetMap.Make
    (struct
      type t = influence_node
      let compare = compare
      let print f = function
        | Rule r -> Format.fprintf f "Rule %i" r
        | Var r -> Format.fprintf f "Var %i" r
    end)

module InfluenceNodeMap = InfluenceNodeSetMap.Map

type internal_influence_map =
  Quark_type.Labels.label_set_couple Ckappa_sig.PairRule_setmap.Map.t
  * Quark_type.Labels.label_set_couple Ckappa_sig.PairRule_setmap.Map.t

type location =
  | Direct of int
  | Side_effect of int

type 'a pair = 'a * 'a

type influence_map =
  {
    positive: location pair list InfluenceNodeMap.t InfluenceNodeMap.t ;
    negative: location pair list InfluenceNodeMap.t InfluenceNodeMap.t ;
  }

type contact_map =
  ((string list) * (string*string) list) Mods.StringMap.t Mods.StringMap.t

type state =
  {
    parameters    : Remanent_parameters_sig.parameters  ;
    log_info : StoryProfiling.StoryStats.log_info;
    handler       : Cckappa_sig.kappa_handler option ;
    init : init ;
    compilation   : compilation option ;
    refined_compilation : refined_compilation option ;
    c_compil : Cckappa_sig.compil option ;
    quark_map: quark_map option ;
    internal_influence_map:
      (Quark_type.Labels.label_set_couple Ckappa_sig.PairRule_setmap.Map.t *
       Quark_type.Labels.label_set_couple Ckappa_sig.PairRule_setmap.Map.t)
        AccuracyMap.t ;
    influence_map : influence_map AccuracyMap.t ;
    contact_map   : contact_map AccuracyMap.t ;
    signature     : Signature.s option;
    errors        : Exception.method_handler ;
  }

let create_state ?errors parameters init =
  {
    parameters = parameters;
    log_info = StoryProfiling.StoryStats.init_log_info ();
    handler = None ;
    init = init ;
    compilation = None ;
    refined_compilation = None ;
    c_compil = None ;
    quark_map = None ;
    internal_influence_map = AccuracyMap.empty ;
    influence_map = AccuracyMap.empty ;
    contact_map = AccuracyMap.empty ;
    signature = None ;
    errors =
      match errors
      with None ->
        Exception.empty_error_handler
         | Some errors -> errors      ;
  }

let do_event_gen f phase n state =
  let error, log_info =
    f
      state.parameters
      state.errors
      phase
      n
      state.log_info
  in
  {state with errors = error ; log_info = log_info}

let add_event = do_event_gen StoryProfiling.StoryStats.add_event
let close_event = do_event_gen StoryProfiling.StoryStats.close_event

let set_parameters parameters state = {state with parameters = parameters}
let get_parameters state = state.parameters
let get_init state = state.init
let set_compilation compilation state = {state with compilation = Some compilation}
let get_compilation state = state.compilation
let set_handler handler state = {state with handler = Some handler}
let get_handler state = state.handler
let set_compil compil state = {state with compilation = compil}
let get_compil state = state.compilation
let set_c_compil c_compil state = {state with c_compil = Some c_compil}
let get_c_compil state = state.c_compil
let set_refined_compil refined_compil state =
  {state with refined_compilation = Some refined_compil}
let get_refined_compil state = state.refined_compilation
let set_errors errors state = {state with errors = errors }
let get_errors state = state.errors
let set_quark_map quark_map state =
  {state with quark_map = Some quark_map}
let get_quark_map state = state.quark_map
let set_contact_map accuracy map state =
  {state with contact_map = AccuracyMap.add accuracy map state.contact_map}
let get_contact_map accuracy state =
  AccuracyMap.find_option accuracy state.contact_map
let set_signature signature state = {state with signature = Some signature}
let get_signature state = state.signature

let set_influence_map accuracy map state =
  {state with influence_map = AccuracyMap.add accuracy map state.influence_map}
let get_influence_map accuracy state =
  AccuracyMap.find_option accuracy state.influence_map
let set_internal_influence_map accuracy map state =
  {state
   with internal_influence_map =
          AccuracyMap.add accuracy map state.internal_influence_map}
let get_internal_influence_map accuracy state =
  AccuracyMap.find_option accuracy state.internal_influence_map

let get_influence_map_map state = state.influence_map
let get_contact_map_map state = state.contact_map