(******************************************************************************)
(*  _  __ * The Kappa Language                                                *)
(* | |/ / * Copyright 2010-2017 CNRS - Harvard Medical School - INRIA - IRIF  *)
(* | ' /  *********************************************************************)
(* | . \  * This file is distributed under the terms of the                   *)
(* |_|\_\ * GNU Lesser General Public License Version 3                       *)
(******************************************************************************)

class type snapshot =
  object
    method exportJSON  : Js.js_string Js.t -> unit Js.meth
    method setData : Js.js_string Js.t -> (*int Js.Opt.t ->*) unit Js.meth
    method clearData : unit Js.meth
  end;;

let create_snapshot (id : string) : snapshot Js.t =
  Js.Unsafe.new_obj (Js.Unsafe.variable "Snapshot")
    [| Js.Unsafe.inject (Js.string id) |]
