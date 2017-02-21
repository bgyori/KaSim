(**
   * symmetries.ml
   * openkappa
   * Jérôme Feret & Ly Kim Quyen, projet Antique, INRIA Paris-Rocquencourt
   *
   * Creation: 2016, the 5th of December
   * Last modification: Time-stamp: <Feb 21 2017>
   *
   * Abstract domain to record relations between pair of sites in connected agents.
   *
   * Copyright 2010,2011,2012,2013,2014,2015,2016 Institut National de Recherche
   * en Informatique et en Automatique.
   * All rights reserved.  This file is distributed
   * under the terms of the GNU Library General Public License *)

(***************************************************************************)
(*TYPE*)
(***************************************************************************)

type contact_map =
  ((string list) * (string*string) list)
    Mods.StringSetMap.Map.t Mods.StringSetMap.Map.t

type partitioned_contact_map =
  ((string list list) * (string list list))
    Mods.StringSetMap.Map.t

type symmetries =
  {
    store_contact_map : contact_map ;
    store_partition_contact_map : partitioned_contact_map ;
    store_partition_with_predicate : partitioned_contact_map
  }

(***************************************************************************)
(*PARTITION THE CONTACT MAP*)
(***************************************************************************)

let add k data map =
  let old =
    match
      Mods.IntMap.find_option k map
    with
    | None -> []
    | Some l -> l
  in
  Mods.IntMap.add k (data::old) map

let partition cache hash int_of_hash f map =
  let map =
    fst
      (
        Mods.StringMap.fold
          (fun key data (inverse,cache) ->
             let range = f data in
             if range = []
             then inverse,cache
             else
               let sorted_range = List.sort compare range in
               let cache, hash = hash cache sorted_range in
               let inverse = add (int_of_hash hash) key inverse in
               inverse,cache
          )
          map
          (Mods.IntMap.empty,
           cache))
  in
  List.rev
    (Mods.IntMap.fold
       (fun _ l sol -> l::sol)
       map
       [])

module State =
struct
  type t = string
  let compare = compare
  let print f s = Format.fprintf f "%s" s
end
module StateList = Hashed_list.Make (State)
module BindingType =
struct
  type t = string*string
  let compare = compare
  let print f (s1,s2) = Format.fprintf f "%s.%s" s1 s2
end
module BindingTypeList = Hashed_list.Make (BindingType)

let collect_partition_contact_map contact_map =
  Mods.StringMap.map
    (fun sitemap ->
       let cache1 = StateList.init () in
       let cache2 = BindingTypeList.init () in
       let internal_state_partition =
         partition cache1 StateList.hash
           StateList.int_of_hashed_list fst sitemap
       in
       let binding_state_partition =
         partition
           cache2 BindingTypeList.hash BindingTypeList.int_of_hashed_list snd
           sitemap
       in
       internal_state_partition,
       binding_state_partition
    )
    contact_map

(***************************************************************************)

let refine_class p l result =
  let rec aux to_do classes =
    match to_do
    with
    | [] -> classes
    | h::_ ->
      let newclass,others = List.partition (p h) to_do in
      aux others (newclass::classes)
  in
  aux l result

let refine_class p l =
  List.fold_left
    (fun result l -> refine_class p l result)
    [] l

let collect_partition_with_predicate
    p_internal_state
    p_binding_state
    partitioned_contact_map =
    Mods.StringMap.mapi
      (fun agent_type (internal_sites_partition,binding_sites_partition) ->
    refine_class (p_internal_state agent_type) internal_sites_partition,
    refine_class (p_binding_state agent_type) binding_sites_partition)
      partitioned_contact_map

(***************************************************************************)
(*PRINT*)
(***************************************************************************)

let print_l parameters l =
  if l <> []
  then
    List.iter
      (fun equ_class ->
      let () =
        List.iter
          (Loggers.fprintf (Remanent_parameters.get_logger parameters) "%s,") equ_class
      in
      let () =
        Loggers.print_newline (Remanent_parameters.get_logger parameters)
      in
      ())
      l

let print_partition_contact_map parameters partitioned_contact_map =
  Mods.StringMap.iter
    (fun agent (l1,l2) ->
       let () =
         Loggers.fprintf
           (Remanent_parameters.get_logger parameters)
           "Agent: %s"
           agent
       in
       let () =
         Loggers.print_newline
           (Remanent_parameters.get_logger parameters)
       in
       let () =
         Loggers.fprintf
           (Remanent_parameters.get_logger parameters) "internal sites:"
       in
       let () =
         print_l parameters l1
       in
       let () =
         Loggers.fprintf
           (Remanent_parameters.get_logger parameters) "binding sites:" in

       let () =
         print_l parameters l2
       in ()
    ) partitioned_contact_map

let print_contact_map parameters contact_map =
  Mods.StringMap.iter
    (fun agent sitemap ->
       let () =
         Loggers.fprintf (Remanent_parameters.get_logger parameters)
           "agent:%s\n"
           agent
       in
       Mods.StringMap.iter
         (fun site (l1,l2) ->
         let () =
           Loggers.fprintf (Remanent_parameters.get_logger parameters)
             "  site:%s\n"
             site
         in
         let () =
           if l1<>[]
           then
             let () =
               Loggers.fprintf (Remanent_parameters.get_logger parameters)
                 "internal_states:"
             in
             let () =
               List.iter
                 (Loggers.fprintf (Remanent_parameters.get_logger parameters) "%s;")
                 l1
             in
             let () =
               Loggers.print_newline (Remanent_parameters.get_logger parameters)
             in
             ()
         in
         let () =
           if l2<>[]
           then
             let () =
               Loggers.fprintf (Remanent_parameters.get_logger parameters)
                 "binding_states:"
             in
             let () =
               List.iter
                 (fun (s1,s2) ->
                    Loggers.fprintf (Remanent_parameters.get_logger parameters) "%s.%s;" s1 s2)
                 l2
             in
             let () =
               Loggers.print_newline (Remanent_parameters.get_logger parameters)
             in
             ()
         in
         ())
         sitemap)
    contact_map

(***************************************************************************)
(*DETECT SYMMETRIES*)
(***************************************************************************)

let detect_symmetries parameters (contact_map:contact_map) =
  (*-------------------------------------------------------------*)
  (*PARTITION A CONTACT MAP RETURN A LIST OF LIST OF SITES*)
  let store_partition_contact_map =
    collect_partition_contact_map
      contact_map
  in
  (*-------------------------------------------------------------*)
  (*PARTITION A CONTACT MAP RETURN A LIST OF LIST OF SITES WITH A PREDICATE*)
  let store_partition_with_predicate =
    collect_partition_with_predicate
      (fun a b c -> b = c) (*REPLACE THIS PREDICATE*)
      (fun a b c -> b = c) (*REPLACE THIS PREDICATE*)
      store_partition_contact_map
      in
  (*-------------------------------------------------------------*)
  let store_result =
    {
      store_contact_map = contact_map;
      store_partition_contact_map = store_partition_contact_map;
      store_partition_with_predicate = store_partition_with_predicate
    }
  in
  (*-------------------------------------------------------------*)
  (*PRINT*)
  let () =
    if Remanent_parameters.get_trace parameters
    then
      let () =
        Loggers.fprintf (Remanent_parameters.get_logger parameters)
          "Contact map\n";
        print_contact_map parameters store_result.store_contact_map
      in
      let () =
      Loggers.fprintf (Remanent_parameters.get_logger parameters)
        "Partitioned contact map\n";
      print_partition_contact_map
        parameters store_result.store_partition_contact_map
      in
      let _ =
        Loggers.fprintf (Remanent_parameters.get_logger parameters)
          "With predictate\n";
        print_partition_contact_map
          parameters store_result.store_partition_with_predicate
      in
      ()
  in
   store_result
