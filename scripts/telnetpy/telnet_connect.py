"""A script to check connectivity to host:port.
Usage: python telnet_connect.py <host> <port>
"""

import sys
import telnetlib
import socket


def check_connectivity(host, port, timeout=5):
    """A function to check if a port is open on a remote host."""
    telnet = telnetlib.Telnet()
    try:
        telnet.open(host, port, timeout)
        telnet.sock.close()
        return True
    except (socket.timeout, socket.gaierror, socket.error):
        pass
    return False


def get_localhost_str():
    host_ip = socket.getfqdn()
    host_name = socket.gethostbyname(host_ip)
    return '%s [%s]' % (host_name, host_ip)


if __name__ == '__main__':
    msg = 'Usage ERROR. Run: python telnet_connect.py <host> <port>'
    try:
        remote_host = sys.argv[1]
        remote_port = int(sys.argv[2])
        msg = 'OK' if check_connectivity(remote_host, remote_port) \
              else 'FAIL: Cannot connect from %s to %s on port %s.' % \
                   (get_localhost_str(), remote_host, remote_port)
    except (ValueError, IndexError):
        pass
    print(msg)
