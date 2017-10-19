(**
  * cckappa_sig.mli
  * openkappa
  * Jérôme Feret, projet Abstraction/Antique, INRIA Paris-Rocquencourt
  *
  * Creation: January, the 17th of 2011
  * Last modification: Time-stamp: <Aug 18 2017>
  * *
  * Signature for prepreprocessing language ckappa
  *
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et
  * en Automatique.  All rights reserved.  This file is distributed
  * under the terms of the GNU Library General Public License *)

(* eventually, each type will be abtract, no int will appear in type declaration *)


type site  = (Ckappa_sig.c_site_name, Ckappa_sig.c_site_name) Ckappa_sig.site_type

type state_dic = (unit, unit) Ckappa_sig.Dictionary_of_States.dictionary

type kappa_handler =
  {
    nrules                : int;
    nvars                 : int;
    nagents               : Ckappa_sig.c_agent_name;
    agents_dic            : Ckappa_sig.agent_dic;
    interface_constraints :
      Ckappa_sig.agent_specification
        Ckappa_sig.Agent_type_nearly_Inf_Int_storage_Imperatif.t;
    sites                 : Ckappa_sig.site_dic
        Ckappa_sig.Agent_type_nearly_Inf_Int_storage_Imperatif.t;
    states_dic            : state_dic
        Ckappa_sig.Agent_type_site_nearly_Inf_Int_Int_storage_Imperatif_Imperatif.t;
    dual                  :
      (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name * Ckappa_sig.c_state)
        Ckappa_sig.Agent_type_site_state_nearly_Inf_Int_Int_Int_storage_Imperatif_Imperatif_Imperatif.t;

    agents_sites_dic : Ckappa_sig.agent_site_dic
  }

type 'a interval = {min:'a; max:'a}

type 'state port =
  {
    site_name     : Ckappa_sig.c_site_name;
    site_position : Ckappa_sig.position;
    site_free     : bool option;
    site_state    : 'state
  }

type 'state interface = 'state port Ckappa_sig.Site_map_and_set.Map.t

type 'interface proper_agent =
  {
    agent_kasim_id  : Ckappa_sig.c_agent_id;
    agent_name      : Ckappa_sig.c_agent_name;
    agent_interface : 'interface;
    agent_position  : Ckappa_sig.position
  }

val upgrade_interface: 'a interface proper_agent -> 'b interface -> 'b interface proper_agent
val map_agent: ('a -> 'b) -> 'a interface proper_agent -> 'b interface proper_agent
val upgrade_some_interface:
  'a Ckappa_sig.Site_map_and_set.Map.t proper_agent ->
  'a option Ckappa_sig.Site_map_and_set.Map.t proper_agent

type site_address =
  {
    agent_index : Ckappa_sig.c_agent_id;
    site        : Ckappa_sig.c_site_name;
    agent_type  : Ckappa_sig.c_agent_name
  }

type bond = site_address * site_address

val build_address: Ckappa_sig.c_agent_id -> Ckappa_sig.c_agent_name ->
  Ckappa_sig.c_site_name -> site_address

module Address_map_and_set: Map_wrapper.S_with_logs with type elt = site_address

module KaSim_Site_map_and_set: Map_wrapper.S_with_logs
  with type elt = (string, string) Ckappa_sig.site_type

type agent =
  | Ghost
  | Agent of Ckappa_sig.c_state interval interface proper_agent
  | Dead_agent of Ckappa_sig.c_state interval interface proper_agent * KaSim_Site_map_and_set.Set.t * ((string, unit) Ckappa_sig.site_type) Ckappa_sig.Site_map_and_set.Map.t  * Ckappa_sig.link Ckappa_sig.Site_map_and_set.Map.t
  (* agent with a site or state that never occur in the rhs or an initial
     state, set of the undefined sites, map of sites with undefined
     internal states, map of sites with undefined binding states*)
  | Unknown_agent of (string * Ckappa_sig.c_agent_id)
  (* agent with a type that never occur in rhs or initial states *)

type agent_sig = Ckappa_sig.c_state list interface proper_agent

type views = agent Ckappa_sig.Agent_id_quick_nearly_Inf_Int_storage_Imperatif.t

type diff_views =
  Ckappa_sig.c_state
    interval
    port
    Ckappa_sig.Site_map_and_set.Map.t
    proper_agent
    Ckappa_sig.Agent_id_quick_nearly_Inf_Int_storage_Imperatif.t

type mixture =
  {
    c_mixture : Ckappa_sig.mixture;
    views     : views;
    bonds     : site_address Ckappa_sig.Site_map_and_set.Map.t
        Ckappa_sig.Agent_id_quick_nearly_Inf_Int_storage_Imperatif.t;
    plus      : (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_id) list;
    dot       : (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_id) list
  }

val rename_mixture: Remanent_parameters_sig.parameters ->
  Exception.method_handler ->
  (Remanent_parameters_sig.parameters ->
   Exception.method_handler ->
   Ckappa_sig.c_agent_id ->
   Exception.method_handler * Ckappa_sig.c_agent_id) ->
  mixture ->
  Exception.method_handler * mixture

val join_mixture: Remanent_parameters_sig.parameters ->
  Exception.method_handler ->
  (Remanent_parameters_sig.parameters ->
   Exception.method_handler ->
   Ckappa_sig.c_agent_id ->
   Exception.method_handler * Ckappa_sig.c_agent_id) ->
  (Remanent_parameters_sig.parameters ->
   Exception.method_handler ->
   Ckappa_sig.c_agent_id ->
   Exception.method_handler * Ckappa_sig.c_agent_id) ->
   mixture -> mixture ->
  Exception.method_handler * mixture

(*TODO*)
module Mixture_setmap: SetMap.S with type elt = mixture

module Mixture_map_and_set : Map_wrapper.S_with_logs with type
  elt = mixture

module MixtureAgent_map_and_set  :Map_wrapper.S_with_logs with type
  elt = (mixture * Ckappa_sig.c_agent_id)


type enriched_variable =
  {
    e_id       : string * Ckappa_sig.position ;
    e_id_dot   : string * Ckappa_sig.position ;
    c_variable : (Ckappa_sig.mixture,string) Alg_expr.e;
    e_variable : (mixture,string) Ast.variable_def
  }

type actions =
  {
    creation   : (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name) list;
    remove     : (Ckappa_sig.c_agent_id * unit interface proper_agent * Ckappa_sig.c_site_name list) list;
    release    : bond list;
    bind       : bond list;
    half_break : (site_address * (Ckappa_sig.c_state interval option)) list
  }

val empty_actions: actions

type rule =
  {
    prefix             : int;
    delta              : int;
    rule_lhs           : mixture;
    rule_rhs           : mixture;
    diff_direct        : diff_views;
    diff_reverse       : diff_views;
    actions            : actions
  }

type perturbation =
  ((((mixture,string) Alg_expr.bool) * Ckappa_sig.position) *
   (modif_expr list) *
   (((mixture,string) Alg_expr.bool * Ckappa_sig.position)  option)) *
  Ckappa_sig.position

and modif_expr =
  | INTRO    of ((mixture,string) Alg_expr.e * mixture * Ckappa_sig.position)
  | DELETE   of ((mixture,string) Alg_expr.e * mixture * Ckappa_sig.position)
  | UPDATE   of (string * Ckappa_sig.position * (mixture, string) Alg_expr.e * Ckappa_sig.position)
  (*TODO: pause*)
  | STOP     of Ckappa_sig.position
  | SNAPSHOT of Ckappa_sig.position (*maybe later of mixture too*)

type enriched_rule =
  {
    e_rule_label             : (string * Ckappa_sig.position) option;
    e_rule_label_dot         : (string * Ckappa_sig.position) option;
    e_rule_initial_direction : Ckappa_sig.direction;
    e_rule_rule              : Ckappa_sig.mixture Ckappa_sig.rule;
    e_rule_c_rule            : rule
  }

type enriched_init =
  {
    e_init_factor     : (Ckappa_sig.mixture,string) Alg_expr.e;
    e_init_c_factor   : (mixture,string) Alg_expr.e;
    e_init_string_pos : string Locality.annot option;
    e_init_mixture    : Ckappa_sig.mixture;
    e_init_c_mixture  : mixture
  }

val dummy_init: Remanent_parameters_sig.parameters -> Exception.method_handler -> Exception.method_handler * enriched_init


type compil =
  {
    variables : enriched_variable Ckappa_sig.Rule_nearly_Inf_Int_storage_Imperatif.t;
    (*pattern declaration for reusing as variable in perturbations or kinetic rate*)
    signatures : (agent_sig (** position*)) Int_storage.Nearly_inf_Imperatif.t;
    (*agent signature declaration*)
    rules : enriched_rule Ckappa_sig.Rule_nearly_Inf_Int_storage_Imperatif.t;
    (*rules (possibly named)*)
    observables :
      (mixture,string) Alg_expr.e Locality.annot Int_storage.Nearly_inf_Imperatif.t;
    (*list of patterns to plot*)
    init : enriched_init Int_storage.Nearly_inf_Imperatif.t  ;
    (*initial graph declaration*)
    perturbations :
      (mixture,rule) Ckappa_sig.perturbation Int_storage.Nearly_inf_Imperatif.t
  }
