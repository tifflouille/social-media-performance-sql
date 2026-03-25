Instagram Post Performance SQL Analysis
A one-month SQL analysis of Instagram post performance data, examining engagement quality, content scoring, and posting window optimization for a D2C fashion brand.
Tools: MySQL
Data source: Post Performance Analytics export from Later
Note: The underlying data is proprietary and not included in this repository. Queries are written to be portable and can be applied to any CSV export from Later's Post Performance Analytics.

Business Context
Most brands track vanity metrics such as likes, follower count, reach. Fewer ask the harder questions: which content is actually worth making again, which posting windows drive real engagement, and which posts are quietly underperforming despite decent view counts. This analysis builds a framework to answer those questions from a single month of Instagram data.


Questions Answered
- Engagement quality by content type: mot all engagement is equal. This analysis separates raw engagement rate from saves-to-likes ratio and engagement-per-view, which distingues content that people passively scroll past from content they actively want to return to.
- Posting window optimization: which two-hour windows consistently outperform on engagement rate, and does posting time actually move the needle enough to matter?
- Weighted post health scoring: a composite score weighting engagement rate, saves, reach, comments, and views, calibrated to reflect growth-stage brand priorities rather than raw popularity. Posts are bucketed into performance tiers (Top, High, Mid, Poor) and quartiles.
- Reach-to-follower ratio: which posts punched above their weight in distribution reaching beyond the existing audience rather than just performing well within it?
- Above-average engagement flagging: which posts beat the monthly average engagement rate, and does media type predict whether a post will outperform?

Key Findings
- Saves are the most predictive signal of content quality. Posts with a high save-to-like ratio consistently score in the top performance tier, which is suggesting that content designed to be bookmarked (educational, inspirational, reference-worthy) outperforms content designed to entertain in the moment.
- Posting window matters, but not uniformly. Certain two-hour windows show meaningfully higher average engagement rates than others, but the effect is smaller than content quality differences. Getting the format right matters more than getting the timing perfect.
- Reach and engagement rate are not correlated. Some of the highest-reach posts scored mid or low on the weighted health score — indicating that distribution alone does not equal performance. Optimizing for reach without monitoring engagement quality risks inflating vanity metrics at the expense of community signal.

Methodology
All analysis performed in MySQL on a cleaned export of post-level data. Key techniques include window functions for cross-type and within-type ranking, CTEs for multi-step scoring logic, weighted composite health scores using NTILE quartiling, and CASE WHEN classification for performance tiering. Date parsing was used to extract posting hour and bucket posts into two-hour time windows.

Limitations
One month of data is a limited sample: posting frequency, algorithmic changes, and seasonal factors can all distort patterns that would average out over a longer window. Findings should be treated as directional rather than definitive, and validated against at least three months of data before informing content strategy decisions.
