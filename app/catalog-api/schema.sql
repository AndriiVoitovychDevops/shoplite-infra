-- ShopLite catalog schema and seed data.
-- Creates only the table and rows. Creating the database and the user
-- (and limiting where that user may connect from) is the provisioning's job.
-- Safe to run more than once.

CREATE TABLE IF NOT EXISTS products (
    id         INT UNSIGNED  NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(120)  NOT NULL UNIQUE,
    price      DECIMAL(10,2) NOT NULL,
    stock      INT UNSIGNED  NOT NULL DEFAULT 0,
    created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO products (name, price, stock) VALUES
    ('Mechanical keyboard', 89.90, 25),
    ('USB-C hub',           34.50, 120),
    ('27" monitor',        219.00, 8),
    ('Wireless mouse',      24.99, 0);
