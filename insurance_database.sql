

-- Creating Tables
CREATE TABLE PERSON (
    driver_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    address VARCHAR(100)
);

CREATE TABLE CAR (
    regno VARCHAR(20) PRIMARY KEY,
    model VARCHAR(50),
    year INT
);

CREATE TABLE ACCIDENT (
    report_number INT PRIMARY KEY,
    acc_date DATE,
    location VARCHAR(100)
);

CREATE TABLE OWNS (
    driver_id VARCHAR(20),
    regno VARCHAR(20),
    PRIMARY KEY (driver_id, regno),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno)
);

CREATE TABLE PARTICIPATED (
    driver_id VARCHAR(20),
    regno VARCHAR(20),
    report_number INT,
    damage_amount INT,
    PRIMARY KEY (driver_id, regno, report_number),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno),
    FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number)
);

-- Queries

-- 1. Find the total number of people who owned cars that were involved in accidents in 2021.
SELECT COUNT(DISTINCT o.driver_id) 
FROM OWNS o 
JOIN PARTICIPATED p ON o.regno = p.regno 
JOIN ACCIDENT a ON p.report_number = a.report_number 
WHERE a.acc_date LIKE '2021%';

-- 2. Find the number of accidents in which the cars belonging to “Smith” were involved.
SELECT COUNT(DISTINCT a.report_number) 
FROM ACCIDENT a 
JOIN PARTICIPATED p ON a.report_number = p.report_number 
JOIN PERSON pr ON pr.driver_id = p.driver_id 
WHERE pr.name = 'Smith';

-- 3. Add a new accident to the database; assume any values for required attributes.
INSERT INTO ACCIDENT (report_number, acc_date, location) VALUES (101, '2025-03-25', 'Main Street');

-- 4. Delete the Mazda belonging to “Smith”.
DELETE FROM OWNS 
WHERE driver_id = (SELECT driver_id FROM PERSON WHERE name = 'Smith') 
AND regno = (SELECT regno FROM CAR WHERE model = 'Mazda');

-- 5. Update the damage amount for the car with license number “KA09MA1234” in the accident with report number 101.
UPDATE PARTICIPATED 
SET damage_amount = 5000 
WHERE regno = 'KA09MA1234' AND report_number = 101;

-- 6. A view that shows models and years of cars that are involved in accidents.
CREATE VIEW modelyear AS 
SELECT DISTINCT c.model, c.year 
FROM CAR c 
JOIN PARTICIPATED p ON p.regno = c.regno;

-- 7. A trigger that prevents a driver from participating in more than 3 accidents in a given year.
DELIMITER //
CREATE TRIGGER prevent_more_than_3_accidents 
BEFORE INSERT ON PARTICIPATED 
FOR EACH ROW 
BEGIN 
    IF (SELECT COUNT(*) FROM PARTICIPATED 
        WHERE driver_id = NEW.driver_id 
        AND YEAR((SELECT acc_date FROM ACCIDENT WHERE report_number = NEW.report_number)) = YEAR(CURDATE())) >= 3 
    THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'A driver cannot participate in more than 3 accidents per year'; 
    END IF; 
END;
//
DELIMITER ;

