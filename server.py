# server.py
import os
from livekit import api

def generate_token():
    token = api.AccessToken(
        os.getenv('LIVEKIT_API_KEY'),
        os.getenv('LIVEKIT_API_SECRET')
    ).with_identity("dgertsch") \
     .with_name("Dana") \
     .with_grants(api.VideoGrants(
         room_join=True,
         room="NN0G-room",
     ))
    return token.to_jwt()

if __name__ == "__main__":
    jwt_token = generate_token()
    print(jwt_token)
