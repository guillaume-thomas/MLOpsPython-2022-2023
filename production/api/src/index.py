import io
import logging

from fastapi import FastAPI, UploadFile
from mlopspython_inference.model_pillow import Model

app = FastAPI()
model = Model(logging, "./production/api/resources/final_model.h5")


@app.get("/health")
def health():
    return {"status": "OK"}


@app.post("/upload")
async def upload(file: UploadFile):
    file_readed = await file.read()
    file_bytes = io.BytesIO(file_readed)
    return model.execute(file_bytes)
