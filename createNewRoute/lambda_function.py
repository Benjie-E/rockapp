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
        body = json.loads(event['body'])
        cursor = connection.cursor()
        
        name = unquote(body['name'])
        type_id = body['type_id']
        color = body['color']
        grade = body['grade']
        description = body['description']
        if event.get('pathParameters') and event['pathParameters'].get("locationId"):
            location_id = event['pathParameters'].get("locationId")
        else:
            location_id = 1
            
        query = """
                INSERT INTO Route (name, location_id, type_id, color, grade, description)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
        cursor.execute(query, (name, location_id, type_id, color, grade, description))      
        route_id = cursor.lastrowid
        connection.commit()

        created_object = {            
            'id': route_id,
            'name': name,
            #'location_id': location_id,
            'type': type_id,
            'color': color,
            'grade': grade,
            'description': description
        }
        # Confirm success with an appropriate message
        print(created_object)
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
            'statusCode': 404,
            'body': json.dumps(f'Error: {str(e)}')
        }
    finally:
        # Ensure the database connection is closed
        connection.close()
    