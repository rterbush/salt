DROP DATABASE IF EXISTS salt;
CREATE DATABASE salt WITH ENCODING 'utf-8';

--
-- Table structure for table `salt`
--
DROP TABLE IF EXISTS salt;
CREATE TABLE salt(
   id SERIAL PRIMARY KEY,
   data jsonb NOT NULL
);