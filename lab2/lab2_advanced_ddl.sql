/*Task 1.1*/
drop database if exists university_main;
drop database if exists university_archive;
drop database if exists university_test;
drop database if exists university_distributed;
drop database if exists university_backup;

create database university_main
    with owner = postgres
    template = template0
    encoding = 'UTF8';

create database university_archive
    with template = template0
    connection limit = 50;

create database university_test
    with template = template0
    connection limit = 10
    is_template = true;

/*Task 1.2*/
drop tablespace if exists student_data;
drop tablespace if exists course_data;

create tablespace student_data location 'C:/Users/erbat/Desktop/database/database/lab2/data/students';
create tablespace course_data owner postgres location 'C:/Users/erbat/Desktop/database/database/lab2/data/courses';

create database university_distributed
    with tablespace = student_data
    encoding = 'UTF8';

/*Task 2.1*/
drop table if exists student_records CASCADE;
drop table if exists class_schedule CASCADE;
drop table if exists  courses CASCADE;
drop table if exists  professors CASCADE;
drop table if exists students CASCADE;

create table students(
    student_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone char(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa numeric(3,2),
    is_active boolean,
    graduation_year smallint
);

create table professors(
    professor_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    office_number char(20),
    hire_date DATE,
    salary numeric(13,2),
    is_tenured boolean,
    years_experience integer
);

create table courses(
    course_id serial primary key,
    course_code char(8),
    course_title varchar(100),
    description text,
    credits smallint,
    max_enrollment integer,
    course_fee numeric(10,2),
    is_online boolean,
    created_at timestamp without time zone
);

/*Task 2.2*/

create table class_schedule(
    schedule_id serial primary key,
    course_id integer,
    professor_id integer,
    classroom varchar(20),
    class_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration interval
);

create table student_records(
    record_id serial primary key,
    student_id integer,
    course_id integer,
    semester varchar(20),
    year integer,
    grade char(2),
    attendance_percentage numeric(4,1),
    submission_timestamp timestamp with time zone,
    last_updated timestamp with time zone
);

/*Task 3.1*/

alter table students add column if not exists middle_name varchar(30);
alter table students add column if not exists student_status varchar(20);
alter table students alter column phone type varchar(20);
alter table students alter column student_status set default 'ACTIVE';
alter table students alter column gpa set default 0.00;

alter table professors add column if not exists department_code char(5);
alter table professors add column if not exists research_area text;
alter table professors alter column years_experience type smallint;
alter table professors alter column is_tenured set default false;
alter table professors add column if not exists last_promotion_data date;

alter table courses add column if not exists prerequisite_course_id integer;
alter table courses add column if not exists difficulty_level smallint;
alter table courses alter column course_code type varchar(10);
alter table courses alter column credits set default 3;
alter table courses add column if not exists lab_required boolean default false;

/*Task 3.2*/

alter table class_schedule add column if not exists room_capacity integer;
alter table class_schedule drop column if exists duration;
alter table class_schedule add column if not exists session_type varchar(15);
alter table class_schedule alter column classroom type varchar(30);
alter table class_schedule add column if not exists equipment_needed text;

alter table student_records add column if not exists extra_credit_points numeric(4,1);
alter table student_records alter column grade type varchar(5);
alter table student_records alter column extra_credit_points set default 0.0;
alter table student_records add column if not exists final_exam_date date;
alter table student_records drop column if exists last_updated;

/*Task 4.1*/
drop table if exists  student_book_loans CASCADE;
drop table if exists library_books CASCADE;
drop table if exists  departments CASCADE;

create table departments(
    department_id serial primary key,
    department_name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget numeric(18,2),
    established_year integer
);

create table library_books(
    book_id serial primary key,
    isbn char(13),
    title varchar(200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price numeric(12,2),
    is_available boolean,
    acquisition_timestamp timestamp without time zone
);

create table student_book_loans(
    loan_id serial primary key,
    student_id integer,
    book_id integer,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount numeric(10,2),
    loan_status varchar(20)
);


/*Task 4.2*/
alter table professors add column if not exists department_id integer;
alter table students add column if not exists advisor_id integer;
alter table courses add column if not exists department_id integer;

drop table if exists  grade_scale CASCADE;
create table grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(4,1),
    max_percentage numeric(4,1),
    gpa_points numeric(3,2)
);

drop table if exists  semester_calendar CASCADE;
create table semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

/*Task 5.1*/

drop table if exists student_book_loans;
drop table if exists library_books;
drop table if exists grade_scale;

create table grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(4,1),
    max_percentage numeric(4,1),
    gpa_points numeric(3,2),
    description text
);

drop table if exists semester_calendar cascade;

create table semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

/*Task 5.2*/
update pg_database
set datistemplate = false
where datname = 'university_test';

drop database if exists university_test;
drop database if exists university_distributed;
create database university_backup template = university_main;

