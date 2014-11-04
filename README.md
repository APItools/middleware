# APItools Middleware Repository [![Build Status](https://travis-ci.org/APItools/middleware.svg?branch=master)](https://travis-ci.org/APItools/middleware)

This is a collection of Middleware that you can use in APItools Traffic Monitors. Either [On Premise](//github.com/APItools/monitor) or [Cloud](//apitools.com).

You can use almost all of [Lua Standard Library](http://www.lua.org/manual/5.1/manual.html#5) with [some exceptions](//github.com/APItools/monitor/blob/master/lua/sandbox.lua#L53-L71).

## Creating Middleware

We provide simple rake task to get started with middleware template.
You just have to have Ruby, install dependencies, run `rake middleware`
and fill out the questions.

```shell
bundle
rake middleware
```

## Testing Middleware

When you generate a middleware by `rake middleware` a spec will be created for you.
Then you can run all the tests by running `make`.


### Test Dependencies
To run all the tests you need: `lua` (5.1) (or `luajit`) with `luarocks`.
Then you can install dependencies via `make dependencies`.

If you can't get it installed on your machine, you can use vagrant.
Run `make vagrant` to create vagrant machine and ssh into it.

### OSX
If you have homebrew, you can just install luarocks lika `brew install luarocks --with-luajit`
and run `make dependencies`.

## Contributing

1. Fork it ( https://github.com/APItools/middleware/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
