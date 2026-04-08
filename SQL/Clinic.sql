CREATE TABLE clinics (
    cid TEXT PRIMARY KEY,
    clinic_name TEXT,
    city TEXT,
    state TEXT,
    country TEXT
);

CREATE TABLE customer (
    uid TEXT PRIMARY KEY,
    name TEXT,
    mobile TEXT
);

CREATE TABLE clinic_sales (
    oid TEXT PRIMARY KEY,
    uid TEXT,
    cid TEXT,
    amount REAL,
    datetime TEXT,
    sales_channel TEXT
);

CREATE TABLE expenses (
    eid TEXT PRIMARY KEY,
    cid TEXT,
    description TEXT,
    amount REAL,
    datetime TEXT
);


INSERT INTO clinics VALUES
('C1','Clinic A','Hyderabad','Telangana','India'),
('C2','Clinic B','Hyderabad','Telangana','India'),
('C3','Clinic C','Bangalore','Karnataka','India');

INSERT INTO customer VALUES
('U1','John','9876543210'),
('U2','Alice','9876543211'),
('U3','Bob','9876543212');

INSERT INTO clinic_sales VALUES
('O1','U1','C1',2000,'2021-01-10 10:00:00','online'),
('O2','U2','C1',3000,'2021-01-15 11:00:00','offline'),
('O3','U1','C2',5000,'2021-01-20 12:00:00','online'),
('O4','U3','C3',7000,'2021-02-10 09:00:00','offline');

INSERT INTO expenses VALUES
('E1','C1','supplies',500,'2021-01-10 08:00:00'),
('E2','C2','rent',2000,'2021-01-15 07:00:00'),
('E3','C3','maintenance',3000,'2021-02-10 06:00:00');


Q1: Revenue by sales channel (2021)

SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY sales_channel;


Q2: Top 10 valuable customers

SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


Q3: Month-wise revenue, expense, profit, status

SELECT 
    r.month,
    r.revenue,
    IFNULL(e.expense, 0) AS expense,
    r.revenue - IFNULL(e.expense, 0) AS profit,
    CASE 
        WHEN r.revenue - IFNULL(e.expense, 0) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM (
    SELECT 
        strftime('%m', datetime) AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY strftime('%m', datetime)
) r
LEFT JOIN (
    SELECT 
        strftime('%m', datetime) AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY strftime('%m', datetime)
) e
ON r.month = e.month;


Q4: Most profitable clinic per city (January example)

SELECT *
FROM (
    SELECT 
        c.city,
        c.cid,
        SUM(cs.amount) - IFNULL(SUM(e.amount), 0) AS profit,

        RANK() OVER (
            PARTITION BY c.city
            ORDER BY SUM(cs.amount) - IFNULL(SUM(e.amount), 0) DESC
        ) AS rnk

    FROM clinics c
    LEFT JOIN clinic_sales cs 
        ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid

    WHERE strftime('%m', cs.datetime) = '01'

    GROUP BY c.city, c.cid
)
WHERE rnk = 1;


Q5: 2nd least profitable clinic per state (January example)

SELECT *
FROM (
    SELECT 
        c.state,
        c.cid,
        SUM(cs.amount) - IFNULL(SUM(e.amount), 0) AS profit,

        RANK() OVER (
            PARTITION BY c.state
            ORDER BY SUM(cs.amount) - IFNULL(SUM(e.amount), 0) ASC
        ) AS rnk

    FROM clinics c
    LEFT JOIN clinic_sales cs 
        ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid

    WHERE strftime('%m', cs.datetime) = '01'

    GROUP BY c.state, c.cid
)
WHERE rnk = 2;

