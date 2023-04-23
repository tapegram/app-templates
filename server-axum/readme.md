# Server-Axum

Example web server using Axum

Axum example apps: https://github.com/tokio-rs/axum/tree/main/examples

## Dev Flow

Run with `cargo run`

and then visit `http://localhost:3000`

## Todo

- [x] Hello World
- [x] Request/Response types
- [] Writing tests
- [] Connecting to a DB


## How to Run Tests

``` cargo watch -q -c -w tests/ -x "test -q tests_1 -- --nocapture" ```
