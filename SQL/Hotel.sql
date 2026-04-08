CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    name TEXT,
    phone_number TEXT,
    mail_id TEXT,
    billing_address TEXT
);

CREATE TABLE bookings (
    booking_id TEXT PRIMARY KEY,
    booking_date TEXT,
    room_no TEXT,
    user_id TEXT
);

CREATE TABLE items (
    item_id TEXT PRIMARY KEY,
    item_name TEXT,
    item_rate REAL
);

CREATE TABLE booking_commercials (
    id TEXT PRIMARY KEY,
    booking_id TEXT,
    bill_id TEXT,
    bill_date TEXT,
    item_id TEXT,
    item_quantity REAL
);


INSERT INTO users VALUES
('U1','John Doe','9876543210','john@example.com','ABC City'),
('U2','Alice','9876543211','alice@example.com','XYZ City'),
('U3','Bob','9876543212','bob@example.com','LMN City');

INSERT INTO bookings VALUES
('B1','2021-11-10 10:00:00','R1','U1'),
('B2','2021-11-15 12:00:00','R2','U1'),
('B3','2021-10-05 09:00:00','R3','U2'),
('B4','2021-12-01 14:00:00','R4','U3');

INSERT INTO items VALUES
('I1','Tawa Paratha',18),
('I2','Mix Veg',89),
('I3','Paneer Butter Masala',150);

INSERT INTO booking_commercials VALUES
('C1','B1','BL1','2021-11-10 12:00:00','I1',3),
('C2','B1','BL1','2021-11-10 12:00:00','I2',1),
('C3','B2','BL2','2021-11-15 13:00:00','I2',5),
('C4','B3','BL3','2021-10-05 10:00:00','I1',50),
('C5','B4','BL4','2021-12-01 15:00:00','I3',2);


1. SELECT user_id, room_no
	FROM (
    	SELECT user_id, room_no, booking_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) rn
    	FROM bookings
	)
	WHERE rn = 1;

2. SELECT b.booking_id,
       SUM(bc.item_quantity * i.item_rate) total_billing
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE strftime('%Y-%m', bc.bill_date) = '2021-11'
GROUP BY b.booking_id;


3. SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE strftime('%Y-%m', bc.bill_date) = '2021-10'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;


4. SELECT *
FROM (
    SELECT strftime('%m', bc.bill_date) month,
           i.item_name,
           SUM(bc.item_quantity) total_qty,
           RANK() OVER (PARTITION BY strftime('%m', bc.bill_date)
                        ORDER BY SUM(bc.item_quantity) DESC) max_rank,
           RANK() OVER (PARTITION BY strftime('%m', bc.bill_date)
                        ORDER BY SUM(bc.item_quantity) ASC) min_rank
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE strftime('%Y', bc.bill_date) = '2021'
    GROUP BY month, i.item_name
)
WHERE max_rank = 1 OR min_rank = 1;


5. SELECT *
FROM (
    SELECT strftime('%m', bc.bill_date) month,
           b.user_id,
           bc.bill_id,
           SUM(bc.item_quantity * i.item_rate) total_bill,
           RANK() OVER (PARTITION BY strftime('%m', bc.bill_date)
                        ORDER BY SUM(bc.item_quantity * i.item_rate) DESC) rnk
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE strftime('%Y', bc.bill_date) = '2021'
    GROUP BY month, b.user_id, bc.bill_id
)
WHERE rnk = 2;