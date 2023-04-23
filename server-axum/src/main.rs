pub use self::error::{Error, Result};
use self::model::SharedState;
use axum::Router;
use model::State;
use serde::Serialize;
use std::net::SocketAddr;
use std::sync::RwLock;
use tower::ServiceBuilder;
use tower_http::add_extension::AddExtensionLayer;
use tower_http::cors::CorsLayer;

mod error;
mod model;
mod web;

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
}

#[tokio::main]
async fn main() {
    let state = State::new().await;
    let shared_state = SharedState::new(RwLock::new(state));
    // Route all requests on "/" endpoint to anonymous handler.
    //
    // A handler is an async function which returns something that implements
    // `axum::response::IntoResponse`.

    // A closure or a function can be used as handler.

    let app = Router::new()
        .merge(web::routes_users::routes(shared_state))
        .layer(
            // Use tower/tower-http middleware to inject our shared state into our routes
            // Based on example: https://github.com/tokio-rs/axum/blob/dea36db400f27c025b646e5720b9a6784ea4db6e/examples/key-value-store/src/main.rs
            ServiceBuilder::new()
                .layer(AddExtensionLayer::new(SharedState::default()))
                .layer(
                    CorsLayer::permissive(), // CorsLayer::new()
                                             // .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
                                             // .allow_origin(Any),
                )
                .into_inner(),
        );

    // Address that server will bind to.
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    // Use `hyper::server::Server` which is re-exported through `axum::Server` to serve the app.
    axum::Server::bind(&addr)
        // Hyper server takes a make service.
        .serve(app.into_make_service())
        .await
        .unwrap();
}

