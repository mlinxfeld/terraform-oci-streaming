import io
import os
import json
import oci
import cx_Oracle
from fdk import response


def handler(ctx, data: io.BytesIO=None):
    
    signer = oci.auth.signers.get_resource_principals_signer()

    stream_ocid = os.getenv('OCIFN_STREAM_OCID')
    stream_endpoint = os.getenv('OCIFN_STREAM_ENDPOINT')
    stream_client = oci.streaming.StreamClient({}, stream_endpoint, signer=signer)

    cursor_details = oci.streaming.models.CreateCursorDetails()
    cursor_details.partition = "0"
    cursor_details.type = "TRIM_HORIZON"
    cursor = stream_client.create_cursor(stream_ocid, cursor_details)
    r = stream_client.get_messages(stream_ocid, cursor.data.value)

    if len(r.data):
        for msg in r.data:
            insert_iot_data_into_atp(b64decode(msg.value).decode('utf-8'))

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": "Insert into ATP done!"}),
        headers={"Content-Type": "application/json"}
    )

def insert_iot_data_into_atp(iot_data1):
    
    try: 
        atp_user = os.getenv('OCIFN_ATP_USER')
        atp_password = os.getenv('OCIFN_ATP_PASSWORD')
        atp_alias = os.getenv('OCIFN_ATP_ALIAS')

        connection = cx_Oracle.connect(atp_user, atp_password, atp_alias)
        cursor = connection.cursor()
        rs = cursor.execute("select iot_data_seq.nextval from dual")
        rows = rs.fetchone()
        new_cust_id = str(rows).replace(',','')
        rs = cursor.execute("insert into iot_data values ({},'{}')".format(new_iot_data_id, iot_data1))
        rs = cursor.execute('COMMIT')
        cursor.close()
        connection.close()
    except Exception as e:
        return {"Result": "Not connected to ATP! Exception: {}".format(str(e)),}

    return {"Result": "Row inserted (iot_data_id={}, iot_data1={})".format(new_iot_data_id, iot_data1),}