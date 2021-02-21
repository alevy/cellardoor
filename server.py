from http.server import *
import os

class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write("Ok".encode("utf-8"))

    def do_POST(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        os.system("gpioset -b --mode=time --sec=1 0 26=0")
        self.wfile.write("Ok".encode("utf-8"))

def run(port=8000, server_class=HTTPServer, handler_class=MyHandler):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()

run()
if __name__ == '__main__':
    from sys import argv
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
