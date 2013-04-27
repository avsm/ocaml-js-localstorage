(*
 * Copyright (c) 2012 Anil Madhavapeddy <anil@recoil.org>
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

let localStorage () =
  let st = LocalStorage.init_js () in
  let key = Js.string "testKey" in
  let rec looper n () =
    debug "loop %d" n;
    st#set key (Js.string (string_of_int n));
    Lwt_js.sleep 1.0
    >>= looper (succ n)
  in
  let startVal =
     match st#get key with
     |None -> debug "initialising key to 0"; 0
     |Some k -> 
      let v = int_of_string (Js.to_string k) in
      debug "Found start key %d" v;
      v
  in
  looper startVal ()

let go _ = ignore (
  catch (fun () -> localStorage ())
    (fun exn -> error "uncaught exception: %s" (Printexc.to_string exn)));
  _true

let _ = Dom_html.window##onload <- Dom_html.handler go
