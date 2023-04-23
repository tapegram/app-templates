use crate::model::{MutationRoot, QueryRoot};
use crate::routes::{graphql_handler, graphql_playground, health};
use async_graphql::{EmptySubscription, Schema};
use axum::{extract::Extension, routing::get, Router, Server};

mod model;
mod routes;

#[tokio::main]
async fn main() {
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription).finish();
    let app = Router::new()
        .route("/", get(graphql_playground).post(graphql_handler))
        .route("/health", get(health))
        // You somehow need your compiled schema accessible in your endpoint.
        // By providing axum with a layer, you do exactly this.
        // The schema you build a few lines above is now passed into axum so that
        // you can access it within your GraphQL handler.
        .layer(Extension(schema));

    Server::bind(&"0.0.0.0:8000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
