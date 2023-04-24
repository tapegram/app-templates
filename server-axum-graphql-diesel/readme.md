# server-axum-graphql-diesel

Building on server-axum-graphql but using Diesel and a real postgres DB.

Following along with:

https://diesel.rs/guides/getting-started.html

There is a docker-compose file you can use `docker compose up` to spin up an instance of a postgres DB. This needs to be running for the app to work.

## Dev flow

### diesel_cli

You will want to have the `diesel_cli` installed locally on your machine (not added to cargo/the project).

`cargo install diesel_cli --no-default-features --features postgres`

For an explanation of the flags, see: https://diesel.rs/guides/getting-started.html

### Creating a new DB migration

From the project root (note: not the repo root, since this repo is a collection of separate projects): 

`diesel migration generate <migration_name>`

This will put a new migration in ./migrations. You can then write sql for the `up.sql` and it's corresponding rollback `down.sql`.

When you are done, you can run the migration with `diesel migration run`

It’s a good idea to make sure that down.sql is correct. You can quickly confirm that your down.sql rolls back your migration correctly by redoing the migration:

`diesel migration redo`
