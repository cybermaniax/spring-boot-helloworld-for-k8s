CREATE TABLE IF NOT EXISTS country (
     id   INTEGER GENERATED BY DEFAULT AS IDENTITY,
     name VARCHAR(128) NOT NULL,
     PRIMARY KEY (id)
);