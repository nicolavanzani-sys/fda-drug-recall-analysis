-- ============================================
-- FDA Drug Recall Analysis - SQL Queries
-- Database: PostgreSQL
-- Author: Nicola Vanzani
-- ============================================

-- Query 1: Top 10 recalling firms by Class I recalls
-- Business question: Which firms have the highest number 
-- of the most severe recalls?
WITH total AS ( 
    SELECT COUNT(event_id) AS total
FROM fda_recalls
WHERE classification = 'Class I'
)
SELECT
    recalling_firm,
    COUNT(event_id) AS total_recalls,
    ROUND((COUNT(event_id) *100.0 / total.total), 2) AS percentage
FROM fda_recalls, total
WHERE classification = 'Class I'
GROUP BY recalling_firm, total.total   
ORDER BY total_recalls DESC
LIMIT 10;


-- Query 2: Average classification time by severity class
-- Business question: How long does it take for the FDA to classify a recall by severity class?
WITH classification_days AS (
    SELECT
        classification,
        AVG(center_classification_date - recall_initiation_date) AS avg_days
    FROM fda_recalls
    WHERE (center_classification_date - recall_initiation_date) > 0
    AND (center_classification_date - recall_initiation_date) <= 365
    GROUP BY classification
)
SELECT
    classification,
    avg_days
FROM classification_days
WHERE avg_days IS NOT NULL AND avg_days > 0 AND avg_days <= 365
ORDER BY avg_days DESC;


-- Query 3: Voluntary vs mandated recalls by year (2012-2026)
-- Business question: How many recalls are voluntary vs mandated by year?
-- Note: 35 records with NULL voluntary_mandated are excluded from this analysis
-- as they cannot be classified as Voluntary or Mandated.
WITH recall_type_counts AS (
    SELECT 
        CASE
            WHEN voluntary_mandated LIKE '%Voluntary%' THEN 'Voluntary'
            WHEN voluntary_mandated LIKE '%Mandated%' THEN 'Mandated'
            ELSE 'Unknown'
        END AS recall_type,
        EXTRACT(YEAR FROM recall_initiation_date) AS recall_year,
        COUNT(event_id) AS total_recalls,
        SUM(COUNT(event_id)) OVER (PARTITION BY EXTRACT(YEAR FROM recall_initiation_date)) AS total_recalls_year
    FROM fda_recalls
    WHERE EXTRACT(YEAR FROM recall_initiation_date) >= 2012 
    GROUP BY recall_type, recall_year
)
SELECT
    recall_type,
    recall_year,
    total_recalls,
    ROUND((total_recalls::NUMERIC / total_recalls_year * 100), 2) AS percentage
FROM recall_type_counts
WHERE recall_type != 'Unknown'
ORDER BY recall_year, recall_type; 


-- Query 4: Recall category ranking by average classification time
-- Business question: How long does it take for the FDA to classify a recall by category?
WITH recall_categories AS (
    SELECT
        CASE
            WHEN LOWER(reason_for_recall) LIKE '%sterili%' THEN 'Sterility'

            WHEN LOWER(reason_for_recall) LIKE '%adverse reaction%'
            OR LOWER(reason_for_recall) LIKE '%adverse event%'
            THEN 'Adverse Event'

            WHEN LOWER(reason_for_recall) LIKE '%particulate%'
            OR LOWER(reason_for_recall) LIKE '%contaminat%'
            OR LOWER(reason_for_recall) LIKE '%foreign%'
            THEN 'Contamination'

            WHEN LOWER(reason_for_recall) LIKE '%potency%'
            OR LOWER(reason_for_recall) LIKE '%strength%'
            OR LOWER(reason_for_recall) LIKE '%assay%'
            OR LOWER(reason_for_recall) LIKE '%below label%'
            OR LOWER(reason_for_recall) LIKE '%subpotent drug%'
            OR LOWER(reason_for_recall) LIKE '%superpotent%'
            THEN 'Potency'

            WHEN LOWER(reason_for_recall) LIKE '%failed specification%'
            OR LOWER(reason_for_recall) LIKE '%failed test%'
            OR LOWER(reason_for_recall) LIKE '%failed dissolution%'
            OR LOWER(reason_for_recall) LIKE '%failed impurit%'
            OR LOWER(reason_for_recall) LIKE '%impurit%'
            OR LOWER(reason_for_recall) LIKE '%degradation%'
            OR LOWER(reason_for_recall) LIKE '%dissolution%'
            OR LOWER(reason_for_recall) LIKE '%precipitat%'
            OR LOWER(reason_for_recall) LIKE '%discolor%'
            OR LOWER(reason_for_recall) LIKE '%out of spec%'
            OR LOWER(reason_for_recall) LIKE '%failed tablet%'
            OR LOWER(reason_for_recall) LIKE '%failed capsule%'
            OR LOWER(reason_for_recall) LIKE '%failed stability%'
            OR LOWER(reason_for_recall) LIKE '%broken tablet%'
            THEN 'Analytical Failure'

            WHEN LOWER(reason_for_recall) LIKE '%without an approved%'
            OR LOWER(reason_for_recall) LIKE '%marketed without%'
            THEN 'Regulatory'

            WHEN LOWER(reason_for_recall) LIKE '%cgmp%'
            OR LOWER(reason_for_recall) LIKE '%gmp%'
            OR LOWER(reason_for_recall) LIKE '%manufacturing practice%'
            OR LOWER(reason_for_recall) LIKE '%processing control%'
            OR LOWER(reason_for_recall) LIKE '%insanitary%'
            THEN 'CGMP'

            WHEN LOWER(reason_for_recall) LIKE '%container%'
            OR LOWER(reason_for_recall) LIKE '%packaging%'
            OR LOWER(reason_for_recall) LIKE '%package%'
            OR LOWER(reason_for_recall) LIKE '%leak%'
            OR LOWER(reason_for_recall) LIKE '%blister%'
            THEN 'Packaging'

            WHEN LOWER(reason_for_recall) LIKE '%label%'
            OR LOWER(reason_for_recall) LIKE '%expir%'
            OR LOWER(reason_for_recall) LIKE '%lot number%'
            THEN 'Labeling'

            WHEN LOWER(reason_for_recall) LIKE '%refrigerat%'
            OR LOWER(reason_for_recall) LIKE '%storage%'
            OR LOWER(reason_for_recall) LIKE '%temperature%'
            THEN 'Storage'

            ELSE 'Other'
        END AS recall_category,
        center_classification_date - recall_initiation_date AS days_to_classification
    FROM fda_recalls
    WHERE (center_classification_date - recall_initiation_date) > 0
    AND (center_classification_date - recall_initiation_date) <= 365
) 
SELECT
    recall_category,
    ROUND(AVG(days_to_classification), 2) AS avg_days_to_classification,
    RANK() OVER (ORDER BY AVG(days_to_classification) DESC) AS rank
FROM recall_categories
GROUP BY recall_category;
