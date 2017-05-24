(******************************************************************************)
(*  _  __ * The Kappa Language                                                *)
(* | |/ / * Copyright 2010-2017 CNRS - Harvard Medical School - INRIA - IRIF  *)
(* | ' /  *********************************************************************)
(* | . \  * This file is distributed under the terms of the                   *)
(* |_|\_\ * GNU Lesser General Public License Version 3                       *)
(******************************************************************************)

exception BadResponseCode of int
exception TimeOut

open Lwt.Infix

let send
    ?(timeout : float option)
    (url : string)
    (meth : Common.meth)
    ?(data : string option)
    (hydrate : string -> 'a)
  : 'a Api.result Lwt.t =
  let reply,feeder = Lwt.task () in
  let handler status response_text =
    let result_code : Api.manager_code option =
      match status with
      | 200 -> Some `OK
      | 201 -> Some `CREATED
      | 202 -> Some `ACCEPTED
      | 400 -> Some `ERROR
      | 404 -> Some `NOT_FOUND
      | 409 -> Some `CONFLICT
      | _ -> None in
    let result =
      match result_code with
      | None ->
        Api_common.result_error_exception (BadResponseCode status)
      | Some result_code ->
        if (400 <= status) && (status < 500) then
          Api_common.result_messages
            ~result_code
            (Api_types_j.errors_of_string response_text)
        else
          let response = hydrate response_text in
          let () = Common.debug response in
          Api_common.result_ok response in
    let () = Lwt.wakeup feeder result in ()
  in
  let () =
    Common.ajax_request
      ~url:url
      ~meth:meth
      ?timeout
      ?data
      ~handler:handler in
   reply

class manager
    ?(timeout:float = 30.0)
    (url:string) =
  object(self)
  method message :
      Mpi_message_j.request -> Mpi_message_j.response Lwt.t =
    function
    | `EnvironmentInfo  () ->
      send
        ~timeout
        (Format.sprintf "%s/v2" url)
        `GET
        (fun result ->
             (`EnvironmentInfo (Mpi_message_j.environment_info_of_string result)))
    | `FileCreate (project_id,file) ->
      send
        ~timeout
        (Format.sprintf "%s/v2/projects/%s/files" url project_id)
        `POST
        ~data:(Api_types_j.string_of_file file)
        (fun result ->
           (`FileCreate (Mpi_message_j.file_metadata_of_string result)))
    | `FileDelete (project_id,file_id) ->
      send
        (Format.sprintf "%s/v2/projects/%s/files/%s" url project_id file_id)
        `DELETE
        (fun result ->
           (`FileDelete (Api_types_j.unit_t_of_string result)))
    | `FileGet (project_id,file_id) ->
      send
        (Format.sprintf "%s/v2/projects/%s/files/%s" url project_id file_id)
        `GET
        (fun result ->
           (`FileGet (Mpi_message_j.file_of_string result)))
    | `FileCatalog project_id ->
      send
        (Format.sprintf "%s/v2/projects/%s/files" url project_id)
        `GET
        (fun result ->
           (`FileCatalog (Mpi_message_j.file_catalog_of_string result)))
    | `FileUpdate (project_id,file_id,file_modification) ->
      send
        (Format.sprintf "%s/v2/projects/%s/files/%s" url project_id file_id)
        `PUT
        ~data:(Api_types_j.string_of_file_modification file_modification)
        (fun result ->
             (`FileUpdate (Mpi_message_j.file_metadata_of_string result)))
    | `ProjectCatalog () ->
      send
        (Format.sprintf "%s/v2/projects" url)
        `GET
        (fun result ->
             (`ProjectCatalog (Mpi_message_j.project_catalog_of_string result)))
    | `ProjectCreate project_parameter ->
      send
        (Format.sprintf "%s/v2/projects" url)
        `POST
        ~data:(Api_types_j.string_of_project_parameter project_parameter)
        (fun result ->
             (`ProjectCreate (Api_types_j.unit_t_of_string result)))
    | `ProjectDelete project_id ->
      send
        (Format.sprintf "%s/v2/projects/%s" url project_id)
        `DELETE
        (fun result ->
             (`ProjectDelete (Api_types_j.unit_t_of_string result)))
    | `ProjectParse project_id ->
      send
        (Format.sprintf "%s/v2/projects/%s/parse" url project_id)
        `GET
        (fun result ->
             (`ProjectParse (Mpi_message_j.project_parse_of_string result)))
    | `ProjectGet project_id ->
      send
        (Format.sprintf "%s/v2/projects/%s" url project_id)
        `GET
        (fun result ->
             (`ProjectGet (Mpi_message_j.project_of_string result)))
    | `SimulationContinue (project_id,simulation_parameter) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/continue"
           url project_id)
        `PUT
        ~data:(Api_types_j.string_of_simulation_parameter
                 simulation_parameter)
        (fun _ -> (`SimulationContinue ()))
    | `SimulationDelete project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation"
           url
           project_id)
        `DELETE
        (fun _ -> (`SimulationDelete ()))
    | `SimulationDetailFileLine (project_id,file_line_id) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/filelines/%s"
           url
           project_id
           (match file_line_id with
              None -> ""
            |Some file_line_id -> file_line_id
           ))
        `GET
        (fun result ->
           (`SimulationDetailFileLine
                        (Mpi_message_j.file_line_detail_of_string result)))
    | `SimulationDetailFluxMap (project_id,flux_map_id) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/fluxmaps/%s"
           url
           project_id
           flux_map_id)
        `GET
        (fun result ->
             (`SimulationDetailFluxMap (Mpi_message_j.flux_map_of_string result)))
    | `SimulationDetailLogMessage project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/logmessages"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationDetailLogMessage
                        (Mpi_message_j.log_message_of_string result)))
    | `SimulationDetailPlot (project_id,plot_parameters) ->
      let args =
        String.concat
          "&"
          (List.map
             (fun (key,value) -> Format.sprintf "%s=%s" key value)
             (match plot_parameters.Api_types_j.plot_parameter_plot_limit with
              | None -> []
              | Some plot_limit ->
                (match plot_limit.Api_types_j.plot_limit_offset with
                 | None -> []
                 | Some plot_limit_offset -> [("plot_limit_offset",string_of_int plot_limit_offset)])
                @
                (match plot_limit.Api_types_j.plot_limit_points with
                 | None -> []
                 | Some plot_limit_points -> [("plot_limit_points",string_of_int plot_limit_points)])
             )) in
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/plot"
           url
           project_id)
        `GET
        ~data:args
        (fun result ->
             (`SimulationDetailPlot (Mpi_message_j.plot_detail_of_string result)))
    | `SimulationDetailSnapshot (project_id,snapshot_id) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/snapshots/%s"
           url
           project_id
           snapshot_id)
        `GET
        (fun result ->
           (`SimulationDetailSnapshot
              (Mpi_message_j.snapshot_detail_of_string result)))
    | `SimulationInfo project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation"
           url
           project_id)
        `GET
        (fun result ->
             (`SimulationInfo (Mpi_message_j.simulation_info_of_string result)))
    | `SimulationEfficiency project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/efficiency"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationEfficiency
                        (Mpi_message_j.simulation_efficiency_of_string result)))
    | `SimulationTrace project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/trace"
           url
           project_id)
        `GET
        (fun s -> (`SimulationTrace s))
    | `SimulationCatalogFileLine project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/filelines"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationCatalogFileLine
                        (Mpi_message_j.file_line_catalog_of_string result)))
    | `SimulationCatalogFluxMap project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/fluxmaps"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationCatalogFluxMap
                        (Mpi_message_j.flux_map_catalog_of_string result)))
    | `SimulationCatalogSnapshot project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/snapshots"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationCatalogSnapshot
                        (Mpi_message_j.snapshot_catalog_of_string result)))
    | `SimulationPause project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/pause"
           url
           project_id)
        `PUT
        (fun _ -> (`SimulationPause ()))
    | `SimulationParameter project_id ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/parameter"
           url
           project_id)
        `GET
        (fun result ->
           (`SimulationParameter
                        (Mpi_message_j.simulation_parameter_of_string result)))
    | `SimulationPerturbation
        (project_id,simulation_perturbation) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation/perturbation"
           url
           project_id)
        `PUT
        ~data:(Api_types_j.string_of_simulation_perturbation
                 simulation_perturbation)
        (fun _ -> (`SimulationPerturbation ()))
    | `SimulationStart
        (project_id,simulation_parameter) ->
      send
        (Format.sprintf
           "%s/v2/projects/%s/simulation"
           url
           project_id)
        `POST
        ~data:(Api_types_j.string_of_simulation_parameter simulation_parameter)
        (fun result ->
           (`SimulationStart
                        (Mpi_message_j.simulation_artifact_of_string result)))

  inherit Mpi_api.manager_base ()
  method terminate () = () (*TODO*)

  method init_static_analyser_raw data =
    send
      (Format.sprintf "%s/v2/analyses" url)
      `PUT ~data
      (fun x ->
         match Yojson.Basic.from_string x with
         | `Null -> ()
         | x ->
           raise
             (Yojson.Basic.Util.Type_error ("Not a KaSa INIT response: ", x)))
    >>= Api_common.result_map
      ~ok:(fun _ x -> Lwt.return_ok x)
      ~error:(fun _ -> function
          | e :: _ -> Lwt.return_error e.Api_types_t.message_text
          | [] -> Lwt.return_error "Rest_api empty error")

  method init_static_analyser compil =
    self#init_static_analyser_raw
      (Yojson.Basic.to_string (Ast.compil_to_json compil))

  method get_contact_map accuracy =
    send
      (match accuracy with
       | Some accuracy ->
         Format.sprintf "%s/v2/analyses/contact_map/%s" url
           (Yojson.Basic.to_string (Remanent_state.accuracy_to_json accuracy))
       | None -> Format.sprintf "%s/v2/analyses/contact_map" url)
      `GET
      (fun x -> Yojson.Basic.from_string x)
    >>= Api_common.result_map
      ~ok:(fun _ x -> Lwt.return_ok x)
      ~error:(fun _ -> function
          | e :: _ -> Lwt.return_error e.Api_types_t.message_text
          | [] -> Lwt.return_error "Rest_api empty error")

  method get_influence_map accuracy =
    send
      (match accuracy with
       | Some accuracy ->
         Format.sprintf "%s/v2/analyses/influence_map/%s" url
           (Yojson.Basic.to_string (Remanent_state.accuracy_to_json accuracy))
       | None -> Format.sprintf "%s/v2/analyses/influence_map" url)
      `GET
      (fun x -> Yojson.Basic.from_string x)
    >>= Api_common.result_map
      ~ok:(fun _ x -> Lwt.return_ok x)
      ~error:(fun _ -> function
          | e :: _ -> Lwt.return_error e.Api_types_t.message_text
          | [] -> Lwt.return_error "Rest_api empty error")

  method get_dead_rules =
    send
      (Format.sprintf "%s/v2/analyses/dead_rules" url)
      `GET
      (fun x -> Yojson.Basic.from_string x)
    >>= Api_common.result_map
      ~ok:(fun _ x -> Lwt.return_ok x)
      ~error:(fun _ -> function
          | e :: _ -> Lwt.return_error e.Api_types_t.message_text
          | [] -> Lwt.return_error "Rest_api empty error")

  method  get_constraints_list =
    send
      (Format.sprintf "%s/v2/analyses/constraints" url)
      `GET
      (fun x -> Yojson.Basic.from_string x)
    >>= Api_common.result_map
      ~ok:(fun _ x -> Lwt.return_ok x)
      ~error:(fun _ -> function
          | e :: _ -> Lwt.return_error e.Api_types_t.message_text
          | [] -> Lwt.return_error "Rest_api empty error")
end
