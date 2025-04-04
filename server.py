# server.py
import os
from livekit import api

def generate_token():
    token = api.AccessToken(
        os.getenv('LIVEKIT_API_KEY'),
        os.getenv('LIVEKIT_API_SECRET')
    ).with_identity("yourId") \
     .with_name("yourName") \
     .with_grants(api.VideoGrants(
         room_join=True,
         room="YourRoom",
     ))
    return token.to_jwt()

if __name__ == "__main__":
    jwt_token = generate_token()
    print(jwt_token)
