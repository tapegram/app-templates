use async_graphql::EmptySubscription;
use async_graphql::{Context, Object, Result, Schema, SimpleObject};

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

#[Object] // Macro wires Rust struct together with the underlying framework logic of
          // async-graphql
          //
          // Implementation contains all queries your service supports
impl QueryRoot {
    // hello is our first query
    // async fn hello(&self, _ctx: &Context<'_>) -> &'static str {
    //     "hello world"
    // }
    async fn users(&self, _ctx: &Context<'_>) -> Vec<User> {
        let users = &mut Vec::new();
        let user1 = User {
            id: 123,
            name: "Bob".to_string(),
            email: "Balaban".to_string(),
            password: "12345".to_string(),
        };
        let user2 = User {
            id: 456,
            name: "Fred".to_string(),
            email: "Astaire".to_string(),
            password: "12345".to_string(),
        };

        users.push(user1);
        users.push(user2);
        users.clone()
    }
}

#[Object]
impl MutationRoot {
    async fn create_user(&self, name: String, password: String, email: String) -> Result<User> {
        let user = User {
            id: 123,
            name: name.clone(),
            email: email.clone(),
            password: password.clone(),
        };
        Ok(user)
    }
}
