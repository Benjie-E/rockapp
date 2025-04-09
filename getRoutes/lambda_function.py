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
        if 'id' in event and event['id'] is not None:
            location_id = event['id']
        elif event.get('pathParameters') and event['pathParameters'].get("locationId"):
            location_id = event['pathParameters'].get("locationId")
        else:
            raise KeyError
    except KeyError:
        print(f'Error: No Location specified')
        return {
            "statusCode": 400,  # Bad Request
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"message": "No Location specified!"})
        }
    try:
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()
        query = 'SELECT route_id, name, type_id, color, grade, description FROM Route WHERE location_id = %s'
        cursor.execute(query, (location_id,))
        rows = cursor.fetchall()
        
        if rows:
            routes = [
                {
                    "id": row[0],
                    "name": row[1],
                    "type": row[2],
                    "color": row[3],
                    "grade": row[4],
                    "description": row[5]
                }
                for row in rows
            ]
            response = {"routes": routes}
            return {
                    "statusCode": 200,
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "body": json.dumps(response)
                }
        else:
            return {
                "statusCode": 404,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"message": "No routes found for the specified location!"})
            }
    except Exception as e:
        # Handle any errors that occur
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

