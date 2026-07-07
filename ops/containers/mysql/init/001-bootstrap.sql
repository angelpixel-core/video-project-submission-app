CREATE DATABASE IF NOT EXISTS `video_project_submission_app_development`;
CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'app_password';
GRANT ALL PRIVILEGES ON `video_project_submission_app_development`.* TO 'app'@'%';
FLUSH PRIVILEGES;
