-- Part A: Database and Table Setup
-- 1. Create database and tables
drop database if exists advanced_lab;

create database advanced_lab
    with owner = postgres
    template = template0;

create table if not exists employees(
    emp_id serial primary key,
    first_name varchar(100),
    last_name varchar(100),
    department varchar(100),
    salary integer,
    hire_date date,
    status varchar(100) default 'Active'
);

create table if not exists departments(
    dept_id serial primary key,
    dept_name varchar(100),
    budget integer,
    manager_id integer
);

create table if not exists projects(
    project_id serial primary key,
    project_name varchar(100),
    dept_id integer,
    start_date date,
    end_date date,
    budget integer
);
-- Part B: Advanced INSERT Operations
-- 2. INSERT with column specification
insert into employees(first_name, last_name, department, salary, hire_date, status) values
('Yerbatyr', 'Nursultan', 'IT', 62520, date '2017-05-18', default),
('Arman', 'Norsultanov', 'AC', 54125, date '2018-12-30', default),
('Amanbek', 'Anuarbekuly', 'AC' , 45554, date '2020-04-14', default),
('Ainamkoz', 'Oryngali', 'Sales', 84884, date '2021-06-24', default),
('Amangerey', 'Amankossov', 'HR', 45562, date '2019-01-20', default);
--

insert into employees(emp_id, first_name, last_name, department) values
(99, 'Zhandos', 'Bazargaliev', 'AC');

-- 3. INSERT with DEFAULT values
insert into employees(first_name, last_name, department, salary, hire_date, status) values
('Dimash','Baizakov',default, 50000,NULL,DEFAULT),
('Dorash','Nurbolatuly',default, 55854,NULL,DEFAULT);
--
-- INSERT multiple rows in single statement
insert into departments(dept_name, budget, manager_id) values
('IT', 300000000, NULL),
('Sales', 20000000, NULL),
('HR', 10000000, NULL),
('AC', 500000000, NULL),
('Security', 5252522, NULL);

--
-- 5. INSERT with expressions
insert into employees(first_name, last_name, department, salary, hire_date, status) values
('Nurbekzat', 'Nurlybekuly', 'HR', (50000*1.1), current_date, Default);

--
-- 6. INSERT from SELECT (subquery)
drop table if exists temp_employees;
create temp table temp_employees as
    select * from employees where department = 'IT';

--
-- Part C: Complex UPDATE Operations
-- 7. UPDATE with arithmetic expressions
update employees
set salary = case when salary is not null then (salary*1.1) end;

--
-- 8. UPDATE with WHERE clause and multiple conditions
update employees
set status = 'Senior'
where salary > 60000 and hire_date < date '2020-01-01';
--
-- 9. UPDATE using CASE expression
update employees
set department = case
    when salary > 80000 then 'Management'
    when salary between 50000 and 80000 then 'Senior'
    else 'Junior'
    end;

--
-- 10. UPDATE with DEFAULT
update employees
set department = DEFAULT
where status = 'Inactive';
--
-- 11. UPDATE with subquery
update departments
set budget = (select avg(salary) from employees where employees.department = departments.dept_name)*1.2
where exists (select 1 from employees where employees.department = departments.dept_name);
--
-- 12. UPDATE multiple columns
update employees
set salary = (salary*1.15), status = 'Promoted'
where department = 'Sales';


--
-- Part D: Advanced DELETE Operations
-- 13. DELETE with simple WHERE condition
delete from employees where status = 'Terminated';

--
-- 14. DELETE with complex WHERE clause
delete from employees
       where salary < 40000 and
             hire_date > date '2023-01-01' and
             department is null;
--
-- 15. DELETE with subquery
delete from departments
    where dept_id not in (select distinct employees.department from employees where department is not null);
--
-- 16. DELETE with RETURNING clause
delete from projects
    where end_date < date '2023-01-01'
    returning *;


--
-- Part E: Operations with NULL Values
-- 17. INSERT with NULL values
insert into employees(first_name, last_name, department, salary, hire_date, status)
values ('Madina', 'Shpanova', NULL, NULL, date '2019-05-14', default);
--
-- 18. UPDATE NULL handling
update employees
set department = 'Unassigned'
where department is null;
--
-- 19. DELETE with NULL conditions
delete from employees
    where salary is null or department is null;


--
-- Part F: RETURNING Clause Operations
-- 20. INSERT with RETURNING
insert into employees(first_name, last_name, department, salary, hire_date, status)
values ('Mukhammed', 'Garifolla', 'IT', 95358, date '2022-08-17', default)
returning emp_id, concat(first_name, ' ', last_name) as full_name;
--
-- 21. UPDATE with RETURNING
update employees
set salary = (salary + 5000)
where department = 'IT'
returning  emp_id, (salary - 5000) as old_salary, salary as new_salary;
--
-- 22. DELETE with RETURNING all columns
delete from employees
    where hire_date < date '2020-01-01'
    returning *;


--
-- Part G: Advanced DML Patterns
-- 23. Conditional INSERT
insert into employees(first_name, last_name, department, salary, hire_date)
select ('Kazybek', 'Kydyrbai', 'IT', 14568, date '2023-07-09')
where not exists(
    select 1 from employees where first_name = 'Kazybek' and last_name = 'Kydyrbai'
);
--
-- 24. UPDATE with JOIN logic using subqueries
update  employees
set salary = case
    when departments.budget > 100000 then (employees.salary * 1.1)
    else (employees.salary *1.05)
end
from departments
where employees.department = departments.dept_name;
--
-- 25. Bulk operations
insert into employees(first_name, last_name, department, salary, hire_date)
values ('Blabla', 'One', 'Sales', 60000, date '2025-09-29'),
       ('Blabla', 'Two', 'Sales', 60000, date '2025-09-29'),
       ('Blabla', 'Three', 'Sales', 60000, date '2025-09-29'),
       ('Blabla', 'Four', 'Sales', 60000, date '2025-09-29'),
       ('Blabla', 'Five', 'Sales', 60000, date '2025-09-29');
--
-- 26. Data migration simulation
update employees
set salary = (salary * 1.1)
where department = 'Sales';

create table if not exists employee_archive as
    select * from employees;

insert into employee_archive
select * from employees where status = 'Inactive';

delete from employees where status = 'Inactive';
--
-- 27. Complex business logic
UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND EXISTS (
      SELECT 1
      FROM departments d
      JOIN (
          SELECT department, COUNT(*) AS emp_count
          FROM employees
          GROUP BY department
      ) ec ON ec.department = d.dept_name
      WHERE d.dept_id = p.dept_id AND ec.emp_count > 3
  );

select * from employees;
select * from departments;
select * from employee_archive;
select * from temp_employees;
