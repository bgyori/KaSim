(******************************************************************************)
(*  _  __ * The Kappa Language                                                *)
(* | |/ / * Copyright 2010-2017 CNRS - Harvard Medical School - INRIA - IRIF  *)
(* | ' /  *********************************************************************)
(* | . \  * This file is distributed under the terms of the                   *)
(* |_|\_\ * GNU Lesser General Public License Version 3                       *)
(******************************************************************************)

module Html = Tyxml_js.Html5

let navli () = []

let display_id = "contact-map-display"
let export_id = "contact-export"

let configuration : Widget_export.configuration =
  { Widget_export.id = export_id ;
    Widget_export.handlers =
      [ Widget_export.export_svg ~svg_div_id:display_id ()
      ; Widget_export.export_png ~svg_div_id:display_id ()
      ; Widget_export.export_json
          ~serialize_json:(fun () ->
              let model = React.S.value State_project.model in
                let contact_map = model.State_project.model_contact_map in
              (match contact_map with
               | None -> "null"
               | Some parse -> Api_types_j.string_of_contact_map parse
              )
            )
      ];
    show = React.S.map
        (fun model ->
           match model.State_project.model_contact_map with
             | None -> false
             | Some data -> Array.length data > 0
        )
        State_project.model
  }


let xml () =
  let export_controls =
    Widget_export.content configuration
  in
  [%html {|<div>
             <div class="row">
                <div id="|}display_id{|" class="col-sm-8">
                 |}[ Html.entity "nbsp" ]{|
	        </div>
	    </div>
	   |}[ export_controls ]{|
        </div>|}]

let content () = [ Html.div [xml ()] ]

let update
    (data : Api_types_j.contact_map)
    (contactmap : Js_contact.contact_map Js.t) : unit =
  let () = Common.debug (Js.string "updating") in
  (* quick cheat to get the count of the agents *)
  let json : string =
    Api_types_j.string_of_site_graph data in
  let model = React.S.value State_project.model in
  let contact_map = model.State_project.model_contact_map in
  let () = Common.debug (Js.string json) in
    contactmap##setData
      (Js.string json)
      (Js.Opt.option (Option_util.map Api_data.agent_count contact_map))

let onload () =
  let () = Widget_export.onload configuration in
  let contactmap : Js_contact.contact_map Js.t =
    Js_contact.create_contact_map display_id false in
  let _ =
    React.S.map
      (fun model->
         match model.State_project.model_contact_map with
         | None -> (contactmap##clearData)
         | Some data ->
           if Array.length data > 0 then
             update data contactmap
             else
               contactmap##clearData)
      State_project.model
  in
  Common.jquery_on
    "#navcontact"
    "shown.bs.tab"
    (fun _ ->
       match (React.S.value State_project.model).State_project.model_contact_map with
       | None -> (contactmap##clearData)
       | Some data -> update data contactmap)

let onresize () : unit = ()
