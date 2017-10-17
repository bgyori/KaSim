(******************************************************************************)
(*  _  __ * The Kappa Language                                                *)
(* | |/ / * Copyright 2010-2017 CNRS - Harvard Medical School - INRIA - IRIF  *)
(* | ' /  *********************************************************************)
(* | . \  * This file is distributed under the terms of the                   *)
(* |_|\_\ * GNU Lesser General Public License Version 3                       *)
(******************************************************************************)

(**************)
(* JSon labels*)
(**************)

let agent="agent name"
let contactmap="contact map"
let accuracy_string = "accuracy"
let dead_rules = "dead rules"
let map = "map"
let interface="interface"
let site="site name"
let stateslist="states list"
let sitename = "site_name"
let sitetype = "site_type"
let sitelinks = "port_links"
let sitestates = "port_states"
let sitenodename = "node_type"
let sitenodesites = "node_sites"
let hyp = "site graph"
let refinement = "site graph list"
let domain_name = "domain name"
let refinements_list = "refinements list"
let refinement_lemmas="refinement lemmas"
let rule_id = "id"
let label = "label"
let ast = "ast"
let position = "location"
let edit = "edit_rule"
let variable = "variable"
let rule = "rule"
let direct = "direct"
let side_effect = "side effect"
let source = "source"
let target_map = "target map"
let target = "target"
let location_pair_list = "location pair list"
let rhs = "RHS"
let lhs = "LHS"
let influencemap="influence map"
let wakeup = "wake-up map"
let inhibition = "inhibition map"
let nodes = "nodes"
let total_string = "total"
let fwd_string = "fwd"
let bwd_string = "bwd"
let direction = "direction"

(*******************)
(* Accuracy levels *)
(*******************)

type accuracy_level = Low | Medium | High | Full
let accuracy_levels = [ Low; Medium; High; Full ]
let contact_map_accuracy_levels = [ Low; High ]
let influence_map_accuracy_levels = [ Low; Medium; High]
let accuracy_to_string = function
  | Low -> "low"
  | Medium -> "medium"
  | High -> "high"
  | Full -> "full"

let accuracy_to_json x = JsonUtil.of_string (accuracy_to_string x)

let accuracy_of_string = function
  | "low" -> Some Low
  | "medium" -> Some Medium
  | "high" -> Some High
  | "full" -> Some Full
  | _ -> None

let accuracy_of_json json =
  match accuracy_of_string (JsonUtil.to_string json) with
  | Some x -> x
  | None ->
    raise
      (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "accuracy level",json))

(******************************************************************)

module AccuracySetMap =
  SetMap.Make
    (struct
      type t = accuracy_level
      let compare a b =
        match a,b with
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

(******************************************************************)

(***************)
(* Contact map *)
(***************)

type contact_map = User_graph.connected_component

let site_type_to_json = function
  | User_graph.Counter i -> `List [ `String "counter"; `Int i ]
  | User_graph.Port p ->
    `List [
      `String "port";
      `Assoc [
        sitelinks,
        JsonUtil.of_list (fun (x,y) -> `List [`Int x; `Int y])
          p.User_graph.port_links;

        sitestates,
        JsonUtil.of_list JsonUtil.of_string p.User_graph.port_states
      ]
    ]

let site_to_json site =
  `Assoc
    [
      sitename, JsonUtil.of_string site.User_graph.site_name;
      sitetype, site_type_to_json site.User_graph.site_type
    ]

let site_type_of_json = function
  | `List [ `String "counter"; `Int i ] -> User_graph.Counter i
  | `List [ `String "port"; `Assoc l ] as x ->
    begin
      try
        let port_links =
          let json = List.assoc sitelinks l in
          JsonUtil.to_list ~error_msg:"link list"
            (function
              | `List [ `Int ag; `Int si ] -> (ag,si)
              | x -> raise (Yojson.Basic.Util.Type_error
                              (JsonUtil.build_msg "sites_links",x)))
            json
        in
        let port_states =
          let json = List.assoc sitestates l in
          JsonUtil.to_list ~error_msg:"state list"
            (JsonUtil.to_string ~error_msg:"state")
            json
        in
        User_graph.Port { User_graph.port_links; User_graph.port_states }
      with
      | _ ->
        raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node type",x))
    end
  | x -> raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node type",x))

let site_of_json =
  function
    | `Assoc l as x ->
      begin
        try
          let site_name =
            let json = List.assoc sitename l in
            JsonUtil.to_string json
          in
          let site_type =
            let json = List.assoc sitetype l in
            site_type_of_json json
          in
          {
            User_graph.site_name;
            User_graph.site_type;
          }
        with
        | _ ->
          raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node",x))
      end
    | x -> raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node",x))


let site_node_sites_to_json list =
  JsonUtil.of_array site_to_json list

let site_node_sites_of_json =
  JsonUtil.to_array
    ~error_msg:"site node sites"
    site_of_json



let site_node_to_json node =
  `Assoc
    [ sitenodename,
      JsonUtil.of_string node.User_graph.node_type;

      sitenodesites,
      site_node_sites_to_json node.User_graph.node_sites]


let site_node_of_json =
function
| `Assoc l as x ->
  begin
    try
      let node_type =
        let json = List.assoc sitenodename l in
        JsonUtil.to_string json
      in
      let node_sites =
        let json = List.assoc sitenodesites l in
        site_node_sites_of_json json
      in
      {
        User_graph.node_type;
        User_graph.node_sites
      }
    with
    | _ ->
      raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node",x))
  end
| x -> raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "site node",x))

let contact_map_to_json contact_map=
  `Assoc
    [contactmap,
     JsonUtil.of_pair
       ~lab1:accuracy_string ~lab2:map
       accuracy_to_json
       (JsonUtil.of_array
          site_node_to_json)
       contact_map
    ]


let contact_map_of_json =
  function
  | `Assoc l as x ->
    begin
      try
        let json = List.assoc contactmap l in
        JsonUtil.to_pair
          ~lab1:accuracy_string ~lab2:map
          ~error_msg:(JsonUtil.build_msg "contact map")
          accuracy_of_json
          (JsonUtil.to_array
             ~error_msg:(JsonUtil.build_msg "site nodes list")
             site_node_of_json
          )
          json
  with
      | _ -> raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "contact map",x))
    end
  | x -> raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "contact map",x))

(******************************************************************************)

(**************)
(* dead rules *)
(**************)

type rule_direction =
  | Direct_rule
  | Reverse_rule
  | Both_directions
  | Dummy_rule_direction
  | Variable


type rule =
  {
    rule_id: int;
    rule_label: string ;
    rule_ast: string;
    rule_position: Locality.t;
    rule_direction: rule_direction;
  }

let direction_to_json d =
  match d with
  | Direct_rule -> `String "direct"
  | Reverse_rule -> `String "reverse"
  | Both_directions -> `String "both"
  | Dummy_rule_direction -> `String "dummy"
  | Variable -> `String "variable"


let json_to_direction s =
  match s with
  | `String "direct" -> Direct_rule
  | `String "reverse" -> Reverse_rule
  | `String "both" -> Both_directions
  | `String "dummy" -> Dummy_rule_direction
  | `String "variable" -> Variable
  | x ->
    raise (Yojson.Basic.Util.Type_error ("rule direction",x))


let rule_to_json rule =
  `Assoc
    [
      rule_id,JsonUtil.of_int rule.rule_id;
      label, JsonUtil.of_string rule.rule_label;
      ast, JsonUtil.of_string rule.rule_ast;
      position,Locality.annot_to_yojson
        JsonUtil.of_unit ((),rule.rule_position);
      direction, direction_to_json rule.rule_direction
    ]

let json_to_rule =
  function
  | `Assoc l as x when List.length l = 5 ->
    begin
      try
        {
          rule_id = JsonUtil.to_int (List.assoc rule_id l) ;
          rule_label =  JsonUtil.to_string (List.assoc label l) ;
          rule_ast =  JsonUtil.to_string (List.assoc ast l) ;
          rule_position =
            snd (Locality.annot_of_yojson
               (JsonUtil.to_unit ~error_msg:(JsonUtil.build_msg "locality"))
               (List.assoc position l));
          rule_direction =
            json_to_direction (List.assoc direction l)
        }
      with Not_found ->
        raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg " rule",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error ("rule",x))

type var =
  {
    var_id: int;
    var_label: string ;
    var_ast: string;
    var_position: Locality.t
  }

let var_to_json var =
  `Assoc
    [
      rule_id,JsonUtil.of_int var.var_id;
      label, JsonUtil.of_string var.var_label;
      ast, JsonUtil.of_string var.var_ast;
      position,Locality.annot_to_yojson
        JsonUtil.of_unit ((),var.var_position)
    ]

let json_to_var =
  function
  | `Assoc l as x when List.length l = 4 ->
    begin
      try
        {
          var_id = JsonUtil.to_int (List.assoc rule_id l) ;
          var_label =  JsonUtil.to_string (List.assoc label l) ;
          var_ast =  JsonUtil.to_string (List.assoc ast l) ;
          var_position =
            snd (Locality.annot_of_yojson
                   (JsonUtil.to_unit ~error_msg:(JsonUtil.build_msg "locality"))
                   (List.assoc position l))}
      with Not_found ->
        raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg " var",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error ("var",x))

type ('rule,'var) influence_node =
  | Rule of 'rule
  | Var of 'var

let influence_node_to_json rule_to_json var_to_json a =
  match a with
  | Var i ->
    `Assoc [variable,var_to_json i]
  | Rule i  ->
    `Assoc [rule,rule_to_json i]

let influence_node_of_json json_to_rule json_to_var
  =
  function
  | `Assoc [s,json] when s = variable ->
    Var (json_to_var json)
  | `Assoc [s,json] when s = rule ->
    Rule (json_to_rule json)
  | x ->
    let error_msg = "Not a correct influence node" in
    raise (Yojson.Basic.Util.Type_error (error_msg,x))

let short_influence_node_to_json =
  influence_node_to_json JsonUtil.of_int JsonUtil.of_int

let short_influence_node_of_json =
  influence_node_of_json
    (JsonUtil.to_int ~error_msg:(JsonUtil.build_msg "rule id"))
    (JsonUtil.to_int ~error_msg:(JsonUtil.build_msg "var id"))

let refined_influence_node_to_json =
  influence_node_to_json rule_to_json var_to_json

let refined_influence_node_of_json =
  influence_node_of_json json_to_rule json_to_var

let get_short_node_opt_of_refined_node_opt node_opt =
  match node_opt with
  | None -> None
  | Some (Rule rule) -> Some (Rule rule.rule_id)
  | Some (Var var) -> Some (Var var.var_id)

module InfluenceNodeSetMap =
  SetMap.Make
    (struct
      type t = (int, int) influence_node
      let compare = compare
      let print f = function
        | Rule r -> Format.fprintf f "Rule %i" r
        | Var r -> Format.fprintf f "Var %i" r
    end)

module InfluenceNodeMap = InfluenceNodeSetMap.Map

(* Relations *)

type 'a pair = 'a * 'a

type location =
  | Direct of int
  | Side_effect of int

type half_influence_map =
  location pair list InfluenceNodeMap.t InfluenceNodeMap.t

type influence_map =
  {
    nodes: (rule, var) influence_node list ;
    positive: half_influence_map ;
    negative: half_influence_map ;

  }

(* Location labels *)
let location_to_json a =
  match a with
  | Direct i -> `Assoc [direct,JsonUtil.of_int i]
  | Side_effect i  -> `Assoc [side_effect,JsonUtil.of_int i]

let location_of_json
    ?error_msg:(error_msg="Not a correct location")
  =
  function
  | `Assoc [s,json] when s=direct -> Direct (JsonUtil.to_int json)
  | `Assoc [s,json] when s=side_effect -> Side_effect (JsonUtil.to_int json)
  | x ->
    raise (Yojson.Basic.Util.Type_error (error_msg,x))

let half_influence_map_to_json =
  InfluenceNodeMap.to_json
    ~lab_key:source ~lab_value:target_map
    short_influence_node_to_json
    (InfluenceNodeMap.to_json
       ~lab_key:target ~lab_value:location_pair_list
       short_influence_node_to_json
       (JsonUtil.of_list
          (JsonUtil.of_pair
             ~lab1:rhs ~lab2:lhs
             location_to_json
             location_to_json
          )
       )
    )

let half_influence_map_of_json =
  InfluenceNodeMap.of_json
    ~error_msg:(JsonUtil.build_msg "activation or inhibition map")
    ~lab_key:source ~lab_value:target_map
    short_influence_node_of_json
    (InfluenceNodeMap.of_json
       ~lab_key:target ~lab_value:location_pair_list
       ~error_msg:"map of lists of pairs of locations"
       short_influence_node_of_json
       (JsonUtil.to_list ~error_msg:"list of pair of locations"
          (JsonUtil.to_pair
             ~error_msg:""
             ~lab1:rhs ~lab2:lhs
             (location_of_json ~error_msg:(JsonUtil.build_msg "location"))
             (location_of_json ~error_msg:(JsonUtil.build_msg "location")))))

(* Influence map *)

let nodes_list_to_json =
  JsonUtil.of_list
    refined_influence_node_to_json

let nodes_list_of_json =
  JsonUtil.to_list
    refined_influence_node_of_json


let influence_map_to_json influence_map =
  `Assoc
    [influencemap,
     JsonUtil.of_pair
       ~lab1:accuracy_string ~lab2:map
       accuracy_to_json
       (fun influence_map ->
          `Assoc
            [ nodes, nodes_list_to_json influence_map.nodes;
              wakeup,half_influence_map_to_json influence_map.positive;
              inhibition,half_influence_map_to_json
                influence_map.negative;]) influence_map]

let local_influence_map_to_json influence_map =
  let accuracy, total, bwd, fwd, influence_map = influence_map in
  `Assoc
    [influencemap,
     `Assoc [accuracy_string,accuracy_to_json accuracy;
             total_string,JsonUtil.of_int total;
             fwd_string,JsonUtil.of_option JsonUtil.of_int fwd;
             bwd_string,JsonUtil.of_option JsonUtil.of_int bwd;
             map,
             (fun influence_map ->
                `Assoc
                  [
                    nodes, nodes_list_to_json influence_map.nodes;
                    wakeup,half_influence_map_to_json influence_map.positive;
                    inhibition,half_influence_map_to_json
                      influence_map.negative;]) influence_map
            ]
    ]

let influence_map_of_json =
  function
  | `Assoc l as x ->
    begin
      try
        let json = List.assoc influencemap l in
        JsonUtil.to_pair
          ~lab1:accuracy_string ~lab2:map
          ~error_msg:(JsonUtil.build_msg "influence map1")
          accuracy_of_json
          (function
            | `Assoc l as x when List.length l = 3 ->
              begin
                try
                  {nodes =
                     nodes_list_of_json (List.assoc nodes l);
                   positive =
                     half_influence_map_of_json (List.assoc wakeup l);
                   negative =
                     half_influence_map_of_json (List.assoc inhibition l)}
                with Not_found ->
                  raise
                    (Yojson.Basic.Util.Type_error
                       (JsonUtil.build_msg "influence map",x))
              end
            | x ->
              raise
                (Yojson.Basic.Util.Type_error
                   (JsonUtil.build_msg "influence map",x)))
          json
      with
      | _ ->
        raise
          (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "influence map",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "influence map",x))

let local_influence_map_of_json =
  function
  | `Assoc l as x ->
    begin
      try
        let json = List.assoc influencemap l in
        match json with
        | `Assoc l'  ->
          let accuracy =
            accuracy_of_json (List.assoc accuracy_string l')
          in
          let total =
            JsonUtil.to_int (List.assoc total_string l')
          in
          let error_msg = JsonUtil.build_msg "fwd radius" in
          let fwd =
            JsonUtil.to_option
              (JsonUtil.to_int ~error_msg) (List.assoc fwd_string l')
          in
          let error_msg = JsonUtil.build_msg "bwd radius" in
          let bwd =
            JsonUtil.to_option
              (JsonUtil.to_int ~error_msg) (List.assoc bwd_string l')
          in
          let influence_map =
            (function
              | `Assoc l as x when List.length l = 3 ->
                begin
                  try
                    {
                      nodes =
                        nodes_list_of_json (List.assoc nodes l);
                      positive =
                        half_influence_map_of_json (List.assoc wakeup l);
                      negative =
                        half_influence_map_of_json (List.assoc inhibition l)
                    }
                  with Not_found ->
                    raise
                      (Yojson.Basic.Util.Type_error
                         (JsonUtil.build_msg "local influence map",x))
                end
              | x ->
                raise
                  (Yojson.Basic.Util.Type_error
                     (JsonUtil.build_msg "local influence map",x)))
              (List.assoc map l')
          in
          (accuracy, total, fwd, bwd, influence_map)
        | _ ->
          raise
            (Yojson.Basic.Util.Type_error
               (JsonUtil.build_msg "influence map",x))
      with _ ->
        raise
          (Yojson.Basic.Util.Type_error
             (JsonUtil.build_msg "influence map",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "influence map",x))



type dead_rules = rule list

let dead_rules_to_json json =
  `Assoc
    [dead_rules, JsonUtil.of_list rule_to_json json]



(***************)
(* dead rules *)
(***************)

let dead_rules_of_json =
  function
  | `Assoc [s,json] as x when s=dead_rules ->
    begin
      try
        JsonUtil.to_list json_to_rule json
      with Not_found ->
        raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "dead rules",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "dead rules",x))



(***************)
(* dead agents *)
(***************)

type separating_transitions = (string * int (*rule_id*) * string) list

let separating_transitions_of_json =
  JsonUtil.to_list
    ~error_msg:"separating transitions"
    (
      JsonUtil.to_triple
        ~error_msg:"transition"
        ~lab1:"s1" ~lab2:"label" ~lab3:"s2"
        (JsonUtil.to_string ?error_msg:None)
        (JsonUtil.to_int ?error_msg:None)
        (JsonUtil.to_string ?error_msg:None))

(***************)
(* Constraints *)
(***************)

type binding_state =
    | Free
    | Wildcard
    | Bound_to_unknown
    | Bound_to of int
    | Binding_type of string * string

type agent =
  string * (*agent name*)
  (string * string option *  binding_state option) list

type 'site_graph lemma =
  {
    hyp : 'site_graph ;
    refinement : 'site_graph list
  }

type 'site_graph poly_constraints_list =
  (string * 'site_graph lemma list) list

let lemma_to_json site_graph_to_json json =
  JsonUtil.of_pair
    ~lab1:hyp ~lab2:refinement
    site_graph_to_json
    (JsonUtil.of_list site_graph_to_json)
    (json.hyp,json.refinement)

let lemma_of_json site_graph_of_json json =
  let a,b =
    JsonUtil.to_pair
      ~lab1:hyp ~lab2:refinement ~error_msg:"lemma"
      site_graph_of_json
      (JsonUtil.to_list  ~error_msg:"refinements list" site_graph_of_json)
      json
  in
  {
    hyp =  a;
    refinement =  b
  }

let get_hyp h = h.hyp

let get_refinement r = r.refinement


let free = ""
let wildcard = "?"
let bound = "!_"
let bond_id = "bond id"
let bound_to = "bound to"
let binding_type = "binding type"
let prop="property state"
let bind="binding state"

let binding_state_light_of_json =
  function
  | `Assoc [s, `Null] when s = free -> Free
  | `Assoc [s, `Null] when s = wildcard -> Wildcard
  | `Assoc [s, `Null] when s = bound_to -> Bound_to_unknown
  | `Assoc [s, j] when s = bond_id ->
    let i =
      JsonUtil.to_int ~error_msg:"wrong binding id" j
    in
    let bond_index = i in
    Bound_to bond_index
  | `Assoc [s, j] when s = binding_type ->
    let (agent_name, site_name) =
      JsonUtil.to_pair
        ~lab1:"agent" ~lab2:"site" ~error_msg:"binding type"
        (JsonUtil.to_string ~error_msg:"agent name") (JsonUtil.to_string
                                                        ~error_msg:"site name")
        j
    in
    Binding_type (agent_name, site_name)
  | x -> raise
           (Yojson.Basic.Util.Type_error ("wrong binding state",x))


let interface_light_of_json json
  =
  JsonUtil.to_map
    ~lab_key:site ~lab_value:stateslist ~error_msg:interface
    ~empty:[]
    ~add:(fun k (a,b) list -> (k,a,b)::list)
    (*json -> elt*)
    (fun json -> JsonUtil.to_string ~error_msg:site json)
    (*json -> 'value*)
    (JsonUtil.to_pair
       ~lab1:prop ~lab2:bind ~error_msg:"wrong binding state"
       (JsonUtil.to_option
          (JsonUtil.to_string ~error_msg:prop)

       )
       (JsonUtil.to_option
          binding_state_light_of_json)
    )
    json

let agent_gen_of_json interface_of_json =
  JsonUtil.to_pair
    ~lab1:agent ~lab2:interface ~error_msg:"agent"
    (JsonUtil.to_string ~error_msg:"agent name")
    interface_of_json

let agent_of_json json = agent_gen_of_json interface_light_of_json json

let poly_constraints_list_of_json site_graph_of_json =
  JsonUtil.to_list
    (JsonUtil.to_pair ~error_msg:"constraints list"
       ~lab1:domain_name ~lab2:refinements_list
       (JsonUtil.to_string ~error_msg:"abstract domain")
       (JsonUtil.to_list (lemma_of_json site_graph_of_json)))


let lemmas_list_of_json_gen agent_of_json =
  function
  | `Assoc l as x ->
    begin
      try
        let json =
          List.assoc refinement_lemmas l
        in
        poly_constraints_list_of_json
          (JsonUtil.to_list ~error_msg:"site graph" agent_of_json)
          json
      with
      | _ ->
        raise
          (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "refinement lemmas list",x))
    end
  | x ->
    raise (Yojson.Basic.Util.Type_error (JsonUtil.build_msg "refinement lemmas list",x))

let lemmas_list_of_json json =
  lemmas_list_of_json_gen agent_of_json json
