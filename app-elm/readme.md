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


## Resources

- https://guide.elm-lang.org/
- https://kindsonthegenius.com/elm/elm-your-first-elm-program/#t2
