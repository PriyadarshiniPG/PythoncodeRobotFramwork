"""The script establishes a VPN connection using an snx VPN client and keep it running
either for the given number of re-connections or permanently.
It is assumed an snx VPN client is installed.

Some notes to get it installed on CentOS:
  $ yum install -y glibc.i686 libX11.so.6 libpam.so.0 libstdc++.so.5
  $ sh snx_install_2013_07_26_800007075.sh

See also: https://wikiprojects.upc.biz/display/CTOBTV/Checkpoint+SNX+Client+Linux
"""
import sys
import os
import time
import argparse
import pexpect
import signal
from functools import partial


def connect(p_child, i, command, password):
    """Establish a VPN connection using an snx VPN client.

    :param p_child: an instance of pexpect.spawn().
    :param i: iteration number.
    :param command: an snx command, e.g. "snx -s lab-ssl.upcbroadband.com -u nsavelyeva01".
    :param password: a password string.

    :return: True if no pexpect timeout exception occurred otherwise False.

    :Example:

    $ snx -s lab-ssl.upcbroadband.com -u nsavelyeva01
    Check Point's Linux SNX
    build 800007075
    Please enter your password:

    SNX - connected.

    Session parameters:
    ===================
    Office Mode IP      : 172.17.134.48
    DNS Server          : 172.30.180.2
    Secondary DNS Server: 172.30.180.130
    DNS Suffix          : upclabs.com,win.upclabs.com,dtvupc.net
    Timeout             : 12 hours
    """
    try:
        print("%s: Trying to connect: %s" % (i, command))
        p_child.sendline(command)
        print("Waiting for password prompt")
        p_child.expect("Please enter your password:")
        print("OK, entering password")
        p_child.sendline(password)
        print("Waiting for the final output")
        p_child.expect("12 hours")
        print("CONNECTED")
    except pexpect.exceptions.TIMEOUT:
        return False
    return True


def disconnect(p_child, shell_prompt="#"):
    """Disconnect a VPN connection established by the snx VPN client (i.e. execute 'snx -d').

    :param p_child: an instance of pexpect.spawn().
    :param shell_prompt: a symbol of a shell prompt.

    :return: True if no pexpect timeout exception occurred otherwise False.

    :Example:

    $ snx -d  # assume VPN connection is established and an snx process is running.
    SNX - Disconnecting...
     done.

    $ snx -d  # assume VPN connection is not established and an snx process is not running.
    SNX - Disconnecting...
     failed: no snx process running.
    """
    try:
        print("Trying to disconnect:")
        p_child.sendline("snx -d")
        print("Waiting for shell prompt: %s" % shell_prompt)
        p_child.expect(shell_prompt)
        print("DISCONNECTED")
    except pexpect.exceptions.TIMEOUT:
        return False
    return True


def snx_vpn(p_child, command, password, count, interval):
    """Establish a VPN connection using an snx VPN client and keep it running
    either for the given number of re-connections or permanently.

    :param p_child: an instance of pexpect.spawn().
    :param command: an snx command, e.g. "snx -s lab-ssl.upcbroadband.com -u nsavelyeva01".
    :param password: a password string.
    :param count: a number of VPN client restarts, set 0 for infinite.
    :param interval: an interval in seconds between VPN client restarts.

    :return: nothing.
    """
    i = 0
    while True:
        if not disconnect(p_child):
            print("Failed to disconnect. Is SNX connection still active?")
            sys.exit(2)
        if i == count > 0:
            break
        # restart counts if reached maxint in infinite loop (Python 2)
        i = i + 1 if i < sys.maxint else 1
        if not connect(p_child, i, command, password):
            print("Failed to connect. Is SNX client already running or killed externally?")
            sys.exit(1)
        time.sleep(interval)
    print("DONE - reached the reconnection number (%s)." % count)
    disconnect(p_child)


def signal_handler(p_child, signal, frame):
    """A function to be called once an interrupting signal is caught."""
    print("Caught SIGNAL %s" % signal)
    disconnect(p_child)
    sys.exit(0)


def handle_signals(p_child):
    """A function to handle signals such as KeyboardInterrupt and process kill.
    Note: the signals SIGKILL and SIGSTOP cannot be caught, blocked, or ignored.
    """
    signals = []
    for sig in dir(signal):
        if sig.startswith("SIG"):
            try:
                signum = getattr(signal, sig)
                signal.signal(signum, partial(signal_handler, p_child))
            except (RuntimeError, ValueError):
                signals.append(sig)
    print("Note: the following signals will not be intercepted: %s." % ", ".join(signals))


if __name__ == "__main__":
    hlp = """Run SNX VPN client permanent or for the given number of times.
    Examples:
1. Recommended usage (permanent connection & long reconnection intervals):
   python snx_vpn_connect.py -u USER -p PASSWORD
2. Debug usage (permanent connection, short intervals):
   python snx_vpn_connect.py -u USER -p PASSWORD -d 5

Note: it is safe to do Ctrl+C,
      and even to 'kill -9' the process of this script as well as the snx process -
      because the script executes 'snx -d' once started and once the killing signal is intercepted.
"""
    parser = argparse.ArgumentParser(description=hlp, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-s", "--server", default="lab-ssl.upcbroadband.com", type=str,
                        help="The server to establish a VPN connection to.",
                        required=False)
    parser.add_argument("-u", "--user", type=str, default=os.environ.get('SNX_USER'), help="a VPN user name.", required=False)
    parser.add_argument("-p", "--password", type=str, default=os.environ.get('SNX_PWD'),
                        help="Password - will be visible in processes list!",
                        required=False)
    parser.add_argument("-d", "--duration", default=43080, type=int,
                        help="Duration in seconds between VPN client restarts\n" +
                             "(default: 43080 sec = 11h 58 min).",
                        required=False)
    parser.add_argument("-n", "--number", default=0, type=int,
                        help="Number of VPN client restarts, set 0 for infinite (default).",
                        required=False)

    args = vars(parser.parse_args())
    print("Settings loaded: %s.\nStarting...\n" % args)

    child = pexpect.spawn("/bin/bash")
    handle_signals(child)
    snx_cmd = "snx -s %s -u %s" % (args["server"], args["user"])
    snx_vpn(child, snx_cmd, args["password"], args["number"], args["duration"])
