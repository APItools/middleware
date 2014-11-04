package = "apitools"
source = {
url = '.'
}
version = '1.0-0'
description = {
}
dependencies = {
   "lua ~> 5.1",
   'luasec >= 0',
   'luabitop >= 0',
   'luacheck >= 0',
   'busted  >= 0',
   'lua-cjson >= 0',
   'luasocket >= 0',
   'luaexpat >= 0'
}
build = {
   type = "builtin",
   modules = {
   }
}
