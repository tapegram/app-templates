use std::{
    collections::HashMap,
    sync::{Arc, RwLock},
};
use serde::{Deserialize, Serialize};


/*
Structs
*/
#[derive(Deserialize, Debug)]
pub struct CreateUserRequest {
    pub email: String,
    pub password: String,
    pub name: String,
}

#[derive(Deserialize, Debug)]
pub struct UpdateUsersRequest {
    pub email: String,
    pub password: String,
    pub name: String,
}

#[derive(Serialize, Debug)]
pub struct UserResponse {
    pub id: u32,
    pub email: String,
    pub password: String,
    pub name: String,
}

impl From<&User> for UserResponse {
    fn from(user: &User) -> Self {
        UserResponse {
            id: user.id,
            email: user.email.to_string(),
            password: user.password.to_string(),
            name: user.name.to_string(),
        }
    }
}

/**
 * Core Models
 */

 type UserId = u32;

 #[derive(Debug, Deserialize, Clone, Eq, Hash, PartialEq)]
 pub struct User {
     pub id: UserId,
     pub email: String,
     pub password: String,
     pub name: String,
 }
 
 /**
 * App State
 *
 * Faking with just in memory stuff for now
 *
 */
#[derive(Default, Clone)]
pub struct State {
    pub users: HashMap<u32, User>,
}

impl State {
    pub async fn new() -> Self {
        tokio::task::spawn_blocking(|| {
            // create the new instance of the State struct
            Self {
                users: HashMap::new(),
            }
        })
        .await
        .unwrap()
    }
}

// Wrapping the state in a shared type so it can be shared across threads
pub type SharedState = Arc<RwLock<State>>;