use axum::{
    routing::{post, put},
    Router, 
    extract::{Extension, Path}, 
    Json, 
    response::{Response, IntoResponse}, 
    // response::{Json, IntoResponse, Response},
    handler::Handler, http::StatusCode, 
};
use tower::ServiceBuilder;
use tower_http::add_extension::{AddExtensionLayer, AddExtension};
use std::{net::SocketAddr, collections::HashMap, sync::{Arc, RwLock}};
use serde::{Deserialize, Serialize};
use rand::Rng;

/*
 Schema
 */
#[derive(Deserialize, Debug)]
struct CreateUserRequest {
    email: String,
    password: String,
    name: String,
}

#[derive(Deserialize, Debug)]
struct UpdateUsersRequest {
    email: String,
    password: String,
    name: String,
}

#[derive(Serialize, Debug)]
struct UserResponse {
    id: u32,
    email: String,
    password: String,
    name: String,
}

impl From<User> for UserResponse {
    fn from(user: User) -> Self {
        UserResponse {
            id: user.id,
            email: user.email.to_string(),
            password: user.password.to_string(),
            name: user.name.to_string(),
        }
    }
}

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
}

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
    // Route all requests on "/" endpoint to anonymous handler.
    //
    // A handler is an async function which returns something that implements
    // `axum::response::IntoResponse`.

    // A closure or a function can be used as handler.

    let app = Router::new()

    /*
     curl -X POST localhost:3000/users \
     -H 'Content-Type:application/json' \
     -d '{"email": "tapegram@gmail.com", "password": "password123", "name": "Tavish Pegram"}'
     */
    .route("/users", post(create_user_handler))
    /*
     curl -X PUT localhost:3000/users/3834503660 \
     -H 'Content-Type:application/json' \
     -d '{"email": "tapegram+updated@gmail.com", "password": "safepassword", "name": "Charizard"}'
     */
    .route("/users/:id", put(update_user_handler))

    .layer(
        // Use tower/tower-http middleware to inject our shared state into our routes
        // Based on example: https://github.com/tokio-rs/axum/blob/dea36db400f27c025b646e5720b9a6784ea4db6e/examples/key-value-store/src/main.rs
        ServiceBuilder::new()
        .layer(AddExtensionLayer::new(SharedState::default()))
        .into_inner()
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

async fn create_user_handler(
    // Shared state injected by middleware
    Extension(state): Extension<SharedState>,
    // Json body from request
    Json(user): Json<CreateUserRequest>,
) -> Response {
    println!("CreateUserRequest: {:?}", user);

    // Create the User from the request
    // We could also do validation here like duplicate checking, etc.
    // We could also include the random ID generator as part of the shared state so we could
    // manipulate it in tests easier.
    let new_user = User {
        id: rand::thread_rng().gen(),
        email: user.email,
        password: user.password,
        name: user.name,
    };

    // Write the user to the state
    // Need to stick a clone in to get the memory managed correctly.
    // If its the "same entity" then everything goes crazy after
    state.write().unwrap().users.insert(new_user.id, new_user.clone());

    let user_response = UserResponse {
        id: new_user.id,
        email: new_user.email,
        password: new_user.password,
        name: new_user.name,
    };

    (StatusCode::OK, Json(user_response)).into_response()
}

async fn update_user_handler(
    // Shared state injected by middleware
    Extension(state): Extension<SharedState>,
    Path(id): Path<u32>,
    // Json body from request
    Json(user_update): Json<UpdateUsersRequest>,
) -> Response {
    println!("UpdateUserId: {:?}", id);
    let users = &mut state.write().unwrap().users;

    let user: User = match users.get(&id) {
        Some(user) => user,
        None => {
            return (
                StatusCode::NOT_FOUND, 
                Json(ErrorResponse { error: "User not found".to_string() })
            ).into_response();
        },
    }.clone(); // Have to clone this otherwise we cant do a mutable borrow of users

    println!("Found user: {:?}", user);

    // Write the user to the state
    // Need to stick a clone in to get the memory managed correctly.
    // If its the "same entity" then everything goes crazy after
    users.insert(
        user.id, 
        User {
            id: user.id,
            email: user_update.email.clone(),
            password: user_update.password.clone(),
            name: user_update.name.clone(),
        }
    );

    println!("Updated user!");

    let user_response = UserResponse {
        id: user.id,
        email: user_update.email,
        password: user_update.password,
        name: user_update.name,
    };

    (StatusCode::OK, Json(user_response)).into_response()
}
