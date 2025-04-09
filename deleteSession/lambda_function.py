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
        # Establish database connection
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()
        session_id = event['pathParameters'].get("sessionId") or 0

        if not session_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Session ID is required"})
            }

        check_query = "SELECT COUNT(*) FROM Session WHERE session_id = %s"
        cursor.execute(check_query, (session_id,))
        result = cursor.fetchone()

        if result[0] == 0:
            return {
                "statusCode": 404, 
                "body": json.dumps({"message": "Session not found"})
            }

        delete_query = "DELETE FROM Session WHERE session_id = %s"
        cursor.execute(delete_query, (session_id,))
        connection.commit()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Session deleted successfully"})
        }

    except KeyError:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Session ID missing in request"})
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
