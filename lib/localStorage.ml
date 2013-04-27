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

type jsstring = Js.js_string Js.t

class type js_store =
  object
     method get : key:jsstring -> jsstring option
     method set : key:jsstring -> jsstring -> exn option
  end

class type store =
  object
     method get : key:string -> string option
     method set : key:string -> string -> exn option
  end

let mem_store () : js_store =
  debug "Using memory storage";
  let h = Hashtbl.create 1 in
  object
    method get ~key =
      if Hashtbl.mem h key then
        Some (Hashtbl.find h key)
      else
        None

    method set ~key v =
      Hashtbl.replace h key v;
      None
  end

let html5_store ls : js_store =
  debug "Using HTML5 local storage";
  object
    method get ~key =
      Js.Opt.to_option ls##getItem(key)

    method set ~key v  =
      try
        ls##setItem(key,v);
        None
      with exn ->
        Some exn
  end
  
let init_js () =
  try
    Js.Optdef.case 
      (Dom_html.window##localStorage) 
      (mem_store)
      (fun ls -> html5_store ls)
  with exn ->
    (* This can be a DOM SecurityError *)
    mem_store ()
