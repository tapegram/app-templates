# app-elm

## Initial dev setup

Make sure you have `npm` installed already.

Install Elm by following the guide on the official docs: https://guide.elm-lang.org/install/elm.html

Install `elm-live` (for running the app locally with live reloading): `npm i -g elm-live` 

## Dev Flow

### Running the app

```
elm-live src/Main.elm --pushstate
```

The explanation is [here](https://github.com/dwyl/learn-elm/issues/156)

## Styling

At the moment we are using tailwind classes from here: https://package.elm-lang.org/packages/matheus23/elm-default-tailwind-modules/latest/

This dependency lets us avoid needing npm/yarn, doing any code generation, etc. However, according to the doc we may want more control in our configuration and styling, in which case we could look at: https://github.com/matheus23/elm-tailwind-modules

There are also some "gotchas" in the first link that we may run into, with recommendations on how to resolve them

You will likely want to reference
- A tailwindcss cheat sheet: https://nerdcave.com/tailwind-cheat-sheet
- Html-to-Elm which can translate html / tailwind examples to elm/tailwind https://html-to-elm.com/ *CAVEAT* This site does not fully support Tailwind3, so until we fix it, we can't just copy paste the code in, but it is a great reference for now.


## Other Resources

- https://guide.elm-lang.org/
- https://kindsonthegenius.com/elm/elm-your-first-elm-program/#t2
