from flask import Flask, render_template, url_for, request
import os
import socket
import cx_Oracle
import json

app = Flask(__name__)

@app.route('/')
def oracleatpcheck():
     os.environ['TNS_ADMIN'] = '/usr/lib/oracle/18.3/client64/lib/network/admin'
     connection = cx_Oracle.connect('fkuser', 'atp_password', 'fkatpdb5_medium')
     cursor = connection.cursor()
     rs = cursor.execute("select * from iot_data order by iot_data_id")
     rows = rs.fetchall()
     json_output = json.dumps(rows)
     cursor.close()
     connection.close()  
     return render_template('index.html', json_output=json_output)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)