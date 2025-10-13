-- NURSULTAN YERBATYR 24B031074


DROP DATABASE IF EXISTS constraints;

CREATE DATABASE constraints
    WITH OWNER = postgres;

--  Part 1: CHECK Constraints
--  Task 1.1: Basic CHECK Constraint
CREATE TABLE IF NOT EXISTS employees(
    employee_id SERIAL,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK(age BETWEEN 18 AND 65),
    salary NUMERIC CHECK ( salary > 0 )
);
--  Write the CREATE TABLE statement with appropriate CHECK constraints


--  Task 1.2: Named CHECK Constraint
CREATE TABLE IF NOT EXISTS products_catalog(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK ( regular_price > 0 AND
                                      discount_price > 0 AND
                                      discount_price < regular_price)
);
--  Add a named CHECK constraint called valid_discount that ensures:
--  • regular_price is greater than 0
--  • discount_price is greater than 0
--  • discount_price is less than regular_price

--  Task 1.3: Multiple Column CHECK
CREATE TABLE IF NOT EXISTS bookings(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK ( num_guests BETWEEN 1 AND 10),
    CHECK (check_in_date < check_out_date )
);
-- Add CHECK constraints to ensure:
--  • num_guests is between 1 and 10
--  • check_out_date is after check_in_date

--  Task 1.4: Testing CHECK Constraints
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES
 (1, 'Yerbatyr', 'Nursultan', 17, 65000);
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES
 (2, 'Arman',   'Norsultanov', 19, 75000);
/*
ОШИБКА: новая строка в отношении "employees" нарушает ограничение-проверку "employees_age_check"
Подробности: Ошибочная строка содержит (1, Yerbatyr, Nursultan, 17, 65000).*/


INSERT INTO products_catalog VALUES (1, 'Water', 100.00, 80.00);
INSERT INTO products_catalog VALUES (2, 'Juice', 50.00, 53.55);
/*ОШИБКА: новая строка в отношении "products_catalog" нарушает ограничение-проверку "valid_discount"
Подробности: Ошибочная строка содержит (2, Juice, 50.00, 53.55).
*/

INSERT INTO bookings VALUES (1, DATE '2024-09-01', DATE '2024-09-05', 11);
INSERT INTO bookings VALUES (2, DATE '2024-10-10', DATE '2024-10-12', 4);
/*ОШИБКА: новая строка в отношении "bookings" нарушает ограничение-проверку "bookings_num_guests_check"
Подробности: Ошибочная строка содержит (1, 2024-09-01, 2024-09-05, 11).
*/


--  Part 2: NOT NULL Constraints
--  Task 2.1: NOT NULL Implementation
CREATE TABLE IF NOT EXISTS customers(
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

--  Task 2.2: Combining Constraints
CREATE TABLE IF NOT EXISTS inventory(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK ( quantity >= 0 ),
    unit_price NUMERIC NOT NULL CHECK ( unit_price > 0 ),
    last_updated TIMESTAMP NOT NULL
);

--  Task 2.3: Testing NOT NULL
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
 (1, 'a@email.com', null, DATE '2024-01-01');
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
 (1, null, '25-72-37', DATE '2024-01-01');
/*ОШИБКА: значение NULL в столбце "email" отношения "customers" нарушает ограничение NOT NULL
Подробности: Ошибочная строка содержит (1, null, 25-72-37, 2024-01-01).*/

INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES (3, 'Bolt', -5, 0.5, NOW());
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (1, 'Screwdriver', 100, 9.99, NOW());
/*ОШИБКА: новая строка в отношении "inventory" нарушает ограничение-проверку "inventory_quantity_check"
Подробности: Ошибочная строка содержит (3, Bolt, -5, 0.5, 2025-10-13 14:07:23.854894).
*/


--  Part 3: UNIQUE Constraints
--  Task 3.1: Single Column UNIQUE
CREATE TABLE IF NOT EXISTS users(
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

--  Task 3.2: Multi-Column UNIQUE
CREATE TABLE IF NOT EXISTS course_enrollments(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

--  Task 3.3: Named UNIQUE Constraints
ALTER TABLE users
    ADD CONSTRAINT unique_username
                        UNIQUE (username),
    -- Add a named UNIQUE constraint called unique_username on username
    ADD CONSTRAINT unique_email
                        UNIQUE (email);
    -- Add a named UNIQUE constraint called unique_email on email


-- Test by trying to insert duplicate usernames and emails
INSERT INTO course_enrollments VALUES (1, 101, 'CS101', '2024-Fall');
INSERT INTO course_enrollments VALUES (3, 101, 'CS101', '2024-Fall');
/*ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "course_enrollments_student_id_course_code_semester_key"
Подробности: Ключ "(student_id, course_code, semester)=(101, CS101, 2024-Fall)" уже существует.
*/

-- Part 4: PRIMARY KEY Constraints
--  Task 4.1: Single Column Primary Key
CREATE TABLE IF NOT EXISTS departments(
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
--
--  Insert at least 3 departments and attempt to:
INSERT INTO departments VALUES
(1, 'IT', 'Building A'),
(2, 'Sales', 'Building B'),
(3, 'HR', 'Building C');

--  1.Insert a duplicate dept_id
INSERT INTO departments VALUES (3, 'Ops', 'Building D');
/*ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "departments_pkey"
Подробности: Ключ "(dept_id)=(3)" уже существует.*/

--  2.Insert a NULL dept_id
INSERT INTO departments (dept_name, location) VALUES ('New', 'X');
/*ОШИБКА: значение NULL в столбце "dept_id" отношения "departments" нарушает ограничение NOT NULL
[2025-10-13 19:14:16] Подробности: Ошибочная строка содержит (null, New, X)*/

--  Task 4.2: Composite Primary Key
CREATE TABLE IF NOT EXISTS student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

--  Task 4.3: Comparison Exercise
--  Write a document explaining:
--  1.The difference between UNIQUE and PRIMARY KEY
--   PRIMARY KEY: uniquely identifies rows, implies NOT NULL, table may have only one PK.
--   UNIQUE: enforces uniqueness but allows NULLs, and there can be multiple unique constraints.
--  2.When to use a single-column vs. composite PRIMARY KEY
--    Single-column PK is simpler. Composite PK used when natural uniqueness spans multiple columns (e.g., mapping tables).
--  3.Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
--    Because PK is the main identifier of the row; database design allows multiple secondary uniqueness constraints via UNIQUE.


--  Part 5: FOREIGN KEY Constraints
-- Task 5.1: Basic Foreign Key
CREATE TABLE IF NOT EXISTS employees_dept(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
--  Test by:
--  1.Inserting employees with valid dept_id
INSERT INTO employees_dept VALUES (10, 'Dorash', 1, DATE '2022-06-01');
--  2.Attempting to insert an employee with a non-existent dept_id
INSERT INTO employees_dept VALUES (11, 'Amanbek', 99, DATE '2024-01-01');
/* ОШИБКА: INSERT или UPDATE в таблице "employees_dept" нарушает ограничение внешнего ключа "employees_dept_dept_id_fkey"
Подробности: Ключ (dept_id)=(99) отсутствует в таблице "departments".
*/

--  Task 5.2: Multiple Foreign Keys
CREATE TABLE IF NOT EXISTS authors(
    authors_id INTEGER PRIMARY KEY,
    authors_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE IF NOT EXISTS publishers(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE IF NOT EXISTS books(
    books_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(authors_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

--   Insert sample data into all tables
INSERT INTO authors VALUES (1, 'George Orwell', 'UK'),
                           (2, 'Jane Austen', 'UK');

INSERT INTO publishers VALUES (1, 'Penguin Books', 'London'),
                              (2, 'Vintage', 'NYC');

INSERT INTO books VALUES (1, '1984', 1, 1, 1949, '9780451524935'),
                         (2, 'Pride and Prejudice', 2, 2, 1813, '9780141040349');

-- Task 5.3: ON DELETE Options
--  Create a schema demonstrating different ON DELETE behaviors:
CREATE TABLE IF NOT EXISTS categories(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS products_fk(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS orders(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK ( quantity > 0 )
);

INSERT INTO categories VALUES (10, 'Electronics');
INSERT INTO products_fk VALUES (100, 'Phone', 10);
INSERT INTO products_fk VALUES (101, 'Laptop', 10);

INSERT INTO orders VALUES (500, DATE '2024-08-01');
INSERT INTO order_items VALUES (900, 500, 100, 2);
INSERT INTO order_items VALUES (901, 500, 101, 1);

--  Test the following scenarios:
--  1.Try to delete a category that has products (should fail with RESTRICT)
DELETE FROM categories WHERE category_id = 10;
/*ОШИБКА: UPDATE или DELETE в таблице "categories" нарушает ограничение внешнего ключа "products_fk_category_id_fkey" таблицы "products_fk"
Подробности: На ключ (category_id)=(10) всё ещё есть ссылки в таблице "products_fk".*/

--  2.Delete an order and observe that order_items are automatically deleted (CASCADE)
DELETE FROM orders WHERE order_id = 500; -- 1 row affected in 38 ms
DELETE FROM products_fk WHERE product_id = 100; -- 1 row affected in 39 ms
--  3. Document what happens in each case



--  Part 6: Practical Application
--  Task 6.1: E-commerce Database Design


CREATE TABLE IF NOT EXISTS customers_e(
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS products_e(
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK ( price > 0 ),
    stock_quantity INTEGER CHECK ( stock_quantity > 0 )
);

CREATE TABLE IF NOT EXISTS orders_e(
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_e ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount INTEGER,
    status VARCHAR CHECK (status IN ( 'pending', 'processing', 'shipped', 'delivered', 'cancelled') )
);

CREATE TABLE IF NOT EXISTS order_details_e(
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders_e ON DELETE CASCADE ,
    product_id INTEGER REFERENCES customers_e,
    quantity INTEGER CHECK ( quantity > 0 ),
    unit_price NUMERIC
);

--
--  Deliverables:
--  1.Complete CREATE TABLE statements
--  2.At least 5 sample records per table
INSERT INTO customers_e (customer_name, email, phone, registration_date) VALUES
('Alice Customer','alice@shop.test','555-1001', DATE '2024-01-10'),
('Bob Buyer','bob@shop.test','555-1002', DATE '2024-02-15'),
('Carol Client','carol@shop.test','555-2504', DATE '2024-03-05'),
('David Doe','david@shop.test','555-1004', DATE '2024-04-01'),
('Eve Example','eve@shop.test','555-1005', DATE '2024-05-20');

INSERT INTO products_e (product_name, description, price, stock_quantity) VALUES
('Gadget','A cool gadget', 49.99, 100),
('Widget','Useful widget', 19.50, 200),
('Doohickey','Handy doohickey', 5.00, 1000),
('Premium Device','Top-tier device', 199.99, 20),
('Accessory','Accessory item', 9.99, 500);

INSERT INTO orders_e (customer_id, order_date, total_amount, status) VALUES
(1, DATE '2024-07-01', 69.49, 'processing'),
(2, DATE '2024-07-02', 19.50, 'pending'),
(3, DATE '2024-07-03', 250.00, 'shipped'),
(4, DATE '2024-07-04', 15.00, 'delivered'),
(5, DATE '2024-07-05', 199.99, 'pending');

INSERT INTO order_details_e (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 49.99),
(1, 5, 2, 9.75),
(2, 2, 1, 19.50),
(3, 4, 1, 199.99),
(4, 3, 3, 5.00);
--  3.Test queries demonstrating that all constraints work correctly
-- Tests for constraints in e-commerce:
-- 1) Price non-negative:
-- INSERT INTO products_e (name, price, stock_quantity) VALUES ('BadPrice', -1, 10); -- violates CHECK (price >= 0)
-- 2) Stock non-negative:
-- INSERT INTO products_e (name, price, stock_quantity) VALUES ('BadStock', 10, -5); -- violates CHECK (stock_quantity >= 0)
-- 3) Order status allowed values:
-- INSERT INTO orders_e (customer_id, order_date, total_amount, status) VALUES (1, CURRENT_DATE, 10, 'unknown'); -- will fail: invalid input value for enum
-- 4) Quantity positive:
-- INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES (1,1,0,49.99); -- violates CHECK (quantity > 0)
-- 5) Unique email:
-- INSERT INTO customers_e (name,email,registration_date) VALUES ('Dup','alice@shop.test',CURRENT_DATE); -- violates UNIQUE(email)

-- Example test demonstrating ON DELETE behaviors:
-- If an order is deleted, its order_details should be deleted automatically (CASCADE).
-- Run (interactive test):
-- DELETE FROM orders_e WHERE order_id = 1;
-- SELECT * FROM order_details WHERE order_id = 1; -- should return no rows

-- If a customer is deleted, orders_ec.customer_id will be set to NULL (ON DELETE SET NULL).
-- DELETE FROM customers_e WHERE customer_id = 5;
-- SELECT * FROM orders_e WHERE order_id = 5; -- customer_id should now be NULLst',CURRENT_DATE); -- violates UNIQUE(email)