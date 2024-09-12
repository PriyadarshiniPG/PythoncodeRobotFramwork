"""
Module for holding libraries and classes responsible for making
SSH connection to STB
"""

import threading

from SSHLibrary.library import SSHLibrary
from scp import SCPClient, SCPException


class SSHClientException(RuntimeError):
    """SSHClientException"""


class SSHLibImpl(object):
    """Provides means to interact with a CPE via SSH"""
    _max_ssh_connections = 1024 * 1024
    _my_ssh_list = 'ssh_list'
    _my_next_id = 'next_id'
    _my_lock = 'lock'

    def __init__(self, ssh_lib):
        """Initialize class with specified ssh_lib"""
        self._ssh_lib = ssh_lib
        self._sessions = {}

    def open_connection(self, stb_ip):
        """
        Opens connection with given stb_ip and returns SSH object index
        :param stb_ip: STB IP Address
        """
        if stb_ip not in self._sessions:
            self._sessions[stb_ip] = {}
            self._sessions[stb_ip][self._my_ssh_list] = {}
            self._sessions[stb_ip][self._my_next_id] = 0
            self._sessions[stb_ip][self._my_lock] = threading.Lock()

        session = self._sessions[stb_ip]

        with session[self._my_lock]:
            if len(session[self._my_ssh_list]) >= self._max_ssh_connections:
                raise OverflowError()
            ssh = self._ssh_lib()
            ssh.open_connection(stb_ip)
            if session[self._my_next_id] < self._max_ssh_connections - 1:
                key = session[self._my_next_id]
                session[self._my_next_id] += 1
            else:
                for index in range(0, self._max_ssh_connections):
                    if index not in session[self._my_ssh_list]:
                        key = index
                        break

            session[self._my_ssh_list][key] = ssh
            return key

    def close_connection(self, stb_ip, ssh_idx):
        """
        Closes connection with SSH object index
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        """
        session = self._sessions[stb_ip]
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        try:
            ssh.close_connection()
        except RuntimeError:
            raise SSHClientException("No open connection")
        with session[self._my_lock]:
            del session[self._my_ssh_list][ssh_idx]

    def login(self, stb_ip, ssh_idx, username="", password="", build_type=""):
        """
        Login to connected stb with ssh index. If username
        and password is not provided, logs in with default
        username as root and empty password
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        :param username: login
        :param password: password
        :param build_type: STB firmware type, i.e. DBG
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        if username == "" and password == "":
            details_provided = False
            username = "root"
            if not build_type:
                build_provided = False
            else:
                build_provided = True
                if build_type != "DBG":
                    password = "TdBdTncY"
        else:
            details_provided = True
        try:
            ssh.login(username, password)
        except RuntimeError:
            if details_provided is False and build_provided is False:
                username = "root"
                password = "TdBdTncY"
                ssh.login(username, password)
            else:
                conn = ssh.get_connection()
                msg = 'Authentication failed for user: %s and host %s' \
                      % (username, conn.host)
                raise SSHClientException(msg)

    def execute_command(self, stb_ip, ssh_idx, command, timeout=60):
        """
        Executes given command on stb returns result of execution
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        :param command: command to be executed
        :param timeout: timeout in seconds
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        try:
            return ssh.execute_command(command, timeout=timeout)
        except (RuntimeError, AssertionError):
            conn = ssh.get_connection()
            msg = 'Command failed: %s and host %s' \
                  % (command, conn.host)
            raise SSHClientException(msg)

    def start_command(self, stb_ip, ssh_idx, command):
        """
        Starts executing given command on stb
        To have result use read_command_output
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        :param command: command to be executed
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        try:
            ssh.start_command(command)
        except (RuntimeError, AssertionError):
            conn = ssh.get_connection()
            msg = 'Command failed: %s and host %s' \
                  % (command, conn.host)
            raise SSHClientException(msg)

    def read_command_output(self, stb_ip, ssh_idx):
        """
        Reads output of last executed command
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        return ssh.read_command_output()

    def get(self, stb_ip, ssh_idx, remote_path,
            local_path='', recursive=False):
        """
        Downloads file(s) from the remote machine to the local machine.
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        :param remote_path: path used for downloading from
        :param local_path: path used for downloading to
        :param recursive: whether to download files recursively
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        try:
            with SCPClient(ssh.current.client.get_transport()) as scp:
                scp.get(remote_path, local_path, recursive)
        except (RuntimeError, AssertionError, SCPException):
            conn = ssh.get_connection()
            msg = 'Get file failed from %s to %s on host %s' \
                  % (remote_path, local_path, conn.host)
            raise SSHClientException(msg)

    def put(self, stb_ip, ssh_idx, files, remote_path='.', recursive=False):
        """
        Uploads file(s) from the local machine to the remote machine.
        :param stb_ip: STB IP Address
        :param ssh_idx: SSH session index
        :param files: files to upload
        :param remote_path: path used for uploading to
        :param recursive: whether to download files recursively
        """
        ssh = self._check_and_get_ssh(stb_ip, ssh_idx)
        try:
            with SCPClient(ssh.current.client.get_transport()) as scp:
                scp.put(files, remote_path, recursive)
        except (RuntimeError, AssertionError, SCPException):
            conn = ssh.get_connection()
            msg = 'Put file failed from %s to %s on host %s' \
                  % (files, remote_path, conn.host)
            raise SSHClientException(msg)

    def _check_and_get_ssh(self, stb_ip, ssh_idx):
        """Function checking if there is ssh connection with given index"""
        session = self._sessions[stb_ip]
        ssh_idx = int(ssh_idx)
        with session[self._my_lock]:
            ssh = session[self._my_ssh_list].get(ssh_idx)
        if not ssh:
            raise AttributeError('No ssh connection')
        return ssh


class SSHLib(SSHLibImpl):
    """SSH library wrapper"""

    def __init__(self):
        SSHLibImpl.__init__(self, SSHLibrary)
