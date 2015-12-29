DROP SCHEMA IF EXISTS chatapp CASCADE;
CREATE SCHEMA chatapp;

CREATE OR REPLACE FUNCTION chatapp.gettime() RETURNS TIMESTAMP AS
$$
SELECT NOW() AT TIME ZONE 'Europe/Paris';
$$
LANGUAGE SQL;

CREATE TABLE IF NOT EXISTS chatapp.user_status(
  status_id INT PRIMARY KEY,
  description TEXT
);

INSERT INTO chatapp.user_status(status_id, description)
VALUES(1, 'active'),(2, 'blocked'),(3, 'non-active');

CREATE TABLE IF NOT EXISTS chatapp.user_type(
  type_id INT PRIMARY KEY,
  description TEXT
);

INSERT INTO chatapp.user_type(type_id, description)
VALUES(1, 'admin'),(2, 'registered_user');

CREATE TABLE IF NOT EXISTS chatapp.users(
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  location VARCHAR(50) NOT NULL,
  password VARCHAR(50) NOT NULL,
  birthdate DATE NOT NULL,
  on_line BOOLEAN NOT NULL DEFAULT false,
  user_status_id INT REFERENCES chatapp.user_status,
  user_type_id INT REFERENCES chatapp.user_type
);

INSERT INTO chatapp.users(user_id, username, email, first_name, last_name, location, password, birthdate, on_line, user_status_id, user_type_id)
VALUES(DEFAULT, 'admin', 'admin@presidentassad.net', 'Admin', 'al-Assad', 'Syria', 'syria1234', '2015-12-24', FALSE, 1, 1) RETURNING user_id AS admin_id;

CREATE TABLE IF NOT EXISTS chatapp.messages(
  message_id SERIAL PRIMARY KEY,
  user_id_from INT NOT NULL REFERENCES chatapp.users,
  user_id_to INT NOT NULL REFERENCES chatapp.users,
  message_text TEXT NOT NULL,
  is_public BOOLEAN NOT NULL DEFAULT false,
  time_sent TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chatapp.requests(
  request_id SERIAL PRIMARY KEY,
  user_id_from INT NOT NULL REFERENCES chatapp.users,
  user_id_to INT NOT NULL REFERENCES chatapp.users,
  hello_message TEXT DEFAULT 'Hi, add me as friend!',
  time_sent TIMESTAMP DEFAULT chatapp.gettime(),
  accepted BOOLEAN DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS chatapp.relationship(
  user_1 INT NOT NULL REFERENCES chatapp.users,
  user_2 INT NOT NULL REFERENCES chatapp.users,
  best_friends BOOLEAN NOT NULL DEFAULT false,
  user1_blocked_user2 BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS chatapp.log(
  user_id INT NOT NULL REFERENCES chatapp.users,
  description TEXT NOT NULL,
  log_time TIMESTAMP DEFAULT NOW()
);
