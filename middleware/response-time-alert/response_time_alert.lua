local five_mins = 60 * 5
local threshold = 1.0 -- 1 second, for less use decimal numbers
return function (request, next_middleware)
    local res = next_middleware()
    local last_mail = bucket.middleware.get('last_mail')

    if trace.time > threshold  and (not last_mail or last_mail < time.now() - five_mins) then
        send.mail('YOUR-MAIL-HERE@gmail.com',
	          "Trace took more than " .. tostring(threshold),
            request.uri_full .. " took more than " .. tostring(threshold) .. " to load. See full trace:" .. trace.link)
        bucket.middleware.set('last_mail', time.now())
    end
    return res
end

