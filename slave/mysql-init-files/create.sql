CREATE DATABASE db_name;

-- Create replication user
CREATE USER 'db_name'@'%' IDENTIFIED BY 'rootpassword';
GRANT ALL PRIVILEGES ON db_name.* TO 'db_name'@'%';

-- Apply changes
FLUSH PRIVILEGES;
