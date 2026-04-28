CREATE DATABASE IF NOT EXISTS formalis_db;
USE formalis_db;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  role ENUM('apprenant', 'formateur', 'administrateur') NOT NULL DEFAULT 'apprenant',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email, role) VALUES
  ('Admin Formalis', 'admin@formalis.local', 'administrateur'),
  ('Pierre Deltier', 'pierre.deltier@formalis.local', 'apprenant'),
  ('Aïka Ramba', 'aika.ramba@formalis.local', 'formateur');
