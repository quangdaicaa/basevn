from fastapi import FastAPI
from pydantic import BaseModel
from os import system
from typing import Optional, Any


class Github_Ping(BaseModel):
  repository  : Optional[dict]
  hook        : Optional[dict]
  zen         : Optional[str]
  hook_id     : Optional[int]
  sender      : Optional[dict]

class Github_Push(BaseModel):
  repository  : dict
  ref         : Optional[str]
  before      : Optional[str]
  after       : Optional[str]
  pusher      : Optional[dict]
  created     : Optional[bool]
  deleted     : Optional[bool]
  forced      : Optional[bool]
  base_ref    : Optional[Any]
  compare     : Optional[str]
  commits     : Optional[list]
  head_commit : Optional[dict]

app = FastAPI()


@app.get('/')
async def hello():
  return 'Hello'

@app.post('/hook')
async def hook_github(data: Github_Push):
  name = data.repository['name']
  url = data.repository['clone_url']
  system('/usr/bin/rm -rf /code/ci')
  system('/usr/bin/mkdir -p /code/ci')
  open('/code/ci/Dockerfile', 'w').write(f'''
FROM quangdaicaa/html:baseimage
ADD html /usr/share/nginx/html
''')
  open('/code/ci/run.sh', 'w').write(f'''
/usr/bin/git clone {url} /code/ci/{name}
/usr/bin/mv /code/ci/{name} /code/ci/html
cd /code/ci
/usr/bin/docker build -t quangdaicaa/html:current .
/usr/bin/docker push quangdaicaa/html:current
/usr/bin/curl -kX POST https://quang.pro:666/deploy \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{{
  "password": "0i9bYtSy3M08bN3C",
  "image": "quangdaicaa/html:current"
}}'
''')
  system('/usr/bin/chmod +x /code/ci/run.sh')
  system('/code/ci/run.sh')
  return data.dict()

if __name__ == '__main__':
  from uvicorn import run
  run(app=app)
