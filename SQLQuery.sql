USE Car_Rental;
GO

IF OBJECT_ID('view_all_employees', 'V') IS NOT NULL
    DROP VIEW view_all_employees;
GO

-- Вид 1: Вивід усіх працівників
CREATE VIEW view_all_employees AS
SELECT
    e.employee_id,
    CONCAT(p.surname, ' ', p.name, ' ', p.patronymic) AS full_name,
    p.birth_date,
    p.gender,
    p.passport,
    ph.number AS phone_number,
    r.region_name,
    a.city_name,
    a.street_name,
    a.building,
    a.corpus,
    a.flat_number,
    pos.title AS position_title,
    pos.salary,
    e.starts_date,
    e.end_date
FROM employees e
JOIN persons p ON e.person_id = p.person_id
LEFT JOIN phones ph ON ph.person_id = p.person_id
JOIN addresses a ON p.address_id = a.id
JOIN regions r ON a.region_id = r.id
JOIN positions pos ON e.position_id = pos.position_id;
GO

IF OBJECT_ID('view_all_cars', 'V') IS NOT NULL
    DROP VIEW view_all_cars;
GO

-- Вид 2: Вивід усіх машин
CREATE VIEW view_all_cars AS
SELECT
    c.car_id,
    cb.brand,
    cb.model,
    c.number AS registration_number,
    c.car_vin_code,
    c.engine_vin_code,
    c.manufacture_year,
    c.mileage,
    c.rental_price,
    cs.name AS status,
    c.last_services,
    s.engine_type,
    s.transmission,
    s.fuel_type,
    s.seats_amount,
    c.notes
FROM cars c
JOIN car_brands cb ON c.brand_id = cb.brand_id
JOIN car_status cs ON c.status_id = cs.status_id
JOIN car_specifications s ON c.spec_id = s.spec_id;
GO

IF OBJECT_ID('view_monthly_income', 'V') IS NOT NULL
    DROP VIEW view_monthly_income;
GO

-- Вид 3: Скільки зароблено по місяцях
-- Створимо представлення з сумами по місяцях
CREATE VIEW view_monthly_income AS
SELECT
    FORMAT(payment_date, 'yyyy-MM') AS month,
    SUM(total_price) AS total_earnings
FROM payments
WHERE paid = 1
GROUP BY FORMAT(payment_date, 'yyyy-MM');
GO

DECLARE @month VARCHAR(7);
DECLARE @earnings DECIMAL(18,2);

DECLARE monthly_cursor CURSOR FOR
SELECT month, total_earnings
FROM view_monthly_income;

OPEN monthly_cursor;

FETCH NEXT FROM monthly_cursor INTO @month, @earnings;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Місяць: ' + @month + ', Зароблено: ' + CAST(@earnings AS VARCHAR(20));

    FETCH NEXT FROM monthly_cursor INTO @month, @earnings;
END

CLOSE monthly_cursor;
DEALLOCATE monthly_cursor;

--SELECT name
--FROM sys.views;

SELECT * FROM view_all_employees;
SELECT * FROM view_all_cars;
SELECT * FROM view_all_cars WHERE status='Вільна';
SELECT * FROM view_all_cars WHERE status='В оренді';
SELECT * FROM view_monthly_income;
--SELECT * FROM payments;