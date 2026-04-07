USE `xxx`;

-- AVG ENGAGEMENT, VIEWS, AND REACH BY MEDIA TYPE
SELECT 
	media_type,
    ROUND(AVG(`Engagement Rate`),2),
    ROUND(AVG(Views),2),
    ROUND(AVG(Reach),2)
    FROM `post_performance_clean-2`
    GROUP BY media_type;
    
-- WEIGHING THE PREVIOUS NUMBERS
SELECT 
    media_type,
    COUNT(*) AS post_count,
    ROUND(SUM(`Engagement Rate`) / COUNT(*), 2) AS avg_eng_rate,
    ROUND(SUM(Views) / COUNT(*), 0) AS avg_views,
    ROUND(SUM(Reach) / COUNT(*), 0) AS avg_reach,
    ROUND(SUM(Engagements) / NULLIF(SUM(Views), 0) * 100, 2) AS eng_per_view_pct,
    ROUND(SUM(Saves) / NULLIF(SUM(Engagements), 0) * 100, 2) AS save_rate
FROM `post_performance_clean-2`
GROUP BY media_type;

-- HIGHEST SAVE TO LIKE RATIO BY MEDIA TYPE
SELECT 
    media_type,
    COUNT(*) AS post_count,
    ROUND(AVG(Saves / NULLIF(Likes, 0)) * 100, 2) AS avg_save_to_like,
    ROUND(MIN(Saves / NULLIF(Likes, 0)) * 100, 2) AS min_save_to_like,
    ROUND(MAX(Saves / NULLIF(Likes, 0)) * 100, 2) AS max_save_to_like
FROM `post_performance_clean-2`
GROUP BY media_type;

-- AVG COMMENTS BY MEDIA TYPE
SELECT 	
	media_type, 
    COUNT(*) AS post_count,
    AVG(Comments) AS avg_comments,
    MIN(Comments) AS min_comments,
    MAX(Comments) AS max_comments
FROM `post_performance_clean-2`
GROUP BY media_type;

-- RANK POSTS BY ENGAGEMENT RATE
SELECT
    post_id,
    media_type,
    `Engagement Rate`,
    DENSE_RANK() OVER(ORDER BY `Engagement Rate` DESC) AS overall_rank,
    DENSE_RANK() OVER(PARTITION BY media_type ORDER BY `Engagement Rate` DESC) AS rank_within_type
FROM `post_performance_clean-2`
ORDER BY overall_rank;

-- RANK POSTS BY VIEWS
SELECT
    post_id,
    media_type,
    Views,
    DENSE_RANK() OVER(ORDER BY Views DESC) AS overall_rank,
    DENSE_RANK() OVER(PARTITION BY media_type ORDER BY Views DESC) AS rank_within_type
FROM `post_performance_clean-2`
ORDER BY overall_rank;

-- RANK POSTS BY REACH 
SELECT
    post_id,
    media_type,
    Reach,
    DENSE_RANK() OVER(ORDER BY Reach DESC) AS overall_rank,
    DENSE_RANK() OVER(PARTITION BY media_type ORDER BY Reach DESC) AS rank_within_type
FROM `post_performance_clean-2`
ORDER BY overall_rank;

-- WEIGHTED HEALTH SCORE FOR EACH POST + GROUPED INTO QUARTILE
SELECT
    post_id,
    media_type,
    `Engagement Rate`,
    Views,
    Reach,
    Saves,
    Comments,
    ROUND(
        (`Engagement Rate` * 0.30) + -- THE WEIGHTS DEPEND ON THE COMPANY'S GOALS. GROWTH VS BUILDING COMMUNITY WOULD SEE DIFFERENT WEIGHTS FOR EACH OF THE METRICS
        (Saves * 0.25) +
        (Reach / 100 * 0.20) +
        (Comments * 0.15) +
        (Views / 1000 * 0.10)
    , 2) AS health_score,
    NTILE(4) OVER(ORDER BY 
        (`Engagement Rate` * 0.30) +
        (Saves * 0.25) +
        (Reach / 100 * 0.20) +
        (Comments * 0.15) +
        (Views / 1000 * 0.10)
    DESC) AS performance_quartile
FROM `post_performance_clean-2`
ORDER BY health_score DESC;

-- ADD DATETIME
SELECT STR_TO_DATE('Feb 27, 2026 07:16:43 PM', '%b %d, %Y %h:%i:%s %p');
SET SQL_SAFE_UPDATES = 0;

UPDATE `post_performance_clean-2`
SET posted_at = STR_TO_DATE(`Time Posted`, '%b %d, %Y %h:%i:%s %p');

SET SQL_SAFE_UPDATES = 1;

-- SEE POST COUNTS AND ENGAGEMENT RATE BY TIME WINDOW POSTED 
SELECT 
    CASE 
        WHEN HOUR(posted_at) BETWEEN 12 AND 13 THEN '12-14h'
        WHEN HOUR(posted_at) BETWEEN 14 AND 15 THEN '14-16h'
        WHEN HOUR(posted_at) BETWEEN 16 AND 17 THEN '16-18h'
        WHEN HOUR(posted_at) BETWEEN 18 AND 19 THEN '18-20h'
        WHEN HOUR(posted_at) BETWEEN 20 AND 21 THEN '20-22h'
        ELSE 'Other'
    END AS time_window,
    ROUND(AVG(`Engagement Rate`), 2) AS avg_eng_rate,
    COUNT(*) AS post_count
FROM `post_performance_clean-2`
GROUP BY time_window
ORDER BY avg_eng_rate DESC;

-- RUNNING TOTAL OF ENGAGEMENTS, WE CAN SEE IF ANY OUTLIER 
SELECT 
	post_id, 
    posted_at, 
    media_type,
    Engagements, 
    SUM(Engagements) OVER (ORDER BY posted_at ASC) AS running_engt
FROM `post_performance_clean-2`
ORDER BY posted_at ASC;


-- WEIGHTED HEALTH SCORE + CLASSIFY PERFORMERS
WITH total_health_score AS (
SELECT
    post_id,
    media_type,
    `Engagement Rate`,
    Views,
    Reach,
    Saves,
    Comments,
    ROUND(
        (`Engagement Rate` * 0.30) + 
        (Saves * 0.25) +
        (Reach / 100 * 0.20) +
        (Comments * 0.15) +
        (Views / 1000 * 0.10)
    , 2) AS health_score
FROM `post_performance_clean-2`)

SELECT 
	post_id,
    media_type,
    health_score,
	CASE WHEN health_score BETWEEN 0 AND 3 THEN 'Poor'
		WHEN health_score BETWEEN 3.01 AND 6 THEN 'Mid'
		WHEN health_score BETWEEN 6.01 AND 8 THEN 'High'
    ELSE 'Top'
END AS performance_tier
FROM total_health_score
ORDER BY performance_tier;

-- REACH TO FOLLOWER RATIO
WITH ratio AS (
	SELECT
		post_id, 
        media_type, 
        reach, 
        followers,
        ROUND((Reach / Followers)*100,2) AS ratio1
	FROM `post_performance_clean-2`
)
SELECT 
	post_id, 
    media_type,
    reach, 
    followers,
    ratio1,
    DENSE_RANK() OVER(ORDER BY ratio1 DESC) AS overall_rank
FROM ratio
ORDER BY ratio1 DESC;

-- POSTS THAT HIT ABOVE AVERAGE ENGAGEMENT RATE
WITH avg_engrate AS (
	SELECT 
		ROUND(AVG(`Engagement Rate`),2) AS avg_eng_rate
	FROM `post_performance_clean-2`
)
	SELECT 
		post_id,
		media_type,
		`Engagement Rate`,
		avg_eng_rate,
        CASE WHEN `Engagement Rate` > avg_eng_rate THEN 'Flag'
        ELSE 'Below'
	END AS engagement_tier
FROM `post_performance_clean-2`
CROSS JOIN avg_engrate
ORDER BY `Engagement Rate` DESC;
    
