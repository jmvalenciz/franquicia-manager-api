-- First, let's create some helper functions for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Clear existing data (if any)
TRUNCATE TABLE productos CASCADE;
TRUNCATE TABLE sucursales CASCADE;
TRUNCATE TABLE franquicias CASCADE;

-- Insert franquicias (franchises)
INSERT INTO franquicias (id, nombre) 
VALUES 
    (uuid_generate_v4(), 'Super Burger'),
    (uuid_generate_v4(), 'Pizza Palace'),
    (uuid_generate_v4(), 'Taco Temple'),
    (uuid_generate_v4(), 'Sushi Express'),
    (uuid_generate_v4(), 'Coffee Haven');

-- Insert sucursales (branches)
WITH franchise_data AS (
    SELECT id as franchise_id, nombre as franchise_name 
    FROM franquicias
)
INSERT INTO sucursales (id, nombre, franquicia_id)
SELECT 
    uuid_generate_v4(),
    franchise_name || ' - ' || location,
    franchise_id
FROM franchise_data
CROSS JOIN (
    VALUES 
        ('Downtown'),
        ('North Mall'),
        ('South Plaza'),
        ('West Station'),
        ('East Park')
) AS locations(location);

-- Insert productos (products)
WITH branch_data AS (
    SELECT 
        s.id as sucursal_id,
        f.nombre as franchise_type
    FROM sucursales s
    JOIN franquicias f ON s.franquicia_id = f.id
),
product_names AS (
    SELECT 
        sucursal_id,
        franchise_type,
        generate_series(1, 8) as prod_num,
        CASE 
            WHEN franchise_type = 'Super Burger' THEN
                ARRAY[
                    'Classic Burger', 'Cheese Burger', 'Bacon Burger', 'Veggie Burger', 
                    'Chicken Burger', 'Fish Burger', 'Double Burger', 'Mushroom Burger'
                ]
            WHEN franchise_type = 'Pizza Palace' THEN
                ARRAY[
                    'Margherita', 'Pepperoni', 'Hawaiian', 'Vegetarian', 
                    'Four Cheese', 'BBQ Chicken', 'Supreme', 'Mediterranean'
                ]
            WHEN franchise_type = 'Taco Temple' THEN
                ARRAY[
                    'Beef Taco', 'Chicken Taco', 'Fish Taco', 'Veggie Taco',
                    'Supreme Burrito', 'Quesadilla', 'Enchiladas', 'Nachos'
                ]
            WHEN franchise_type = 'Sushi Express' THEN
                ARRAY[
                    'California Roll', 'Spicy Tuna Roll', 'Dragon Roll', 'Tempura Roll',
                    'Salmon Nigiri', 'Tuna Nigiri', 'Maki Combo', 'Sashimi Plate'
                ]
            ELSE
                ARRAY[
                    'Espresso', 'Cappuccino', 'Latte', 'Americano',
                    'Mocha', 'Green Tea', 'Hot Chocolate', 'Frappe'
                ]
        END as products
    FROM branch_data
)
INSERT INTO productos (nombre, stock, sucursal_id)
SELECT
    products[prod_num],  -- This ensures each product is used exactly once per branch
    floor(random() * 100 + 1)::integer,  -- Random stock between 1 and 100
    sucursal_id
FROM product_names;
