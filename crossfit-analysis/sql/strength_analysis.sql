--Crossfit Strength Analysis

WITH base AS (
    SELECT 
        name,
        age,
        height_cm,
        bodyweight_kg,
        snatch_kg,
        deadlift_kg,
        backsq_kg,
        candj_kg,

        -- Relative strength calculations
        snatch_kg / bodyweight_kg AS snatch_bw,
        candj_kg / bodyweight_kg AS candj_bw,
        backsq_kg / bodyweight_kg AS squat_bw,
        deadlift_kg / bodyweight_kg AS deadlift_bw,

        -- Strength ratios
        snatch_kg / candj_kg AS snatch_to_cj_ratio,
        candj_kg / backsq_kg AS cj_to_squat_ratio,
        deadlift_kg / backsq_kg AS deadlift_to_squat_ratio,

        -- Total strength score
        (snatch_kg + candj_kg + backsq_kg + deadlift_kg) AS total_lift,

        -- Composite relative score
        (snatch_kg + candj_kg + backsq_kg + deadlift_kg) / bodyweight_kg AS strength_score

    FROM athletes
    WHERE bodyweight_kg > 0
),

classified AS (
    SELECT *,
    
        -- Strength level classification (based on snatch/bodyweight)
        CASE
            WHEN snatch_bw < 0.75 THEN 'Beginner'
            WHEN snatch_bw BETWEEN 0.75 AND 1.0 THEN 'Intermediate'
            WHEN snatch_bw BETWEEN 1.0 AND 1.25 THEN 'Advanced'
            ELSE 'Elite'
        END AS snatch_level,

        -- Weakness detection
        CASE
            WHEN cj_to_squat_ratio < 0.7 THEN 'Weak Clean & Jerk'
            WHEN snatch_to_cj_ratio < 0.7 THEN 'Weak Snatch Technique'
            ELSE 'No Major Imbalance'
        END AS weakness_flag

    FROM base
),

ranked AS (
    SELECT *,
    
        -- Ranking athletes by overall strength
        RANK() OVER (ORDER BY strength_score DESC) AS overall_rank,

        -- Percentile ranking
        NTILE(100) OVER (ORDER BY strength_score DESC) AS percentile_rank,

        -- Age group classification
        CASE
            WHEN age < 18 THEN 'Youth'
            WHEN age BETWEEN 18 AND 34 THEN 'Senior'
            WHEN age BETWEEN 35 AND 49 THEN 'Masters I'
            ELSE 'Masters II'
        END AS age_group

    FROM classified
)

-- Final output
SELECT 
    name,
    age,
    age_group,
    bodyweight_kg,

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