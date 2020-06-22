import io
import os
import json
import oci
import cx_Oracle
from fdk import response


def handler(ctx, data: io.BytesIO=None):
    iot_data1 = "999999999"
    stream_ocid = os.getenv('OCIFN_STREAM_OCID')
    stream_endpoint = os.getenv('OCIFN_STREAM_ENDPOINT')
    
    try:
        body = json.loads(data.getvalue())
        iot_data1 = str(body.get("iot_data1"))
    except (Exception, ValueError) as ex:
        print(str(ex))

    if ctx.Method() == "POST":
        signer = oci.auth.signers.get_resource_principals_signer()
        stream_client = oci.streaming.StreamClient({}, stream_endpoint, signer=signer)
        msg_entry = oci.streaming.models.PutMessagesDetailsEntry()
        msg_entry.value = b64encode(bytes(iot_data1, 'utf-8')).decode('utf-8')
        msgs = oci.streaming.models.PutMessagesDetails()
        msgs.messages = [msg_entry]
        stream_client.put_messages(stream_ocid, msgs)

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": "Message sent to the OCI Stream (iot_data1={}, stream_id={})".format(iot_data1, stream_ocid)}),
        headers={"Content-Type": "application/json"}
    )
