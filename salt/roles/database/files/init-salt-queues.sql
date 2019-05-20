DROP DATABASE IF EXISTS salt;
CREATE DATABASE salt WITH ENCODING 'utf-8' OWNER salt;
GRANT ALL PRIVILEGES ON DATABASE salt TO salt;
\connect salt;
CREATE SCHEMA IF NOT EXISTS salt AUTHORIZATION salt;
--
-- Table structure for table `salt`
--
DROP TABLE IF EXISTS salt;
CREATE TABLE salt(
   id SERIAL PRIMARY KEY,
   data jsonb NOT NULL
);

--
-- Table structure for table `jids`
--
DROP TABLE IF EXISTS jids;
CREATE TABLE jids (
   jid varchar(255) NOT NULL primary key,
   load jsonb NOT NULL
);
CREATE INDEX idx_jids_jsonb on jids
       USING gin (load)
       WITH (fastupdate=on);

--
-- Table structure for table `salt_returns`
--

DROP TABLE IF EXISTS salt_returns;
CREATE TABLE salt_returns (
  fun varchar(50) NOT NULL,
  jid varchar(255) NOT NULL,
  return jsonb NOT NULL,
  id varchar(255) NOT NULL,
  success varchar(10) NOT NULL,
  full_ret jsonb NOT NULL,
  alter_time TIMESTAMP WITH TIME ZONE DEFAULT NOW());

CREATE INDEX idx_salt_returns_id ON salt_returns (id);
CREATE INDEX idx_salt_returns_jid ON salt_returns (jid);
CREATE INDEX idx_salt_returns_fun ON salt_returns (fun);
CREATE INDEX idx_salt_returns_return ON salt_returns
    USING gin (return) with (fastupdate=on);
CREATE INDEX idx_salt_returns_full_ret ON salt_returns
    USING gin (full_ret) with (fastupdate=on);

--
-- Table structure for table `salt_events`
--

DROP TABLE IF EXISTS salt_events;
DROP SEQUENCE IF EXISTS seq_salt_events_id;
CREATE SEQUENCE seq_salt_events_id;
CREATE TABLE salt_events (
    id BIGINT NOT NULL UNIQUE DEFAULT nextval('seq_salt_events_id'),
    tag varchar(255) NOT NULL,
    data jsonb NOT NULL,
    alter_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    master_id varchar(255) NOT NULL);

CREATE INDEX idx_salt_events_tag on
    salt_events (tag);
CREATE INDEX idx_salt_events_data ON salt_events
    USING gin (data) with (fastupdate=on);

GRANT ALL PRIVILEGES ON TABLE jids TO salt;
GRANT ALL PRIVILEGES ON TABLE salt TO salt;
GRANT ALL PRIVILEGES ON TABLE salt_events TO salt;
GRANT ALL PRIVILEGES ON TABLE salt_returns TO salt:
GRANT ALL PRIVILEGES ON SEQUENCE salt_id_seq TO salt;
GRANT ALL PRIVILEGES ON SEQUENCE seq_salt_events_id TO salt;
