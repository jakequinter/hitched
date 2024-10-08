open Lwt.Syntax
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { name : string
  ; email : string
  ; password : string
  ; password2 : string
  }
[@@deriving yojson]

let create_user ~name ~email ~password pool =
  let query =
    [%rapper
      execute
        {sql|
      INSERT INTO users (name, email, password)
      VALUES (%string{name}, %string{email}, %string{password})
      |sql}]
  in
  let* result =
    Caqti_lwt.Pool.use (fun db -> query db ~name ~email ~password) pool
  in
  match result with
  | Ok _ -> Lwt.return (Ok ())
  | Error err -> Lwt.return (Error (Caqti_error.show err))
;;

let handler pool request =
  let* body = Dream.body request in
  let body = t_of_yojson (Yojson.Safe.from_string body) in
  if body.password <> body.password2
  then Dream.json ~status:`Bad_Request {|{ "error": "Passwords do not match" }|}
  else (
    let hashed_password = Bcrypt.hash body.password in
    let* user =
      create_user
        ~name:body.name
        ~email:body.email
        ~password:(Bcrypt.string_of_hash hashed_password)
        pool
    in
    match user with
    | Ok () -> Dream.json {|{ "status": "ok" }|}
    | Error err ->
      Dream.json
        ~status:`Internal_Server_Error
        (Printf.sprintf {|{ "error": "%s" }|} err))
;;
