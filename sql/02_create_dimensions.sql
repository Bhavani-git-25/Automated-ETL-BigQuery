/* Dimension tables (SQL Server T-SQL) */

-- Roles candidates apply for
IF OBJECT_ID('dbo.dim_role') IS NOT NULL DROP TABLE dbo.dim_role;
CREATE TABLE dbo.dim_role (
  role_key INT IDENTITY(1,1) PRIMARY KEY,
  role_name NVARCHAR(50) UNIQUE
);

-- Candidate source (LinkedIn, Referral, etc.)
IF OBJECT_ID('dbo.dim_source') IS NOT NULL DROP TABLE dbo.dim_source;
CREATE TABLE dbo.dim_source (
  source_key INT IDENTITY(1,1) PRIMARY KEY,
  source_name NVARCHAR(50) UNIQUE
);

-- Candidate master
IF OBJECT_ID('dbo.dim_candidate') IS NOT NULL DROP TABLE dbo.dim_candidate;
CREATE TABLE dbo.dim_candidate (
  candidate_key INT IDENTITY(1,1) PRIMARY KEY,
  candidate_id INT UNIQUE,
  full_name NVARCHAR(100),
  current_location NVARCHAR(20),
  years_experience DECIMAL(4,1)
);

------------------------------------------------------------------
-- Seed dimensions from staging
------------------------------------------------------------------

-- role
INSERT INTO dbo.dim_role (role_name)
SELECT DISTINCT role_applied
FROM dbo.stg_candidates
WHERE role_applied IS NOT NULL;

-- source
INSERT INTO dbo.dim_source (source_name)
SELECT DISTINCT source
FROM dbo.stg_candidates
WHERE source IS NOT NULL;

-- candidate
INSERT INTO dbo.dim_candidate (candidate_id, full_name, current_location, years_experience)
SELECT DISTINCT
  sc.candidate_id, sc.full_name, sc.current_location, sc.years_experience
FROM dbo.stg_candidates sc;
