(**
  * graph_loggers.mli
  *
  * a module for KaSim
  * Jérôme Feret, projet Antique, INRIA Paris
  *
  * KaSim
  * Jean Krivine, Université Paris-Diderot, CNRS
  *
  * Creation: 23/05/2016
  * Last modification: 25/05/2016
  * *
  *
  *
  * Copyright 2016  Institut National de Recherche en Informatique et
  * en Automatique.  All rights reserved.  This file is distributed
  * under the terms of the GNU Library General Public License *)

val dot_color_encoding: Graph_loggers_sig.color -> string
val shape_in_dot: Graph_loggers_sig.shape -> string
val shape_in_dot_bis: Graph_loggers_sig.shape -> string

val print_graph_preamble:
  Loggers.t ->
  ?filter_in:Loggers.encoding list option ->
  ?filter_out:Loggers.encoding list ->
  ?header:string list ->
  string ->
  unit
val print_graph_foot: Loggers.t -> unit
val print_comment:
  Loggers.t ->
  ?filter_in:Loggers.encoding list option ->
  ?filter_out:Loggers.encoding list ->
  string ->
  unit
val open_asso: Loggers.t -> unit
val close_asso: Loggers.t -> unit
val print_asso: Loggers.t -> string -> string -> unit
val print_node: Loggers.t -> ?directives:Graph_loggers_sig.options list -> string -> unit
val print_edge: Loggers.t -> ?directives:Graph_loggers_sig.options list -> ?prefix:string -> string -> string -> unit
val print_one_to_n_relation: Loggers.t -> ?directives:Graph_loggers_sig.options list -> ?style_one:Graph_loggers_sig.linestyle -> ?style_n:Graph_loggers_sig.linestyle -> string -> string list -> unit
