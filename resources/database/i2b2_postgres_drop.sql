--
-- delete database 'i2b2' with its users (needed for installation reset)
--

DROP DATABASE IF EXISTS i2b2;

DROP USER IF EXISTS i2b2crcdata;
DROP USER IF EXISTS i2b2hive;
DROP USER IF EXISTS i2b2imdata;
DROP USER IF EXISTS i2b2metadata;
DROP USER IF EXISTS i2b2pm;
DROP USER IF EXISTS i2b2workdata;