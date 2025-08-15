/* Fact tables (SQL Server T-SQL) */

IF OBJECT_ID('dbo.fact_candidate_stage') IS NOT NULL DROP TABLE dbo.fact_candidate_stage;
CREATE TABLE dbo.fact_candidate_stage (
  candidate_key INT NOT NULL,
  role_key INT NOT NULL,
  source_key INT NOT NULL,
  applied_date DATE,
  stage NVARCHAR(20),
  result NVARCHAR(20)
  -- Optional FKs (uncomment after data load if you like)
  -- ,CONSTRAINT FK_fcs_candidate FOREIGN KEY (candidate_key) REFERENCES dbo.dim_candidate(candidate_key)
  -- ,CONSTRAINT FK_fcs_role      FOREIGN KEY (role_key)      REFERENCES dbo.dim_role(role_key)
  -- ,CONSTRAINT FK_fcs_source    FOREIGN KEY (source_key)    REFERENCES dbo.dim_source(source_key)
);

IF OBJECT_ID('dbo.fact_offer') IS NOT NULL DROP TABLE dbo.fact_offer;
CREATE TABLE dbo.fact_offer (
  candidate_key INT NOT NULL,
  role_key INT NOT NULL,
  offered_salary_usd INT,
  decision NVARCHAR(20),
  decision_date DATE
  -- Optional FKs:
  -- ,CONSTRAINT FK_fo_candidate FOREIGN KEY (candidate_key) REFERENCES dbo.dim_candidate(candidate_key)
  -- ,CONSTRAINT FK_fo_role      FOREIGN KEY (role_key)      REFERENCES dbo.dim_role(role_key)
);

------------------------------------------------------------------
-- Load facts from staging + dimensions
------------------------------------------------------------------

-- Candidate stage fact (one row per candidate per interview stage)
INSERT INTO dbo.fact_candidate_stage (candidate_key, role_key, source_key, applied_date, stage, result)
SELECT
  dc.candidate_key,
  dr.role_key,
  ds.source_key,
  sc.applied_date,
  si.stage,
  si.result
FROM dbo.stg_interviews si
JOIN dbo.stg_candidates sc
  ON sc.candidate_id = si.candidate_id
JOIN dbo.dim_candidate dc
  ON dc.candidate_id = sc.candidate_id
JOIN dbo.dim_role dr
  ON dr.role_name = sc.role_applied
JOIN dbo.dim_source ds
  ON ds.source_name = sc.source;

-- Offer fact (one row per candidate offer)
INSERT INTO dbo.fact_offer (candidate_key, role_key, offered_salary_usd, decision, decision_date)
SELECT
  dc.candidate_key,
  dr.role_key,
  so.offered_salary_usd,
  so.decision,
  so.decision_date
FROM dbo.stg_offers so
JOIN dbo.dim_candidate dc
  ON dc.candidate_id = so.candidate_id
JOIN dbo.dim_role dr
  ON dr.role_name = so.role;

------------------------------------------------------------------
-- Helpful indexes
------------------------------------------------------------------
CREATE INDEX IX_fcs_candidate ON dbo.fact_candidate_stage (candidate_key);
CREATE INDEX IX_fcs_role_source ON dbo.fact_candidate_stage (role_key, source_key);
CREATE INDEX IX_fo_role ON dbo.fact_offer (role_key);
