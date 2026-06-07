import smtplib
import sys
from email.mime.text import MIMEText

email    = sys.argv[1]
password = sys.argv[2]
script   = sys.argv[3]
message  = sys.argv[4]
timestamp= sys.argv[5]
machine  = sys.argv[6]

body = f"""
DevOps Alert
─────────────────────────
Script  : {script}
Status  : {message}
Time    : {timestamp}
Machine : {machine}
"""

msg = MIMEText(body)
msg['Subject'] = f'DevOps Alert: {script}'
msg['From']    = email
msg['To']      = email

try:
    with smtplib.SMTP('smtp-mail.outlook.com', 587) as s:
        s.starttls()
        s.login(email, password)
        s.send_message(msg)
    print('Email sent ✅')
except Exception as e:
    print(f'Email failed: {e}')
