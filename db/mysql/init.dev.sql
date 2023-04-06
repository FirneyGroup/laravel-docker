-- Create the central (catalogue) database
CREATE DATABASE `laravel`;

-- Catalogue database read-only user
GRANT ALL PRIVILEGES ON `laravel`.* TO 'laravel'@'%' IDENTIFIED BY 'LaravelPass$123!1';

-- Ensure privileges are flushed
FLUSH PRIVILEGES;
