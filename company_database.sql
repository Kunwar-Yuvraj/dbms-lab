

-- Creating EMPLOYEE Table
CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(255),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    SuperSSN INT,
    DNo INT,
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

-- Creating DEPARTMENT Table
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(100),
    MgrSSN INT,
    MgrStartDate DATE,
    FOREIGN KEY (MgrSSN) REFERENCES EMPLOYEE(SSN)
);

-- Creating DLOCATION Table
CREATE TABLE DLOCATION (
    DNo INT,
    DLoc VARCHAR(100),
    PRIMARY KEY (DNo, DLoc),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

-- Creating PROJECT Table
CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(100),
    PLocation VARCHAR(100),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

-- Creating WORKS_ON Table
CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours DECIMAL(5,2),
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

-- Query 1: List all project numbers for projects that involve an employee named ‘Scott’
SELECT DISTINCT p.PNo
FROM PROJECT p
JOIN WORKS_ON w ON p.PNo = w.PNo
JOIN EMPLOYEE e ON w.SSN = e.SSN
WHERE e.Name LIKE '%Scott%';

-- Query 2: Show new salaries if every employee working on the ‘IoT’ project gets a 10% raise
SELECT e.SSN, e.Name, e.Salary * 1.1 AS New_Salary
FROM EMPLOYEE e
JOIN WORKS_ON w ON e.SSN = w.SSN
JOIN PROJECT p ON w.PNo = p.PNo
WHERE p.PName = 'IoT';

-- Query 3: Compute sum, max, min, avg salary for 'Accounts' department employees
SELECT SUM(Salary) AS Total_Salary, MAX(Salary) AS Max_Salary, 
       MIN(Salary) AS Min_Salary, AVG(Salary) AS Avg_Salary
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.DNo = d.DNo
WHERE d.DName = 'Accounts';

-- Query 4: Retrieve names of employees who work on all projects controlled by department 5
SELECT e.Name
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT p.PNo FROM PROJECT p WHERE p.DNo = 5
    EXCEPT
    SELECT w.PNo FROM WORKS_ON w WHERE w.SSN = e.SSN
);

-- Query 5: Retrieve department number and employee count where more than 5 employees earn > 600000
SELECT d.DNo, COUNT(e.SSN) AS Employee_Count
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.DNo = d.DNo
WHERE e.Salary > 600000
GROUP BY d.DNo
HAVING COUNT(e.SSN) > 5;

-- Query 6: Create a view showing employee name, department name, and location
CREATE VIEW Employee_Details AS
SELECT e.Name, d.DName, dl.DLoc
FROM EMPLOYEE e
JOIN DEPARTMENT d ON e.DNo = d.DNo
JOIN DLOCATION dl ON d.DNo = dl.DNo;

-- Query 7: Trigger to prevent deletion of a project if employees are working on it
DELIMITER //
CREATE TRIGGER Prevent_Project_Deletion
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM WORKS_ON WHERE PNo = OLD.PNo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete project with active employees';
    END IF;
END;
//
DELIMITER ;

