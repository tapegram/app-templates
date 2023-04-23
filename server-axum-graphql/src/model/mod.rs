use async_graphql::EmptySubscription;
use async_graphql::{Context, Error, Object, Result, Schema, SimpleObject};
use rand::Rng;

use crate::SharedState;
use crate::User as CoreUser;

pub(crate) type ServiceSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub(crate) struct QueryRoot;
pub(crate) struct MutationRoot;

#[derive(SimpleObject, Clone)]
struct User {
    id: u32,
    name: String,
    email: String,
    password: String,
}

// Mapper from core type to api type
impl From<&CoreUser> for User {
    fn from(user: &CoreUser) -> Self {
        User {
            id: user.id,
            email: user.email.to_string(),
            password: user.password.to_string(),
            name: user.name.to_string(),
        }
    }
}

#[Object] // Macro wires Rust struct together with the underlying framework logic of
          // async-graphql
          //
          // Implementation contains all queries your service supports
impl QueryRoot {
    async fn users(&self, _ctx: &Context<'_>) -> Result<Vec<User>> {
        let users = &_ctx.data::<SharedState>().unwrap().read().unwrap().users;
        let users: Vec<CoreUser> = users.values().cloned().collect();
        let responses: Vec<_> = users.iter().map(|user| User::from(user)).collect();
        Ok(responses)
    }

    async fn user(&self, _ctx: &Context<'_>, id: u32) -> Result<User> {
        let users = &_ctx.data::<SharedState>().unwrap().read().unwrap().users;
        let user = match users.get(&id) {
            Some(u) => u,
            None => return Err(Error::new("User does not exit")),
        };

        let response = User::from(user);
        Ok(response)
    }
}

#[Object]
impl MutationRoot {
    async fn create_user(
        &self,
        _ctx: &Context<'_>,
        name: String,
        password: String,
        email: String,
    ) -> Result<User> {
        let new_user = CoreUser {
            id: rand::thread_rng().gen(),
            name: name.clone(),
            email: email.clone(),
            password: password.clone(),
        };

        // We should explicitly handle a possible failure instead of exploding
        let users = &_ctx
            .data::<SharedState>()
            .unwrap()
            .write()
            .unwrap()
            .users
            .insert(new_user.id, new_user.clone());

        Ok(User::from(&new_user))
    }
}
