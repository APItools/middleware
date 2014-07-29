return function (request, next_middleware)
  local five_mins = 60 * 5
  local res = next_middleware()
  local last_mail = bucket.middleware.get('last_mail')
  if res.status == 404  and (not last_mail or last_mail < time.now() - five_mins) then
    send.mail('YOUR-MAIL-HERE@gmail.com', "A 404 has ocurred", "a 404 error happened in " .. request.uri_full)
    bucket.middleware.set('last_mail', time.now())
  end
  return res
end
