-- Student Enrollment Database

-- Creating Tables
CREATE TABLE STUDENT (
    regno VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    major VARCHAR(50),
    bdate DATE
);

CREATE TABLE COURSE (
    course# INT PRIMARY KEY,
    cname VARCHAR(50),
    dept VARCHAR(50)
);

CREATE TABLE ENROLL (
    regno VARCHAR(20),
    course# INT,
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course#),
    FOREIGN KEY (regno) REFERENCES STUDENT(regno),
    FOREIGN KEY (course#) REFERENCES COURSE(course#)
);

CREATE TABLE BOOK_ADOPTION (
    course# INT,
    sem INT,
    book_ISBN INT,
    PRIMARY KEY (course#, sem, book_ISBN),
    FOREIGN KEY (course#) REFERENCES COURSE(course#)
);

CREATE TABLE TEXT (
    book_ISBN INT PRIMARY KEY,
    book_title VARCHAR(100),
    publisher VARCHAR(50),
    author VARCHAR(50)
);

-- Queries
-- 1. Add a new textbook and adopt it for a department
INSERT INTO TEXT (book_ISBN, book_title, publisher, author) VALUES (123456, 'Database Systems', 'Pearson', 'Raghu Ramakrishnan');
INSERT INTO BOOK_ADOPTION (course#, sem, book_ISBN) VALUES (101, 1, 123456);

-- 2. List of textbooks for CS department courses using more than 2 books
SELECT c.course#, ba.book_ISBN, t.book_title
FROM COURSE c
JOIN BOOK_ADOPTION ba ON c.course# = ba.course#
JOIN TEXT t ON ba.book_ISBN = t.book_ISBN
WHERE c.dept = 'CS'
GROUP BY c.course#
HAVING COUNT(ba.book_ISBN) > 2
ORDER BY t.book_title;

-- 3. Departments that have all adopted books from a specific publisher
SELECT c.dept
FROM COURSE c
JOIN BOOK_ADOPTION ba ON c.course# = ba.course#
JOIN TEXT t ON ba.book_ISBN = t.book_ISBN
GROUP BY c.dept
HAVING COUNT(DISTINCT t.publisher) = 1;

-- 4. Students who scored maximum marks in DBMS course
SELECT s.name, e.marks
FROM STUDENT s
JOIN ENROLL e ON s.regno = e.regno
JOIN COURSE c ON e.course# = c.course#
WHERE c.cname = 'DBMS' AND e.marks = (SELECT MAX(marks) FROM ENROLL WHERE course# = c.course#);

-- 5. View for all courses opted by a student along with marks
CREATE VIEW Student_Courses AS
SELECT s.regno, s.name, c.course#, c.cname, e.marks
FROM STUDENT s
JOIN ENROLL e ON s.regno = e.regno
JOIN COURSE c ON e.course# = c.course#;

-- 6. Trigger to prevent enrolling if marks prerequisite is less than 40
DELIMITER //
CREATE TRIGGER Prevent_Low_Marks_Enrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot enroll if marks prerequisite is less than 40';
    END IF;
END;
//
DELIMITER ;
