#use "topfind"
#require "yojson"

open Printf
open Scanf
open Yojson.Basic.Util

let json = scanf "%s" @@ fun s -> Yojson.Basic.from_string s

let session_id       = json |> member "session_id" |> to_string
let stop_hook_active = json |> member "stop_hook_active" |> to_bool

let () =
  if stop_hook_active then
    exit 0

let project_name = Filename.basename @@ Sys.getcwd ()

let () =
  ["terminal-notifier";
    "-title"; "'Claude Code 🤖'";
    "-subtitle"; sprintf "'プロジェクト: %s'" project_name;
    "-message"; sprintf "'処理が完了しました (Session: %s)'" (String.sub session_id 0 8);
    "-sound"; "Blow";
    "-group"; "claude-code-completion"
  ]
  |> String.concat " "
  |> Sys.command
  |> exit
