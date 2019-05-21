DROP DATABASE IF EXISTS salt_queues;
CREATE DATABASE salt_queues WITH ENCODING 'utf-8' OWNER salt;
GRANT ALL PRIVILEGES ON DATABASE salt_queues TO salt;
\connect salt_queues;
CREATE SCHEMA IF NOT EXISTS salt_queues AUTHORIZATION salt;

--
-- Table structure for table `salt`
--
DROP TABLE IF EXISTS salt;
CREATE OR REPLACE TABLE salt(
   id SERIAL PRIMARY KEY,
   data jsonb NOT NULL
);

GRANT ALL PRIVILEGES ON TABLE salt TO salt;
