use axum::{http::StatusCode, response::IntoResponse, Json};
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
