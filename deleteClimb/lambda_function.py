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
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()
        
        current_user_id = event.get('requestContext', {}).get('authorizer', {}).get('principalId')

        if event.get('pathParameters') and event['pathParameters'].get("climbId"):
            climb_id = unquote(event['pathParameters'].get("climbId"))
        else:
            raise KeyError 

        if not climb_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Climb ID is required"})
            }

        check_query = "SELECT COUNT(*) FROM Climb WHERE climb_id = %s"
        cursor.execute(check_query, (climb_id,))
        result = cursor.fetchone()

        if result[0] == 0:
            return {
                "statusCode": 404,
                "body": json.dumps({"message": "Climb not found"})
            }

        check_query = "SELECT COUNT(*) FROM Climb JOIN Session ON Climb.session_id = Session.session_id WHERE climb_id = %s AND user_id = %s;"
        cursor.execute(check_query, (climb_id, current_user_id,))
        result = cursor.fetchone()

        if result[0] == 0:
            return {
                "statusCode": 403,
                "body": json.dumps({"message": "User not authorized"})
            }

        delete_query = "DELETE FROM Climb WHERE climb_id = %s"
        cursor.execute(delete_query, (climb_id,))
        connection.commit()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Climb deleted successfully"})
        }

    except KeyError:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Climb ID missing in request"})
        }
    except pymysql.MySQLError as e:
        print(f"MySQL error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Database operation failed"})
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Error: {str(e)}"})
        }
    finally:
        if connection:
            connection.close()
