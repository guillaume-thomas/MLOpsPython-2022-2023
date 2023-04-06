import uvicorn

from production.api.src import index

if __name__ == "__main__":
    uvicorn.run(index.app, host="0.0.0.0", port=8080)