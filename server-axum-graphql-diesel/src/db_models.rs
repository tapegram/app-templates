use crate::db_schema::users::{self, id};
use diesel::{query_dsl::methods::FilterDsl, ExpressionMethods, Insertable, Queryable};
use diesel_async::{pooled_connection::deadpool::Pool, AsyncPgConnection, RunQueryDsl};

// Queryable will generate all of the code needed to load a UserRecord struct from a SQL query
#[derive(Queryable, Clone)]
pub struct UserRecord {
    // Note that field order has to match db_schema.rs
    pub id: i32, // apparently we need to use i32 instead of u32 to match the pk type
    pub name: String,
    pub email: String,
    pub password: String,
}

#[derive(Insertable)]
#[diesel(table_name = users)]
struct NewUser<'a> {
    name: &'a str,
    email: &'a str,
    password: &'a str,
}

pub type PgPool = Pool<AsyncPgConnection>;

pub async fn create_user(pool: &mut PgPool, name: &str, email: &str, password: &str) -> UserRecord {
    let mut conn = pool.get().await.expect("Cant get connection from pool");
    let new_user = NewUser {
        name,
        email,
        password,
    };

    let rows: Vec<UserRecord> = diesel::insert_into(users::table)
        .values(&new_user)
        .get_results(&mut conn)
        .await
        .expect("Failed to create user");

    match rows.as_slice() {
        [record] => record.clone(),
        _ => panic!("Did not get back exactly one created record (either too few or too many)"),
    }
}

pub async fn get_users(pool: &mut PgPool) -> Vec<UserRecord> {
    let mut conn = pool.get().await.expect("Cant get connection from pool");
    users::table
        .load::<UserRecord>(&mut conn)
        .await
        .expect("Error loading users")
}

pub async fn get_user(pool: &mut PgPool, user_id: &i32) -> Vec<UserRecord> {
    let mut conn = pool.get().await.expect("Cant get connection from pool");
    users::table
        .filter(id.eq(user_id))
        .load::<UserRecord>(&mut conn)
        .await
        .expect("Error loading users")
}
