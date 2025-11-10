--  Part 2: Creating Basic Views
--  Exercise 2.1: Simple View Creation
DROP VIEW IF EXISTS employee_details;
CREATE VIEW employee_details AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_id, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;


--  Exercise 2.2: View with Aggregation
DROP VIEW IF EXISTS dept_statistics;
CREATE VIEW dept_statistics AS
SELECT
  d.dept_id,
  d.dept_name,
  COUNT(e.emp_id)          AS employee_count,
  ROUND(AVG(e.salary),2)   AS avg_salary,
  MAX(e.salary)            AS max_salary,
  MIN(e.salary)            AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

--  Exercise 2.3: View with Multiple Joins
DROP VIEW IF EXISTS project_overview;
CREATE VIEW project_overview AS
SELECT
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_id,
  d.dept_name,
  d.location,
  COALESCE(team.team_size, 0) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN (
    SELECT dept_id, COUNT(emp_id) AS team_size
    FROM employees
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
) team USING (dept_id);

--  Exercise 2.4: View with Filtering
DROP VIEW IF EXISTS high_earners;
CREATE VIEW high_earners AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

--  Part 3: Modifying and Managing Views
--  Exercise 3.1: Replace a View
DROP VIEW IF EXISTS employee_details;
CREATE VIEW employee_details AS
SELECT
  e.emp_id,
  e.emp_name,
  e.salary,
  CASE
    WHEN e.salary > 60000 THEN 'High'
    WHEN e.salary > 50000 THEN 'Medium'
    ELSE 'Standard'
  END AS salary_grade,
  d.dept_id, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 3.2: Rename a View
DROP VIEW IF EXISTS top_performers;
ALTER VIEW IF EXISTS high_earners RENAME TO top_performers;

--  Exercise 3.3: Drop a View
CREATE TEMP VIEW temp_view AS
SELECT emp_id, emp_name, salary FROM employees WHERE salary < 50000;

DROP VIEW IF EXISTS temp_view;


--  Part 4: Updatable Views
--  Exercise 4.1: Create an Updatable View
DROP VIEW IF EXISTS employee_salaries;
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

--  Exercise 4.2: Update Through a View
UPDATE employee_salaries SET salary = 52000 WHERE emp_id = 1;

--  Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

--  Exercise 4.4: View with CHECK OPTION
DROP VIEW IF EXISTS it_employees;
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

--  Part 5: Materialized Views
--  Exercise 5.1: Create a Materialized View
DROP MATERIALIZED VIEW IF EXISTS dept_summary_mv;
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
  d.dept_id,
  d.dept_name,
  COALESCE(COUNT(e.emp_id), 0) AS total_employees,
  COALESCE(SUM(e.salary), 0) AS total_salaries,
  COALESCE(COUNT(p.project_id), 0) AS total_projects,
  COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

--  Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

REFRESH MATERIALIZED VIEW dept_summary_mv;

--  Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX IF NOT EXISTS dept_summary_mv_dept_id_idx ON dept_summary_mv (dept_id);

--  Exercise 5.4: Materialized View with NO DATA
DROP MATERIALIZED VIEW IF EXISTS project_stats_mv;
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_name,
  COALESCE(e_count.emp_count, 0) AS assigned_employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN (
  SELECT dept_id, COUNT(emp_id) as emp_count
  FROM employees
  GROUP BY dept_id
) e_count ON e_count.dept_id = p.dept_id
WITH NO DATA;

REFRESH MATERIALIZED VIEW project_stats_mv;

--  Part 6: Database Roles
--  Exercise 6.1: Create Basic Roles
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';


--  Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;

--  Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- Exercise 6.4: Create Group Roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';
GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- Exercise 6.5: Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;

REVOKE hr_team FROM hr_user2;

REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

--  Exercise 6.6: Modify Role Attributes
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;

ALTER ROLE analyst WITH PASSWORD NULL;

ALTER ROLE data_viewer CONNECTION LIMIT 5;

--  Part 7: Advanced Role Management
--  Exercise 7.1: Role Hierarchies
CREATE ROLE read_only;
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;



GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

--  Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner LOGIN PASSWORD 'tempowner123';
CREATE TABLE IF NOT EXISTS temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE IF EXISTS temp_owner;


--  Exercise 7.4: Row-Level Security with Views
DROP VIEW IF EXISTS hr_employee_view;
CREATE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

DROP VIEW IF EXISTS finance_employee_view;
CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

--  Part 8: Practical Scenarios
--  Exercise 8.1: Department Dashboard View
DROP VIEW IF EXISTS dept_dashboard;
CREATE VIEW dept_dashboard AS
SELECT
  d.dept_id,
  d.dept_name,
  d.location,
  COALESCE(COUNT(e.emp_id),0) AS employee_count,
  ROUND(COALESCE(AVG(e.salary),0),2) AS avg_salary,
  COALESCE(COUNT(DISTINCT p.project_id),0) AS active_projects,
  COALESCE(SUM(p.budget),0) AS total_project_budget,
  ROUND(
    CASE WHEN COUNT(e.emp_id) = 0 THEN 0
         ELSE COALESCE(SUM(p.budget),0) / NULLIF(COUNT(e.emp_id),0)
    END
  ,2) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

-- Exercise 8.2: Audit View
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

DROP VIEW IF EXISTS high_budget_projects;
CREATE VIEW high_budget_projects AS
SELECT
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_name,
  p.created_date,
  CASE
    WHEN p.budget > 150000 THEN 'Critical Review Required'
    WHEN p.budget > 100000 THEN 'Management Approval Needed'
    ELSE 'Standard Process'
  END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

--  Exercise 8.3: Create Access Control System
CREATE ROLE viewer_role;
CREATE ROLE entry_role;
CREATE ROLE analyst_role;
CREATE ROLE manager_role;


CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';


  -- Role memberships: viewer_role -> entry_role -> analyst_role -> manager_role (entry inherits viewer)
  GRANT viewer_role TO entry_role;    -- entry_role has viewer permissions
  GRANT entry_role TO analyst_role;   -- analyst inherits entry (and viewer)
  GRANT analyst_role TO manager_role; -- manager inherits analyst (and entry, viewer)


  GRANT viewer_role TO alice;
  GRANT analyst_role TO bob;
  GRANT manager_role TO charlie;


GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;
GRANT INSERT ON employees, projects TO entry_role;
GRANT UPDATE ON employees, projects TO analyst_role;
GRANT DELETE ON employees, projects TO manager_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO viewer_role;



