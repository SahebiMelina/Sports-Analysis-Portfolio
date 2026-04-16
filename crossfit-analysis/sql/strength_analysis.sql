-- Crossfit Strength Analysis

DROP TABLE IF EXISTS athlete_strength_analysis;

CREATE TABLE athlete_strength_analysis AS
WITH base AS (
    SELECT 
        name,
        age,
        height,
        bodyweight,
        snatch,
        deadlift,
        backsq,
        candj,

        -- Relative strength calculations
        snatch / bodyweight AS snatch_bw,
        candj / bodyweight AS candj_bw,
        backsq / bodyweight AS squat_bw,
        deadlift / bodyweight AS deadlift_bw,

        -- Strength ratios
        snatch / candj AS snatch_to_cj_ratio,
        candj / backsq AS cj_to_squat_ratio,
        deadlift / backsq AS deadlift_to_squat_ratio,

        -- Total strength score
        (snatch + candj + backsq + deadlift) AS total_lift,

        -- Composite relative score
        (snatch + candj + backsq + deadlift) / bodyweight AS strength_score

    FROM athletes
    WHERE bodyweight > 0
),

classified AS (
    SELECT *,
    
        CASE
            WHEN snatch_bw < 0.75 THEN 'Beginner'
            WHEN snatch_bw BETWEEN 0.75 AND 1.0 THEN 'Intermediate'
            WHEN snatch_bw BETWEEN 1.0 AND 1.25 THEN 'Advanced'
            ELSE 'Elite'
        END AS snatch_level,

        CASE
            WHEN cj_to_squat_ratio < 0.7 THEN 'Weak Clean & Jerk'
            WHEN snatch_to_cj_ratio < 0.7 THEN 'Weak Snatch Technique'
            ELSE 'No Major Imbalance'
        END AS weakness_flag

    FROM base
),

ranked AS (
    SELECT *,
    
        RANK() OVER (ORDER BY strength_score DESC) AS overall_rank,
        NTILE(100) OVER (ORDER BY strength_score DESC) AS percentile_rank,

        CASE
            WHEN age < 18 THEN 'Youth'
            WHEN age BETWEEN 18 AND 34 THEN 'Senior'
            WHEN age BETWEEN 35 AND 49 THEN 'Masters I'
            ELSE 'Masters II'
        END AS age_group

    FROM classified
)

SELECT 
    name,
    age,
    age_group,
    bodyweight,

    ROUND(snatch_bw, 2) AS snatch_bw,
    ROUND(candj_bw, 2) AS candj_bw,
    ROUND(squat_bw, 2) AS squat_bw,
    ROUND(deadlift_bw, 2) AS deadlift_bw,

    ROUND(snatch_to_cj_ratio, 2) AS snatch_to_cj,
    ROUND(cj_to_squat_ratio, 2) AS cj_to_squat,
    ROUND(strength_score, 2) AS strength_score,

    snatch_level,
    weakness_flag,

    overall_rank,
    percentile_rank

FROM ranked
ORDER BY overall_rank;