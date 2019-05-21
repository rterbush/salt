DROP DATABASE IF EXISTS salt-queues;
CREATE DATABASE salt-queues WITH ENCODING 'utf-8' OWNER salt;
GRANT ALL PRIVILEGES ON DATABASE salt-queues TO salt;
\connect salt-queues;
CREATE SCHEMA IF NOT EXISTS salt-queues AUTHORIZATION salt;

--
-- Table structure for table `salt`
--
DROP TABLE IF EXISTS salt;
CREATE OR REPLACE TABLE salt(
   id SERIAL PRIMARY KEY,
   data jsonb NOT NULL
);

GRANT ALL PRIVILEGES ON TABLE salt TO salt;
