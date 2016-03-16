 (**
  * influence_map.ml
  * openkappa
  * Jérôme Feret, projet Abstraction, INRIA Paris-Rocquencourt
  * 
  * Creation: March the 10th of 2011
  * Last modification: February the 25th of 2015
  * 
  * Compute the influence relations between rules and sites. 
  *  
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et   
  * en Automatique.  All rights reserved.  This file is distributed     
  * under the terms of the GNU Library General Public License *)

let warn parameters mh message exn default = 
     Exception.warn parameters mh (Some "Influence_map") message exn (fun () -> default) 

let local_trace = true
                                                     
let generic_add fold2_common agent_diag rule_diag parameters error handler n a b c = 
  fold2_common
     parameters 
     error 
     (fun parameters error _ a b map -> 
        Int_storage.Quick_Nearly_inf_Imperatif.fold 
           parameters 
           error 
           (fun parameters error rule a map -> 
               Int_storage.Quick_Nearly_inf_Imperatif.fold 
                    parameters 
                    error 
                    (fun parameters error rule' a' map -> 
                        let rule' = n + rule' in 
                        if (not rule_diag && rule = rule') 
			then 
                          (error,map) 
                        else 
                          let key = rule,rule' in 
                          let old =
			    Quark_type.Int2SetMap.Map.find_default
			      Quark_type.Labels.empty_couple key map in
			  let error,couple =
			    Quark_type.Labels.add_couple
			      parameters error (agent_diag || not (rule = rule')) a a' old in
			  error,if Quark_type.Labels.is_empty_couple couple
			  then map
			  else 
			    Quark_type.Int2SetMap.Map.add key couple map)
                 b 
                 map)
          a
          map)
    a b c 

let compute_influence_map parameters error handler quark_maps nrules = 
  let wake_up_map = Quark_type.Int2SetMap.Map.empty in 
  let inhibition_map  = Quark_type.Int2SetMap.Map.empty in 
  let error,wake_up_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      true
      true
      parameters 
      error 
      handler 
      0 
      quark_maps.Quark_type.agent_modif_plus 
      quark_maps.Quark_type.agent_test 
      wake_up_map
  in
  let error,wake_up_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      true
      true
      parameters 
      error 
      handler 
      nrules 
      quark_maps.Quark_type.agent_modif_plus 
      quark_maps.Quark_type.agent_var_plus
      wake_up_map
  in
   let error,inhibition_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      true
      true
      parameters 
      error 
      handler 
      nrules 
      quark_maps.Quark_type.agent_modif_plus 
      quark_maps.Quark_type.agent_var_minus
      inhibition_map 
  in
  let error,wake_up_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      true
      true
      parameters 
      error 
      handler
      0 
      quark_maps.Quark_type.site_modif_plus 
      quark_maps.Quark_type.site_test
      wake_up_map
  in
  let error,wake_up_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      true
      true
      parameters 
      error 
      handler
      nrules
      quark_maps.Quark_type.site_modif_plus 
      quark_maps.Quark_type.site_var_plus
      wake_up_map
  in
  let error,inhibition_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      true
      true
      parameters 
      error 
      handler
      nrules
      quark_maps.Quark_type.site_modif_plus 
      quark_maps.Quark_type.site_var_minus
      inhibition_map 
  in
  let error,inhibition_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      false
      true
      parameters 
      error 
      handler 
      0
      quark_maps.Quark_type.agent_modif_minus 
      quark_maps.Quark_type.agent_test
      inhibition_map
  in
  let error,inhibition_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      false
      true
      parameters 
      error 
      handler 
      0
      quark_maps.Quark_type.site_modif_minus 
      quark_maps.Quark_type.site_test
      inhibition_map
  in
  let error,inhibition_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      false
      true 
      parameters 
      error 
      handler 
      nrules
      quark_maps.Quark_type.agent_modif_minus 
      quark_maps.Quark_type.agent_var_plus
      inhibition_map
  in
  let error,inhibition_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      false
      true 
      parameters 
      error 
      handler 
      nrules
      quark_maps.Quark_type.site_modif_minus 
      quark_maps.Quark_type.site_var_plus
      inhibition_map
  in
   let error,wake_up_map = 
    generic_add 
      (*Quark_type.AgentMap.fold2_common*)
      Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      true
      true
      parameters 
      error 
      handler 
      nrules
      quark_maps.Quark_type.agent_modif_minus 
      quark_maps.Quark_type.agent_var_minus
      wake_up_map
  in
  let error,wake_up_map = 
    generic_add 
      Quark_type.SiteMap.fold2_common
      true
      true
      parameters 
      error 
      handler 
      nrules
      quark_maps.Quark_type.site_modif_minus 
      quark_maps.Quark_type.site_var_minus
      wake_up_map
  in
  let error,inhibition_map =
    generic_add
      (Quark_type.StringMap.Map.fold2_sparse_with_logs Exception.wrap)
      false
      true
      parameters
      error
      handler
      nrules
      quark_maps.Quark_type.dead_agent
      quark_maps.Quark_type.dead_agent_plus
      inhibition_map 
  in
  let error,inhibition_map =
    generic_add
      (Quark_type.StringMap.Map.fold2_sparse_with_logs Exception.wrap)
      false
      true
      parameters
      error
      handler
      0
      quark_maps.Quark_type.dead_agent
      quark_maps.Quark_type.dead_agent
      inhibition_map 
  in
  let error,wake_up_map =
    generic_add
      (Quark_type.StringMap.Map.fold2_sparse_with_logs Exception.wrap)
      false
      true
      parameters
      error
      handler
      nrules
      quark_maps.Quark_type.dead_agent
      quark_maps.Quark_type.dead_agent_minus
      wake_up_map
  in
  let fold_site parameters error f  =
    (*Quark_type.AgentMap.fold2_common*)
    Ckappa_sig.Agent_type_quick_nearly_Inf_Int_storage_Imperatif.fold2_common
      parameters
      error
      (fun parameters error _ a b   ->
       Cckappa_sig.KaSim_Site_map_and_set.Map.fold2_sparse
	 parameters error
	 f
         a
         b )
  in 
   let error,inhibition_map =
    generic_add
      fold_site
       false
      true
      parameters
      error
      handler
      0
      quark_maps.Quark_type.dead_sites
      quark_maps.Quark_type.dead_sites
      inhibition_map 
   in
   let error,inhibition_map =
    generic_add
      fold_site
      false
      true
      parameters
      error
      handler
      nrules
      quark_maps.Quark_type.dead_sites
      quark_maps.Quark_type.dead_sites_plus
      inhibition_map 
   in 
  let error,wake_up_map =
    generic_add
      fold_site
      false
      true
      parameters
      error
      handler
      nrules
      quark_maps.Quark_type.dead_sites
      quark_maps.Quark_type.dead_sites_minus
      wake_up_map
  in
   let error,inhibition_map =
    generic_add
      Quark_type.DeadSiteMap.fold2_common     
      false
      true
      parameters
      error
      handler
      0
      quark_maps.Quark_type.dead_states
      quark_maps.Quark_type.dead_states
      inhibition_map 
   in
   let error,inhibition_map =
     generic_add
       Quark_type.DeadSiteMap.fold2_common     
       false
       true
       parameters
       error
       handler
       nrules
       quark_maps.Quark_type.dead_states
       quark_maps.Quark_type.dead_states_plus
       inhibition_map 
   in
   let error,wake_up_map =
    generic_add
      Quark_type.DeadSiteMap.fold2_common
      false
      true
      parameters
      error
      handler
      nrules
      quark_maps.Quark_type.dead_states
      quark_maps.Quark_type.dead_states_minus
      wake_up_map
  in
      error,wake_up_map,inhibition_map
