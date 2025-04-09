import pymysql
import json
import credentials
from urllib.parse import unquote

username = 'admin'
database_name = 'rockapp'
endpoint = "rockapp-3.cj6s4a6muuw2.us-east-1.rds.amazonaws.com"
password = credentials.get_password("rds!db-836caeea-61cc-4a95-a9e0-016040f381e2")

def lambda_handler(event, context):
    try:
        # Retrieve session ID from the event or path parameters
        if 'id' in event and event['id'] is not None:
            session_id = event['id']
        elif event.get('pathParameters') and event['pathParameters'].get("sessionId"):
            session_id = unquote(event['pathParameters'].get("sessionId"))
        else:
            raise KeyError  # No session ID found in the event or path parameters
    except KeyError:
        print('Error: No Session specified')
        return {
            "statusCode": 400,  # Bad Request
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"message": "No Session specified!"})
        }
    except Exception as e:
        print(f"Exception: {str(e)}")
        return {
            "statusCode": 500,  # Internal Server Error
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"message": f"Error: {str(e)}"})
        }

    try:
        # Establish database connection
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()
        query = 'SELECT Climb.climb_id, Climb.attempts, Climb.sent, Climb.flashed, Climb.comment, Route.name, Route.color, Route.grade, Route.description, ClimbType.type_desc AS type FROM Climb JOIN Route ON Climb.route_id = Route.route_id JOIN ClimbType ON Route.type_id = ClimbType.type_id WHERE Climb.session_id = %s'
        #query = 'SELECT climb_id, route_id, comment FROM Climb WHERE session_id = %s'
        cursor.execute(query, (session_id,))
        rows = cursor.fetchall()

        if rows:
            climbs = [
                {
                    "id": row[0],
                    "attempts": row[1],
                    "sent": bool(row[2]),
                    "flashed": bool(row[3]),
                    "comment": row[4],
                    "name": row[5],
                    "color": row[6],
                    "grade": row[7],
                    "description": row[8],
                    "type": row[9]
                }
                for row in rows
            ]
            response = {"climbs" : climbs}
            return {
                "statusCode": 200,  # OK
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps(response)
            }
        else:
            #response = {"message": "No climbs found for the specified session"}
            response = {"climbs" : []}
            return {
                "statusCode": 200,  # Not Found
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps(response)
            }
    except pymysql.MySQLError as e:
        print(f"MySQL error: {str(e)}")
        return {
            "statusCode": 500,  # Internal Server Error
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"message": "Database connection failed"})
        }
    finally:
        if connection:
            connection.close()  # Ensure the connection is closed after use
