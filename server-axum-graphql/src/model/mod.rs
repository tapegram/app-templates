use async_graphql::{Context, Object, Schema, SimpleObject};
use async_graphql::{EmptyMutation, EmptySubscription};

pub(crate) type ServiceSchema = Schema<QueryRoot, EmptyMutation, EmptySubscription>;

pub(crate) struct QueryRoot;

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

#[derive(SimpleObject, Clone)]
struct User {
    id: u32,
    name: String,
    email: String,
    password: String,
}
