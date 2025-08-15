CREATE TABLE stg_candidates (
  candidate_id INT PRIMARY KEY,
  full_name NVARCHAR(100),
  role_applied NVARCHAR(50),
  source NVARCHAR(50),
  applied_date DATE,
  years_experience DECIMAL(4,1),
  current_location NVARCHAR(20),
  status NVARCHAR(20)
);

CREATE TABLE stg_interviews (
  interview_id INT PRIMARY KEY,
  candidate_id INT,
  stage NVARCHAR(20),
  scheduled_datetime DATETIME2,
  interviewer NVARCHAR(50),
  result NVARCHAR(20)
);

CREATE TABLE stg_offers (
  offer_id INT PRIMARY KEY,
  candidate_id INT,
  role NVARCHAR(50),
  offered_salary_usd INT,
  decision NVARCHAR(20),
  decision_date DATE
);
