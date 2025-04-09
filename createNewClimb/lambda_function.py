import pymysql
import json
import credentials
from urllib.parse import unquote
username = 'admin'
database_name = 'rockapp'
endpoint = "rockapp-3.cj6s4a6muuw2.us-east-1.rds.amazonaws.com"
password = credentials.get_password("rds!db-836caeea-61cc-4a95-a9e0-016040f381e2")
# Retrieve the secret value before attempting to connect
# Create the database connection only after the secret is verified
def lambda_handler(event, context):
    connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
    try:    
        print(event['body'])
        body = json.loads(event['body'])
        cursor = connection.cursor()
        session_id = body['session_id']
        route_id = body['route_id']
        comment = body['comment'] #fix
        # Execute the insert query
        query = "INSERT INTO Climb (session_id, route_id, comment) VALUES (%s, %s, %s)"
        cursor.execute(query, (session_id, route_id, comment))
        climb_id = cursor.lastrowid
        # Commit the transaction
        connection.commit()

        created_object = {
            "climb_id": climb_id,
            "session_id": session_id,
            "route_id": route_id,
            "comment": comment
        }
        # Confirm success with an appropriate message
        return {
            'statusCode': 201,
            'body': json.dumps({
                "message": "Insert successful",
                "session": created_object
            })
        }
    except Exception as e:
        # Handle any errors that occur
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
    finally:
        # Ensure the database connection is closed
        connection.close()
    