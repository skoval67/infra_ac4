from os import environ
from flask import Flask

app = Flask(__name__)
key = environ.get('KEY_NAME')

@app.route("/ping")
def hello():
    return "pong"

@app.route("/healthz")
def health():
    return "ok"

@app.route("/")
def main():
    return key

if __name__ == '__main__':
    app.run("0.0.0.0", 8888)
