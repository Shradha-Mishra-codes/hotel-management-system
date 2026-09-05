 🏨 Hotel Management System — DBMS Project

📌 Project Overview

The Hotel Management System is a PostgreSQL-based Database Management System project designed to manage the major operations of a hotel.
This project stores and manages information about guests, rooms, employees, reservations, food orders, bills, payments, and housekeeping.
The project demonstrates important DBMS and SQL concepts such as DDL, DML, DQL, joins, subqueries, aggregate functions, views, indexes, sequences, functions, procedures, triggers, TCL, and DCL.
 🎯 Objectives

* Manage hotel guest information.
* Maintain room details and availability.
* Manage hotel employees and departments.
* Store and track room reservations.
* Manage food orders and menu items.
* Handle billing and payments.
* Maintain housekeeping records.
* Generate useful hotel reports.
* Demonstrate practical SQL and DBMS concepts.

🗂️ Database Name
```sql
hotel_management
```
 🛠️ Technologies Used

* PostgreSQL 15
* SQL / PLpgSQL
* PostgreSQL SQL Shell (psql)
* GitHub
📊 Database Tables

The project contains the following tables:

| Table              | Description                          |
| ------------------ | ------------------------------------ |
| `guest`            | Stores guest information             |
| `room`             | Stores room details and availability |
| `employee`         | Stores employee information          |
| `reservation`      | Manages room reservations            |
| `menu`             | Stores food menu items               |
| `food_order`       | Stores food orders                   |
| `order_details`    | Stores food order details            |
| `checkin_checkout` | Manages check-in/check-out records   |
| `bill`             | Stores guest billing information     |
| `payment`          | Stores payment details               |
| `housekeeping`     | Manages room cleaning activities     |

 🔑 DBMS Concepts Demonstrated
 DDL — Data Definition Language

* `CREATE DATABASE`
* `CREATE TABLE`
* `CREATE VIEW`
* `CREATE INDEX`
* `CREATE SEQUENCE`

 DML — Data Manipulation Language

* `INSERT`
* `UPDATE`
* `DELETE`

 DQL — Data Query Language

* `SELECT`
* `WHERE`
* `ORDER BY`
* `DISTINCT`
* `LIKE`
* `ILIKE`

Aggregate Functions

* `COUNT()`
* `SUM()`
* `AVG()`
* `MAX()`
* `MIN()`

Other SQL Concepts

* `GROUP BY`
* `HAVING`
* String functions
* Date functions
* `INNER JOIN`
* `LEFT JOIN`
* `RIGHT JOIN`
* `FULL OUTER JOIN`
* Subqueries
* `EXISTS`
* `NOT EXISTS`
* `ANY`
* `ALL`
* `UNION`
* `INTERSECT`
* `EXCEPT`
* `CASE`

 Advanced PostgreSQL Concepts

* Views
* Indexes
* Sequences
* Functions
* Procedures
* Triggers
* Transactions
* `COMMIT`
* `ROLLBACK`
* `SAVEPOINT`
* `GRANT`
* `REVOKE`

---

🔗 Database Relationships

The major relationships in the database include:

* A **guest** can have multiple reservations.
* A **room** can be associated with reservations.
* A **guest** can place food orders.
* A **food order** can contain multiple food items.
* A **bill** is associated with a guest and reservation.
* A **bill** can have one or more payments.
* Employees can be assigned to housekeeping activities.
* Housekeeping records are linked with rooms and employees.

 📈 Sample Reports

The project can generate reports such as:

* Available rooms
* Occupied rooms
* Guest reservation details
* Checked-in guests
* Upcoming reservations
* Food order reports
* Bill reports
* Payment reports
* Remaining balance reports
* Housekeeping reports
* Hotel dashboard
* Final combined hotel report
📂 Project File

The main SQL backup file is:

```text
Hotel_Management_Project.sql
```
It contains the database structure, sample data, views, functions, procedures, triggers, and other database objects created for the project.

▶️ How to Run the Project

### Step 1 — Create the database

Open PostgreSQL SQL Shell and run:

```sql
CREATE DATABASE hotel_management;
```

Step 2 — Connect to the database

```sql
\c hotel_management
```

 Step 3 — Run the SQL file

From Command Prompt:

```cmd
psql -U postgres -d hotel_management -f Hotel_Management_Project.sql
```

Enter your PostgreSQL password when prompted.

Step 4 — Check the tables

```sql
\dt
```

---

👩‍💻 Project Type
DBMS / SQL Academic Project
Domain
Hotel Management
Database
PostgreSQL
⭐ Conclusion

The Hotel Management System demonstrates how a relational database can be used to efficiently manage hotel operations. The project provides practical implementation of SQL queries and advanced DBMS concepts while maintaining relationships between different hotel activities.
