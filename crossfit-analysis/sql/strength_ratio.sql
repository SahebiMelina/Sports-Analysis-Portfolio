SELECT 
    name,
    bodyweight,
    snatch,
    ROUND(snatch * 1.0 / bodyweight, 2) AS snatch_ratio
FROM athletes
WHERE gender = 'F'
ORDER BY snatch_ratio DESC
LIMIT 10;