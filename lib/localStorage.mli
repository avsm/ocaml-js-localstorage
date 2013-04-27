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

(** Bindings to HTML5 LocalStorage key/value store, with a fallback to a
    memory-based version if a persistent store isn't available. *)

(** A get/set interface to the storage, which may be persistent across
    invocations if LocalStorage is available.  [js_store] operates on
    immutable Javascript strings and not OCaml strings.
    TODO: signal failure in set, which might fail due to a full storage. *)
class type js_store =
  object
    method get : key:Js.js_string Js.t -> Js.js_string Js.t option
    method set : key:Js.js_string Js.t -> Js.js_string Js.t -> exn option
  end

(** Initialise a [js_store] using LocalStorage if availabl, and a
    non-persistent memory version otherwise *)
val init_js : unit -> js_store
