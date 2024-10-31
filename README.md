# Globant’s Data Engineering Coding Challenge

Welcome to Globant’s Data Engineering coding challenge! This repository contains multiple sections addressing the tasks presented in the challenge.

- You can choose which sections to solve based on your experience and available time.
- If you are unsure about a section, you may skip it and continue to the next.
- You may use any programming language, libraries, and frameworks of your choice.
- Usage of cloud services is allowed, and you can select any provider.
- Please follow best practices to build a scalable solution.
- While solving all sections is recommended, if time constraints exist, consider outlining the tool stack and architecture you would ideally use.

---

## Section 1: API

In a context of database migration with three different tables (`departments`, `jobs`, `employees`), this section includes creating a local REST API that:
1. Receives historical data from CSV files.
2. Uploads these files to the new database.
3. Supports batch transactions (1-1000 rows) per request.

### How to Build the Docker Image

In the root folder, run:
```bash
cd app
docker build -t company-api:latest .
```

### How to run docker compose 

### First download mysql and phpmyadmin , phpmyadmin is option, only used to query database tables easy,
it's possible to remove it from docker-compose.yaml file
```bash
docker pull mysql
docker pull phpmyadmin/phpmyadmin
```

### when running docker-compose for first time, database and it's table creating proccess is executed, it will take some minutes to be done. 
```bash
docker-compose up 
```

### How execute csv upload to mysql database 
```bash
curl -X POST "http://localhost:8000/upload/departments/?file_path=/opt/files/departments.csv"
curl -X POST "http://localhost:8000/upload/jobs/?file_path=/opt/files/jobs.csv"
curl -X POST "http://localhost:8000/upload/hired_employees/?file_path=/opt/files/hired_employees.csv"
```

### How test update to mysql database
```bash
curl -X POST "http://localhost:8000/upload/jobs/?file_path=/opt/files/jobs_updated.csv"
curl -X POST "http://localhost:8000/upload/hired_employees/?file_path=/opt/files/hired_employees_updated.csv"
curl -X POST "http://localhost:8000/upload/departments/?file_path=/opt/files/departments_big_file.csv"
```

### How get values from data loaded into mysql 

```bash
curl -X GET "http://localhost:8000/departments/"
curl -X GET "http://localhost:8000/jobs/"
curl -X GET "http://localhost:8000/employees/"
```

## Section 2: SQL

You need to explore the data that was inserted in the previous section. The stakeholders ask
for some specific metrics they need. You should create an end-point for each requirement.
**Requirements**
* Number of employees hired for each job and department in 2021

```sql
select 
	b.department,
    c.jobs,
	sum(case when MONTH(a.datetime) between 1 and 3 then 1 else 0 end) as Q1,
    sum(case when MONTH(a.datetime) between 4 and 6 then 1 else 0 end) as Q2,
    sum(case when MONTH(a.datetime) between 7 and 9 then 1 else 0 end) as Q3,
    sum(case when MONTH(a.datetime) between 10 and 12 then 1 else 0 end) as Q4
from hired_employees a
inner join departments b on
a.department_id = b.id
inner join jobs c on
a.job_id = c.id
where
	year(a.datetime) = 2021
group by
	b.department,
    c.jobs
order by
	b.department,
    c.jobs
asc
```

List of ids, name and number of employees hired of each department that hired more
employees than the mean of employees hired in 2021 for all the departments, ordered
by the number of employees hired (descending).

```sql
WITH department_hires AS (
    SELECT 
        b.id,
        b.department,
        COUNT(*) AS hired
    FROM hired_employees a
    INNER JOIN departments b ON a.department_id = b.id
    WHERE YEAR(a.datetime) = 2021
    GROUP BY b.id, b.department
),
average_hires AS (
    SELECT AVG(hired) AS avg_hired
    FROM department_hires
)
SELECT 
    a.id,
    a.department,
    a.hired
FROM department_hires a
CROSS JOIN average_hires b
WHERE a.hired > b.avg_hired
ORDER BY a.hired DESC;
```
