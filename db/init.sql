CREATE DATABASE IF NOT EXISTS company;
use company;

create table if not exists `departments` (
    id int not null auto_increment,
    department text not null,
    primary key (id)
);


create table if not exists  `jobs` (
    id int not null auto_increment,
    jobs text not null,
    primary key (id)
);


create table if not exists  `hired_employees` (
    id int not null auto_increment,
    name text null,
    datetime text  null,
    department_id int null,
    job_id int null,
    primary key (id)
);

ALTER TABLE hired_employees
ADD CONSTRAINT FK_department_id
FOREIGN KEY (department_id) REFERENCES departments(id);

ALTER TABLE hired_employees
ADD CONSTRAINT FK_jobs_id
FOREIGN KEY (job_id) REFERENCES jobs(id);

GRANT ALL PRIVILEGES ON company.* TO MYSQL_USER;

FLUSH PRIVILEGES;
