-- SOURCES
DROP TABLE IF EXISTS databases CASCADE;
CREATE TABLE databases (
	id	TEXT NOT NULL,
	subtype TEXT NOT NULL,
	host	TEXT NOT NULL,
	port	INTEGER,
	service	TEXT,
	username	TEXT,
	password	TEXT,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS sources CASCADE;
CREATE TABLE sources (
  id TEXT NOT NULL,
  type TEXT NOT NULL,
  key_fields TEXT,
  PRIMARY KEY(id)
);

DROP TABLE IF EXISTS hdfs_files CASCADE;
CREATE TABLE hdfs_files (
  id TEXT NOT NULL,
  path TEXT NOT NULL,
  file_type TEXT NOT NULL,
  separator CHAR(1),
  header BOOLEAN,
  schema_path TEXT,
  date TEXT,
  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS file_fields CASCADE;
CREATE TABLE file_fields (
  owner TEXT NOT NULL,
  field_name TEXT NOT NULL,
  field_type TEXT NOT NULL,
  UNIQUE (owner, field_name),
  FOREIGN KEY (owner) REFERENCES hdfs_files (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS hive_tables CASCADE;
CREATE TABLE hive_tables (
  id TEXT NOT NULL,
  date TEXT NOT NULL,
  query VARCHAR(256) NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY (id) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS db_tables CASCADE;
CREATE TABLE db_tables (
  id TEXT NOT NULL,
  database TEXT NOT NULL,
  table_name TEXT NOT NULL,
  username TEXT,
  password TEXT,
  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (database) REFERENCES databases (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS virtual_sources;
CREATE TABLE virtual_sources (
  id TEXT NOT NULL,
  tipo TEXT NOT NULL,
  left_source TEXT NOT NULL,
  right_source TEXT,
  query TEXT NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY (id) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (left_source) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (right_source) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- METRICS

DROP TABLE IF EXISTS metrics CASCADE;
CREATE TABLE metrics(
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS file_metrics CASCADE;
CREATE TABLE file_metrics(
  id TEXT NOT NULL,
  source TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (source) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS column_metrics CASCADE;
CREATE TABLE column_metrics(
  id TEXT NOT NULL,
  source TEXT NOT NULL,
  column_names TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (source) REFERENCES sources (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS metric_parameters CASCADE;
CREATE TABLE metric_parameters(
  owner TEXT NOT NULL,
  name TEXT NOT NULL,
  value TEXT NOT NULL,
  UNIQUE (owner, name),
  FOREIGN KEY (owner) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS composed_metrics CASCADE;
CREATE TABLE composed_metrics(
  id TEXT NOT NULL,
  formula TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS composed_metric_connections CASCADE;
CREATE TABLE composed_metric_connections(
  composed_metric TEXT NOT NULL,
  formula_metric TEXT NOT NULL,
  UNIQUE (composed_metric, formula_metric),
  FOREIGN KEY (composed_metric) REFERENCES composed_metrics (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (formula_metric) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- CHECKS
DROP TABLE IF EXISTS checks CASCADE;
CREATE TABLE checks(
  id TEXT NOT NULL,
  type TEXT NOT NULL,
  subtype TEXT NOT NULL,
  description TEXT,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS sql_checks CASCADE;
CREATE TABLE sql_checks(
  id TEXT NOT NULL,
  database TEXT NOT NULL,
  query TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (database) REFERENCES databases (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id) REFERENCES checks (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS snapshot_checks CASCADE;
CREATE TABLE snapshot_checks(
  id TEXT NOT NULL,
  metric TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (metric) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id) REFERENCES checks (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS trend_checks CASCADE;
CREATE TABLE trend_checks(
  id TEXT NOT NULL,
  metric TEXT NOT NULL,
  rule TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (metric) REFERENCES metrics (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id) REFERENCES checks (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS check_parameters CASCADE;
CREATE TABLE check_parameters(
  owner TEXT NOT NULL,
  name TEXT NOT NULL,
  value TEXT NOT NULL,
  UNIQUE (owner, name),
  FOREIGN KEY (owner) REFERENCES checks (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TARGETS
DROP TABLE IF EXISTS targets CASCADE;
CREATE TABLE targets (
	id	TEXT NOT NULL,
	target_type TEXT NOT NULL,
	file_format	TEXT NOT NULL,
	path	TEXT NOT NULL,
	delimiter	TEXT,
	savemode	TEXT,
	partitions	INTEGER,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS target_to_checks CASCADE;
CREATE TABLE target_to_checks (
  target_id TEXT NOT NULL,
  check_id TEXT NOT NULL,
  FOREIGN KEY (check_id) REFERENCES checks (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (target_id) REFERENCES targets (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS mails CASCADE;
CREATE TABLE mails (
  address TEXT NOT NULL,
  owner TEXT NOT NULL,
  UNIQUE (address, owner),
  FOREIGN KEY (owner) REFERENCES targets (id) ON UPDATE CASCADE ON DELETE CASCADE
);
