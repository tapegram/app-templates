# app-elm

## Dev Flow

### Running the app

You can use Elm's built in `elm reactor` though you have to manually refresh.

Alternatively, you can install and run `elm-live`:

```
npm i -g elm-live
```

Then run it like
```
elm-live <elm-file>
```

```
elm-live src/Main.elm
```

See: https://www.elm-live.com/

HOWEVER, just this won't work with single page apps (SPAs), which is what we will likely be doing.

instead do this:
```
elm-live src/Main.elm --pushstate
```

The explanation is [here](https://github.com/dwyl/learn-elm/issues/156)

## Styling

At the moment we are using tailwind classes from here: https://package.elm-lang.org/packages/matheus23/elm-default-tailwind-modules/latest/

This dependency lets us avoid needing npm/yarn, doing any code generation, etc. However, according to the doc we may want more control in our configuration and styling, in which case we could look at: https://github.com/matheus23/elm-tailwind-modules

There are also some "gotchas" in the first link that we may run into, with recommendations on how to resolve them


## Resources

- https://guide.elm-lang.org/
- https://kindsonthegenius.com/elm/elm-your-first-elm-program/#t2
