--[[
-- This middleware shows how to anonymize lots of different parts of a request in APItools, for various privacy concerns.
--
-- Since each app is different, we can't provide a one-size-fits-all solution for this; you will have to
-- adapt the code to suit your needs.
--
-- The middleware completely commented out by default, so it is safe to include it on any Service. You can then start making
-- modifications until all the data you need anonymized is gone.
-- ]]

return function (req, next_middleware)
  --> Call the endpoint without masking anything first. Otherwise you will send anonymized requests to the endpoint
  local res = next_middleware()

  --> What follows is a list of optional steps - ways to anonymize data in the requests/responses
  -->
  --> * Pick as many steps as you want, uncommenting their lua code.
  --> * You can duplicate any step if you need to
  --> * Adapt them to your field names
  --> * Don't uncomment the lines that begin with --> ; those are explanatory comments, not commented-out code.
  -->   You can either leave them commented out or remove the whole line.

  --> BEGIN OF OPTIONAL STEPS <--

  --> REQUEST HEADERS
  --> remove a REQUEST HEADER
  -- req.headers["Authorization"] = nil

  --> anonymize a REQUEST header
  -- req.headers["Authorization"] =  "*****"

  --> remove ALL REQUEST HEADERS
  -- req.headers = {}

  --> RESPONSE HEADERS
  --> Do the same as in the REQUEST HEADERS above, replacing `req` by `res`

  --> remove a REQUEST QUERY PARAMETER
  -- req.query = req.query:gsub("api_key=[^&]+&?","")
  -- req.args["api_key"] = nil

  --> anonymize a REQUEST QUERY PARAMETER
  -- req.query = req.query:gsub("api_key=[^&]+","api_key=xxxx")
  -- req.args["api_key"] = "xxxx"

  --> remove ALL REQUEST QUERY PARAMETERS
  -- req.query = ""
  -- req.args = {}

  --> Remove a FIELD FROM A JSON REQUEST BODY
  -- local body = json.decode(req.body)
  -- body["user_id"] = nil
  -- req.body = json.encode(body)

  --> Anonymize a FIELD FROM THE JSON REQUEST BODY
  -- local body = json.decode(req.body)
  -- body["user_id"] = "xxxxxxx"
  -- req.body = json.encode(body)

  --> remove the REQUEST BODY
  -- req.body = ""

  --> RESPONSE BODY
  -- Same as the request body. Just replace `req` by `res`.

  --> Anonymize a PARTIAL PATH of the REQUEST URI
  --> Example: /foo/secret/bar/baz => /foo/secret/xxx/baz
  -- req.uri = req.uri:gsub("/secret/[^/]+", "/secret/xxx")
  -- req.uri_full = req.uri_full:gsub("/secret/[^/]+", "/secret/xxx")
  -- req.uri_relative = req.uri_relative:gsub("/secret/[^/]+", "/secret/xxx")

  --> Remove the REQUEST URI
  -- req.uri = ""
  -- req.uri_full = ""
  -- req.uri_relative = ""

  --> END OF OPTIONAL STEPS <--

  --> Always remember to return the response at the end
  return res
end
