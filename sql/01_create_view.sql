USE HigherEdEnrollment;
GO

CREATE OR ALTER VIEW dbo.vw_enrollment_master AS
SELECT
    -- Student & course identifiers
    sr.id_student,
    sr.code_module,
    sr.code_presentation,

    -- Derived time dimensions (for trend analysis in Power BI)
    LEFT(sr.code_presentation, 4)  AS academic_year,
    RIGHT(sr.code_presentation, 1) AS semester_code,
    CASE 
        WHEN RIGHT(sr.code_presentation, 1) = 'B' THEN 'February'
        WHEN RIGHT(sr.code_presentation, 1) = 'J' THEN 'October'
    END AS semester_name,

    -- Enrollment status (key KPI column)
    CASE 
        WHEN sr.date_unregistration IS NOT NULL THEN 'Withdrawn' 
        ELSE 'Active' 
    END AS enrollment_status,

    -- Registration dates
    sr.date_registration,
    sr.date_unregistration,

    -- Demographics
    si.gender,
    si.region,
    si.age_band,
    si.highest_education,
    ISNULL(si.imd_band, 'Not Available') AS imd_band,
    si.disability,
    si.studied_credits,
    si.num_of_prev_attempts,
    si.final_result,

    -- Course metadata
    c.module_presentation_length

FROM dbo.studentRegistration sr
JOIN dbo.studentInfo si
    ON  sr.id_student       = si.id_student
    AND sr.code_module      = si.code_module
    AND sr.code_presentation = si.code_presentation
JOIN dbo.courses c
    ON  sr.code_module       = c.code_module
    AND sr.code_presentation  = c.code_presentation;
GO

-- check 1
SELECT TOP 10 * FROM dbo.vw_enrollment_master;

--check 2
SELECT COUNT(*) FROM dbo.vw_enrollment_master;
SELECT COUNT(*) FROM dbo.studentRegistration;

--check 3
SELECT DISTINCT code_presentation, academic_year, semester_code, semester_name from dbo.vw_enrollment_master;

--check 4
Select date_unregistration, enrollment_status from dbo.vw_enrollment_master;

select enrollment_status, count(*) as students_enrolled from dbo.vw_enrollment_master group by enrollment_status;

--check 5
SELECT distinct imd_band from dbo.vw_enrollment_master order by imd_band;


SELECT 
    ISNULL(enrollment_status, 'Total') AS enrollment_status,
    COUNT(*) AS students_enrolled
FROM dbo.vw_enrollment_master
GROUP BY ROLLUP(enrollment_status);