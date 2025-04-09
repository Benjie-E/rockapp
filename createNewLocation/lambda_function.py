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
    connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
    try:
        cursor = connection.cursor()
        print(event)
        body = json.loads(event['body'])
        location_name = body['name']
        address = body['address']
        description = body['description']
        # Execute the insert query
        query = 'INSERT INTO Location (Name, Address, Description) VALUES (%s, %s, %s)'
        cursor.execute(query, (location_name, address, description))
        
        location_id = cursor.lastrowid
        # Commit the transaction
        connection.commit()

        created_object = {
            "id": location_id,
            "name": location_name,
            "address": address,
            "description": description
        }

        # Confirm success with an appropriate message
        return {
            'statusCode': 201,
            'body': json.dumps({
                "message": "Insert successful",
                "location": created_object
            })
        }
    except Exception as e:
        # Handle any errors that occur
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
    finally:
        # Ensure the database connection is closed
        connection.close()
