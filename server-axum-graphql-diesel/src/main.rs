use std::env;
use std::sync::Arc;

use crate::model::{MutationRoot, QueryRoot};
use crate::routes::{graphql_handler, graphql_playground, health};
use async_graphql::{EmptySubscription, Schema};
use axum::{extract::Extension, routing::get, Router, Server};
use diesel_async::pooled_connection::deadpool::Pool;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use diesel_async::AsyncPgConnection;
use dotenvy::dotenv;
use serde::Deserialize;
use tower::ServiceBuilder;
use tower_http::cors::CorsLayer;
mod db_models;
mod db_schema;
mod model;
mod routes;

/**
 * Core Models
 */

type UserId = i32;

#[derive(Debug, Deserialize, Clone, Eq, Hash, PartialEq)]
struct User {
    id: UserId,
    email: String,
    password: String,
    name: String,
}

/**
 * DB state
 *
 */
pub fn get_connection_pool() -> Pool<AsyncPgConnection> {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let config = AsyncDieselConnectionManager::<diesel_async::AsyncPgConnection>::new(database_url);
    let pool = Pool::builder(config)
        .build()
        .expect("Could not create postgres connection pool");
    pool
}

#[tokio::main]
async fn main() {
    let pg_pool = Arc::new(get_connection_pool());
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(pg_pool)
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
