/*
Question #1:
Write a solution to find the employee_id of managers with at least 2 direct reports.


Expected column names: employee_id

*/


SELECT employee_id
FROM employee
WHERE title LIKE '%Manager%'
AND employee_id IN (
    SELECT reports_to
    FROM employee
    GROUP BY reports_to
    HAVING COUNT(*) >= 2
)
ORDER BY employee_id ASC;


/*

Question #2: 
Calculate total revenue for MPEG-4 video files purchased in 2024.

Expected column names: total_revenue

*/


SELECT 
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_revenue
FROM 
    invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN media_type ON media_type.media_type_id = track.media_type_id
WHERE 
    media_type.name LIKE '%MPEG-4 video%'
    AND EXTRACT(YEAR FROM invoice.invoice_date) = 2024;


/*
Question #3: 
For composers appearing in classical playlists, count the number of distinct playlists they appear on and 
create a comma separated list of the corresponding (distinct) playlist names.

Expected column names: composer, distinct_playlists, list_of_playlists

*/

SELECT 
    track.composer,
    COUNT(DISTINCT playlist.name) AS distinct_playlists,
    STRING_AGG(DISTINCT playlist.name, ', ') AS list_of_playlists
FROM 
    playlist
    JOIN playlist_track ON playlist.playlist_id = playlist_track.playlist_id
    JOIN track ON playlist_track.track_id = track.track_id
WHERE 
    track.composer IS NOT NULL 
    AND playlist.name LIKE '%Classical%'
GROUP BY 
    track.composer;


/*
Question #4: 
Find customers whose yearly total spending is strictly increasing*.


*read the hints!


Expected column names: customer_id
*/


WITH yearly_spending AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM invoice_date::date) AS year,
        SUM(total) AS total_spending,
  			LAG(SUM(total)) OVER (PARTITION BY customer_id ORDER BY EXTRACT(YEAR FROM invoice_date::date)) AS prev_year_spending
    FROM
        invoice
    WHERE
        EXTRACT(year FROM invoice_date::date) !=2025 
    GROUP BY
    1, 2
  	ORDER  BY 1 , 2)
SELECT
        customer_id
    FROM
        yearly_spending
		GROUP BY 1
    HAVING bool_and(total_spending > prev_year_spending);

