import pymysql
import json
import credentials
username = 'admin'
database_name = 'rockapp'
endpoint = "rockapp-3.cj6s4a6muuw2.us-east-1.rds.amazonaws.com"
password = credentials.get_password("rds!db-836caeea-61cc-4a95-a9e0-016040f381e2")
# Retrieve the secret value before attempting to connect
# Create the database connection only after the secret is verified
def lambda_handler(event, context):
    try:
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()
        query = 'SELECT * FROM Location'
        cursor.execute(query, )
        rows = cursor.fetchall()
        if rows:
            locations = [
                {
                    "id": row[0],
                    "name": row[1],
                    "address": row[2],
                    "description": row[3],
                }
                for row in rows
            ]
            response = locations
        return {
                            "statusCode": 200,
                            "headers": {
                                "Content-Type": "application/json"
                            },
                "body": json.dumps(response)
            }
    except Exception as e:
        # Handle any errors that occur
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

