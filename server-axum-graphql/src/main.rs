use std::collections::HashMap;
use std::sync::{Arc, RwLock};

use crate::model::{MutationRoot, QueryRoot};
use crate::routes::{graphql_handler, graphql_playground, health};
use async_graphql::{EmptySubscription, Schema};
use axum::{extract::Extension, routing::get, Router, Server};
use serde::Deserialize;
use tower::ServiceBuilder;
use tower_http::cors::CorsLayer;

mod model;
mod routes;

/**
 * Core Models
 */

type UserId = u32;

#[derive(Debug, Deserialize, Clone, Eq, Hash, PartialEq)]
struct User {
    id: UserId,
    email: String,
    password: String,
    name: String,
}

/**
 * App State
 *
 * Faking with just in memory stuff for now
 *
 */
#[derive(Default)]
struct State {
    users: HashMap<u32, User>,
}

// Wrapping the state in a shared type so it can be shared across threads
type SharedState = Arc<RwLock<State>>;

#[tokio::main]
async fn main() {
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(SharedState::default())
        .finish();
    let app = Router::new()
        .route("/", get(graphql_playground).post(graphql_handler))
        .route("/health", get(health))
        .layer(
            // Use tower/tower-http middleware to inject our shared state into our routes
            // Based on example: https://github.com/tokio-rs/axum/blob/dea36db400f27c025b646e5720b9a6784ea4db6e/examples/key-value-store/src/main.rs
            ServiceBuilder::new()
                // You somehow need your compiled schema accessible in your endpoint.
                // By providing axum with a layer, you do exactly this.
                // The schema you build a few lines above is now passed into axum so that
                // you can access it within your GraphQL handler.
                .layer(Extension(schema))
                .layer(
                    CorsLayer::permissive(), // CorsLayer::new()
                )
                .into_inner(),
        );

    Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
