CREATE DATABASE db_name;

-- Create master user and grant privileges
CREATE USER 'db_name'@'%' IDENTIFIED BY 'rootpassword';
GRANT ALL PRIVILEGES ON db_name.* TO 'db_name'@'%';

-- Grant replication permissions
GRANT REPLICATION SLAVE ON *.* TO 'db_name'@'%';

-- Apply changes
FLUSH PRIVILEGES;
