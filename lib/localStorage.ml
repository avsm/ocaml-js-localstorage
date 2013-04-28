(*
 * Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt
open Js

let error f = Printf.ksprintf (fun s -> Firebug.console##error (Js.string s); failwith s) f
let debug f = Printf.ksprintf (fun s -> Firebug.console##log(Js.string s)) f

(*
class type localStorage =
  object
    method getItem : js_string t -> js_string t opt meth
    method removeItem : js_string t -> unit meth
    method length : int prop
    method clear : unit meth
    method setItem : js_string t -> js_string t -> unit meth
  end
*)
class type js_store =
  object
     method get : key:js_string t -> js_string t opt
     method set : key:js_string t -> js_string t -> exn option
     method remove : key:js_string t -> unit
     method length : int
     method clear : unit
  end

class type store =
  object
    method get : key:string -> string option
    method set : key:string -> string -> exn option
    method remove : key:string -> unit
    method length : int
    method clear : unit
  end

let mem_store () : js_store =
  debug "Using memory storage";
  let (h: (js_string t, js_string t) Hashtbl.t) = Hashtbl.create 1 in
  object
    method get ~key =
      if Hashtbl.mem h key then
        some (Hashtbl.find h key)
      else
        null

    method set ~key v = Hashtbl.replace h key v; None
    method length = Hashtbl.length h
    method clear = Hashtbl.clear h
    method remove ~key = Hashtbl.remove h key
  end

let html5_store (ls:Dom_html.storage t) : js_store =
  debug "Using HTML5 local storage";
  object
    method get ~key =
      ls##getItem(key)

    method set ~key v =
      try
        ls##setItem(key,v);
        None
      with exn ->
        Some exn

    method length = ls##length
    method clear = ls##clear()
    method remove ~key = ls##removeItem(key)
  end
  
let init_js () =
  try
    Js.Optdef.case 
      (Dom_html.window##localStorage) 
      mem_store
      html5_store
  with exn ->
    (* This can be a DOM SecurityError *)
    mem_store ()
