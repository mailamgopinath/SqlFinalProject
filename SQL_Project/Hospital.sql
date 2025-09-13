/* ===========================================
   HOSPITAL MANAGEMENT MINI-DB (MySQL 8+)
   Entities: Patients, Doctors, Visits, Bills
   =========================================== */

-- Start clean (CAUTION: drops schema if it exists)
DROP DATABASE IF EXISTS hospital_mini;
CREATE DATABASE hospital_mini CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE hospital_mini;

-- ---------- 1) SCHEMA ----------
CREATE TABLE patients (
  patient_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  first_name     VARCHAR(60) NOT NULL,
  last_name      VARCHAR(60) NOT NULL,
  dob            DATE NOT NULL,
  gender         ENUM('Male','Female','Other') NOT NULL,
  phone          VARCHAR(20),
  email          VARCHAR(120),
  address_line   VARCHAR(200),
  city           VARCHAR(80),
  state_region   VARCHAR(80),
  postal_code    VARCHAR(20),
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_patients_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE doctors (
  doctor_id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  full_name         VARCHAR(120) NOT NULL,
  specialty         VARCHAR(120) NOT NULL,
  consultation_fee  DECIMAL(10,2) NOT NULL DEFAULT 500.00,
  phone             VARCHAR(20),
  email             VARCHAR(120),
  active            TINYINT(1) NOT NULL DEFAULT 1,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_doctors_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE visits (
  visit_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id   BIGINT NOT NULL,
  doctor_id    BIGINT NOT NULL,
  visit_dt     DATETIME NOT NULL,
  reason       VARCHAR(200),
  status       ENUM('Scheduled','CheckedIn','Completed','Discharged','Cancelled')
               NOT NULL DEFAULT 'Scheduled',
  height_cm    DECIMAL(5,2),
  weight_kg    DECIMAL(5,2),
  notes        TEXT,
  discharge_dt DATETIME NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_visits_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  CONSTRAINT fk_visits_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
  INDEX idx_visits_patient_dt (patient_id, visit_dt),
  INDEX idx_visits_doctor_dt (doctor_id, visit_dt),
  INDEX idx_visits_status (status)
) ENGINE=InnoDB;

CREATE TABLE bills (
  bill_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
  visit_id       BIGINT NOT NULL,
  subtotal       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  discount       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_rate_pct   DECIMAL(5,2)  NOT NULL DEFAULT 0.00, -- e.g. 18.00 = 18%
  tax_amount     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total_amount   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  paid_amount    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  payment_method ENUM('Cash','Card','UPI','Insurance','Other') NULL,
  payment_dt     DATETIME NULL,
  status         ENUM('Unbilled','Pending','Paid','Closed','Refunded') NOT NULL DEFAULT 'Unbilled',
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_bills_visit FOREIGN KEY (visit_id) REFERENCES visits(visit_id),
  CONSTRAINT uq_bills_visit UNIQUE (visit_id),
  INDEX idx_bills_status (status)
) ENGINE=InnoDB;

-- ---------- 2) SAMPLE DATA ----------
INSERT INTO patients (first_name,last_name,dob,gender,phone,email,address_line,city,state_region,postal_code) VALUES
('Aarav','Sharma','1992-03-11','Male','9999911111','aarav.sharma@example.com','12 MG Road','Bengaluru','Karnataka','560001'),
('Isha','Patel','1988-07-25','Female','8888822222','isha.patel@example.com','3 Nehru St','Ahmedabad','Gujarat','380001'),
('Vikram','Rao','1979-12-01','Male','7777733333','vikram.rao@example.com','45 Park Ave','Hyderabad','Telangana','500001'),
('Diya','Kapoor','2001-09-05','Female','6666644444','diya.kapoor@example.com','22 Beach Rd','Chennai','Tamil Nadu','600001'),
('Krish','Iyer','1995-01-19','Male','9998855555','krish.iyer@example.com','9 Lake View','Mumbai','Maharashtra','400001'),
('Meera','Nair','1985-11-14','Female','9998877777','meera.nair@example.com','55 River St','Kochi','Kerala','682001'),
('Rohan','Singh','1990-05-02','Male','9998899999','rohan.singh@example.com','7 Temple Rd','Delhi','Delhi','110001'),
('Anaya','Das','1998-02-21','Female','9998800000','anaya.das@example.com','100 Hill Top','Kolkata','West Bengal','700001');

INSERT INTO doctors (full_name,specialty,consultation_fee,phone,email) VALUES
('Dr. Neeraj Malhotra','Cardiology',1200.00,'9900012345','neeraj.malhotra@hospital.in'),
('Dr. Pooja Verma','Dermatology',800.00,'9900012346','pooja.verma@hospital.in'),
('Dr. Karthik Menon','Orthopedics',1000.00,'9900012347','karthik.menon@hospital.in'),
('Dr. Sana Qureshi','General Medicine',600.00,'9900012348','sana.qureshi@hospital.in'),
('Dr. Arjun Bhatia','Pediatrics',700.00,'9900012349','arjun.bhatia@hospital.in');

-- Visits across different statuses (today ~ adjust dates as needed)
-- Use NOW() references so data remains “current”
INSERT INTO visits (patient_id,doctor_id,visit_dt,reason,status,height_cm,weight_kg,notes) VALUES
(1,4,          NOW() + INTERVAL 2 HOUR,      'Fever & cold','Scheduled',NULL,NULL,'New appointment'),
(2,2,          NOW() + INTERVAL 1 DAY,       'Rash on arm','Scheduled',NULL,NULL,'Follow-up next day'),
(3,1,          NOW() - INTERVAL 2 DAY,       'Chest pain','Completed',176,82,'ECG done'),
(4,3,          NOW() - INTERVAL 1 DAY,       'Knee pain','Discharged',164,58,'Physio advised'),
(5,5,          NOW() - INTERVAL 3 DAY,       'Child vaccination','Completed',NULL,NULL,'Dose given'),
(6,4,          NOW() - INTERVAL 10 HOUR,     'Annual checkup','CheckedIn',168,70,'Vitals noted'),
(7,1,          NOW() - INTERVAL 6 DAY,       'Palpitations','Discharged',178,86,'Holter recommended'),
(8,2,          NOW() - INTERVAL 8 DAY,       'Acne','Cancelled',NULL,NULL,'Rescheduled'),
(1,5,          NOW() - INTERVAL 12 DAY,      'Pediatric consult','Completed',NULL,NULL,'(Parent consult)'),
(2,4,          NOW() - INTERVAL 15 DAY,      'General weakness','Discharged',170,74,'B12 shots'),
(3,3,          NOW() - INTERVAL 20 DAY,      'Shoulder pain','Completed',176,82,'MRI suggested'),
(6,2,          NOW() + INTERVAL 3 DAY,       'Dermatitis','Scheduled',NULL,NULL,'Patch test planned');

-- Create some initial bills (some visits may be billed later via procedures)
INSERT INTO bills (visit_id, subtotal, discount, tax_rate_pct, tax_amount, total_amount, paid_amount, payment_method, payment_dt, status)
VALUES
(3,  2500.00, 200.00, 18.00, 414.00, 2714.00, 2714.00, 'Card', NOW() - INTERVAL 2 DAY, 'Paid'),
(4,  3200.00, 0.00,   18.00, 576.00, 3776.00, 2000.00, 'Cash', NOW() - INTERVAL 1 DAY, 'Pending'),
(5,  900.00,  0.00,   0.00,  0.00,   900.00,  900.00,  'UPI',  NOW() - INTERVAL 3 DAY, 'Paid'),
(7,  4500.00, 300.00, 18.00, 756.00, 4956.00, 4956.00, 'Insurance', NOW() - INTERVAL 5 DAY, 'Paid'),
(9,  1200.00, 0.00,   5.00,   60.00, 1260.00,  800.00, 'Cash', NOW() - INTERVAL 12 DAY, 'Pending'),
(10, 3000.00, 200.00, 12.00,  336.00, 3136.00, 3136.00, 'Card', NOW() - INTERVAL 15 DAY, 'Paid'),
(11, 2200.00, 0.00,   18.00,  396.00, 2596.00, 1000.00, 'UPI', NOW() - INTERVAL 20 DAY, 'Pending');

-- ---------- 3) HELPER FUNCTIONS ----------
-- Age in years
DROP FUNCTION IF EXISTS fn_age_years;
DELIMITER //
CREATE FUNCTION fn_age_years(p_dob DATE)
RETURNS INT DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
END//
DELIMITER ;

-- Compute tax amount given a base and percentage
DROP FUNCTION IF EXISTS fn_tax_amount;
DELIMITER //
CREATE FUNCTION fn_tax_amount(p_base DECIMAL(12,2), p_pct DECIMAL(5,2))
RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
  RETURN ROUND(IFNULL(p_base,0) * IFNULL(p_pct,0) / 100, 2);
END//
DELIMITER ;

-- ---------- 4) STORED PROCEDURES (Billing) ----------
/*
  sp_generate_bill:
  - Creates/updates a bill for a visit by summing consultation_fee + treatment + medicine + extras
  - Applies discount and tax
  - Optionally records an immediate payment
*/
DROP PROCEDURE IF EXISTS sp_generate_bill;
DELIMITER //
CREATE PROCEDURE sp_generate_bill(
  IN p_visit_id BIGINT,
  IN p_treatment_cost DECIMAL(12,2),
  IN p_medicine_cost  DECIMAL(12,2),
  IN p_extra_charges  DECIMAL(12,2),
  IN p_discount       DECIMAL(12,2),
  IN p_tax_rate_pct   DECIMAL(5,2),
  IN p_payment_amt    DECIMAL(12,2),
  IN p_payment_method ENUM('Cash','Card','UPI','Insurance','Other'),
  IN p_payment_dt     DATETIME
)
BEGIN
  DECLARE v_doctor_id BIGINT;
  DECLARE v_consult DECIMAL(12,2);
  DECLARE v_subtotal DECIMAL(12,2);
  DECLARE v_tax DECIMAL(12,2);
  DECLARE v_total DECIMAL(12,2);
  DECLARE v_bill_id BIGINT;

  -- Get consultation fee from doctor on the visit
  SELECT d.doctor_id, d.consultation_fee
    INTO v_doctor_id, v_consult
  FROM visits v
  JOIN doctors d ON d.doctor_id = v.doctor_id
  WHERE v.visit_id = p_visit_id;

  SET v_subtotal = IFNULL(v_consult,0) + IFNULL(p_treatment_cost,0) + IFNULL(p_medicine_cost,0) + IFNULL(p_extra_charges,0);
  SET v_tax = fn_tax_amount(GREATEST(v_subtotal - IFNULL(p_discount,0), 0), IFNULL(p_tax_rate_pct,0));
  SET v_total = ROUND(GREATEST(v_subtotal - IFNULL(p_discount,0), 0) + v_tax, 2);

  -- Upsert bill row
  INSERT INTO bills (visit_id, subtotal, discount, tax_rate_pct, tax_amount, total_amount, paid_amount, payment_method, payment_dt, status)
  VALUES (p_visit_id, v_subtotal, IFNULL(p_discount,0), IFNULL(p_tax_rate_pct,0), v_tax, v_total,
          IFNULL(p_payment_amt,0), p_payment_method, p_payment_dt,
          CASE
            WHEN IFNULL(p_payment_amt,0) = 0 THEN 'Pending'
            WHEN IFNULL(p_payment_amt,0) >= v_total THEN 'Paid'
            ELSE 'Pending'
          END)
  ON DUPLICATE KEY UPDATE
      subtotal = VALUES(subtotal),
      discount = VALUES(discount),
      tax_rate_pct = VALUES(tax_rate_pct),
      tax_amount = VALUES(tax_amount),
      total_amount = VALUES(total_amount),
      paid_amount = IF(p_payment_amt IS NULL, bills.paid_amount, ROUND(VALUES(paid_amount),2)),
      payment_method = IFNULL(VALUES(payment_method), bills.payment_method),
      payment_dt = IFNULL(VALUES(payment_dt), bills.payment_dt),
      status = CASE
                 WHEN (IF(p_payment_amt IS NULL, bills.paid_amount, VALUES(paid_amount))) >= VALUES(total_amount) THEN 'Paid'
                 ELSE 'Pending'
               END;

  SELECT bill_id INTO v_bill_id FROM bills WHERE visit_id = p_visit_id;

  -- Return the (re)computed bill
  SELECT b.*
  FROM bills b
  WHERE b.bill_id = v_bill_id;
END//
DELIMITER ;

-- Record an additional payment towards a bill
DROP PROCEDURE IF EXISTS sp_record_payment;
DELIMITER //
CREATE PROCEDURE sp_record_payment(
  IN p_bill_id BIGINT,
  IN p_amount  DECIMAL(12,2),
  IN p_method  ENUM('Cash','Card','UPI','Insurance','Other'),
  IN p_pay_dt  DATETIME
)
BEGIN
  UPDATE bills
     SET paid_amount = ROUND(paid_amount + IFNULL(p_amount,0),2),
         payment_method = p_method,
         payment_dt = p_pay_dt,
         status = CASE
                    WHEN ROUND(paid_amount + IFNULL(p_amount,0),2) >= total_amount THEN 'Paid'
                    ELSE 'Pending'
                  END
   WHERE bill_id = p_bill_id;

  SELECT * FROM bills WHERE bill_id = p_bill_id;
END//
DELIMITER ;

-- ---------- 5) TRIGGERS (Discharge & Status Sync) ----------

-- When a visit is marked Discharged, stamp discharge_dt
DROP TRIGGER IF EXISTS trg_visits_before_update_discharge;
DELIMITER //
CREATE TRIGGER trg_visits_before_update_discharge
BEFORE UPDATE ON visits
FOR EACH ROW
BEGIN
  IF NEW.status = 'Discharged' AND (OLD.status <> 'Discharged' OR OLD.status IS NULL) THEN
    SET NEW.discharge_dt = NOW();
  END IF;
END//
DELIMITER ;

-- After a visit is Discharged, sync the related bill’s lifecycle
DROP TRIGGER IF EXISTS trg_visits_after_update_discharge_bill;
DELIMITER //
CREATE TRIGGER trg_visits_after_update_discharge_bill
AFTER UPDATE ON visits
FOR EACH ROW
BEGIN
  IF NEW.status = 'Discharged' THEN
    UPDATE bills b
       SET b.status = CASE
                        WHEN b.paid_amount >= b.total_amount AND b.total_amount > 0 THEN 'Closed'
                        WHEN b.total_amount = 0 THEN 'Unbilled'
                        ELSE 'Pending'
                      END
     WHERE b.visit_id = NEW.visit_id;
  END IF;
END//
DELIMITER ;

-- If a bill becomes fully paid by any update, ensure status reflects it
DROP TRIGGER IF EXISTS trg_bills_after_update_paidstatus;
DELIMITER //
CREATE TRIGGER trg_bills_after_update_paidstatus
AFTER UPDATE ON bills
FOR EACH ROW
BEGIN
  IF NEW.paid_amount >= NEW.total_amount AND NEW.total_amount > 0 AND NEW.status <> 'Refunded' THEN
    UPDATE bills SET status = 'Paid' WHERE bill_id = NEW.bill_id;
  END IF;
END//
DELIMITER ;

-- ---------- 6) VIEWS (Reports) ----------

-- Detailed visit report (joins core entities)
CREATE OR REPLACE VIEW vw_visits_detailed AS
SELECT
  v.visit_id,
  v.visit_dt,
  v.status AS visit_status,
  p.patient_id,
  CONCAT(p.first_name,' ',p.last_name) AS patient_name,
  fn_age_years(p.dob) AS patient_age,
  d.doctor_id,
  d.full_name AS doctor_name,
  d.specialty,
  b.bill_id,
  b.subtotal, b.discount, b.tax_rate_pct, b.tax_amount, b.total_amount, b.paid_amount,
  b.status AS bill_status
FROM visits v
JOIN patients p ON p.patient_id = v.patient_id
JOIN doctors d  ON d.doctor_id = v.doctor_id
LEFT JOIN bills b ON b.visit_id = v.visit_id;

-- Revenue by calendar day (based on payment date)
CREATE OR REPLACE VIEW vw_revenue_by_day AS
SELECT
  DATE(COALESCE(b.payment_dt, v.visit_dt)) AS txn_date,
  COUNT(DISTINCT v.visit_id) AS visits_count,
  SUM(b.total_amount) AS billed_amount,
  SUM(b.paid_amount)  AS collected_amount,
  SUM(GREATEST(b.total_amount - b.paid_amount,0)) AS outstanding_amount
FROM visits v
LEFT JOIN bills b ON b.visit_id = v.visit_id
GROUP BY DATE(COALESCE(b.payment_dt, v.visit_dt))
ORDER BY txn_date DESC;

-- Upcoming schedule for all doctors (next 7 days)
CREATE OR REPLACE VIEW vw_upcoming_7d AS
SELECT
  v.visit_id,
  v.visit_dt,
  v.status,
  CONCAT(p.first_name,' ',p.last_name) AS patient_name,
  d.full_name AS doctor_name,
  d.specialty
FROM visits v
JOIN patients p ON p.patient_id = v.patient_id
JOIN doctors d  ON d.doctor_id = v.doctor_id
WHERE v.status IN ('Scheduled','CheckedIn')
  AND v.visit_dt BETWEEN NOW() AND NOW() + INTERVAL 7 DAY
ORDER BY v.visit_dt;

-- ---------- 7) QUERY SNIPPETS ----------
/* APPOINTMENTS */

/* A. Doctor’s appointments on a specific day (bind :doctor_id, :date) */
-- SET @doctor_id = 4; SET @d = DATE(NOW());
-- SELECT * FROM vw_visits_detailed
-- WHERE doctor_id = @doctor_id AND DATE(visit_dt) = @d
-- ORDER BY visit_dt;

/* B. Next 10 appointments (all doctors) */
-- SELECT * FROM vw_upcoming_7d LIMIT 10;

/* C. Patient history (all past visits & bills) for a patient */
-- SET @patient_id = 1;
-- SELECT * FROM vw_visits_detailed
-- WHERE patient_id = @patient_id
-- ORDER BY visit_dt DESC;

/* PAYMENTS */

/* D. Outstanding bills (not fully paid) */
-- SELECT * FROM vw_visits_detailed
-- WHERE total_amount > paid_amount OR bill_status IN ('Pending','Unbilled')
-- ORDER BY visit_dt DESC;

/* E. Collection summary last 30 days */
-- SELECT * FROM vw_revenue_by_day
-- WHERE txn_date >= CURDATE() - INTERVAL 30 DAY
-- ORDER BY txn_date DESC;

/* ---------- 8) DEMO: BILLING PROCEDURES ----------

Example 1: Generate a bill for a visit (id 6 = CheckedIn today)
Treatment=1500, Medicine=350, Extras=0, Discount=100, Tax=18%, pay immediately 1000 via UPI
*/
-- CALL sp_generate_bill(6, 1500, 350, 0, 100, 18.00, 1000.00, 'UPI', NOW());
-- SELECT * FROM bills WHERE visit_id = 6;

/* Example 2: Add a follow-up payment to settle (use resulting bill_id) */
-- SET @bill_id = (SELECT bill_id FROM bills WHERE visit_id = 6);
-- CALL sp_record_payment(@bill_id, 1000.00, 'Card', NOW());
-- SELECT * FROM bills WHERE bill_id = @bill_id;

/* ---------- 9) HANDY INDEXED LOOKUPS ---------- */
-- Find all visits by status/date window
-- SELECT * FROM visits WHERE status='Scheduled' AND visit_dt BETWEEN NOW() AND NOW()+INTERVAL 3 DAY;

-- Top specialties by billed amount
-- SELECT specialty, SUM(b.total_amount) AS total_billed
-- FROM vw_visits_detailed
-- GROUP BY specialty
-- ORDER BY total_billed DESC;
SHOW DATABASES;