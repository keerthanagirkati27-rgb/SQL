-- Implementing Joins in Hospital_Details

CREATE DATABASE hospital_details;

use hospital_details;

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    PatientName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50)
);

-- Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT,
    DoctorName VARCHAR(100),
    Department VARCHAR(50),
    AppointmentDate DATE,
    Fees DECIMAL(10 , 2 ),
    FOREIGN KEY (PatientID)
        REFERENCES Patients (PatientID)
);

SELECT * FROM Patients;

SELECT * FROM Appointments;


-- Retrieve all patients who have booked an appointment, showing their name, doctor, and appointment date.
SELECT 
    PatientName, AppointmentDate
FROM
    Patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID;
    

-- List all patients along with their appointment details. Include patients even if they don’t have any appointments.
SELECT 
    *
FROM
    Patients p
        LEFT JOIN
    Appointments a ON p.PatientID = a.PatientID;


-- Show all appointments along with patient details. Include appointments even if the patient record is missing.
SELECT 
    *
FROM
    Patients
        RIGHT JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID;
    

-- Display all patients and appointments, ensuring no data is excluded (patients without appointments and appointments without patients should appear).
SELECT 
    *
FROM
    Patients
        LEFT JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID 
UNION SELECT 
    *
FROM
    Patients
        RIGHT JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID;
    

-- Find all patients who have appointments in the Cardiology department.
SELECT 
    *
FROM
    patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    Department = 'Cardiology';


-- Identify patients who have never booked an appointment.
SELECT 
    *
FROM
    Patients
        LEFT JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    Appointments.PatientID IS NULL;
    

-- Find all patients older than 50 who have at least one appointment scheduled.
SELECT 
    Patients.PatientID, PatientName, Age
FROM
    Patients
        JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    Age > 50;
    

-- List patients who had appointments in March 2024.
SELECT 
    PatientName, DoctorName, AppointmentDate
FROM
    Patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    AppointmentDate BETWEEN '2024-03-01' AND '2024-03-31';
    
    
-- Find the patient with the highest total fees.
SELECT 
    Patients.PatientID, PatientName, SUM(Fees) AS TotalFees
FROM
    Patients
        JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
GROUP BY Patients.PatientID , PatientName
ORDER BY SUM(Fees) DESC
LIMIT 1;


-- Compare patients from the same city:
SELECT 
    P1.PatientName, P2.PatientName, P1.City
FROM
    Patients P1
        INNER JOIN
    Patients P2 ON P1.City = P2.City
        AND P1.PatientID <> P2.PatientID;
        

-- Patients visiting multiple departments
SELECT 
    PatientName, COUNT(DISTINCT department) AS deptCount
FROM
    patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
GROUP BY PatientName
HAVING COUNT(DISTINCT department) > 1;


-- Highest fee appointment per patient
SELECT 
    PatientName, DoctorName, Fees
FROM
    Patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    Fees = (SELECT 
            MAX(Fees)
        FROM
            Appointments
        WHERE
            PatientID = Patients.PatientID);
    
-- Department revenue by city
SELECT 
    Department, City, SUM(Fees) AS revenue
FROM
    Patients
        INNER JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
GROUP BY City , Department;


-- Patients with consecutive appointments
SELECT PatientName, AppointmentDate, 
LEAD(AppointmentDate) OVER (PARTITION BY Appointments.PatientID ORDER BY AppointmentDate) AS NextAppointment
FROM Patients
INNER JOIN Appointments
ON Patients.PatientID = Appointments.PatientID;



-- Rank doctors by their total appointment revenue, showing their rank and cumulative revenue.
SELECT DoctorName,
SUM(Fees) AS TotalRevenue,
RANK() OVER (ORDER BY SUM(Fees) DESC) AS RevenueRank,
SUM(SUM(Fees)) OVER (ORDER BY SUM(Fees) DESC 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeRevenue
FROM Appointments
GROUP BY DoctorName;


-- . Retrieve patients who never had an appointment in the "Cardiology" department
SELECT 
    PatientName
FROM
    Patients
WHERE
    PatientID NOT IN (SELECT 
            PatientID
        FROM
            Appointments
        WHERE
            Department = 'Cardiology');
            

-- Find the top 3 patients who paid the highest total fees
SELECT 
    Patients.PatientID, PatientName, SUM(Fees) AS TotalFees
FROM
    Patients
        JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
GROUP BY Patients.PatientID , PatientName
ORDER BY SUM(Fees) DESC
LIMIT 3;

-- Find patients who have more than 2 appointments
SELECT 
    Patients.PatientID,
    PatientName,
    COUNT(AppointmentID) AS AppointmentCount
FROM
    Patients
        JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
GROUP BY Patients.PatientID , PatientName
HAVING COUNT(AppointmentID) > 2;


-- Retrieve each patient’s latest appointment date and doctor
SELECT 
    Patients.PatientID, PatientName, DoctorName, AppointmentDate
FROM
    Patients
        JOIN
    Appointments ON Patients.PatientID = Appointments.PatientID
WHERE
    AppointmentDate = (SELECT 
            MAX(AppointmentDate)
        FROM
            Appointments
        WHERE
            PatientID = Patients.PatientID);
            

-- Find patients who have spent more than the average fees across all appointments
SELECT 
    PatientID, PatientName, SUM(Fees) AS TotalSpent
FROM
    Patients
        NATURAL JOIN
    Appointments
GROUP BY PatientID , PatientName
HAVING SUM(Fees) > (SELECT 
        AVG(Fees)
    FROM
        Appointments);




