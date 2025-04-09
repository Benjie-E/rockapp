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
        resource = event.get('resource') or ''
        path_params = event.get('pathParameters') or {}
        response = []
        cursor = connection.cursor()
        if resource == '/users':
            query = 'SELECT username, profile_picture_url FROM User'
            cursor.execute(query, )
        elif resource == '/users/{userId}':
            user_id = unquote(path_params.get('userId', ''))
            if not user_id:
                raise ValueError("User not Found")
            query = 'SELECT username, profile_picture_url FROM User WHERE user_id = %s'
            cursor.execute(query, (user_id,))      
        else:
            return {
                "statusCode": 404,
                "body": json.dumps("Resource not found")
            }
        rows = cursor.fetchall()
        
        if rows:
            users = [
                {
                    "username": row[0],
                    "profile_picture_url": row[1],
                }
                for row in rows
            ]
            response = users
        return {
                            "statusCode": 200,
                            "headers": {
                                "Content-Type": "application/json"
                            },
                "body": json.dumps(response)
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }


