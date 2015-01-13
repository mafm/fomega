open Format
open Support.Error
open Syntax

let output_buffer = Buffer.create 100

let print = Buffer.add_substring output_buffer
let flush () = ()

let () = set_formatter_output_functions print flush

let fomega s =
  let s = Js.to_string s in
  Buffer.clear output_buffer;
  let lexbuf = Lexer.from_string s in
  let result =
    try
      Parser.toplevel Lexer.main lexbuf
    with Parser.Error ->
      error (Lexer.info lexbuf) "parse error"
  in
  let cmds, _ = result emptycontext in
  let _ = Process.process_file cmds emptycontext in
  let res = Buffer.contents output_buffer in
    Js.string res

let () = Js.Unsafe.set Js.Unsafe.global "fomega" (Js.wrap_callback fomega)
