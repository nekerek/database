DROP DATABASE IF EXISTS assignment;
CREATE DATABASE assignment
    with owner = postgres;

-- Create tables
CREATE TABLE IF NOT EXISTS employees(
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary  NUMERIC(10,2),
    hire_date DATE,
    manager_id INTEGER,
    email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE  IF NOT EXISTS assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked NUMERIC(5,1),
    assignment_date DATE
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
 ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
 ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
 ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
 ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
 ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
 ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

 INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
 ('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
 ('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
 ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
 ('Database Migration', 120000, '2024-01-10', NULL, 'Active');

 INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
 (1, 1, 120.5, '2024-01-15'),
 (2, 1, 95.0, '2024-01-20'),
 (1, 4, 80.0, '2024-02-01'),
 (3, 3, 60.0, '2024-03-05'),
 (5, 2, 110.0, '2024-02-20'),
 (6, 3, 75.5, '2024-03-10');

--TASK 1.1
SELECT
    concat(first_name, ' ', last_name) AS full_name,
    department,
    salary
FROM employees;

--TASK 1.2
SELECT DISTINCT department
FROM employees;

--TASK 1.3
SELECT project_name,
       budget,
       CASE
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
        END AS budget_category
FROM projects;

--TASK 1.4
SELECT
    concat(first_name, ' ', last_name) AS full_name,
    coalesce(email, 'No email provided') AS email
FROM employees;

--TASK 2.1
SELECT
    concat(first_name, ' ', last_name) as full_name,
    hire_date
FROM employees
WHERE hire_date > DATE '2020-01-01';

--TASK 2.2
SELECT
    concat(first_name, ' ', last_name) as full_name,
    salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

--TASK 2.3
SELECT
    concat(first_name, ' ', last_name) as full_name,
    last_name
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

--TASK 2.4
SELECT
    concat(first_name, ' ', last_name) as full_name,
    employees.manager_id,
    employees.department
FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

--TASK 3.1
SELECT
    upper(concat(first_name, ' ', last_name)) as full_name,
    length(last_name) AS last_name_length,
    substring(email FROM 1 FOR 3) AS email3
FROM employees;

--TASK 3.2
SELECT
    concat(first_name, ' ', last_name) as full_name,
    (salary) AS annual_salary,
    round((salary / 12.0)::numeric,2) AS monthly_salary,
    round((salary * 0.10)::numeric, 2) AS raise_percent_10
FROM employees;

--TASK 3.3
SELECT
    format('Project: %s - Budget: $%s - Status: %s',
    project_name,
    budget,
    status) AS project_summary
FROM projects;

--TASK 3.4
SELECT
    concat(first_name, ' ', last_name) as full_name,
    hire_date,
    floor((CURRENT_DATE - hire_date)/365.25) AS experience
FROM employees;

--TASK 4.1
SELECT
    department,
    avg(salary) as average_salary
FROM employees
GROUP BY department;

--TASK 4.2
SELECT
  p.project_id,
  p.project_name,
  COALESCE(SUM(a.hours_worked),0) AS total_hours
FROM projects p
LEFT JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name;

--TASK 4.3
SELECT
    department,
    count(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

--TASK 4.4
SELECT
  MAX(salary) AS max_salary,
  MIN(salary) AS min_salary,
  SUM(salary) AS total_payroll
FROM employees;

--TASK 5.1
SELECT
    employee_id,
    concat(first_name, ' ', last_name) as full_name,
    salary
FROM employees
WHERE salary > 65000

UNION

SELECT
    employee_id,
    concat(first_name, ' ', last_name) as full_name,
    salary
FROM employees
WHERE hire_date > DATE '2020-01-01';

--TASK 5.2
SELECT
    employee_id,
    concat(first_name, ' ', last_name) as full_name,
    department,
    salary
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT
    employee_id,
    concat(first_name, ' ', last_name) as full_name,
    department,
    salary
FROM employees
WHERE salary > 65000;

--TASK 5.3
SELECT
    employees.employee_id,
    concat(first_name, ' ', last_name) as full_name
FROM employees

EXCEPT

SELECT
    employees.employee_id,
    concat(employees.first_name, ' ', employees.last_name) as full_name
FROM employees
JOIN assignments ON employees.employee_id = assignments.employee_id;

--TASK 6.1
SELECT
    employee_id,
    concat(first_name, ' ', last_name) as full_name
FROM employees
WHERE EXISTS(
    SELECT 1 FROM assignments WHERE employees.employee_id = assignments.employee_id
);

--TASK 6.2
SELECT
    e.employee_id,
    concat(e.first_name, ' ', e.last_name) as full_name
FROM employees e
WHERE e.employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);

--TASK 6.3
SELECT
    employees.employee_id,
    concat(employees.first_name, ' ', employees.last_name) AS full_name,
    employees.salary
FROM employees
WHERE salary > ANY (
    SELECT
        salary
    FROM employees
    WHERE department = 'Sales'
    );

--TASK 7.1
SELECT
    e.employee_id,
    concat(e.first_name, ' ', e.last_name) as full_name,
    (AVG(a.hours_worked)) AS avg_hours,
    (SELECT
         count(*) + 1
     FROM employees e2
     WHERE e2.department = e.department
        AND e2.salary > e.salary
     ORDER BY e.salary DESC
    ) AS rank_int_dept
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY department, rank_int_dept;

--TASK 7.2
SELECT
  p.project_id,
  p.project_name,
  SUM(a.hours_worked) AS total_hours,
  COUNT(DISTINCT a.employee_id) AS employees_assigned
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

--TASK 7.3
SELECT
    e1.department,
    count(e1.employee_id) AS total_emp,
    avg(e1.salary) AS average_salary,
    (SELECT
        concat(e2.first_name, ' ', e2.last_name) AS full_name
    FROM employees e2
    WHERE e2.department = e1.department
    ORDER BY e2.salary DESC
    LIMIT 1
    ) AS highest_paid,
    GREATEST(AVG(e1.salary), MIN(e1.salary)) AS max_salary,
    LEAST(AVG(e1.salary), MAX(e1.salary)) AS min_salary
FROM employees e1
GROUP BY e1.department;




