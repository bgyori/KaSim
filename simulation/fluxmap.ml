(******************************************************************************)
(*  _  __ * The Kappa Language                                                *)
(* | |/ / * Copyright 2010-2017 CNRS - Harvard Medical School - INRIA - IRIF  *)
(* | ' /  *********************************************************************)
(* | . \  * This file is distributed under the terms of the                   *)
(* |_|\_\ * GNU Lesser General Public License Version 3                       *)
(******************************************************************************)

let create_flux env counter flux_kind flux_name =
  let size = Model.nb_syntactic_rules env + 1 in
  {
    Data.flux_name; Data.flux_kind;
    Data.flux_start = Counter.current_time counter;
    Data.flux_hits = Array.make size 0;
    Data.flux_fluxs = Array.make_matrix size size 0.;
  }

let incr_flux_flux of_rule on_rule v flux =
  flux.Data.flux_fluxs.(of_rule).(on_rule) <-
    flux.Data.flux_fluxs.(of_rule).(on_rule) +. v

let incr_flux_hit of_rule flux =
  flux.Data.flux_hits.(of_rule) <- succ flux.Data.flux_hits.(of_rule)

let get_flux_name flux = flux.Data.flux_name
let flux_has_name name flux = flux.Data.flux_name = name

let stop_flux env counter flux_data =
  let size = Model.nb_syntactic_rules env + 1 in
  let flux_rules =
    Array.init size
      (fun x -> Format.asprintf "%a" (Model.print_ast_rule ~env) x) in
  let () =
    match flux_data.Data.flux_kind with
    | Primitives.ABSOLUTE -> ()
    | Primitives.RELATIVE | Primitives.PROBABILITY ->
      Array.iteri
        (fun i -> Array.iteri
            (fun j x ->
               flux_data.Data.flux_fluxs.(i).(j) <-
                 if flux_data.Data.flux_hits.(i) = 0 then x
                 else x /. float_of_int flux_data.Data.flux_hits.(i)))
        flux_data.Data.flux_fluxs in
  { Data.flux_rules; Data.flux_data;
    Data.flux_end = Counter.current_time counter }
