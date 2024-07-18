# osTicket-to-Zammad
For the migration of an old osTicket without API to Zammad.

The files were written for our use and our requirements. The version we found did not yet have API access, so the export had to be done via SQL.

It is important for the import that all users in Zammad have an agent role at that moment in order to be able to set the owner of the ticket when creating it in Zammad.

Notes:
- All articles from osTicket are summarised in one article in Zammad.
- No attachments are transferred, only a reference to the ticket in osTicket (link)


Change as required:
- Mapping User osTicket / UserId Zammad
- State mapping
- Adress of the osTicket instanz
- API Adress of Zammad

Translated with www.DeepL.com/Translator (free version)
