#![allow(unused)]

use anyhow::Result;
use serde_json::json;

#[tokio::test]
async fn test_1() -> Result<()> {
    //Create the client to do testing on the endpoints
    let hc = httpc_test::new_client("http://localhost:3000")?;

    //Test-1: Getting all users
    hc.do_get("/users").await?.print().await?;

    //Test-2: Creating a user
    hc.do_post("/users", json!({
        "email": "test2@test.com",
        "password": "password",
        "name": "testUser"
    }),
).await?.print().await?;

    Ok(())
}
