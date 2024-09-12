"""Module contains common functions used by keywords.py and test_keywords.py."""
# pylint: disable=W0102
# pylint: disable=too-many-locals
# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
import os
import sys
import inspect
import re
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
lib_dir = os.path.dirname(currentdir)
import socket
import paramiko
import pysftp
from pysftp.exceptions import ConnectionException, CredentialException
from paramiko.ssh_exception import  SSHException
from robot.libraries.BuiltIn import BuiltIn
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
from Libraries.general.keywords import Keywords as general
easy_debug = general.easy_debug
general = general()


class Tools(object):
    """A class to store all useful tools what will be used in helpers and keywords files"""

    def __init__(self, conf):
        self.conf = conf
        self.workers_list = []
        self.trancoder_workers_list = []

        for i in range(0, len(self.conf["AIRFLOW_WORKERS"])):
            self.workers_list.append(
                self.conf["AIRFLOW_WORKERS"][i]["host"]
            )

        for i in range(0, len(self.conf["TRANSCODER_WORKERS"])):
            self.trancoder_workers_list.append(
                self.conf["TRANSCODER_WORKERS"][i]["host"]
            )

    @easy_debug
    def run_ssh_cmd(self, host, port, username, password, command, timeout=15, get_pty=False,
                    return_connect_only=False):
        """A function to execute an arbitrary command on the remote host through SSH.

        :param host: an IP address of the host.
        :param port: a port number to connect via SSH (usually 22).
        :param username: a user name to login via SSH.
        :param password: a password to login via SSH.
        :param command: a string - the command to be executed on the remote host.
        :param timeout: timeout in seconds.

        :return: a tuple of strings: stdout and stderr returned by the given command.

        :Example:

        >>>run_ssh_cmd(e2e_obj.conf["ASSET_GENERATOR"]["host"],
        ...    e2e_obj.conf["ASSET_GENERATOR"]["port"],
        ...    e2e_obj.conf["ASSET_GENERATOR"]["user"], e2e_obj.conf["ASSET_GENERATOR"]["password"],
        ...    "whoami")
        ('og\n', '')
        """
        if not isinstance(timeout, int):
            timeout = int(timeout)
        if not isinstance(port, int):
            try:
                port = int(port)
            except ValueError:
                raise Exception("Unexpected type for 'port' variable: %s" % type(port))

        if "USE_JUMP_SERVER" in os.environ:
            if host in self.workers_list or host in self.trancoder_workers_list:
                stdout, stderr = self.run_ssh_command_through_jump_server(
                    host, port, username, password, command, timeout=timeout, get_pty=get_pty,
                    return_connect_only=return_connect_only)
            else:
                stdout, stderr = self.run_ssh_command_itself(
                    host, port, username, password, command, timeout=timeout, get_pty=get_pty,
                    return_connect_only=return_connect_only)
        else:
            stdout, stderr = self.run_ssh_command_itself(
                host, port, username, password, command, timeout=timeout, get_pty=get_pty,
                return_connect_only=return_connect_only)
        stdout = general.insure_text(stdout)
        stderr = general.insure_text(stderr)
        return stdout, stderr

    @easy_debug
    def run_ssh_command_through_jump_server(self, host, port, username,
                                            password, command, timeout=15, get_pty=False,
                                            return_connect_only=False,
                                            attempts=0, catched_exceptions=[]):
        """A method to run ssh command on target host, but to get there
        use additional (jump) server. Like:
        ssh to jump server => ssh to target server => command

        :param host: IP or hostname of target host, where command will be run
        :param port: port of target host, where command will be run
        :param username: username to be used to make ssh connect to target host
        :param password: password to be used to make ssh connect to target host
        :param command: command itself, string
        :param timeout: ssh connection timeout
        :return: stdout, stderr
        """
        stdout_result, stderr_result = "", ""
        clean_command = ""
        exceptions = []
        if host in self.workers_list:
            jump_server_name = "AIRFLOW_WORKERS_JUMP_SERVER"
        elif host in self.trancoder_workers_list:
            jump_server_name = "TRANSCODER_WORKERS_JUMP_SERVER"
        else:
            raise Exception("Unexpected host (%s) for using as a jump server" % host)

        jump_server_ip = self.conf[jump_server_name]["host"]
        jump_server_port = self.conf[jump_server_name]["port"]
        jump_server_user_name = self.conf[jump_server_name]["user"]
        jump_server_password = self.conf[jump_server_name]["password"]
        destination_ip = host
        dest_addr = (destination_ip, port)
        exc_obj = None

        if attempts < 10:
            try:
                local_ip = socket.gethostbyname(socket.gethostname())
                local_addr = (local_ip, 22)

                ssh_to_jump_server = paramiko.SSHClient()
                ssh_to_destination_server = paramiko.SSHClient()
                ssh_to_jump_server.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh_to_jump_server.connect(
                    hostname=jump_server_ip,
                    port=jump_server_port,
                    username=jump_server_user_name,
                    password=jump_server_password,
                    timeout=timeout
                )
                connect_to_jump_server = True
            except (socket.gaierror, socket.error, EOFError, SSHException,
                    AttributeError, TypeError) as err:
                exceptions.append(" SSH Connection from %s (%s) to %s host failed: %s" %
                                  (socket.gethostname(),
                                   socket.gethostbyname(socket.getfqdn()), jump_server_ip, err))
                connect_to_jump_server = False
                exc_obj = sys.exc_info()[1]    # pylint: disable=unused-variable

            if connect_to_jump_server:
                exceptions = []
                exc_obj = None
                try:
                    # Get underlying Transport object for this SSH connection.
                    # This will be used to perform lower-level tasks, to open new kinds of channel.
                    ssh_transport = ssh_to_jump_server.get_transport()
                    ssh_channel_using_jump_server = ssh_transport.open_channel(
                        "direct-tcpip", dest_addr, local_addr)
                    ssh_to_destination_server.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                    ssh_to_destination_server.connect(
                        destination_ip,
                        username=username,
                        password=password,
                        sock=ssh_channel_using_jump_server,
                        timeout=timeout,
                        allow_agent=False,
                        look_for_keys=False
                    )
                    if return_connect_only:
                        return ssh_to_destination_server, ""

                    connect_to_destination_server = True
                except (socket.gaierror, socket.error, EOFError,
                        SSHException, AttributeError, TypeError) as err:
                    exceptions.append(" SSH Connection from %s (%s) to %s host failed: %s" % \
                                      (socket.gethostname(),
                                       socket.gethostbyname(socket.getfqdn()), destination_ip, err))
                    connect_to_destination_server = False

                if connect_to_destination_server:
                    try:
                        path_string = "/sbin/:/usr/local/bin:/usr/bin:/usr/local/sbin:" \
                                      "/usr/sbin:" \
                                      "/home/airflowlogin/.local/bin:/home/airflowlogin/bin"
                        clean_command = str(command).strip()
                        full_command = "export PATH=$PATH:%s && %s" % (path_string, clean_command)
                        stdout, stderr = ssh_to_destination_server.exec_command(
                            command=full_command,
                            get_pty=get_pty
                        )[1:]
                        stdout_result = stdout.read().decode("utf-8").strip()
                        stderr_result += stderr.read().decode("utf-8").strip()
                    except (socket.gaierror, socket.error, EOFError,
                            SSHException, AttributeError, TypeError) as err:
                        exceptions.append(" SSH command %s on %s failed: %s" % \
                                         (clean_command, destination_ip, err))
                ssh_to_destination_server.close()
            ssh_to_jump_server.close()

            # BuiltIn().log_to_console("\n\command:\n%s\n\n\n\n" % clean_command)
            # BuiltIn().log_to_console("\n\nstdout_result:\n%s\n\n\n\n" % stdout_result)
            # BuiltIn().log_to_console("\n\nstderr_result:\n%s\n\n\n\n" % stderr_result)

            if exceptions:
                attempts += 1
                for exception in exceptions:
                    if exception not in catched_exceptions:
                        BuiltIn().log_to_console("Exception cached in "
                                                 "run_ssh_command_through_jump_server: %s" %
                                                 exceptions)
                        catched_exceptions.append(exception)
                        # # Debug
                        # raise exc_obj  # pylint: disable=raising-bad-type
                return self.run_ssh_command_through_jump_server(
                    host, port, username, password, command, timeout=15, attempts=attempts,
                    catched_exceptions=catched_exceptions)
        else:
            # # Debug
            # if exc_obj:
            #     raise exc_obj  # pylint: disable=raising-bad-type
            return stdout_result, " .\n ".join(catched_exceptions)

        return stdout_result, stderr_result

    @easy_debug
    def run_ssh_command_itself(self, host, port, username, password, command, timeout=15,
                               get_pty=False, return_connect_only=False,
                               attempts=0, catched_exceptions=[]):
        """A method to run ssh command on target host

        :param host: IP or hostname of target host, where command will be run
        :param port: port of target host, where command will be run
        :param username: username to be used to make ssh connect to target host
        :param password: password to be used to make ssh connect to target host
        :param command: command itself, string
        :param timeout: ssh connection timeout
        :return: stdout, stderr
        """

        stdout_result, stderr_result = "", ""
        exceptions = []

        if attempts < 10:
            try:
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.connect(host, port, username, password, timeout=timeout,
                            allow_agent=False, look_for_keys=False)
                if return_connect_only:
                    return ssh, ""
                connect = True
            except (socket.gaierror, socket.error, EOFError,
                    SSHException, AttributeError, TypeError) as err:
                exceptions.append(" SSH Connection from %s (%s) to %s host failed: %s" %\
                                 (socket.gethostname(),
                                  socket.gethostbyname(socket.getfqdn()), host, err))
                connect = False
            if connect:
                try:
                    stdout, stderr = ssh.exec_command(command=command, get_pty=get_pty)[1:]
                    stdout_result = stdout.read().decode("utf-8").strip()
                    stderr_result = stderr.read().decode("utf-8").strip()
                except (socket.gaierror, socket.error, EOFError,
                        SSHException, AttributeError, TypeError) as err:
                    exceptions.append(" SSH command %s on %s failed: %s" % (command, host, err))

            ssh.close()

            if exceptions:
                BuiltIn().log_to_console("Exception cached in run_ssh_command_itself: "
                                         "%s" % exceptions)
                attempts += 1
                for exception in exceptions:
                    if exception not in catched_exceptions:
                        catched_exceptions.append(exception)
                return self.run_ssh_command_itself(host, port, username, password, command,
                                                   timeout=15, attempts=attempts,
                                                   catched_exceptions=catched_exceptions)
        else:
            return stdout_result, " .\n ".join(catched_exceptions)

        return stdout_result, stderr_result

    @staticmethod
    @easy_debug
    def ssh_read_file(host, port, username, password, abs_file_name, timeout=15):
        """A function to read contents of the file located on the remote host - through SSH.

        :param host: an IP address of the host.
        :param port: a port number to connect via SSH (usually 22).
        :param username: a user name to login via SSH.
        :param password: a password to login via SSH.
        :param abs_file_name: an absolute file name located on the remote host.

        :return: a string - content of the remote file if it has been successfully read,
        None otherwise.
        """
        content = None
        ssh_connect = False
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                ssh.connect(host, port, username, password, timeout=timeout)
                ssh_connect = True
            except (paramiko.SSHException, socket.error) as err:
                BuiltIn().log_to_console("SSH Connection from %s (%s) to %s host failed: %s" % (
                    socket.gethostname(), socket.gethostbyname(socket.getfqdn()), host, err))
            if ssh_connect:
                sftp = ssh.open_sftp()
                try:
                    with sftp.open(abs_file_name, "r+") as remote_f:
                        raw_content = remote_f.read()
                        content = general.insure_text(raw_content)
                except IOError as err:
                    BuiltIn().log_to_console("Error reading file %s on host %s via SSH: %s" % (
                        abs_file_name, host, err))
        return content

    @staticmethod
    @easy_debug
    def ssh_write_file(host, port, username, password, abs_file_name, content, timeout=15):
        """A function to write contents into the file located on the remote host - through SSH.

        :param host: an IP address of the host.
        :param port: a port number to connect via SSH (usually 22).
        :param username: a user name to login via SSH.
        :param password: a password to login via SSH.
        :param abs_file_name: an absolute file name located on the remote host.
        :param content: a string to be written into remote file.

        :return: True if the file has been successfully written, False otherwise.
        """
        ssh_connect = False
        result = False
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                ssh.connect(host, port, username, password, timeout=timeout)
                ssh_connect = True
            except (paramiko.SSHException, socket.error) as err:
                BuiltIn().log_to_console("SSH Connection from %s (%s) to %s host failed: %s"
                                         % (socket.gethostname(),
                                            socket.gethostbyname(socket.getfqdn()),
                                            host, err))
            if ssh_connect:
                sftp = ssh.open_sftp()
                try:
                    with sftp.open(abs_file_name, "w+") as remote_f:
                        content = general.insure_text(content)
                        remote_f.write(content)
                        result = True
                except IOError as err:
                    BuiltIn().log_to_console("Error accessing file %s on host %s via SSH: %s" % (
                        abs_file_name, host, err))
        return result

    @easy_debug
    def ssh_move_file(self, host, port, username, password, file_path, destination_folder):
        """A function to write contents into the file located on the remote host - through SSH.

        :param host: an IP address of the host.
        :param port: a port number to connect via SSH (usually 22).
        :param username: a user name to login via SSH.
        :param password: a password to login via SSH.
        :param file_path: an absolute path to file name located on the remote host.
        :param destination_folder: an absolute path to destination folder.

        :return: True if the file has been successfully written, False otherwise.
        """
        result = False
        file_name = file_path.split("/")[-1]
        command = "mv %s %s/%s" % (file_path, destination_folder, file_name)
        stdout, stderr = self.run_ssh_cmd(host, port, username, password, command)
        if not stdout and not stderr:
            result = True
        return result

    @staticmethod
    @easy_debug
    def sftp_put_file(host, port, username, password, localpath, remotepath):
        """A method to put a file on a remote host using SFTP protocol

        :param host: an IP address of the remote host.
        :param port: a port number to connect via SFTP (usually 22).
        :param username: a user name to login via SFTP.
        :param password: a password to login via SFTP.
        :param localpath: relative local path to file what will be transfered
        :param remotepath: absolute remote path to the directory where file has to be placed
        """
        result = False
        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None
        try:
            with pysftp.Connection(host, username, password, port, cnopts) as sftp:
                try:
                    with sftp.cd(remotepath):
                        listdir = sftp.listdir()
                        BuiltIn().log_to_console("listdir-1: %s" % listdir)
                        sftp.put(localpath)
                        listdir = sftp.listdir()
                        BuiltIn().log_to_console("listdir-2: %s" % listdir)
                        result = True
                except IOError as err:
                    BuiltIn().log_to_console("Path %s doesn't exist" % remotepath)
                    raise Exception(err)

        except(ConnectionException, CredentialException, SSHException) as err:
            BuiltIn().log_to_console("Failed to connect to %s in sftp_put_file" % host)
            raise Exception(err)
        return result

    @easy_debug
    def grep_logs(self, host, port, username, password, path, entry, pipes="",
                  grep_ignore_pattern=""):
        """A function to find a string entry in the files,
        useful to search for something in log files within log folder.
        In fact, it connects to the host via SSH, runs "grep -r ..." command and parses its output.

        :param host: an IP address of the host.
        :param port: a port number to connect via SSH (usually 22).
        :param username: a user name to login via SSH.
        :param password: a password to login via SSH.
        :param path: an absolute path to a folder which will be
            searched recursively for a string entry.
        :param entry: a string to be searched for.
        :param pipes: a string of pipes which will be added to the "grep" command.
        :param grep_ignore_pattern: regexp pattern to not to match (ignore) in search

        :return: an array of lines containing the requested entry, or [""] if no entries were found.

        :Example:

        grep -r "1502271815.36" /var/tmp/adi-auto-deploy/e2esi/* | grep Package | head -n 1
        >>>grep_logs(e2e_obj.conf["ASSET_GENERATOR"]["host"],
        ...     e2e_obj.conf["ASSET_GENERATOR"]["port"],
        ...     e2e_obj.conf["ASSET_GENERATOR"]["user"],
        ...     e2e_obj.conf["ASSET_GENERATOR"]["password"],
        ...     "%s/%s/*" % (e2e_obj.conf["ASSET_GENERATOR"]["path"], e2e_obj.lab_name),
        ...     e2e_obj.package_id, " | grep Package | head -n 1")
        ['/var/tmp/adi-auto-deploy/e2esi/1001-ts0000_20170809_094340pt-0-0_Package-Done/ADI.XML:\
        <!-- user=unknown, testscript=ts0000, testrunid=1502271815.36, lab=e2esi -->']
        """
        if grep_ignore_pattern:
            command = "grep -r '%s' %s %s | grep -vP %s" % (entry, path, pipes, grep_ignore_pattern)
        else:
            command = "grep -r '%s' %s %s" % (entry, path, pipes)
        stdout, stderr = self.run_ssh_cmd(host, port, username, password, command)
        # BuiltIn().log_to_console("ssh %s@%s pass %s => %s" % (username, host, password, command))
        # BuiltIn().log_to_console("stdout: %s\nstderr: %s" % (stdout, stderr))
        if stderr:
            BuiltIn().log_to_console("Reading logs via SSH failed on %s: %s =(" % (host, stderr))
        return stdout.strip().split("\n")

    @staticmethod
    @easy_debug
    def filter_list(strings, skip=None):
        """A function removes duplicates, "" elements and elements starting with skip_prefix.
        By default, only empty strings and duplicates will be removed (i.e. when skip_prefix="").

        :param strings: a list of string values.
        :param skip: a list of entries for strings items to be
        excluded from the initial strings list.

        :return: a list of unique strings (can be empty), containing no "" elements.

        :Example:

        >>># ignore "Could not chdir to home directory" because some users don't have home dirs:
        >>>errors = ["", "Error 1", "", "Err 2",
        ...          "Could not chdir to home directory /home/airflow ..."]
        >>>tools.filter_list(errors, skip=["Could not chdir to home directory"])
        ['Error 1', 'Err 2']
        """
        items = [item for item in list(set(strings)) if item]
        skip = skip or []
        for entry in skip:
            i = 0
            while items:
                if entry in items[i]:
                    items.remove(items[i])
                else:
                    i += 1
                if i == len(items):
                    break
        return items

    @staticmethod
    @easy_debug
    def filter_chars(str_input):
        """A function filters the given string "str_input" for "bad" characters."""
        # return re.sub("[^\040-\176]", "", str_input).encode("ascii")
        return re.sub("[^\040-\176]", "", str_input)

    @easy_debug
    def dict_walk(self, obj, prev_path="obj", path_repr="{}[{!s}]".format):
        """Traverse through a "quite deep" dictionary."""
        if isinstance(obj, dict):
            items = list(obj.items())
        elif isinstance(obj, list):
            items = enumerate(obj)
        else:
            yield prev_path, obj
            return
        for key, value in items:
            for data in self.dict_walk(value, path_repr(prev_path, key), path_repr):
                yield data

    @staticmethod
    @easy_debug
    def run_local_command(command):
        """A method to run local bash commands"""
        command = general.insure_text(command)
        return os.system(command)
