# social-media-performance-sql
SQL analysis of Instagram post performance data throughout a month based on Post Performance Analytics on Later: engagement patterns, content scoring, and posting window optimization.
Please note the data is proprietary and not included in this repository.
Queries are written on MySQL and can be applied to all CSVs from the Post Performance Analytics on Later. 

Skills Demonstrated
Aggregations and GROUP BY
Window functions (DENSE_RANK, NTILE, SUM OVER)
CTEs
CASE WHEN / conditional aggregation
CROSS JOIN
Date parsing and time-based bucketing
Composite scoring / weighted metrics

Key Questions Answered
Which media type drives higher engagement quality?
What time windows generate the best engagement rate?
Which posts are top/mid/low performers based on a weighted health score?
How many posts beat the average engagement rate, and does media type predict it?
