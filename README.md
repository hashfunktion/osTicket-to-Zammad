# osTicket-to-Zammad
For the migration of an old osTicket without API to Zammad.

The files were written for our use and our requirements. The version we found did not yet have API access, so the export had to be done via SQL.

It is important for the import that all users in Zammad have an agent role at that moment in order to be able to set the owner of the ticket when creating it in Zammad. After the import all Customers can be Customers only.

Notes:
- All articles from osTicket are summarised in one article in Zammad.
- No attachments are transferred, only a reference to the ticket in osTicket via Zammad Object(link)


Change as required:
- Mapping User osTicket / UserId Zammad
- State mapping
- Adress of the osTicket instanz
- API Adress of Zammad
- Zammad Ticket Object for OSTicket Referenz Link to original Ticket


1. Export a CSV file with the Tickets from OSTicket
2. Replace html tags etc. with regex
``````
REPLACE ALL HTML TAGS in VS CODE WITH
<(?!p>|br|bra)[^>]+>
</?(?!br|p\b)[^>]*>
&lt; stands for the less-than sign:  <
&gt; stands for the greater-than sign:  >
&le; stands for the less-than or equals sign:  ≤
&ge; stands for the greater-than or equals sign:  ≥
``````
4. Edit Mappings in the Python Script (Agents, Groups)
5. Import Tickets from CSV file with the Python Script via Zammad API
