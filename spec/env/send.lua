local send = {}

function send.new(spec)
  local sent     = spec.sent or {emails = {}, events = {}}

  spec.sent      = sent

  local instance = {sent = sent}

  instance.email = function(to, subject, message)
    local email =  {to=to, subject=subject, message = message}
    sent.emails[#sent.emails + 1] = email
    sent.emails.last = email
  end

  instance.mail = instance.email

  instance.event = function(ev)
    sent.events[#send.events + 1] = ev
    sent.events.last = ev
  end

  instance.notification = function(notification)
    notification.channel = 'middleware'
    instance.event(notification)
  end

  return instance
end

return send
