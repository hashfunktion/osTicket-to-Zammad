-- ##
-- Script to Export osTicket Tickets from SQL to CSV for further processing and import into Zammad via API
-- ##

-- Copyright (C) 2024  Jesse Reppin - Github --> hashfunktion

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

DROP FUNCTION clean_thread;
SET SESSION group_concat_max_len = 1000000000;

DELIMITER //
CREATE FUNCTION clean_thread(thread TEXT)
RETURNS TEXT
LANGUAGE SQL
DETERMINISTIC
BEGIN
#    SET thread = REPLACE(thread, 'br /', '');
#    SET thread = REPLACE(thread, '/p', '');
#    SET thread = REPLACE(thread, '<p class=\"MsoNormal\">', '');
#    SET thread = REPLACE(thread, 'div', '');
#    SET thread = REPLACE(thread, '–', '-');
#    SET thread = REPLACE(thread, '<p>', '');
#    SET thread = REPLACE(thread, '</p>', '');
#    SET thread = REPLACE(thread, ' ', '');
#    SET thread = REPLACE(thread, '<', '');
#    SET thread = REPLACE(thread, '>', '');
#    SET thread = REPLACE(thread, '“', '');
#    SET thread = REPLACE(thread, ';', ',');
#    SET thread = substring_index(thread,' ',1) LIKE '<[^>]+>';
#    SET thread = substring_index(thread,' ',1) LIKE '&nbsp;|&lt;|&gt;|&amp;|&quot;|&apos;|br /|p class="MsoNormal"|/p|div';

    RETURN thread;
END//
DELIMITER ;


SELECT
    'id' AS 'ID',
    'ticket_number' AS 'Ticket Number',
    'created_at' AS 'Created At',
    'updated_at' AS 'Updated At',
    'customer_email' AS 'Customer Email',
    'staff' AS 'Staff',
    'department' AS 'Group',
    'subject' AS 'Subject',
    'status' AS 'Status',
    'source' AS 'Source',
#    'attatchments' AS 'Attatchments',
    'threads' AS 'Threads'
UNION ALL
SELECT
    t.ticket_id AS 'id',
    t.number AS 'ticket_number',
    t.created AS 'created_at',
    t.updated AS 'updated_at',
    ue.address AS 'customer_email',
    IFNULL(st.username,'none') AS 'staff',
    t.dept_id AS 'department',
    td.subject AS 'subject',
    ts.name AS 'status',
    t.source AS 'source',
#   GROUP_CONCAT(TO_BASE64(fc.filedata) SEPARATOR ',') AS 'attatchments',
    GROUP_CONCAT(CONCAT_WS('#- Article start: <br>', clean_thread(tt.body)) ORDER BY tt.id SEPARATOR '<br> <br> #-#-#-#-# <br> <br>') AS 'tt.bodys'
FROM
    ost_ticket AS t
LEFT JOIN ost_ticket__cdata AS td ON t.ticket_id = td.ticket_id
LEFT JOIN ost_ticket_status AS ts ON t.status_id = ts.id
LEFT JOIN ost_user AS ou ON t.user_id = ou.id
LEFT JOIN ost_user_email AS ue ON t.user_id = ue.user_id
LEFT JOIN ost_ticket_thread AS tt ON t.ticket_id = tt.ticket_id
LEFT JOIN ost_staff AS st ON t.staff_id = st.staff_id
#LEFT JOIN ost_ticket_attachment AS ta ON t.ticket_id = ta.ticket_id
#LEFT JOIN ost_file AS fl ON ta.file_id = fl.id
#LEFT JOIN ost_file_chunk AS fc ON fl.id = fc.file_id

WHERE
    ts.state = 'open'
    AND
    t.created >= '2023-12-31 00:00:00'
#    AND
#    t.ticket_id = 11585
GROUP BY
    t.ticket_id
INTO OUTFILE '/share/Public/export050624_final-2.csv'
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

# REPLACE ALL HTML TAGS in VS CODE WITH <(?!p>|br|bra)[^>]+>
# </?(?!br|p\b)[^>]*>
# &lt; stands for the less-than sign:  <
# &gt; stands for the greater-than sign:  >
# &le; stands for the less-than or equals sign:  ≤
# &ge; stands for the greater-than or equals sign:  ≥
