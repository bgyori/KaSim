(**
  * bdu_analysis_type.ml
  * openkappa
  * Jérôme Feret, projet Abstraction, INRIA Paris-Rocquencourt
  * 
  * Creation: 2015, the 15th of July
  * Last modification: 
  * 
  * Compute the relations between sites in the BDU data structures
  * 
  * Copyright 2010,2011,2012,2013,2014 Institut National de Recherche en Informatique et   
  * en Automatique.  All rights reserved.  This file is distributed     
  * under the terms of the GNU Library General Public License *)

open Int_storage
open Fifo

let warn parameters mh message exn default =
  Exception.warn parameters mh (Some "Bdu_analysis_type") message exn (fun () -> default)

let local_trace = false

module AgentMap = Quick_Nearly_inf_Imperatif

type bdu = ((Boolean_mvbdu.memo_tables, Boolean_mvbdu.mvbdu_dic,
	     Boolean_mvbdu.list_dic, bool, int)
	       Memo_sig.handler * bool Mvbdu_sig.mvbdu) 
    
type pair_bdu =
    ((int * int) list *
	((Boolean_mvbdu.memo_tables, Boolean_mvbdu.mvbdu_dic,
	  Boolean_mvbdu.list_dic, bool, int)
	    Memo_sig.handler * bool Mvbdu_sig.mvbdu))

type pair_list =
    ((int * int) list * bool Mvbdu_sig.mvbdu list)

type bdu_analysic =
    {
      store_creation    : pair_bdu AgentMap.t;
      store_iteration   : (pair_list AgentMap.t * pair_list AgentMap.t * bdu AgentMap.t)
    }
