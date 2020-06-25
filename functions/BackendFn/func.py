import io
import os
import json
import oci
import cx_Oracle
from fdk import response
from base64 import b64decode, b64encode


def handler(ctx, data: io.BytesIO=None):
    my_error = "No Error"
    try:
        signer = oci.auth.signers.get_resource_principals_signer()
        stream_ocid = os.getenv('OCIFN_STREAM_OCID')
        stream_endpoint = os.getenv('OCIFN_STREAM_ENDPOINT')
        stream_client = oci.streaming.StreamClient({}, str("https://" + stream_endpoint), signer=signer)

        cursor_details = oci.streaming.models.CreateCursorDetails()
        cursor_details.partition = "0"
        cursor_details.type = "TRIM_HORIZON"
        cursor = stream_client.create_cursor(stream_ocid, cursor_details)
        r = stream_client.get_messages(stream_ocid, cursor.data.value)

        atp_user = os.getenv('OCIFN_ATP_USER')
        atp_password = os.getenv('OCIFN_ATP_PASSWORD')
        atp_alias = os.getenv('OCIFN_ATP_ALIAS')

        connection = cx_Oracle.connect(atp_user, atp_password, atp_alias)
        cursor = connection.cursor()

        if len(r.data):
            for msg in r.data:
                rs = cursor.execute("select iot_data_seq.nextval from dual")
                rows = rs.fetchone()
                new_iot_data_id = str(rows).replace(',','')
                new_iot_key = str(b64decode(msg.key).decode('utf-8'))
                new_iot_value = str(b64decode(msg.value).decode('utf-8'))
                rs = cursor.execute("insert into iot_data values ({},'{}','{}')".format(new_iot_data_id, new_iot_key, new_iot_value))
                rs = cursor.execute('COMMIT')

        cursor.close()
        connection.close()        

    except (Exception, ValueError) as ex:
        my_error = str(ex) 

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": "Insert into ATP (my_error={})".format(my_error)}),
        headers={"Content-Type": "application/json"}
    )
