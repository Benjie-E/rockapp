import pymysql
import json
import credentials
from urllib.parse import unquote

username = 'admin'
database_name = 'rockapp'
endpoint = "rockapp-3.cj6s4a6muuw2.us-east-1.rds.amazonaws.com"
password = credentials.get_password("rds!db-836caeea-61cc-4a95-a9e0-016040f381e2")

def lambda_handler(event, context):
    connection = None
    try:
        current_user_id = event.get('requestContext', {}).get('authorizer', {}).get('principalId')
        path_params = event.get('pathParameters') or {}
        resource = event.get('resource')
        print(current_user_id)
        connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=database_name)
        cursor = connection.cursor()

        if resource == '/me/sessions':
            cursor.execute('SELECT user_id, session_id, date, location, comment FROM Session WHERE user_id = %s', (current_user_id,))
            rows = cursor.fetchall()

        elif resource == '/users/{userId}/sessions':
            target_user_id = unquote(path_params.get('userId', ''))
            cursor.execute(
                'SELECT 1 FROM SharingPermissions WHERE SharedWith = %s AND sharedBy = %s',
                (current_user_id, target_user_id)
            )
            if not cursor.fetchone():
                return {
                    "statusCode": 403,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps({"message": "You don't have permission to view this user's sessions."})
                }
            cursor.execute('SELECT user_id, session_id, date, location, comment FROM Session WHERE user_id = %s', (target_user_id,))
            rows = cursor.fetchall()

        elif resource == '/sessions/{sessionId}':
            session_id = unquote(path_params.get('sessionId', ''))
            cursor.execute('SELECT user_id, session_id, date, location, comment FROM Session WHERE session_id = %s', (session_id,))
            row = cursor.fetchone()
            if not row:
                return {
                    "statusCode": 404,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps({"message": "Session not found"})
                }

            session_owner_id = row[0]
            if session_owner_id != current_user_id:
                cursor.execute(
                    'SELECT 1 FROM SharingPermissions WHERE SharedWith = %s AND sharedBy = %s',
                    (current_user_id, session_owner_id)
                )
                if not cursor.fetchone():
                    return {
                        "statusCode": 403,
                        "headers": {"Content-Type": "application/json"},
                        "body": json.dumps({"message": "You don't have permission to view this session."})
                    }

            session_data = {
                "userId": row[0],
                "id": row[1],
                "date": str(row[2]),
                "location": row[3],
                "comment": row[4]
            }
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"session": session_data})
            }
        elif resource == '/sessions':
            cursor.execute('''
                SELECT s.user_id, s.session_id, s.date, s.location, s.comment
                FROM Session s
                JOIN SharingPermissions sp ON s.user_id = sp.sharedBy
                WHERE sp.SharedWith = %s
            ''', (current_user_id,))
            rows = cursor.fetchall()
            print(rows)
            print(current_user_id)
        else:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"message": "Unsupported route."})
            }

        sessions = [
            {
                "userId": row[0],
                "id": row[1],
                "date": str(row[2]),
                "location": row[3],
                "comment": row[4]
            }
            for row in rows
        ]

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"sessions": sessions})
        }

    except pymysql.MySQLError as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": "Database error occurred"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": f"Unexpected error: {str(e)}"})
        }

    finally:
        if connection:
            connection.close()
