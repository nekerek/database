-- Create table: employees
CREATE TABLE IF NOT EXISTS employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2)
);

-- Create table: departments
CREATE TABLE IF NOT EXISTS departments(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
-- Create table: projects
 CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
 );
--  Step 1.2: Insert Sample Data
           -- Insert data into employees
 INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 102, 60000),
 (3, 'Mike Johnson', 101, 55000),
 (4, 'Sarah Williams', 103, 65000),
 (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
 INSERT INTO departments (dept_id, dept_name, location)
 VALUES
 (101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Finance', 'Building C'),
 (104, 'Marketing', 'Building D');
-- Insert data into projects
 INSERT INTO projects (project_id, project_name, dept_id, budget)
 VALUES
 (1, 'Website Redesign', 101, 100000),
 (2, 'Employee Training', 102, 50000),
 (3, 'Budget Analysis', 103, 75000),
 (4, 'Cloud Migration', 101, 150000),
 (5, 'AI Research', NULL, 200000);


-- Part 2: CROSS JOIN Exercises
--  Exercise 2.1: Basic CROSS JOIN
--  Write a query using CROSS JOIN to show all possible combinations of employees and
-- departments.

SELECT e.emp_name,
       d.dept_name
FROM employees e
CROSS JOIN departments d;

-- N = number of employees = 5
-- M = number of departments = 4
-- 5 * 4 = 20


--  Exercise 2.2: Alternative CROSS JOIN Syntax
-- a
SELECT e.emp_name,
       d.dept_name
FROM employees e, departments d;
-- b
SELECT e.emp_name,
       d.dept_name
FROM employees e
INNER JOIN departments d
ON TRUE;

--  Exercise 2.3: Practical CROSS JOIN
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;

-- Part 3: INNER JOIN Exercises
--  Exercise 3.1: Basic INNER JOIN with ON
 SELECT e.emp_name, d.dept_name, d.location
 FROM employees e
 INNER JOIN departments d ON e.dept_id = d.dept_id;
--Tom Brown has dept_id = NULL, so he excluded, COUNT = 4

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

-- Difference with ON version:
-- USING collapses the join column into a single column (dept_id not repeated).

--  Exercise 3.3: NATURAL INNER JOIN
 SELECT emp_name, dept_name, location
 FROM employees
 NATURAL INNER JOIN departments;

--  Exercise 3.4: Multi-table INNER JOIN
 SELECT e.emp_name, d.dept_name, p.project_name
 FROM employees e
 INNER JOIN departments d ON e.dept_id = d.dept_id
 INNER JOIN projects p ON d.dept_id = p.dept_id;

--  Part 4: LEFT JOIN Exercises
--  Exercise 4.1: Basic LEFT JOIN
 SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
 FROM employees e
 LEFT JOIN departments d ON e.dept_id = d.dept_id;

--Tom Brown with emp_dept = NULL and dept_dept = NULL, dept_name = NULL.

--  Exercise 4.2: LEFT JOIN with USING
 SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
 FROM employees e
 LEFT JOIN departments d
 USING (dept_id);

--  Exercise 4.3: Find Unmatched Records
 SELECT e.emp_name, e.dept_id
 FROM employees e
 LEFT JOIN departments d ON e.dept_id = d.dept_id
 WHERE d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with Aggregation
 SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
 FROM departments d
 LEFT JOIN employees e ON d.dept_id = e.dept_id
 GROUP BY d.dept_id, d.dept_name
 ORDER BY employee_count DESC;

--  Part 5: RIGHT JOIN Exercises
--  Exercise 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
 FROM employees e
 RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
 FROM departments d
 LEFT JOIN employees e ON e.dept_id = d.dept_id;

 Exercise 5.3: Find Departments Without Employees
 SELECT d.dept_name, d.location
 FROM employees e
 RIGHT JOIN departments d ON e.dept_id = d.dept_id
 WHERE e.emp_id IS NULL;

--  Part 6: FULL JOIN Exercises
--  Exercise 6.1: Basic FULL JOIN
 SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
 FROM employees e
 FULL JOIN departments d ON e.dept_id = d.dept_id;

-- - NULL on the left side occurs for departments that have no employees.
-- - NULL on the right side  occurs for employees without departments.
--  Exercise 6.2: FULL JOIN with Projects
 SELECT d.dept_name, p.project_name, p.budget
 FROM departments d
 FULL JOIN projects p ON d.dept_id = p.dept_id;

--  Exercise 6.3: Find Orphaned Records

 SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
 FROM employees e
 FULL JOIN departments d ON e.dept_id = d.dept_id
 WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--  Part 7: ON vs WHERE Clause
--  Exercise 7.1: Filtering in ON Clause (Outer Join)
 SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

--  Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--  Question: Compare the results of Query 1 and Query 2. Explain the difference.
--  Answer:
--  • Query 1 (ON clause): Applies the filter BEFORE the join, so all employees are included, but
-- only departments in Building A are matched.
--  • Query 2 (WHERE clause): Applies the filter AFTER the join, so employees are excluded if
-- their department is not in Building A.

--  Exercise 7.3: ON vs WHERE with INNER JOIN
 SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- For INNER JOIN, applying the filter in ON or WHERE yields the same final result


--  Part 8: Complex JOIN Scenarios
--  Exercise 8.1: Multiple Joins with Different Types
 SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
 FROM departments d
 LEFT JOIN employees e ON d.dept_id = e.dept_id
 LEFT JOIN projects p ON d.dept_id = p.dept_id
 ORDER BY d.dept_name, e.emp_name;

--  Exercise 8.2: Self Join
 ALTER TABLE employees ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
 UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
 UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
 UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
 UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
-- Self join query
 SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
 FROM employees e
 LEFT JOIN employees m ON e.manager_id = m.emp_id;

--  Exercise 8.3: Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS average_salary
FROM departments d
INNER JOIN employees e on d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- Lab Questions

--  What is the difference between INNER JOIN and LEFT JOIN?
    -- INNER JOIN returns only rows where the join condition matches in both tables. LEFT JOIN returns all rows from the left table and matching rows from the right; unmatched right-side columns are NULL.
--  When would you use CROSS JOIN in a practical scenario?
    -- To generate Cartesian product
--  Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
    -- ON is applied during the join (controls which rows match). WHERE filters final result set. For outer joins, ON can limit matched rows without excluding unmatched outer rows, while WHERE may exclude those unmatched rows (turning the outer join into an inner-like result). INNER JOIN discards unmatched rows anyway, so applying a condition in ON or WHERE yields same result.
--  What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
    --  SELECT COUNT(*) FROM table1 CROSS JOIN table2 returns 50.
--  How does NATURAL JOIN determine which columns to join on?
    -- it uses all columns with the same names in both tables.
--  What are the potential risks of using NATURAL JOIN?
    -- unintended matches if new columns with same names appear;
--  Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
    -- SELECT * FROM B RIGHT JOIN A ON A.id = B.id
--  When should you use FULL OUTER JOIN instead of other join types?
    -- Use FULL OUTER JOIN when you need to show all rows from both tables



--  Create a query that simulates FULL OUTER JOIN using UNION of LEFT and RIGHT joins (for databases that don't support FULL OUTER JOIN).
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON d.dept_id = e.dept_id

UNION

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON d.dept_id = e.dept_id;
