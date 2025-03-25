-- Sailors Database
CREATE TABLE SAILORS (
    sid INT PRIMARY KEY,
    sname VARCHAR(100),
    rating INT,
    age INT
);

CREATE TABLE BOAT (
    bid INT PRIMARY KEY,
    bname VARCHAR(100),
    color VARCHAR(50)
);

CREATE TABLE RSERVERS (
    sid INT,
    bid INT,
    date DATE,
    PRIMARY KEY (sid, bid, date),
    FOREIGN KEY (sid) REFERENCES SAILORS(sid),
    FOREIGN KEY (bid) REFERENCES BOAT(bid)
);

-- Queries
-- 1. Find the colors of boats reserved by Albert
SELECT DISTINCT b.color 
FROM BOAT b 
JOIN RSERVERS r ON b.bid = r.bid 
JOIN SAILORS s ON s.sid = r.sid 
WHERE s.sname = 'Albert';

-- 2. Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
SELECT DISTINCT s.sid 
FROM SAILORS s 
JOIN RSERVERS r ON s.sid = r.sid 
WHERE s.rating >= 8 OR r.bid = 103;

-- 3. Find the names of sailors who have not reserved a boat whose name contains "storm"
SELECT DISTINCT s.sname 
FROM SAILORS s 
WHERE s.sid NOT IN (
    SELECT DISTINCT r.sid 
    FROM RSERVERS r 
    JOIN BOAT b ON r.bid = b.bid 
    WHERE b.bname LIKE '%storm%'
)
ORDER BY s.sname ASC;

-- 4. Find the names of sailors who have reserved all boats
SELECT s.sname 
FROM SAILORS s 
JOIN RSERVERS r ON s.sid = r.sid 
GROUP BY s.sid 
HAVING COUNT(DISTINCT r.bid) = (SELECT COUNT(*) FROM BOAT);

-- 5. Find the name and age of the oldest sailor
SELECT sname, age 
FROM SAILORS 
WHERE age = (SELECT MAX(age) FROM SAILORS);

-- 6. Find boat id and average age of sailors who reserved it and are at least 40 years old
SELECT r.bid, AVG(s.age) AS avg_age 
FROM RSERVERS r 
JOIN SAILORS s ON s.sid = r.sid 
WHERE s.age >= 40 
GROUP BY r.bid 
HAVING COUNT(DISTINCT r.sid) >= 5;

-- 7. Create a view showing names and colors of reserved boats by sailors with a specific rating
CREATE VIEW NameColorView AS 
SELECT s.sname, b.color, s.rating 
FROM SAILORS s 
JOIN RSERVERS r ON r.sid = s.sid 
JOIN BOAT b ON b.bid = r.bid;

-- 8. Trigger to prevent deletion of boats with active reservations
DELIMITER //
CREATE TRIGGER prevent_boat_deletion
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM RSERVERS WHERE bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
    END IF;
END;
//
DELIMITER ;
