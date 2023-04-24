from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, validator
from hashlib import sha3_512
from os import system

app = FastAPI()

class DeploySignal(BaseModel):
  password: str
  image: str
  @validator('password')
  def check_password(cls, passw):
    if sha3_512(passw.encode()).hexdigest() != '98a55dc9284a94372fa0e018d8459e314f207458f8512d3e37270d9b7f62637123287168a6dd699ea5c378553d68556f05bdd663a1831e0f8abc3580e2989f32':
      raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

@app.get('/')
async def hello():
  return 'Hello'

@app.post('/deploy')
async def deploy(item: DeploySignal):
  system('/usr/bin/docker rm -f html')
  system(f'/usr/bin/docker image rm -f {item.image}')
  system(f'/usr/bin/docker run -d --name html -p 127.0.0.1:77:80 -v /etc/ssl:/etc/ssl {item.image}')
  return item.image

if __name__ == '__main__':
  from uvicorn import run
  run(app=app)
