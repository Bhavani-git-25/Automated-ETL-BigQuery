/* KPI Views (SQL Server T-SQL) */

-- Funnel conversions by role & source (counts at each stage)
IF OBJECT_ID('dbo.vw_funnel_conversions') IS NOT NULL DROP VIEW dbo.vw_funnel_conversions;
GO
CREATE VIEW dbo.vw_funnel_conversions AS
SELECT
  dr.role_name,
  ds.source_name,
  SUM(CASE WHEN fcs.stage = 'HR Screen'   THEN 1 ELSE 0 END) AS cnt_hr_screen,
  SUM(CASE WHEN fcs.stage = 'Tech Screen' THEN 1 ELSE 0 END) AS cnt_tech_screen,
  SUM(CASE WHEN fcs.stage = 'Panel'       THEN 1 ELSE 0 END) AS cnt_panel,
  SUM(CASE WHEN fcs.stage = 'Manager'     THEN 1 ELSE 0 END) AS cnt_manager
FROM dbo.fact_candidate_stage fcs
JOIN dbo.dim_role dr   ON dr.role_key = fcs.role_key
JOIN dbo.dim_source ds ON ds.source_key = fcs.source_key
GROUP BY dr.role_name, ds.source_name;
GO

-- Offer acceptance by role
IF OBJECT_ID('dbo.vw_offer_acceptance') IS NOT NULL DROP VIEW dbo.vw_offer_acceptance;
GO
CREATE VIEW dbo.vw_offer_acceptance AS
SELECT
  dr.role_name,
  SUM(CASE WHEN fo.decision = 'Accepted' THEN 1 ELSE 0 END) AS accepted,
  SUM(CASE WHEN fo.decision = 'Declined' THEN 1 ELSE 0 END) AS declined,
  CAST(100.0 * SUM(CASE WHEN fo.decision = 'Accepted' THEN 1 ELSE 0 END)
       / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS acceptance_pct
FROM dbo.fact_offer fo
JOIN dbo.dim_role dr ON dr.role_key = fo.role_key
GROUP BY dr.role_name;
GO

-- Average days from application to offer (time-to-offer) by role
IF OBJECT_ID('dbo.vw_time_to_offer') IS NOT NULL DROP VIEW dbo.vw_time_to_offer;
GO
CREATE VIEW dbo.vw_time_to_offer AS
SELECT
  dr.role_name,
  AVG(DATEDIFF(DAY, fcs.applied_date, fo.decision_date)) AS avg_days_to_offer
FROM dbo.fact_offer fo
JOIN dbo.fact_candidate_stage fcs
  ON fcs.candidate_key = fo.candidate_key
JOIN dbo.dim_role dr
  ON dr.role_key = fo.role_key
GROUP BY dr.role_name;
GO
