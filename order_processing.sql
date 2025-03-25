-- Order Processing Database Schema

-- Creating Customer table
CREATE TABLE Customer (
    CustNo INT PRIMARY KEY,
    CName VARCHAR(255),
    City VARCHAR(255)
);

-- Creating Order table
CREATE TABLE Orders (
    OrderNo INT PRIMARY KEY,
    ODate DATE,
    CustNo INT,
    OrderAmt INT,
    FOREIGN KEY (CustNo) REFERENCES Customer(CustNo)
);

-- Creating Order-Item table
CREATE TABLE OrderItem (
    OrderNo INT,
    ItemNo INT,
    Qty INT,
    PRIMARY KEY (OrderNo, ItemNo),
    FOREIGN KEY (OrderNo) REFERENCES Orders(OrderNo),
    FOREIGN KEY (ItemNo) REFERENCES Item(ItemNo)
);

-- Creating Item table
CREATE TABLE Item (
    ItemNo INT PRIMARY KEY,
    UnitPrice INT
);

-- Creating Shipment table
CREATE TABLE Shipment (
    OrderNo INT,
    WarehouseNo INT,
    ShipDate DATE,
    PRIMARY KEY (OrderNo, WarehouseNo),
    FOREIGN KEY (OrderNo) REFERENCES Orders(OrderNo),
    FOREIGN KEY (WarehouseNo) REFERENCES Warehouse(WarehouseNo)
);

-- Creating Warehouse table
CREATE TABLE Warehouse (
    WarehouseNo INT PRIMARY KEY,
    City VARCHAR(255)
);

-- Query 1: List the Order# and Ship_date for all orders shipped from Warehouse# "W2"
SELECT OrderNo, ShipDate FROM Shipment WHERE WarehouseNo = 'W2';

-- Query 2: List the Warehouse information for orders supplied to customer "Kumar"
SELECT o.OrderNo, s.WarehouseNo
FROM Orders o
JOIN Shipment s ON o.OrderNo = s.OrderNo
JOIN Customer c ON o.CustNo = c.CustNo
WHERE c.CName = 'Kumar';

-- Query 3: Listing customer name, total number of orders, and average order amount
SELECT c.CName, COUNT(o.OrderNo) AS TotalOrders, AVG(o.OrderAmt) AS AvgOrderAmt
FROM Customer c
JOIN Orders o ON c.CustNo = o.CustNo
GROUP BY c.CName;

-- Query 4: Delete all orders for customer "Kumar"
DELETE FROM Orders WHERE CustNo IN (SELECT CustNo FROM Customer WHERE CName = 'Kumar');

-- Query 5: Find the item with the maximum unit price
SELECT ItemNo FROM Item WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Item);

-- Query 6: Trigger to update order amount based on quantity and unit price
DELIMITER //
CREATE TRIGGER UpdateOrderAmount
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE price INT;
    SELECT UnitPrice INTO price FROM Item WHERE ItemNo = NEW.ItemNo;
    UPDATE Orders SET OrderAmt = OrderAmt + (NEW.Qty * price) WHERE OrderNo = NEW.OrderNo;
END;
//
DELIMITER ;

-- Query 7: Create a view to display order ID and shipment date of all orders shipped from warehouse 5
CREATE VIEW OrderShipmentView AS
SELECT OrderNo, ShipDate FROM Shipment WHERE WarehouseNo = 5;
