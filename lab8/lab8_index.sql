-- Part 2: Creating Basic Indexes
--  Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

 SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- employees_pkey — automatically created for PRIMARY KEY (emp_id)
-- emp_salary_idx — created manually


-- Exercise 2.2: Create an Index on a Foreign Key
--  Create an index on the dept_id column in the employees table:
 CREATE INDEX emp_dept_idx ON employees(dept_id);

 SELECT * FROM employees WHERE dept_id = 101;

-- Because foreign key columns are frequently used in:
-- JOIN operations
-- Filtering WHERE dept_id = …
-- ON DELETE / UPDATE actions (to verify referential integrity)

--  Exercise 2.3: View Index Information
--  Use PostgreSQL system catalogs to view detailed index information:


 SELECT
    tablename,
    indexname,
    indexdef
 FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;
-- departments,departments_pkey,CREATE UNIQUE INDEX departments_pkey ON public.departments USING btree (dept_id)
-- departments,dept_name_hash_idx,CREATE INDEX dept_name_hash_idx ON public.departments USING hash (dept_name)
-- dept_summary_mv,dept_summary_mv_dept_id_idx,CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx ON public.dept_summary_mv USING btree (dept_id)
-- employees,emp_dept_salary_idx,"CREATE INDEX emp_dept_salary_idx ON public.employees USING btree (dept_id, salary)"
-- employees,emp_email_unique_idx,CREATE UNIQUE INDEX emp_email_unique_idx ON public.employees USING btree (email)
-- employees,emp_hire_year_idx,CREATE INDEX emp_hire_year_idx ON public.employees USING btree (EXTRACT(year FROM hire_date))
-- employees,emp_name_lower_idx,CREATE INDEX emp_name_lower_idx ON public.employees USING btree (lower((emp_name)::text))
-- employees,emp_salary_desc_idx,CREATE INDEX emp_salary_desc_idx ON public.employees USING btree (salary DESC)
-- employees,employees_phone_key,CREATE UNIQUE INDEX employees_phone_key ON public.employees USING btree (phone)
-- employees,employees_pkey,CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (emp_id)
-- employees,employees_salary_index,CREATE INDEX employees_salary_index ON public.employees USING btree (salary)
-- projects,proj_high_budget_idx,CREATE INDEX proj_high_budget_idx ON public.projects USING btree (budget) WHERE (budget > (80000)::numeric)
-- projects,proj_name_btree_idx,CREATE INDEX proj_name_btree_idx ON public.projects USING btree (project_name)
-- projects,projects_pkey,CREATE UNIQUE INDEX projects_pkey ON public.projects USING btree (project_id)



-- Automatic indexes:
-- Any index ending with _pkey
-- Any index created by UNIQUE constraint
--


--  Part 3: Multicolumn Indexes
-- Exercise 3.1: Create a Multicolumn Index
--  Create an index on both dept_id and salary columns:
 CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
-- No
-- PostgreSQL uses a multicolumn index only from the first column.

--  Exercise 3.2: Understanding Column Order
--  Create another multicolumn index with reversed column order:
 CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
-- Yes
--  PostgreSQL uses left-prefix matching:
-- (A,B) can be used for A
-- but NOT for B alone

--  Part 4: Unique Indexes
--  Exercise 4.1: Create a Unique Index
--  First, add a new column for employee email:
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
 UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
 UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
 UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
 UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
 UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

 CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

 INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
 VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "emp_email_unique_idx"
--   Detail: Ключ "(email)=(john.smith@company.com)" уже существует.

--  Exercise 4.2: Unique Index vs UNIQUE Constraint
--  Check what indexes exist after adding a UNIQUE constraint:
 ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

 SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Yes. A unique constraint automatically creates:
-- B-tree index
-- Name like: employees_phone_key

--  Part 5: Indexes and Sorting
--  Exercise 5.1: Create an Index for Sorting
 CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

-- PostgreSQL can read the index in sorted order instead of sorting the table.
-- This avoids a costly SORT operation and improves performance.

--  Exercise 5.2: Index with NULL Handling
--  Create an index that handles NULL values specially:
 CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

--  Part 6: Indexes on Expressions
--  Exercise 6.1: Create a Function-Based Index
--  Create an index for case-insensitive employee name searches:
 CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
-- apply LOWER() to every row
--
--  Exercise 6.2: Index on Calculated Values
-- Add a hire_date column and create an index on the year:
 ALTER TABLE employees ADD COLUMN hire_date DATE;
 UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
 UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
 UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
 UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
 UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;
-- Create index on the year extracted from hire_date
 CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
--
--  Part 7: Managing Indexes
--  Exercise 7.1: Rename an Index
--  Rename the emp_salary_idx index to employees_salary_index:
 ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

-- Exercise 7.2: Drop Unused Indexes
--  Drop the redundant multicolumn index we created earlier:
 DROP INDEX emp_salary_dept_idx;

-- It is never used (confirmed with EXPLAIN)
-- It duplicates another index
-- It slows down INSERT, UPDATE, DELETE
-- Saves disk space

-- Exercise 7.3: Reindex
--  Rebuild an index to optimize its structure:
 REINDEX INDEX employees_salary_index;


--  Part 8: Practical Scenarios
--  Exercise 8.1: Optimize a Slow Query
--  Consider this query that runs frequently:
 SELECT e.emp_name, e.salary, d.dept_name
 FROM employees e
 JOIN departments d ON e.dept_id = d.dept_id
 WHERE e.salary > 50000
 ORDER BY e.salary DESC;

--
--  Exercise 8.2: Partial Index
--  Create an index only for high-budget projects (budget > 80000):
 CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;
-- Partial indexes reduce overhead.


-- Exercise 8.3: Analyze Index Usage
--  Use EXPLAIN to see if indexes are being used:
 EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- If index is used - Index Scan
-- If ignored - Seq Scan

--  Part 9: Index Types Comparison
--  Exercise 9.1: Create a Hash Index
--  Create a hash index on department name:
 CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
-- Equality comparisons (= only)
-- Very fast hash lookup use-cases

--  Exercise 9.2: Compare Index Types
--  Create both B-tree and Hash indexes on the project name:
-- B-tree index
 CREATE INDEX proj_name_btree_idx ON projects(project_name);
-- Hash index
 CREATE INDEX proj_name_hash_idx ON projects USING HASH (project_name);


-- Part 10: Cleanup and Best Practices
--  Exercise 10.1: Review All Indexes
--  List all indexes and their sizes:
 SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
 FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;
-- dept_summary_mv_dept_id_idx
    -- multicolumn indexes or expression indexes

--  Exercise 10.2: Drop Unnecessary Indexes
--  Identify and drop indexes that are duplicates or rarely used:
 DROP INDEX IF EXISTS proj_name_hash_idx;


--  Exercise 10.3: Document Your Indexes
--  Create a view that documents all custom indexes:
 CREATE VIEW index_documentation AS
 SELECT
    tablename,
    indexname,
    indexdef,
 'Improves salary-based queries' as purpose
 FROM pg_indexes
 WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
 SELECT * FROM index_documentation;


-- 1. What is the default index type in PostgreSQL?
--  B-tree index
-- 2. Name three scenarios where you should create an index:
--  When a column is:
-- Frequently used in WHERE filters
-- Used in JOIN conditions
-- Used in ORDER BY or sorting operations
-- 3. Name two scenarios where you should NOT create an index:
--  When a column:
-- Has very few distinct values (e.g., boolean)
-- Is rarely used in queries (not searched or filtered)
-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
--  Indexes must also be updated — this slows down writes.
-- 5. How can you check if a query is using an index?
--  Use the command:
-- EXPLAIN <your_query>;

