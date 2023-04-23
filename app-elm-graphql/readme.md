# app-elm-graphl

## Initial dev setup

Make sure you have `npm` installed already.

### Install Elm

Install Elm by following the guide on the official docs: https://guide.elm-lang.org/install/elm.html

### Install Elm-Live

Install `elm-live` (for running the app locally with live reloading): `npm i -g elm-live` 

### Install the Elm-Graphql command line tool

`npm install --save-dev @dillonkearns/elm-graphql`

## Dev Flow

### Running the app

```
elm-live src/Main.elm --pushstate
```

The explanation is [here](https://github.com/dwyl/learn-elm/issues/156)

### GraphQL Types

We are using https://github.com/dillonkearns/elm-graphql to help generate graphql types from an introspectable server (i.e. server-axum-graphql).

`package.json` contains a script to generate those types for us -- for example:


```json
  "scripts": {
    "api": "elm-graphql http://localhost:8000/ --base UsersAPI"
  }
```

So you can run `npm run api` to regenerate the types against a running instance of the graphql server (on :8000) and the types will be generated under `UsersAPI`


### Styling

At the moment we are using tailwind classes from here: https://package.elm-lang.org/packages/matheus23/elm-default-tailwind-modules/latest/

This dependency lets us avoid needing npm/yarn, doing any code generation, etc. However, according to the doc we may want more control in our configuration and styling, in which case we could look at: https://github.com/matheus23/elm-tailwind-modules

There are also some "gotchas" in the first link that we may run into, with recommendations on how to resolve them

You will likely want to reference
- A tailwindcss cheat sheet: https://nerdcave.com/tailwind-cheat-sheet
- Html-to-Elm which can translate html / tailwind examples to elm/tailwind https://html-to-elm.com/ *CAVEAT* This site does not fully support Tailwind3, so until we fix it, we can't just copy paste the code in, but it is a great reference for now.


## Other Resources

- https://guide.elm-lang.org/
- https://kindsonthegenius.com/elm/elm-your-first-elm-program/#t2
- https://github.com/dillonkearns/elm-graphql
