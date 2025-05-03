import os
import json
import pymysql
from datetime import datetime

# RDS config from Lambda environment variables
rds_host     = os.environ['RDS_HOST']
rds_user     = os.environ['RDS_USER']
rds_password = os.environ['RDS_PASSWORD']
rds_db       = os.environ['RDS_NAME']

def handler(event, context):
    print("S3 Event Triggered")
    print(json.dumps(event))

    try:
        # Connect to MySQL
        conn = pymysql.connect(
            host=rds_host,
            user=rds_user,
            passwd=rds_password,
            db=rds_db,
            connect_timeout=5
        )
        print("Connected to RDS")

        with conn.cursor() as cursor:
            for record in event.get("Records", []):
                bucket = record["s3"]["bucket"]["name"]
                key    = record["s3"]["object"]["key"]
                ts     = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

                sql = "INSERT INTO uploads (filename, bucket, uploaded_at) VALUES (%s, %s, %s)"
                cursor.execute(sql, (key, bucket, ts))

        conn.commit()

    except Exception as e:
        print("Database error:", str(e))
        raise e

    finally:
        if 'conn' in locals():
            conn.close()

    return {
        "statusCode": 200,
        "body": json.dumps("Upload logged to RDS")
    }
