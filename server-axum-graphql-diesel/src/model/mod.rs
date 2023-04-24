use std::sync::Arc;

use crate::db_models::{create_user as new_user, get_user, get_users, PgPool, UserRecord};
use async_graphql::EmptySubscription;
use async_graphql::{Context, Object, Result, Schema, SimpleObject};

use crate::User as CoreUser;

pub(crate) type ServiceSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub(crate) struct QueryRoot;
pub(crate) struct MutationRoot;

#[derive(SimpleObject, Clone)]
struct User {
    id: i32,
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
//
// Mapper from db type to api schema type
impl From<&UserRecord> for User {
    fn from(user: &UserRecord) -> Self {
        User {
            id: user.id,
            email: user.email.to_string(),
            password: user.password.to_string(),
            name: user.name.to_string(),
        }
    }
}
//
// Mapper from api schema type to db type
//
impl From<&User> for UserRecord {
    fn from(user: &User) -> Self {
        UserRecord {
            id: user.id,
            email: user.email.to_string(),
            password: user.password.to_string(),
            name: user.name.to_string(),
        }
    }
}

#[Object]
impl QueryRoot {
    async fn users(&self, _ctx: &Context<'_>) -> Result<Vec<User>> {
        let pg_pool = _ctx.data::<Arc<PgPool>>().unwrap();
        let users: Vec<UserRecord> = get_users(&mut pg_pool.get().await.expect("")).await;
        let responses: Vec<User> = users.iter().map(|user| User::from(user)).collect();
        Ok(responses)
    }

    async fn user(&self, _ctx: &Context<'_>, id: i32) -> Result<User> {
        let pg_pool = _ctx.data::<Arc<PgPool>>().unwrap();
        let user = get_user(&mut pg_pool.get().await.expect(""), &id).await;
        let response = User::from(&user);
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
        let pg_pool = _ctx.data::<Arc<PgPool>>().unwrap();

        let user = new_user(
            &mut pg_pool.get().await.expect(""),
            &name,
            &email,
            &password,
        )
        .await;

        Ok(User::from(&user))
    }
}
