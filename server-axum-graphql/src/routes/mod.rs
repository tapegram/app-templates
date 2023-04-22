use crate::model::ServiceSchema;
use async_graphql::http::{playground_source, GraphQLPlaygroundConfig};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    extract::Extension,
    http::StatusCode,
    response::{Html, IntoResponse},
    Json,
};
use serde::Serialize;

#[derive(Serialize)]
struct Health {
    healthy: bool,
}

// returning an "impl IntoResponse" means we are returning some type
// that implement the IntoResponse trait.
//
// IntoResponse is a trait axum exposes/requires that allows
// generating a value it can return to a client
pub(crate) async fn health() -> impl IntoResponse {
    let health = Health { healthy: true };
    (StatusCode::OK, Json(health))
}

pub(crate) async fn graphql_playground() -> impl IntoResponse {
    // async-graphql comes witha  full implementation of GraphQL Playground.
    // Thankfully, you can just call it as a function and wrap it within Axum's
    // Html helper that takes care of returning everything correctly.
    Html(playground_source(
        GraphQLPlaygroundConfig::new("/").subscription_endpoint("/ws"),
    ))
}

pub(crate) async fn graphql_handler(
    // The graphql handler function does receive both the request and, even more importantly,
    // an instance of the schema you designed and implemented. Extension is a special helper
    // by Axum, which allows you to add data and other context-specific things to your handler
    // functions.
    Extension(schema): Extension<ServiceSchema>,
    req: GraphQLRequest,
) -> GraphQLResponse {
    // GraphQL over HTTP is conceptually nothing but an API endpoint with a special processor.
    schema.execute(req.into_inner()).await.into()
}
