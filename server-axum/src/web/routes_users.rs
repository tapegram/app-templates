use axum::{
    extract::Path,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{post, put},
    Extension, Json, Router,
};
use rand::Rng;

use crate::{
    model::{CreateUserRequest, SharedState, UpdateUsersRequest, User, UserResponse},
    ErrorResponse,
};

pub fn routes(s: SharedState) -> Router {
    Router::new()
        .route("/users", post(create_user_handler).get(get_users_handler))
        .route("/users/:id", put(update_user_handler).get(get_user_handler))
        .with_state(s)
}

async fn get_users_handler(
    // Shared state injected by middleware
    Extension(state): Extension<SharedState>,
) -> Response {
    let users = &state.read().unwrap().users;
    let users: Vec<User> = users.values().cloned().collect();

    let responses: Vec<_> = users.iter().map(|user| UserResponse::from(user)).collect();
    (StatusCode::OK, Json(responses)).into_response()
}

async fn get_user_handler(
    // Shared state injected by middleware
    Extension(state): Extension<SharedState>,
    Path(id): Path<u32>,
) -> Response {
    let users = &state.read().unwrap().users;

    let user = match users.get(&id) {
        Some(u) => u,
        None => {
            return (
                StatusCode::NOT_FOUND,
                Json(ErrorResponse {
                    error: "User not found".to_string(),
                }),
            )
                .into_response();
        }
    };

    (StatusCode::OK, Json(UserResponse::from(user))).into_response()
}

async fn create_user_handler(
    // Note the order of args does matter -- if you swap these two you get a really weird error that's hard to debug
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
    state
        .write()
        .unwrap()
        .users
        .insert(new_user.id, new_user.clone());

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
                Json(ErrorResponse {
                    error: "User not found".to_string(),
                }),
            )
                .into_response();
        }
    }
    .clone(); // Have to clone this otherwise we cant do a mutable borrow of users

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
        },
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
