create table users (
  id serial primary key,
  name varchar not null,
  email varchar not null,
  -- Don't ever actual save passwords in a DB -- only save the hashes
  password varchar not null
);
