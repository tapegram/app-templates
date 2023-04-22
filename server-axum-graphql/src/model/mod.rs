use async_graphql::{Context, Object, Schema};
use async_graphql::{EmptyMutation, EmptySubscription};

pub(crate) type ServiceSchema = Schema<QueryRoot, EmptyMutation, EmptySubscription>;

pub(crate) struct QueryRoot;

#[Object] // Macro wires Rust struct together with the underlying framework logic of
          // async-graphql
          //
          // Implementation contains all queries your service supports
impl QueryRoot {
    // hello is our first query
    async fn hello(&self, _ctx: &Context<'_>) -> &'static str {
        "hello world"
    }
}
