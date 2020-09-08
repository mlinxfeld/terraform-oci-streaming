from flask import Flask, render_template, url_for, request
import os
import socket
import cx_Oracle
import json

app = Flask(__name__)

@app.route('/')
def oracleatpcheck():
 
     os.environ['TNS_ADMIN'] = '/usr/lib/oracle/18.3/client64/lib/network/admin'
     connection = cx_Oracle.connect("atp_user", "atp_password", "atp_alias")
     cursor = connection.cursor()
     rs = cursor.execute("select id, iot_key, iot_data from iot_data order by id")
     rows = rs.fetchall()
     json_output = json.dumps(rows) 

     cursor.close()
     connection.close()  

     return render_template('index.html', json_output=json_output, apigw_endpoint_url="apigw_endpoint_URL")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)