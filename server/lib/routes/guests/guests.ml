let routes pool =
  [ Dream.get "/api/guests" (Get_guests.handler pool)
  ; Dream.post "/api/guests" (Add_guest.handler pool)
  ]
;;
