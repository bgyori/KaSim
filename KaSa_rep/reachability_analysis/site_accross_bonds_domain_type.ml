(**
   * site_accross_bonds_domain.ml
   * openkappa
   * Jérôme Feret & Ly Kim Quyen, projet Abstraction, INRIA Paris-Rocquencourt
   *
   * Creation: 2016, the 31th of March
   * Last modification: Time-stamp: <Sep 15 2016>
   *
   * Abstract domain to record relations between pair of sites in connected agents.
   *
   * Copyright 2010,2011,2012,2013,2014,2015,2016 Institut National de Recherche
   * en Informatique et en Automatique.
   * All rights reserved.  This file is distributed
   * under the terms of the GNU Library General Public License *)

(*static views rhs/lhs*)
module AgentsSiteState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(*static question mark*)
module AgentsSitesState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(*views in initial state*)
module AgentsSitesStates_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name
            * Ckappa_sig.c_site_name * Ckappa_sig.c_site_name
            * Ckappa_sig.c_state * Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(************************************************************)
(*PAIR*)

(*partition bonds/created bond rhs map*)
module PairAgentSiteState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name *
            Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

module PairAgentSitesState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(*collect tuple in the lhs*)
module PairAgentSitesStates_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state * Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state * Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(*-----------------------------------------------------*)

module PairAgentsSiteState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name
            * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name
            * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

module PairAgentsSitesState_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

module PairAgentsSitesStates_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state * Ckappa_sig.c_state) *
           (Ckappa_sig.c_agent_id * Ckappa_sig.c_agent_name *
            Ckappa_sig.c_site_name * Ckappa_sig.c_site_name *
            Ckappa_sig.c_state * Ckappa_sig.c_state)
         let compare = compare
         let print _ _ = ()
       end))

(*******************************************************************)
(*a map from tuples to sites*)
(*******************************************************************)

module PairAgentSite_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name) *
           (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name) *
           (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name) *
           (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name)
         let compare = compare
         let print _ _ = ()
       end))

module Partition_tuples_to_sites_map =
  Map_wrapper.Proj
    (PairAgentSitesState_map_and_set) (*set*)
    (PairAgentSite_map_and_set) (*map*)

(***************************************************************)
(*Projection*)

module PairSite_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_site_name *
            Ckappa_sig.c_site_name)
         let compare = compare
         let print _ _ = ()
       end))

(*project second site*)
module Proj_potential_tuple_pair_set =
  Map_wrapper.Proj
    (PairAgentSitesState_map_and_set) (*potential tuple pair set*)
    (PairSite_map_and_set) (*use to search the set in bonds rhs*)

module Partition_bonds_rhs_map =
  Map_wrapper.Proj
    (PairAgentSitesState_map_and_set)
    (PairAgentSiteState_map_and_set)

module Partition_created_bonds_map =
  Map_wrapper.Proj
    (PairAgentSitesState_map_and_set)
    (PairAgentSiteState_map_and_set)

(*partition modified map*)
module AgentSite_map_and_set =
  Map_wrapper.Make
    (SetMap.Make
       (struct
         type t =
           (Ckappa_sig.c_agent_name * Ckappa_sig.c_site_name)
         let compare = compare
         let print _ _ = ()
       end))

module Partition_modified_map =
  Map_wrapper.Proj
    (PairAgentSitesState_map_and_set)
    (AgentSite_map_and_set)

module Proj_potential_tuple_pair_set_lhs =
  Map_wrapper.Proj (PairAgentSitesStates_map_and_set)(PairAgentSitesState_map_and_set)

(***************************************************************)

let convert_single_without_state parameters error kappa_handler single =
  let (agent, site) = single in
  let error, site = Handler.string_of_site_contact_map parameters error kappa_handler agent site in
  let error, agent =
    Handler.translate_agent
      ~message:"unknown agent type" ~ml_pos:(Some __POS__)
      parameters error kappa_handler agent
  in
  error, (agent, site)

let convert_single parameters error kappa_handler single =
  let (agent, site, state) = single in
  let error, state = Handler.string_of_state_fully_deciphered parameters error kappa_handler agent site state in
  let error, site = Handler.string_of_site_contact_map parameters error kappa_handler agent site in
  let error, agent =
    Handler.translate_agent
      ~message:"unknown agent type" ~ml_pos:(Some __POS__)
      parameters error kappa_handler agent
  in
  error, (agent, site, state)

let convert_tuple parameters error kappa_handler tuple =
  let (agent,site,site',state),(agent'',site'',site''',state'') = tuple in
  let error, state = Handler.string_of_state_fully_deciphered parameters error kappa_handler agent site state in
  let error, state'' = Handler.string_of_state_fully_deciphered parameters error kappa_handler agent'' site'' state'' in
  let error, site = Handler.string_of_site_contact_map parameters error kappa_handler agent site in
  let error, site' = Handler.string_of_site_contact_map parameters error kappa_handler agent site' in
  let error, agent =
    Handler.translate_agent
      ~message:"unknown agent type" ~ml_pos:(Some __POS__)
      parameters error kappa_handler agent
  in
  let error, site'' = Handler.string_of_site_contact_map parameters error kappa_handler agent'' site'' in
  let error, site''' = Handler.string_of_site_contact_map parameters error kappa_handler agent'' site''' in
  let error, agent'' =
    Handler.translate_agent
      ~message:"unknown agent type" ~ml_pos:(Some __POS__)
      parameters error kappa_handler agent''
  in
  error, (agent,site,site', state, agent'',site'',site''', state'')

(*remove states*)
let project (_,b,c,d,_,_) = (b,c,d)
let project2 (x,y) = (project x,project y)

let print_site_accross_domain
    ?verbose:(verbose=true)
    ?sparse: (sparse = false)
    ?final_result:(final_result = false)
    ?dump_any:(_dump_any = false) parameters error kappa_handler handler tuple mvbdu =
  let prefix = Remanent_parameters.get_prefix parameters in
  let (agent_type1, site_type1, site_type1', _), (agent_type2, site_type2, site_type2', _) = tuple in
  (*----------------------------------------------------*)
  (*state1 and state1' are a binding states*)
  let error, (agent1, site1, site1',_, agent2, site2, site2', _) =
    convert_tuple parameters error kappa_handler tuple
  in
  if sparse && compare (agent1,site1,site1') (agent2,site2,site2') > 0
  then error, handler
  else
    (*only print the final_result in the case of final_result is set true*)
    let error, handler, non_relational =
      if final_result
      then
        (*at the final result needs to check the non_relational condition*)
      Translation_in_natural_language.non_relational
        parameters handler error mvbdu
      else
        (*other cases will by pass this test*)
        error, handler, false
    in
    if non_relational
    then error, handler
    else
      (*----------------------------------------------------*)
      let error, handler, pair_list =
        Ckappa_sig.Views_bdu.extensional_of_mvbdu
          parameters handler error mvbdu
    in
      (*----------------------------------------------------*)
      match Remanent_parameters.get_backend_mode parameters
      with
      | Remanent_parameters_sig.Kappa
      | Remanent_parameters_sig.Raw ->
        let pattern = Ckappa_backend.Ckappa_backend.empty in
        let error, agent_id1, pattern =
          Ckappa_backend.Ckappa_backend.add_agent
            parameters error kappa_handler agent_type1 pattern
        in
        let error, agent_id2, pattern =
          Ckappa_backend.Ckappa_backend.add_agent
            parameters error kappa_handler agent_type2 pattern
        in
        let error, pattern =
          Ckappa_backend.Ckappa_backend.add_bond
            parameters error kappa_handler agent_id1 site_type1 agent_id2 site_type2 pattern
        in
        let error =
          (*do not print the precondition if it is not the final result*)
          if final_result
          then
            let error =
              Ckappa_backend.Ckappa_backend.print
                (Remanent_parameters.get_logger parameters) parameters error
                kappa_handler
                pattern
            in
            let () =
              Loggers.fprintf (Remanent_parameters.get_logger parameters) " => "
            in
            error
          else error
        in
        begin
          match pair_list with
          | [] ->
            let () =
              Loggers.fprintf (Remanent_parameters.get_logger parameters) ""
            in
            error, handler
          | _::_ ->
            let () =
              if final_result
              then
              let () =
                Loggers.print_newline (Remanent_parameters.get_logger parameters)
              in
                Loggers.fprintf (Remanent_parameters.get_logger parameters) "\t["
              else ()
            in
            let error, _ =
              List.fold_left
                (fun (error, bool) l ->
                   match l with
                   | [siteone, state1; sitetwo, state2] when
                       siteone == Ckappa_sig.fst_site
                       && sitetwo == Ckappa_sig.snd_site ->
                     let () =
                       Loggers.print_newline (Remanent_parameters.get_logger parameters)
                     in
                     let () =
                       Loggers.fprintf
                         (Remanent_parameters.get_logger parameters)
                         (if bool  then "\t\tv " else "\t\t  ")
                     in
                     let error, pattern =
                       Ckappa_backend.Ckappa_backend.add_state
                         parameters error kappa_handler
                         agent_id1 site_type1' state1 pattern
                     in
                     let error, pattern =
                       Ckappa_backend.Ckappa_backend.add_state
                         parameters error kappa_handler
                         agent_id2 site_type2' state2 pattern
                     in
                     let error =
                       Ckappa_backend.Ckappa_backend.print
                         (Remanent_parameters.get_logger parameters) parameters error kappa_handler
                         pattern
                     in
                     error, true
                   | _ -> Exception.warn parameters error __POS__ Exit bool
                )
                (error, false) pair_list
            in
            let () =
              if final_result
              then
                let () = Loggers.print_newline (Remanent_parameters.get_logger parameters) in
                let () = Loggers.fprintf
                    (Remanent_parameters.get_logger parameters) "\t]" in
                let () = Loggers.print_newline                    (Remanent_parameters.get_logger parameters) in
                ()
              else
              let () = Loggers.print_newline (Remanent_parameters.get_logger parameters) in ()
            in
            error, handler
        end
      | Remanent_parameters_sig.Natural_language ->
        let () =
          Loggers.fprintf (Remanent_parameters.get_logger parameters)
            "%sWhenever the site %s of %s and the site %s of %s are bound \
             together, then the site %s of %s and %s of %s can have the \
             following respective states:"
            prefix site1 agent1 site2 agent2
            site1' agent1 site2' agent2 in
        let () =
          Loggers.print_newline (Remanent_parameters.get_logger parameters)
        in
        let prefix = prefix^"\t" in
        List.fold_left (fun (error, handler) l ->
            match l with
            | [siteone, statex; sitetwo, statey] when
                siteone == Ckappa_sig.fst_site
                && sitetwo == Ckappa_sig.snd_site ->
              let error, (_, _, statex) =
                convert_single parameters error kappa_handler
                  (agent_type1, site_type1, statex)
              in
              let error, (_, _, statey) =
                convert_single parameters error kappa_handler
                  (agent_type2, site_type2, statey)
              in
              let () =
                Loggers.fprintf (Remanent_parameters.get_logger parameters)
                  "%s%s, %s\n"
                  prefix statex statey
              in
              error, handler
            | [] | _::_ ->
              let error, () =
                Exception.warn parameters error __POS__ Exit ()
              in
              error, handler
          ) (error, handler) pair_list

let add_link parameter error bdu_false handler kappa_handler pair mvbdu
     store_result =
  let error, bdu_old =
    match
      PairAgentSitesState_map_and_set.Map.find_option_without_logs
        parameter error
        pair
        store_result
    with
    | error, None -> error, bdu_false
    | error, Some bdu -> error, bdu
  in
  (*-----------------------------------------------------------*)
  (*check the freshness *)
  (*let proj (a, b, _, _) = (a, b) in
  let proj' (a, _, c, _) = (a, c) in
  let each_pair (x, y) = proj x, proj' x, proj y, proj' y in*)
  (*-----------------------------------------------------------*)
  (*new bdu, union*)
  let error, handler, new_bdu =
    Ckappa_sig.Views_bdu.mvbdu_or
      parameter handler error bdu_old mvbdu
  in
  (*compare mvbdu and old mvbdu*)
  (*if Ckappa_sig.Views_bdu.equal new_bdu bdu_false
     &&
     PairAgentSite_map_and_set.Set.mem
       (each_pair pair)
       store_set
  then
    (*nothing change*)
    error, handler, store_result
  else*)
  (*different*)
  (*print each step*)
    let error, handler =
      if Remanent_parameters.get_dump_reachability_analysis_diff parameter
      then
        let parameter = Remanent_parameters.update_prefix parameter "                " in
        print_site_accross_domain
          ~verbose:false
          ~dump_any:true parameter error kappa_handler handler pair mvbdu
      else error, handler
    in
    (*-----------------------------------------------------------*)
    let error, store_result =
      PairAgentSitesState_map_and_set.Map.add_or_overwrite
        parameter error
        pair
        new_bdu
        store_result
    in
    error, handler, store_result

    let proj (a, b, _, _) = (a, b)
    let proj' (a, _, c, _) = (a, c)
    let each_pair (x, y) = proj x, proj' x, proj y, proj' y

let add_link_and_event parameter error bdu_false handler kappa_handler pair mvbdu
    store_set store_result =
  let error, bdu_old =
    match
      PairAgentSitesState_map_and_set.Map.find_option_without_logs
        parameter error
        pair
        store_result
    with
    | error, None -> error, bdu_false
    | error, Some bdu -> error, bdu
  in
  (*-----------------------------------------------------------*)
  (*check the freshness *)
  (*let proj (a, b, _, _) = (a, b) in
  let proj' (a, _, c, _) = (a, c) in
  let each_pair (x, y) = proj x, proj' x, proj y, proj' y in*)
  (*-----------------------------------------------------------*)
  (*new bdu, union*)
  let error, handler, new_bdu =
    Ckappa_sig.Views_bdu.mvbdu_or
      parameter handler error bdu_old mvbdu
  in
  (*compare mvbdu and old mvbdu*)
  if Ckappa_sig.Views_bdu.equal new_bdu bdu_false
     &&
     PairAgentSite_map_and_set.Set.mem
       (each_pair pair)
       store_set
  then
    (*nothing change*)
    error, handler, store_set, store_result
  else
    (*different*)
    (*print each step*)
    let error, handler =
      if Remanent_parameters.get_dump_reachability_analysis_diff parameter
      then
        let parameter = Remanent_parameters.update_prefix parameter "                " in
        print_site_accross_domain
          ~verbose:false
          ~dump_any:true parameter error kappa_handler handler pair mvbdu
      else error, handler
    in
    (*-----------------------------------------------------------*)
    let error, store_result =
      PairAgentSitesState_map_and_set.Map.add_or_overwrite
        parameter error
        pair
        new_bdu
        store_result
    in
    let error, new_set =
      PairAgentSite_map_and_set.Set.add
        parameter
        error
        (each_pair pair)
        store_set
    in
    error, handler, new_set, store_result
