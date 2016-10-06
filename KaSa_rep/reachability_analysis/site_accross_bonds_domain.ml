(**
   * site_accross_bonds_domain.ml
   * openkappa
   * Jérôme Feret & Ly Kim Quyen, projet Abstraction, INRIA Paris-Rocquencourt
   *
   * Creation: 2016, the 31th of March
   * Last modification: Time-stamp: <Sep 26 2016>
   *
   * Abstract domain to record relations between pair of sites in connected agents.
   *
   * Copyright 2010,2011,2012,2013,2014,2015,2016 Institut National de Recherche
   * en Informatique et en Automatique.
   * All rights reserved.  This file is distributed
   * under the terms of the GNU Library General Public License *)

let local_trace = false

module Domain =
struct

  (* the type of the struct that contains all static information as in the
     previous version of the analysis *)

  (*************************************************************************)
  (* Domain specific info:
     Collect the set of tuples (A,x,y,B,z,t) such that there exists a rule
     with a bond connecting the site A.x and B.z and that the agent of type A
     document a site y <> x, and the agent of type B document a site t <> z
     - For each tuple, collect three maps -> (A,x,y,B,z,t) -> Ag_id list
     RuleIdMap to explain in which rule and which agent_id the site y can be modified.
     -> (A,x,y,B,z,t) -> Ag_id list RuleIdMap to explain in which rule and
        which agent_id the site t can be modified
     -> (A,x,y,B,z,t) -> Ag_id list RuleIdMap to explain in which rule and
        which agent_id (A) a site x of A may become bound to a site z of
        B *)
  (*************************************************************************)

  type local_static_information =
    {
      store_basic_static_information: Site_accross_bonds_domain_static.basic_static_information;
      dummy:unit;
    }

  type static_information =
    {
      global_static_information : Analyzer_headers.global_static_information;
      local_static_information : local_static_information
    }

  (*--------------------------------------------------------------*)
  (* A triple of maps : mvbdu_of_association_list
     - One maps each such tuples (A,x,y,B,z,t) to a mvbdu with two variables
     that describes the relation between the state of y and the state of t,
     when both agents are connected via x and z.
     - One maps each such tuples (A,x,y,B,z,t) to a mvbdu with one variables
     that decribes the range of y when both agents are connected via x and
     z.
     - One maps each such tuples (A,x,y,B,z,t) to a mvbdu with one variables
     that decribes the range of t when both agents are connected via x and
     z. *)
  (*--------------------------------------------------------------*)

  type local_dynamic_information =
    {
      dumy: unit;
      store_value :
        Ckappa_sig.Views_bdu.mvbdu
          Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.t;
    }

  type dynamic_information =
    {
      local  : local_dynamic_information ;
      global : Analyzer_headers.global_dynamic_information ;
    }

  (*------------------------------------------------------------*)
  (** global static information.  Explain how to extract the handler for
      kappa expressions from a value of type static_information. Kappa
      handler is static and thus it should never updated. *)

  let get_global_static_information static = static.global_static_information

  let lift f x = f (get_global_static_information x)

  let get_parameter static = lift Analyzer_headers.get_parameter static

  let get_kappa_handler static = lift Analyzer_headers.get_kappa_handler static

  let get_potential_side_effects static =
    lift Analyzer_headers.get_potential_side_effects_per_rule static

  let get_compil static = lift Analyzer_headers.get_cc_code static

  let get_views_rhs static = lift Analyzer_headers.get_views_rhs static

  let get_views_lhs static = lift Analyzer_headers.get_views_lhs static

  let get_created_bonds static = lift Analyzer_headers.get_created_bonds static

  let get_modified_map static = lift Analyzer_headers.get_modified_map static

  let get_bonds_rhs static = lift Analyzer_headers.get_bonds_rhs static

  let get_bonds_lhs static = lift Analyzer_headers.get_bonds_lhs static

  let get_rule parameter error static r_id =
    let compil = get_compil static in
    let error, rule  =
      Ckappa_sig.Rule_nearly_Inf_Int_storage_Imperatif.get
        parameter
        error
        r_id
        compil.Cckappa_sig.rules
    in
    error, rule

  (*static information*)

  let get_local_static_information static = static.local_static_information

  let set_local_static_information local static =
    {
      static with
      local_static_information = local
    }

  let get_basic_static_information static =
    (get_local_static_information static).store_basic_static_information

  let set_basic_static_information domain static =
    set_local_static_information
      {
        (get_local_static_information static) with
        store_basic_static_information = domain
      } static

  (*tuple pair*)

  let get_potential_tuple_pair_rhs static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_potential_tuple_pair_rhs

  let set_potential_tuple_pair_rhs r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_potential_tuple_pair_rhs = r
      } static

  (*TODO*)
  (*let get_rule_potential_tuple_pair_rhs static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_rule_potential_tuple_pair_rhs

  let set_rule_potential_tuple_pair_rhs r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_rule_potential_tuple_pair_rhs = r
      } static*)

  let get_rule_potential_tuple_pair_lhs static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_rule_potential_tuple_pair_lhs

  let set_rule_potential_tuple_pair_lhs l static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_rule_potential_tuple_pair_lhs = l
      } static

  let get_tuples_of_interest static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_tuples_of_interest

  let set_tuples_of_interest t static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_tuples_of_interest = t
      } static

  (*let get_rule_proj_potential_tuple_pair_lhs static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_rule_proj_potential_tuple_pair_lhs

  let set_rule_proj_potential_tuple_pair_lhs l static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_rule_proj_potential_tuple_pair_lhs = l
      } static*)

  (*let get_partition_bonds_rhs_map static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_partition_bonds_rhs_map

  let set_partition_bonds_rhs_map r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_partition_bonds_rhs_map = r
      } static*)

  let get_partition_created_bonds_map static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_partition_created_bonds_map

  let set_partition_created_bonds_map r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_partition_created_bonds_map = r
      } static

  let get_partition_modified_map_1 static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_partition_modified_map_1

  let set_partition_modified_map_1 r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_partition_modified_map_1 = r
      } static

  let get_partition_modified_map_2 static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_partition_modified_map_2

  let set_partition_modified_map_2 r static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_partition_modified_map_2 = r
      } static

  (*map tuple to sites*)

  let get_sites_to_tuple static =
    (get_basic_static_information
       static).Site_accross_bonds_domain_static.store_sites_to_tuple

  let set_sites_to_tuple tuple static =
    set_basic_static_information
      {
        (get_basic_static_information static) with
        Site_accross_bonds_domain_static.store_sites_to_tuple = tuple
      }
      static

  (** dynamic information*)

  let get_global_dynamic_information dynamic = dynamic.global

  let set_global_dynamic_information gdynamic dynamic =
    {
      dynamic with global = gdynamic
    }

  let get_mvbdu_handler dynamic =
    Analyzer_headers.get_mvbdu_handler (get_global_dynamic_information dynamic)

  let set_mvbdu_handler handler dynamic =
    {
      dynamic with
      global = Analyzer_headers.set_mvbdu_handler handler
          (get_global_dynamic_information dynamic)
    }

  let get_local_dynamic_information dynamic = dynamic.local

  let set_local_dynamic_information local dynamic =
    {
      dynamic with local = local
    }

  let get_value dynamic =
    (get_local_dynamic_information dynamic).store_value

  let set_value value dynamic =
    set_local_dynamic_information
      {
        (get_local_dynamic_information dynamic) with
        store_value = value
      } dynamic

  (*-------------------------------------------------------------*)

  type 'a zeroary =
    static_information
    -> dynamic_information
    -> Exception.method_handler
    -> Exception.method_handler * dynamic_information * 'a

  type ('a, 'b) unary =
    static_information
    -> dynamic_information
    -> Exception.method_handler
    -> 'a
    -> Exception.method_handler * dynamic_information * 'b

  type ('a, 'b, 'c) binary =
    static_information
    -> dynamic_information
    -> Exception.method_handler
    -> 'a
    -> 'b
    -> Exception.method_handler * dynamic_information * 'c

  (****************************************************************)
(*rule*)

  let get_mvbdu_false global_static dynamic error =
    let parameter = get_parameter global_static in
    let handler_bdu = get_mvbdu_handler dynamic in
    let error, handler_bdu, bdu_false =
      Ckappa_sig.Views_bdu.mvbdu_false
        parameter handler_bdu error
    in
    error, set_mvbdu_handler handler_bdu dynamic, bdu_false

  let scan_rule parameter error rule_id rule static =
    let kappa_handler = get_kappa_handler static in
    (*------------------------------------------------------------*)
    (*tuple pair in the rhs*)
    let store_views_rhs = get_views_rhs static in
    let store_bonds_rhs = get_bonds_rhs static in
    let store_potential_tuple_pair_rhs = get_potential_tuple_pair_rhs static in
    let error, store_potential_tuple_pair_rhs =
      Site_accross_bonds_domain_static.collect_potential_tuple_pair_rhs
        parameter error
        rule_id
        store_bonds_rhs
        store_views_rhs
        store_potential_tuple_pair_rhs
    in
    let static =
      set_potential_tuple_pair_rhs store_potential_tuple_pair_rhs
        static
    in
    (*------------------------------------------------------------*)
    let store_views_lhs = get_views_lhs static in
    let store_bonds_lhs = get_bonds_lhs static in
    let store_rule_potential_tuple_pair_lhs = get_rule_potential_tuple_pair_lhs static in
    let error, store_rule_potential_tuple_pair_lhs =
      Site_accross_bonds_domain_static.collect_rule_potential_tuple_pair_lhs
        parameter error
        rule_id
        store_bonds_lhs
        store_views_lhs
        store_rule_potential_tuple_pair_lhs
    in
    let static =
      set_rule_potential_tuple_pair_lhs store_rule_potential_tuple_pair_lhs
        static
    in
    (*------------------------------------------------------------*)
    error, static

  (****************************************************************)
  (*rules*)

  let scan_rules static dynamic error =
    let parameter = get_parameter static in
    let compil = get_compil static in
    let error, static =
      Ckappa_sig.Rule_nearly_Inf_Int_storage_Imperatif.fold
        parameter
        error
        (fun parameter error rule_id rule static ->
           let error, static =
             scan_rule
               parameter error
               rule_id
               rule.Cckappa_sig.e_rule_c_rule
               static
           in
           error, static
        ) compil.Cckappa_sig.rules static
    in
    (*------------------------------------------------------------*)
    let store_potential_tuple_pair_rhs = get_potential_tuple_pair_rhs static in
    (*there is an action binding*)
    let error, store_partition_created_bonds_map =
      Site_accross_bonds_domain_static.collect_partition_created_bonds_map
        parameter error
        store_potential_tuple_pair_rhs
    in
    let static =
      set_partition_created_bonds_map
        store_partition_created_bonds_map
        static
    in
    (*a site is modified explicitly*)
    let error, store_partition_modified_map_1 =
      Site_accross_bonds_domain_static.collect_partition_modified_map_1
        parameter error
        store_potential_tuple_pair_rhs
    in
    let static =
      set_partition_modified_map_1
        store_partition_modified_map_1
        static
    in
    let error, store_partition_modified_map_2 =
      Site_accross_bonds_domain_static.collect_partition_modified_map_2
        parameter error
        store_potential_tuple_pair_rhs
    in
    let static =
      set_partition_modified_map_2
        store_partition_modified_map_2
        static
    in
    (*------------------------------------------------------------*)
    (*a map from tuples -> sites*)
    (*let store_tuples_of_interest = get_tuples_of_interest static in
    let error, store_tuple_to_sites =
      Site_accross_bonds_domain_static.collect_tuple_to_sites
        parameter error store_tuples_of_interest
    in
    let static = set_tuple_to_sites store_tuple_to_sites static in*)
    error, static, dynamic

  (****************************************************************)

  let initialize static dynamic error =
    let init_local_static_information =
      {
        store_basic_static_information =
          Site_accross_bonds_domain_static.init_basic_static_information;
        dummy = ()
      }
    in
    let init_global_static_information =
      {
        global_static_information = static;
        local_static_information = init_local_static_information;
      }
    in
    let init_local_dynamic_information =
      {
        dumy = ();
        store_value =
          Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.empty;

      }
    in
    let init_global_dynamic_information =
      {
        global = dynamic;
        local = init_local_dynamic_information;
      }
    in
    let error, static, dynamic =
      scan_rules
        init_global_static_information
        init_global_dynamic_information
        error
    in
    error, static, dynamic

  (*------------------------------------------------------------*)
  (* take into account bounds that may occur in initial states *)

  let add_initial_state static dynamic error species =
    let parameter = get_parameter static in
    (*views in the initial state that has two agents and their sites are different*)
    let error, store_views_init =
      Site_accross_bonds_domain_static.collect_views_init
        parameter error species in
    let error, store_sites_init =
      Site_accross_bonds_domain_static.collect_sites_init
        parameter error store_views_init in
    let error, store_pair_sites_init =
      Site_accross_bonds_domain_static.collect_pair_sites_init
        parameter error store_sites_init in
    (*a set of site that can be bounds*)
    let error, store_bonds_init =
      Site_accross_bonds_domain_static.collect_bonds_init
        parameter error species
    in
    (*collect the first site bound, and the second site different than the
      first site, return the information of its state, result*)
    let store_result = get_value dynamic in
    let kappa_handler = get_kappa_handler static in
    let error, dynamic, bdu_false = get_mvbdu_false static dynamic error in
    let handler = get_mvbdu_handler dynamic in
    let tuple_of_interest = get_potential_tuple_pair_rhs static in
    let error, handler, store_result =
      Site_accross_bonds_domain_static.collect_pair_tuple_init
        parameter
        error
        bdu_false
        handler
        kappa_handler
        store_bonds_init
        store_pair_sites_init
        tuple_of_interest
        store_result
    in
    let dynamic = set_mvbdu_handler handler dynamic in
    let dynamic = set_value store_result dynamic in
    let event_list = [] in
    error, dynamic, event_list

  (* check for each bond that occur in the lhs, whether
     the constraints in the lhs are consistent *)
  (* For each bond in the lhs of the rule rule_id *)
  (* For each tuple (x,y) of interest that gives information about this kind of bonds *)
  (* Fetch the state of the two other sites in the lhs and in the precondition if they are not available (take the meet)*)
  (* Check that there exists at least one such pair of state in the image of the pair (x,y) in dynamic *)

  let is_enabled static dynamic error (rule_id:Ckappa_sig.c_rule_id)
      precondition =
    let parameter = get_parameter static in
    let error, dynamic, bdu_false = get_mvbdu_false static dynamic error in
    (*look into the lhs whether or not there exists a site accross pattern or
      not *)
    let store_rule_potential_tuple_pair_lhs =
      get_rule_potential_tuple_pair_lhs static
    in
    let error, tuple_set =
      match Ckappa_sig.Rule_map_and_set.Map.find_option_without_logs
              parameter error rule_id store_rule_potential_tuple_pair_lhs
      with
      | error, None ->
        error,
        Site_accross_bonds_domain_type.PairAgentSitesStates_map_and_set.Set.empty
      | error, Some s -> error, s
    in
    let list =
      Site_accross_bonds_domain_type.PairAgentSitesStates_map_and_set.Set.elements
        tuple_set
    in
    let store_value = get_value dynamic in
    (*check if this pattern belong to the set of the patterns in the result*)
    let error, bool, dynamic =
      begin
        let rec scan list error =
          match list with
          | [] -> error, true, dynamic
          | tuple :: tail ->
            let proj (b,c,d,e,f) = (b,c,d,e) in
            let proj2 (x, y) = proj x, proj y in
            let tuple' = proj2 tuple in
            let error, mvbdu_value =
              match
                Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.find_option_without_logs
                  parameter error
                  tuple'
                  store_value
              with
              | error, None -> error, bdu_false
              | error, Some mvbdu -> error, mvbdu
            in
            (*build mvbdu for the tuple in the lhs, then do the
              intersection with the result*)
            let ((_, _, _, _, state2),
                 (_, _, _, _, state2')) = tuple in
            let pair_list =
              [Ckappa_sig.fst_site, state2;
               Ckappa_sig.snd_site, state2']
            in
            let handler = get_mvbdu_handler dynamic in
            let error, handler, mvbdu =
              Ckappa_sig.Views_bdu.mvbdu_of_association_list
                parameter handler error pair_list
            in
            (*intersection*)
            let error, handler, new_mvbdu =
              Ckappa_sig.Views_bdu.mvbdu_and
                parameter handler error mvbdu mvbdu_value
            in
            let dynamic = set_mvbdu_handler handler dynamic in
            (*check*)
            if Ckappa_sig.Views_bdu.equal new_mvbdu bdu_false
            then
              error, false, dynamic
            else
              scan tail error
        in
        scan list error
      end
    in
    if bool
    then error, dynamic, Some precondition
    else error, dynamic, None

  (****************************************************************)

  let context rule_id agent_id site_type =
    " rule "^(Ckappa_sig.string_of_rule_id rule_id)^
    " agent_id "^(Ckappa_sig.string_of_agent_id agent_id)^
    " site_type "^(Ckappa_sig.string_of_site_name site_type)

  (***************************************************************)
  (*there is an action binding in the domain of a rule*)

  let apply_rule_created_bonds static dynamic error rule_id rule precondition store_set =
    let parameter  = get_parameter static in
    let kappa_handler = get_kappa_handler static in
    let error, dynamic, bdu_false = get_mvbdu_false static dynamic error in
    (*------------------------------------------------------*)
    let store_created_bonds = get_created_bonds static in
    let error, created_bonds_set =
      Common_static.get_set parameter error
        rule_id
        Ckappa_sig.PairAgentsSiteState_map_and_set.Set.empty
        store_created_bonds
    in
    let store_partition_created_bonds_map =
      get_partition_created_bonds_map static in
    (*------------------------------------------------------*)
    let error, store_set, dynamic, precondition =
      Ckappa_sig.PairAgentsSiteState_map_and_set.Set.fold
        (fun (t, u) (error, store_set, dynamic, precondition) ->
           (*a pair of binding sites*)
           let (agent_id_t, agent_type_t, site_type_t, state_t) = t in
           let (agent_id_u, agent_type_u, site_type_u, state_u) = u in
           (*tuples that has a binding sites*)
           let error, potential_tuple_pair_set =
             match
               Site_accross_bonds_domain_type.PairAgentSiteState_map_and_set.Map.find_option_without_logs
                 parameter error
                 ((agent_type_t, site_type_t, state_t),
                  (agent_type_u, site_type_u, state_u))
                 store_partition_created_bonds_map
             with
             | error, None ->
               error,
               Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.empty
             | error, Some s -> error, s
           in
           (*-----------------------------------------------------------*)
           (*project the second site*) (*MOVE this function in static*)
           let proj (_, _, d, _) = d in
           let proj2 (x, y) = proj x, proj y in
           let error, proj_potential_tuple_pair_set =
             Site_accross_bonds_domain_type.Proj_potential_tuple_pair_set.proj_set
               proj2
               parameter
               error
               potential_tuple_pair_set
           in
           (*-----------------------------------------------------------*)
           (*getting the information of the state of the second site of this tuple in the
             precondition*)
           Site_accross_bonds_domain_type.PairSite_map_and_set.Set.fold
             (fun (site_type'_x, site_type'_y) (error, store_set, dynamic, precondition) ->
                let error', dynamic, precondition, state'_list_x =
                  Communication.get_state_of_site_in_postcondition
                    get_global_static_information
                    get_global_dynamic_information
                    set_global_dynamic_information
                    error static dynamic
                    (rule_id, rule)
                    agent_id_t
                    site_type'_x
                    precondition
                in
                let error =
                  Exception.check_point
                    Exception.warn
                    parameter error error'
                    ~message:(context rule_id agent_id_t site_type'_x)
                    __POS__ Exit
                in
                let error', dynamic, precondition, state'_list_y =
                  Communication.get_state_of_site_in_postcondition
                    get_global_static_information
                    get_global_dynamic_information
                    set_global_dynamic_information
                    error static dynamic
                    (rule_id,rule)
                    agent_id_u
                    site_type'_y
                    precondition
                in
                let error =
                  Exception.check_point
                    Exception.warn
                    parameter error error'
                    ~message:(context rule_id agent_id_u site_type'_y)
                    __POS__ Exit
                in
                (*-----------------------------------------------------------*)
                (*building the mvbdu from these states that received*)
                let error, store_set, dynamic, precondition =
                  match state'_list_x, state'_list_y with
                  | _::_::_, _::_::_ ->
                    (*we know for sure that none of the two sites have been
                      modified*)
                    error, store_set, dynamic, precondition
                  | [], _ | _, [] ->
                    let error, () =
                      Exception.warn parameter error __POS__
                        ~message: "empty list in potential states in post condition" Exit ()
                    in
                    error, store_set, dynamic, precondition
                  | [_], _ | _, [_] -> (*general case*)
                    List.fold_left
                      (fun (error, store_set, dynamic, precondition) state'_x ->
                         List.fold_left
                           (fun (error, store_set, dynamic, precondition) state'_y ->
                              let store_result = get_value dynamic in
                              let pair_list =
                                [Ckappa_sig.fst_site, state'_x;
                                 Ckappa_sig.snd_site, state'_y]
                              in
                              let pair =
                                (agent_type_t, site_type_t, site_type'_x,
                                 state_t),
                                (agent_type_u, site_type_u, site_type'_y,
                                 state_u)
                              in
                              let handler = get_mvbdu_handler dynamic in
                              let error, handler, mvbdu =
                                Ckappa_sig.Views_bdu.mvbdu_of_association_list
                                  parameter handler error pair_list
                              in
                              let error, handler, store_set, store_result =
                                Site_accross_bonds_domain_type.add_link_and_event (*TODO*)
                                  parameter error bdu_false handler
                                  kappa_handler
                                  pair
                                  mvbdu
                                  store_set
                                  store_result
                              in
                              let dynamic = set_value store_result dynamic in
                              let dynamic = set_mvbdu_handler handler dynamic in
                              error, store_set, dynamic, precondition
                           ) (error, store_set, dynamic, precondition) state'_list_y
                      ) (error, store_set, dynamic, precondition) state'_list_x
                in
                error, store_set, dynamic, precondition
             ) proj_potential_tuple_pair_set (error, store_set, dynamic, precondition)
        ) created_bonds_set (error, store_set, dynamic, precondition)
    in
    error, store_set, dynamic, precondition

  (***************************************************************)
  (*a site is modified (explicitly)*)

  (*build a new path *)
  let get_state_of_site_in_pre_post_condition_2
      error
      static dynamic
      agent_id_t
      (site_type_x, agent_type_y, site_type_y)
      site_type'_y
      defined_in precondition = (*CHECK ME*)
    let step =
      {
        Communication.site_out = site_type_x;
        Communication.site_in = site_type_y;
        Communication.agent_type_in = agent_type_y;
      }
    in
    let path =
      {
        Communication.defined_in = defined_in;
        path =
          {
            Communication.agent_id = agent_id_t;
            Communication.relative_address = [step];
            Communication.site = site_type'_y}
      }
    in
    let error, global_dynamic, precondition, state_list_lattice =
      Communication.get_state_of_site
        error
        precondition
        (get_global_static_information static)
        (get_global_dynamic_information dynamic)
        path
    in
    let error, state_list =
      match state_list_lattice with
      | Usual_domains.Val l -> error, l
      | Usual_domains.Undefined -> error, []
      | Usual_domains.Any ->
        Exception.warn
          (get_parameter static) error __POS__ Exit []
    in
    let dynamic = set_global_dynamic_information global_dynamic dynamic in
    error, dynamic, precondition, state_list

  let get_state_of_site_in_precondition_2
      error static dynamic rule agent_id
      (site_type_x, agent_type_y, site_type_y)
      site_type'_y
      precondition =
    let defined_in = Communication.LHS rule in
    get_state_of_site_in_pre_post_condition_2
      error static dynamic
      agent_id
      (site_type_x, agent_type_y, site_type_y)
      site_type'_y
      defined_in
      precondition

  let get_state_of_site_in_postcondition_2
      error static dynamic rule agent_id
      (site_type_x, agent_type_y, site_type_y) site_type'_y
      precondition =
    let defined_in = Communication.RHS rule in
    get_state_of_site_in_pre_post_condition_2
      error static dynamic
      agent_id (site_type_x, agent_type_y, site_type_y) site_type'_y defined_in
      precondition

  type pos = Fst | Snd

  let get_partition_modified pos static =
    match pos with
    | Fst -> get_partition_modified_map_1 static
    | Snd -> get_partition_modified_map_2 static

  let get_state_of_site_in_postcondition_gen
      pos error static dynamic
      rule agent_id_mod
      (agent_type_x, site_type_x, site_type'_x, _)
      (agent_type_y, site_type_y, site_type'_y, _)
      precondition
    =
    match pos with
    | Fst ->
      get_state_of_site_in_postcondition_2
        error static dynamic
        rule agent_id_mod
        (site_type_x, agent_type_y, site_type_y) site_type'_y
        precondition
    | Snd ->
      get_state_of_site_in_postcondition_2
        error static dynamic
        rule agent_id_mod
        (site_type_y, agent_type_x, site_type_x) site_type'_x
        precondition

  (*a tuple that has modified site*)
  let  apply_rule_modified_explicity_gen
      ~pos bdu_false parameter error kappa_handler static dynamic
      rule_id rule precondition modified_set store_set =
    let store_partition_modified_map = get_partition_modified pos static in
    (*------------------------------------------------------*)
    Ckappa_sig.AgentsSiteState_map_and_set.Set.fold
      (fun mod_tuple (error, store_set, dynamic, precondition) ->
         let (agent_id_mod, agent_type_mod, site_type_mod, state_mod) = mod_tuple in
         (*a tuple that has a pair (agent_type, site_name) modified*)
         let error, potential_tuple_pair_set =
           match
             Site_accross_bonds_domain_type.AgentSite_map_and_set.Map.find_option_without_logs
               parameter error
               (agent_type_mod, site_type_mod)
               store_partition_modified_map
           with
           | error, None ->
             error,
             Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.empty
           | error, Some s -> error, s
         in
         (*-----------------------------------------------------------*)
         (*explore this tuple and get the information of the state of the second site in
           the precondition*)
         Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.fold
           (fun (x, y) (error, store_set, dynamic, precondition) ->
              let (agent_type_x, site_type_x, site_type'_x, state_x) = x in
              let (agent_type_y, site_type_y, site_type'_y, state_y) = y in
              let error', dynamic, precondition, state'_list_other =
                get_state_of_site_in_postcondition_gen
                  pos error static dynamic
                  (rule_id, rule)
                  agent_id_mod
                  x
                  y
                  precondition
              in
              let error', (agent_y, site_y) =
                Site_accross_bonds_domain_type.convert_single_without_state
                  parameter error'
                  kappa_handler
                  (agent_type_y, site_type_y)
              in
              let error', (agent_x, site_x) =
                Site_accross_bonds_domain_type.convert_single_without_state
                  parameter error'
                  kappa_handler
                  (agent_type_x, site_type_x)
              in
              let () =
                if error' == error then ()
                else
                  Loggers.fprintf (Remanent_parameters.get_logger parameter)
                    "\nWRONG TUPLE: !!! \n Rule %i agent_id_t: %i%s:%s( site_type_x: %i:%s), agent_type_y:%i:%s: (site_type_y:%i:%s) \n"
                    (Ckappa_sig.int_of_rule_id rule_id)
                    (Ckappa_sig.int_of_agent_id agent_id_mod)
                    (match pos with Fst -> "->" | Snd -> "<-")
                    agent_x
                    (Ckappa_sig.int_of_site_name site_type_x)
                    site_x
                    (Ckappa_sig.int_of_agent_name agent_type_y)
                    agent_y
                    (Ckappa_sig.int_of_site_name site_type_y)
                    site_y
              in
              let error =
                Exception.check_point
                  Exception.warn
                  parameter error error'
                  ~message:(context rule_id agent_id_mod
                              (match pos with
                               | Fst -> site_type'_x
                               | Snd -> site_type'_x))
                  __POS__ Exit
              in
              (*-----------------------------------------------------------*)
              (*compute the mvbdu value from the information receive*)
              let error, store_set, dynamic, precondition =
                match state'_list_other with
                | _::_::_ ->
                  (*we know for sure that none of the two sites have been
                    modified*)
                  error, store_set, dynamic, precondition
                | [] ->
                  (*let error, () =
                    Exception.warn parameter error __POS__
                      ~message: "empty list in potential states in post condition" Exit ()
                    in*)
                  error, store_set, dynamic, precondition
                | [_] -> (*general case, singleton*)
                  List.fold_left
                    (fun (error, store_set, dynamic, precondition) state'_other ->
                       let store_result = get_value dynamic in
                       let pair_list =
                         match pos
                         with Fst ->
                           [Ckappa_sig.fst_site, state_mod;
                            Ckappa_sig.snd_site, state'_other]
                            | Snd ->
                              [Ckappa_sig.fst_site, state'_other;
                               Ckappa_sig.snd_site, state_mod]
                       in
                       let pair =
                         (agent_type_x, site_type_x, site_type'_x,state_x),
                         (agent_type_y, site_type_y, site_type'_y,state_y)
                       in
                       let handler = get_mvbdu_handler dynamic in
                       let error, handler, mvbdu =
                         Ckappa_sig.Views_bdu.mvbdu_of_association_list
                           parameter handler error pair_list
                       in
                       (*return store_set*)
                       let error, handler, store_set, store_result =
                         Site_accross_bonds_domain_type.add_link_and_event (*TODO*)
                           parameter error bdu_false handler
                           kappa_handler
                           pair
                           mvbdu
                           store_set
                           store_result
                       in
                       let dynamic = set_value store_result dynamic in
                       let dynamic = set_mvbdu_handler handler dynamic in
                       error, store_set, dynamic, precondition
                    ) (error, store_set, dynamic, precondition) state'_list_other
              in
              error, store_set, dynamic, precondition
           ) potential_tuple_pair_set (error, store_set, dynamic, precondition)
      ) modified_set (error, store_set, dynamic, precondition)

  let apply_rule_modified_explicity static dynamic error rule_id
      rule precondition store_set = (*CHECK ME*)
    let parameter  = get_parameter static in
    let kappa_handler = get_kappa_handler static in
    let error, dynamic, bdu_false = get_mvbdu_false static dynamic error in
    let store_modified_map = get_modified_map static in
    let error, modified_set =
      Common_static.get_set parameter
        error
        rule_id
        Ckappa_sig.AgentsSiteState_map_and_set.Set.empty
        store_modified_map
    in
    let error, store_set, dynamic, precondition =
      apply_rule_modified_explicity_gen
        ~pos:Fst bdu_false parameter error kappa_handler static dynamic
        rule_id rule precondition modified_set store_set
    in
    (*fold over a set of modified sites*)
    let error, store_set, dynamic, precondition =
      apply_rule_modified_explicity_gen
        ~pos:Snd bdu_false parameter error kappa_handler static dynamic
        rule_id rule precondition modified_set store_set
    in
    error, store_set, dynamic, precondition

  (***************************************************************)
  (*side effect*)

  let free_site_gen ~pos static dynamic error agent' site_name' state' store_set =
    let parameter  = get_parameter static in
    let store_partition_modified_map = get_partition_modified pos static in
    let error, potential_tuple_pair_set =
      match
        Site_accross_bonds_domain_type.AgentSite_map_and_set.Map.find_option_without_logs
          parameter error
          (agent', site_name')
          store_partition_modified_map
      with
      | error, None ->
        error,
        Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.empty
      | error, Some s -> error, s
    in
    (*-----------------------------------------------------------*)
    Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.fold
      (fun (x, y) (error, store_set, dynamic) ->
         (*check if it is the fresh pair or not*)
         if Site_accross_bonds_domain_type.PairAgentSite_map_and_set.Set.mem
             (Site_accross_bonds_domain_type.each_pair (x, y))
             store_set
         then error, store_set, dynamic
         else
           let handler = get_mvbdu_handler dynamic in
           let result = get_value dynamic in
           let error, mvbdu_opt =
             Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.find_option_without_logs parameter error
               (x,y)
               result
           in
           match mvbdu_opt with
           | None -> error, store_set, dynamic
           | Some mvbdu ->
             let var  =
               match pos with
               | Fst -> Ckappa_sig.fst_site
               | Snd -> Ckappa_sig.snd_site
             in
             let error, handler, cap =
               Ckappa_sig.Views_bdu.mvbdu_of_association_list
                 parameter handler error
                 [var, state']
             in
             let error, handler, redefine =
               Ckappa_sig.Views_bdu.build_association_list
                 parameter handler error
                 [var, Ckappa_sig.dummy_state_index]
             in
             let error, handler, mvbdu_cap =
               Ckappa_sig.Views_bdu.mvbdu_and
                 parameter handler error
                 mvbdu cap
             in
             let error, handler, mvbdu' =
               Ckappa_sig.Views_bdu.mvbdu_redefine
                 parameter handler error
                 mvbdu_cap
                 redefine
             in
             let error, handler, mvbdu_or = (*union*)
               Ckappa_sig.Views_bdu.mvbdu_or
                 parameter handler error
                 mvbdu
                 mvbdu'
             in
             let error, result =
               Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.add_or_overwrite parameter error
                 (x,y)
                 mvbdu_or
                 result
             in
             let dynamic = set_mvbdu_handler handler dynamic in
             let dynamic = set_value result dynamic in
             let error, new_set =
               Site_accross_bonds_domain_type.PairAgentSite_map_and_set.Set.add_when_not_in
                 parameter error
                 (Site_accross_bonds_domain_type.each_pair (x, y))
                 store_set
             in
             error, new_set, dynamic
      ) potential_tuple_pair_set (error, store_set, dynamic)

  let free_site static dynamic error agent' site_name' state' store_set =
    let error, store_set, dynamic =
      free_site_gen ~pos:Fst static dynamic error agent' site_name' state' store_set
    in
    free_site_gen ~pos:Snd static dynamic error agent' site_name' state' store_set

  let apply_rule_side_effects static dynamic error rule_id store_set =
    let parameter = get_parameter static in
    let error, list =
      Ckappa_sig.Rule_map_and_set.Map.find_default_without_logs
        parameter error
        []
        rule_id
        (get_potential_side_effects static)
    in
    List.fold_left
      (fun (error, store_set, dynamic) (agent_name, site, state) ->
         free_site
           static dynamic error agent_name site state store_set)
      (error, store_set, dynamic)
      list

  (***************************************************************)

  let apply_rule_event_aux error store_set event_list =
    Site_accross_bonds_domain_type.PairAgentSite_map_and_set.Set.fold
      (fun (x, y, z, t) (error, event_list) ->
         error, (Communication.Modified_sites x) ::
                (Communication.Modified_sites y) ::
                (Communication.Modified_sites z) ::
                (Communication.Modified_sites t) :: event_list
      ) store_set (error, event_list)

  let apply_rule static dynamic error rule_id precondition =
    let parameter  = get_parameter static in
    let event_list = [] in
    (*-----------------------------------------------------------*)
    let error, rule = get_rule parameter error static rule_id in
    match rule with
    | None ->
      let error, () =
        Exception.warn  parameter error __POS__ Exit ()
      in
      error, dynamic, (precondition, [])
    | Some rule ->
      (*------------------------------------------------------*)
      (*1.a bonds on the rhs: not sure you need this test, it will be
        covered by 1.c and 1.d *)
      (*------------------------------------------------------*)
      (*    let error, dynamic, precondition =
            apply_rule_bonds_rhs
            static dynamic error rule_id rule precondition
            in*)
      (*------------------------------------------------------*)
      (*1.b created bonds *)
      (*------------------------------------------------------*)
      let parameter =
        Remanent_parameters.update_prefix parameter "                "
      in
      let dump_title () =
        if local_trace || Remanent_parameters.get_dump_reachability_analysis_diff parameter
        then
          let () =
            Loggers.fprintf
              (Remanent_parameters.get_logger parameter)
              "%sUpdate information about potential sites accross domain"
              (Remanent_parameters.get_prefix parameter)
          in
          Loggers.print_newline (Remanent_parameters.get_logger parameter)
        else
          ()
      in
      (*-----------------------------------------------------------*)
      (*created a binding site*)
      let error, store_set, dynamic, precondition =
        apply_rule_created_bonds
          static dynamic error rule_id rule precondition
          Site_accross_bonds_domain_type.PairAgentSite_map_and_set.Set.empty
      in
      (*add site that is modified into an event list*)
      let error, event_list =
        apply_rule_event_aux error store_set event_list
      in
      let store_value = get_value dynamic in
      let bool =
        if
          Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.is_empty
            store_value
        then false
        else let () = dump_title () in true
      in
      (*-----------------------------------------------------------*)
      (*1.c a site is modified (explicitly) *) (*FIX ME*)
      let error, store_set, dynamic, precondition =
        apply_rule_modified_explicity
          static dynamic error rule_id rule
          precondition
          store_set
      in
      (*-----------------------------------------------------------------------*)
      (*check the new event*)
      let error, event_list =
        apply_rule_event_aux error store_set event_list
      in
      (*-----------------------------------------------------------------------*)
      let store_value = get_value dynamic in
      let () =
        if not bool &&
           Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.is_empty
             store_value
        then ()
        else dump_title ()
      in
      (*-----------------------------------------------------------*)
      (*1.d a site is modified by side effect *)
      let error, store_set, dynamic =
        apply_rule_side_effects static dynamic error rule_id store_set
      in
      let error, event_list =
        apply_rule_event_aux error store_set event_list
      in
      let store_value = get_value dynamic in
      let () =
        if not bool &&
           Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.is_empty
             store_value
        then ()
        else dump_title ()
      in
      (*-----------------------------------------------------------*)
      (*let event_list = [] in*)
      error, dynamic, (precondition, event_list)

  (* events enable communication between domains. At this moment, the
       global domain does not collect information *)

  let apply_event_list static dynamic error event_list =
    (*get from the site that are modified*)
    let parameter = get_parameter static in
    let store_sites_to_tuple1, store_sites_to_tuple2 = get_sites_to_tuple static in
    let error, event_list =
      List.fold_left (fun (error, event_list) event ->
          match event with
          | Communication.Dummy | Communication.Check_rule _
          | Communication.See_a_new_bond _ -> error, event_list
          | Communication.Modified_sites (agent, site) ->
            let dummy =
              (Ckappa_sig.dummy_agent_name, Ckappa_sig.dummy_site_name,
               Ckappa_sig.dummy_site_name, Ckappa_sig.dummy_state_index)
            in
            let error, tuple1 =
              match
                Site_accross_bonds_domain_type.AgentSite_map_and_set.Map.find_option_without_logs
                  parameter error
                  (agent, site)
                  store_sites_to_tuple1
              with
              | error, None -> error, (dummy, dummy)
              | error, Some tup -> error, tup
            in
            (*-----------------------------------------------------------------*)
            (*tuple that has modify variables *)
            let error, tuple2 =
              match
                Site_accross_bonds_domain_type.AgentSite_map_and_set.Map.find_option_without_logs
                  parameter error
                  (agent, site)
                  store_sites_to_tuple2
              with
              | error, None -> error, (dummy, dummy)
              | error, Some tup -> error, tup
            in
            (*TODO*)
            error, event_list
        ) (error, []) event_list
    in

    (*get from the site that are bound*)

    (*get from the site that has side effect*)
    error, dynamic, event_list

  let stabilize _static dynamic error =
    error, dynamic, ()

  let export _static dynamic error kasa_state =
    error, dynamic, kasa_state

  (****************************************************************)
  (* to do *)

  let print_potential_tuple_pair parameter error kappa_handler store_result =
    (*Ckappa_sig.Rule_map_and_set.Map.fold
      (fun rule_id set error ->
         let () = Loggers.fprintf (Remanent_parameters.get_logger parameter)
             "rule_id:%i\n"
             (Ckappa_sig.int_of_rule_id rule_id)
         in*)
         Site_accross_bonds_domain_type.PairAgentSitesStates_map_and_set.Set.fold
           (fun (x, y) error ->
              let (agent_type_x, site_type_x, site_type_x', _, state) = x in
              let (agent_type_y, site_type_y, site_type_y', _, state') = y in
              let proj (a, b, c, d, _) = (a, b, c, d) in
              let error, (string_agent_x, string_site_x, string_site_x', _,
                          string_agent_y, string_site_y, string_site_y', _) =
                Site_accross_bonds_domain_type.convert_tuple
                  parameter error kappa_handler
                  (proj x, proj y)
              in
              (*if state <> state'
              then error
              else*)
                let _ =
                  Loggers.fprintf (Remanent_parameters.get_logger parameter)
                    "%s(%i:%s, %i:%s), %s(%s, %s)\n"
                    string_agent_x
                    (Ckappa_sig.int_of_site_name site_type_x)
                    string_site_x
                    (Ckappa_sig.int_of_site_name site_type_x')
                    string_site_x'
                    string_agent_y string_site_y string_site_y'
                in
                error
           ) store_result error
  (* store_result error*)

  let print static dynamic (error:Exception.method_handler) loggers =
    let parameter = get_parameter static in
    let kappa_handler = get_kappa_handler static in
    let handler = get_mvbdu_handler dynamic in
    let log = loggers in
    (*--------------------------------------------------------*)
    let error, handler =
      if Remanent_parameters.get_dump_reachability_analysis_result parameter
      then
        let () =
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log;
          Loggers.fprintf log "* Properties in connected agents";
          Loggers.print_newline log;

          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log
        in
        (*--------------------------------------------------------*)
        (*print result*)
        let store_value = get_value dynamic in
        let error, handler =
          Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Map.fold
            (fun (x, y) mvbdu (error, handler) ->
               Site_accross_bonds_domain_type.print_site_accross_domain
                 ~verbose:true
                 ~sparse:true
                 ~final_result:true
                 ~dump_any:true parameter error kappa_handler handler (x, y) mvbdu
            ) store_value (error, handler)
        in
        error, handler
      else error, handler
    in
    (*--------------------------------------------------------*)
    (*test*)
    (*let error =
      if Remanent_parameters.get_dump_reachability_analysis_result parameter
      then
        let () =
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log;
          Loggers.fprintf log "* Properties in connected agents on the rhs and lhs\n";
          Loggers.print_newline log;
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log
        in
        let store_result = get_tuples_of_interest static in
        let error =
          print_potential_tuple_pair parameter error kappa_handler store_result
        in
        error
      else error
    in*)
    (*--------------------------------------------------------*)
    (*let error =
      if Remanent_parameters.get_dump_reachability_analysis_result parameter
      then
        let () =
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log;
          Loggers.fprintf log "* Properties in connected agents on the lhs\n";
          Loggers.print_newline log;
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log
        in
        let store_result = get_rule_potential_tuple_pair_lhs static in
        let error =
          print_potential_tuple_pair parameter error kappa_handler store_result
        in
        error
      else error
    in*)
    (*--------------------------------------------------------*)
    (*print a map from tuple to sites*)
    (*let error =
      if Remanent_parameters.get_dump_reachability_analysis_result parameter
      then
        let () =
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log;
          Loggers.fprintf log "* Properties in connected agents. A map from tuples to sites\n";
          Loggers.print_newline log;
          Loggers.fprintf log
            "------------------------------------------------------------";
          Loggers.print_newline log
        in
        let store_result = get_tuple_to_sites static in
        let error =
          Site_accross_bonds_domain_type.PairAgentSite_map_and_set.Map.fold
            (*pair of (agent_type, site_name) that belongs to the tuples*)
            (fun (x, y, z, t) pair_set error ->
               (*Pair of tuples*)
               Site_accross_bonds_domain_type.PairAgentSitesState_map_and_set.Set.fold
                 (fun (a, b) error ->
                    let error, (string_agent, string_site, string_site', _,
                                string_agent1, string_site1, string_site1', _) =
                      Site_accross_bonds_domain_type.convert_tuple
                        parameter error kappa_handler
                        (a, b)
                    in
                    let error, (string_agent_x, string_site_x) =
                      Site_accross_bonds_domain_type.convert_single_without_state
                        parameter error kappa_handler x in
                    let error, (string_agent_y, string_site_y) =
                      Site_accross_bonds_domain_type.convert_single_without_state
                        parameter error kappa_handler y in
                    let error, (string_agent_z, string_site_z) =
                      Site_accross_bonds_domain_type.convert_single_without_state
                        parameter error kappa_handler z in
                    let error, (string_agent_t, string_site_t) =
                      Site_accross_bonds_domain_type.convert_single_without_state
                        parameter error kappa_handler t in
                    (*print*)
                    let () =
                      Loggers.fprintf log "%s(%s, %s), %s(%s, %s) => (%s, %s); (%s, %s); (%s, %s); (%s, %s)\n"
                        string_agent string_site string_site'
                        string_agent1 string_site1 string_site1'
                        string_agent_x string_site_x
                        string_agent_y string_site_y
                        string_agent_z string_site_z
                        string_agent_t string_site_t
                    in
                    error
                 ) pair_set error
            ) store_result error
        in
        error
      else error
    in*)
    (*--------------------------------------------------------*)
    let dynamic = set_mvbdu_handler handler dynamic in
    error, dynamic, ()

  let lkappa_mixture_is_reachable _static dynamic error _lkappa =
    error, dynamic, Usual_domains.Maybe (* to do *)

  let cc_mixture_is_reachable _static dynamic error _ccmixture =
    error, dynamic, Usual_domains.Maybe (* to do *)

end
