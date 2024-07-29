###
# Import CSV file with Tickets from osTicket into Zammad via API
###

#Copyright (C) 2024  Jesse Reppin - Github --> hashfunktion

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

import requests
import csv

# Konfiguration der Zammad-API
zammad_url = 'https://zammad.test.local/api/v1/tickets'
zammad_token = '<token>'

# Pfad zur Exportdatei
csv_file = '<file>'


def create_ticket(payload):
    response = requests.post(zammad_url, headers=headers, json=payload)
    if response.status_code == 201:
        print(f"Ticket erfolgreich erstellt: {response.json()['number']}")
    else:
        print(f"Fehler beim Erstellen des Tickets. Statuscode: {response.status_code} - {response.status_code} ")


def process_row(row):
    print(row)



with open(csv_file, 'r', newline='', encoding='utf-8') as file:
    csv_reader = csv.DictReader(file, delimiter=';')  # Benutzerdefiniertes Trennzeichen
    for row in csv_reader:
        #process_row(row)
        if row['staff'] == 'none':
            staffid = ''
        elif row['staff'] == 'alff':
            staffid = '11'
        elif row['staff'] == 'bert':
            staffid = '9'
        elif row['staff'] == 'vox':
            staffid = '874'
        elif row['staff'] == 'nurse':
            staffid = '966'
        elif row['staff'] == 'doc':
            staffid = '856'
        else:
            staffid = ''

        if row['department'] == '3':
            groupid = 'IT'
            zuordnung = 'IT'
        elif row['department'] == '4':
            groupid = 'Software'
            zuordnung = 'Software'
        else:
            groupid = 'IT'

        payload = {
            "title": row['ticket_number']+' - '+row['subject'],
            "group": groupid,
            "customer_id": "guess:"+row['customer_email'],
            "owner_id": staffid,
            "zuordnung": zuordnung,
            "osticket": row['id'],
            "state_id":2,
            "article": {
                "subject": row['subject'],
                "body": row['threads']+'<br> <br> <br> <i> ### <br> Ticket wurde importiert aus OSTicket <br>### </i>',
                "content_type": "text/html",
                "type": "phone",
                "internal": False,
                "sender": "Customer"
            }
        }
        headers = {
            'Authorization': f'Bearer {zammad_token}',
            'Content-Type': 'application/json',
            'X-On-Behalf-Of': row['customer_email']
        }
        create_ticket(payload)
