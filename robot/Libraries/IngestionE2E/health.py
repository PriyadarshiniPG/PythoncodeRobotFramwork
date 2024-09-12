"""A module to handle health checks for the VOD ingestion (OG and Airflow components)."""
# pylint: disable=W0102
# pylint: disable=wrong-import-position
# pylint: disable=wrong-import-order
import os
import sys
import inspect
import time
import socket
import paramiko
from paramiko.ssh_exception import  SSHException
import paramiko_expect
from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
from .tools import Tools
from .helpers import E2E
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
lib_dir = os.path.dirname(currentdir)
robot_dir = os.path.dirname(lib_dir)
sys.path.append(robot_dir)
from Libraries.general.keywords import Keywords as general
easy_debug = general.easy_debug
general = general()


class HealthChecks(object):
    """A class to check the readiness of the components involved into E2E ingestion process."""

    def __init__(self, lab_name, e2e_conf):
        """The class initializer.

        :param lab_name: a lab name, a key of E2E_CONF dictionary in robot/resources/stages/conf.py.
        :param e2e_conf: the entire dictionary E2E_CONF stored in robot/resources/stages/conf.py.
        """
        self.lab_name = lab_name
        self.e2e_conf = e2e_conf
        self.conf = self.e2e_conf[lab_name]
        self.host_name = socket.gethostname()
        self.host_ip = socket.gethostbyname(socket.getfqdn())
        self.tools = Tools(self.conf)

    @staticmethod
    @easy_debug
    def _check_stuck_processes(host, check_stuck, output):
        errors = []
        if check_stuck:
            for line in output.strip().split("\n"):
                line = line.strip()
                if not line:
                    continue
                columns = line.split()  # columns[0]: "25:05" - 25 min 5 seconds
                if len(columns[0]) > 5:  # if duration > 1 hour
                    errors.append("Command '%s' takes too long (%s) on %s" %
                                  (" ".join(columns[1:]), columns[0], host))
        return errors

    @staticmethod
    @easy_debug
    def _reduce_processes_list(processes, output):
        return [process for process in processes if process not in output]

    @staticmethod
    @easy_debug
    def _report_stuck_processes(host, processes):
        errors = []
        for process in processes:
            errors.append("Process '%s' is not running on %s" % (process, host))
        return errors

    @easy_debug
    def check_running_processes(self, conf, processes, check_stuck=False, tries=1, interval=1):
        """A method to check whether the given processes are running/stuck on a given host.
        The output of the following command is checked for presence of processes names:
            ps ax -eo uid,pid,ppid,%cpu,%mem,tname,stime,etime,cmd | grep -v grep | grep -E \
            'celeryd|airflow'
        or:
            ps ax -eo etime,cmd | grep -v grep | grep -E '/home/og/bin'
        This method can be applied even if we need to wait for a certain process to appear -
        this can be achieved with tries > 1.
        .. note :: self.tools.run_ssh_command() isn't used - just to run commands
        within one SSH session.

        :param conf: an ssh login details - a dictionary with keys: host, port, user, password.
        :param processes: a list of processes names expected.
        :param check_stuck: if true, will check whether given processes were started > 1 hour ago.
        :param tries: a number of attempts to execute "ps ax ..." command.
        :param interval: a number of seconds between attempts.

        :return: the list of error messages; should be an empty list if no errors occurred.

        :Example:

        >>>ssh_cnf = E2E_CONF["AIRFLOW_WORKERS"][0]  # from robot/resources/stages/conf.py
        >>>health = HealthChecks("e2esi", E2E_CONF)
        >>>health.check_running_processes(ssh_cnf, ["airflow", "celeryd"], True)
        []
        """
        errors = []
        columns = "uid,pid,ppid,%cpu,%mem,tname,stime,etime,cmd" if not check_stuck else "etime,cmd"
        command = "ps ax -eo %s | grep -v grep | grep -E '%s'" % (columns, "|".join(processes))
        i = 0
        while True:
            i += 1
            stdout, stderr = self.tools.run_ssh_cmd(
                conf["host"], conf["port"], conf["user"], conf["password"], command)

            if stderr:
                if not ("SSH Connection from" in stderr and "host failed:" in stderr):
                    if not stderr.startswith("Could not chdir to home directory"):
                        errors.append(stderr)
                else:
                    return stderr
            else:
                # Remove processes from list if they are mentioned in the output:
                processes = self._reduce_processes_list(processes, stdout)
                errors.extend(self._check_stuck_processes(conf["host"], check_stuck, stdout))
            if not (stdout or i == tries):
                time.sleep(interval)
            else:
                errors.extend(self._report_stuck_processes(conf["host"], processes))
                break
        return errors

    @staticmethod
    @easy_debug
    def _analyze_cmd_output(host, command, output, perms, entry=None, noentry=None):
        errors = []
        if entry:
            if entry not in output:
                message = "Could not create folder '%s' on %s" % (entry, host)
                # BuiltIn().log_to_console(message)
                errors.append(message)
            else:
                for line in output.split("\n"):
                    if entry in line and not line.startswith(perms):
                        folder = command.split("|")[0].split(" ")[2].strip()
                        sub_folder = line.split(" ")[-1].strip()
                        actual_perms = line.split(" ")[0]
                        message = "Host %s. Folder %s had %s permissions, expected: %s" % (
                            host, folder + sub_folder, actual_perms, perms)
                        # BuiltIn().log_to_console(message)
                        errors.append(message)
                        break
        if noentry and noentry in output:
            message = "Could not remove folder '%s' on %s" % (noentry, host)
            # BuiltIn().log_to_console(message)
            errors.append(message)
        return errors

    @easy_debug
    def check_folders_ssh(self, conf, folder, perms, todos=None, sudo_prefix=""):
        """A method to check the permissions of a given folder on a given host using SSH.
        An attempt to create a temporary folder will be performed and its permissions analyzed.
        .. note :: self.tools.run_ssh_command() isn't used - just to run
        commands within one SSH session.

        :param conf: an ssh login details - a dictionary with keys: host, port, user, password.
        :param folder: an absolute path to a folder (could be a mount point).
        :param perms: expected permissions of the temporarily created folder (e.g. "drwxrwsr-x").
        :param todos: a dictionary describing the commands to run.
        .. note :: by default (todos=None), an attempt to create a folder will be done.
        :param sudo_prefix: a string to use sudo, e.g.: "echo -e password | sudo -S su - user -c".

        :return: the list of error messages; should be an empty list if no errors occurred.

        :Example:

        >>>conf = E2E_CONF["AIRFLOW_WORKERS"][0]  # from robot/resources/stages/conf.py
        >>>health = HealthChecks("e2esi", E2E_CONF)
        >>>watch_folder = "/mnt/nfs_watch/Countries/E2ESI/ToAirflow"  # no ending slash
        >>>health.check_folders_ssh(conf, watch_folder, "drwxrwsr-x")
        []
        >>>managed_folder = "/mnt/nfs_managed/Countries/E2ESI/FromAirflow"  # no ending slash
        >>>health.check_folders_ssh(conf, managed_folder, "drwxrwxr-x")
        ['SSH Connection from 2a-jenkins01 (172.30.135.24) to 172.23.169.117 failed: [Errno 10060] \
        A connection attempt failed because the connected party did not properly respond after \
        a period of time, or established connection failed because connected host \
        has failed to respond']
        """
        errors = []
        tmp_folder = "%s-%s" % ("_test-health-check", time.time())
        todos = todos or [{"cmd": "mkdir %s/%s" % (folder, tmp_folder)},
                          {"cmd": "ls -l %s/" % folder, "entry": tmp_folder},
                          {"cmd": "rmdir %s/%s" % (folder, tmp_folder)},
                          {"cmd": "ls -l %s/" % folder, "noentry": tmp_folder}]

        for todo in todos:
            cmd = "%s '%s'" % (sudo_prefix, todo["cmd"]) if sudo_prefix else todo["cmd"]
            # BuiltIn().log_to_console(cmd)
            stdout, stderr = self.tools.run_ssh_cmd(
                conf["host"], conf["port"], conf["user"], conf["password"], cmd, get_pty=True)
            if stderr and not stderr.startswith("Could not chdir to home directory"):
                errors.append(stderr)
            else:
                todo["entry"] = todo["entry"] if "entry" in todo else None
                todo["noentry"] = todo["noentry"] if "noentry" in todo else None
                errors.extend(self._analyze_cmd_output(conf["host"], cmd, stdout, perms,
                                                       todo["entry"], todo["noentry"]))
        return errors

    @easy_debug
    def check_folders_sftp(self, ssh_cnf, sftp_cnf, folder,
                           perms, attempts=0, catched_exceptions=[]):
        """A method to check the permissions of a given folder on a given host using SFTP client.
        An attempt to create a temporary folder will be performed and its permissions analyzed.
        .. note :: self.tools.run_ssh_command() isn't used, since paramiko-pexpect is used for sftp.

        :param ssh_cnf: an ssh login details - a dictionary with keys: host, port, user, password.
        .. note :: additionally ssh_cnf should have "prompt" key with a string value, e.g. "$".
        :param sftp_cnf: an sftp login details - a dictionary with keys: host, port, user, password.
        .. note :: sftp_cnf can also have "prompt" key with a string value, e.g. "sftp> ".
        :param folder: an absolute path to Airflow's watch or managed folder.
        :param perms: expected permissions of the temporarily created folder (e.g. "drwxrwsr-x").

        :return: the list of error messages; should be an empty list if no errors occurred.

        :Example:

        >>>worker = E2E_CONF["AIRFLOW_WORKERS"][0]  # from robot/resources/stages/conf.py
        >>>ssh_cnf = {"host": worker["host"], "port": worker["port"], "prompt": "$",
        ...           "user": worker["user"], "password": worker["password"]}
        >>>sftp_cnf = {"host": "localhost", "port": worker["port"], "prompt": "sftp> ",
        ...            "user": worker["local_user"], "password": worker["local_password"]}
        >>>health = HealthChecks("e2esi", E2E_CONF)
        >>>watch_folder = "/mnt/nfs_watch/Countries/E2ESI/ToAirflow"  # no ending slash
        >>>health.check_folders_sftp(ssh_cnf, sftp_cnf, folder, "drwxrwsr-x")
        []
        >>>managed_folder = "/mnt/nfs_managed/Countries/E2ESI/FromAirflow"  # no ending slash
        >>>health.check_folders_sftp(ssh_cnf, sftp_cnf, folder, "drwxrwxr-x")
        ['SSH Connection from 2a-jenkins01 (172.30.135.24) to 172.23.169.117 failed: [Errno 10060] \
        A connection attempt failed because the connected party did not properly respond after \
        a period of time, or established connection failed because connected host \
        has failed to respond']
        """

        if attempts < 10:
            errors = []
            tmp_folder = "%s-%s" % ("_test-health-check", time.time())
            todos = [
                {"cmd": "sftp -o StrictHostKeyChecking=no %s@%s" %
                        (sftp_cnf["user"], sftp_cnf["host"]),
                 "msg": "password: " if sftp_cnf["password"] else sftp_cnf["prompt"]},
                {"cmd": sftp_cnf["password"], "msg": sftp_cnf["prompt"]},
                {"cmd": "mkdir %s/%s" % (folder, tmp_folder), "msg": sftp_cnf["prompt"]},
                {"cmd": "ls -l %s/" % folder, "msg": sftp_cnf["prompt"], "entry": tmp_folder},
                {"cmd": "rmdir %s/%s" % (folder, tmp_folder), "msg": sftp_cnf["prompt"]},
                {"cmd": "ls -l %s/" % folder, "msg": sftp_cnf["prompt"], "noentry": tmp_folder},
                {"cmd": "bye", "msg": ssh_cnf["prompt"]},
            ]

            ssh = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                         ssh_cnf["password"], "dummy command",
                                         timeout=10, return_connect_only=True)[0]
            command = ""
            try:
                with paramiko_expect.SSHClientInteraction(ssh, timeout=10, display=False) as sftp:
                    for todo in todos:
                        try:
                            command = todo["cmd"]
                            sftp.send("%s" % todo["cmd"])
                            sftp.expect(todo["msg"])
                            todo["entry"] = todo["entry"] if "entry" in todo else None
                            todo["noentry"] = todo["noentry"] if "noentry" in todo else None
                            errors.extend(
                                self._analyze_cmd_output(sftp_cnf["host"], todo["cmd"],
                                                         sftp.current_output_clean, perms,
                                                         todo["entry"], todo["noentry"])
                            )
                        except socket.error as err:
                            errors.append("Command '%s' failed on %s: %s" % (
                                todo["cmd"], sftp_cnf["host"], err))
            except (socket.gaierror, EOFError, SSHException, AttributeError) as err:
                attempts += 1
                message = "Exception cached on command '%s', sftp host %s. Exception: %s" % \
                          (command, sftp_cnf["host"], err)
                BuiltIn().log_to_console(message)
                if err not in catched_exceptions:
                    catched_exceptions.append(message)
                return self.check_folders_sftp(ssh_cnf, sftp_cnf, folder, perms,
                                               attempts=attempts,
                                               catched_exceptions=catched_exceptions)
            ssh.close()
        else:
            return catched_exceptions

        return errors

    @easy_debug
    def check_todays_logs(self, ssh_cnf, logs_folder, err_levels=None):
        """A method to search for todays' errors in a log folder on a given host.
        In fact, the commands like
            grep CRITICAL /opt/og/Countries/E2ESI/log/* | grep 2017-10-03T
            grep ERR /opt/og/Countries/E2ESI/log/* | grep 2017-10-03T
        will be executed on the given host (ssh_cnf["host"]) through SSH.

        :param ssh_cnf: an ssh login details - a dictionary with keys: host, port, user, password.
        :param logs_folder: an absolute path to a log folder (could be a mount point).
        :param err_levels: a list of error levels to be used for grepping the logs.
        .. note :: by default, messages of levels "CRITICAL" and "ERROR" are searched for.

        :return: the list of error messages; should be an empty list if no errors occurred.

        :Example:

        >>>ssh_cnf = E2E_CONF["AIRFLOW_WORKERS"][0]     # from robot/resources/stages/conf.py
        >>>health = HealthChecks("e2esi", E2E_CONF)
        >>>logs_folder = "/opt/og/Countries/E2ESI/log"  # no ending slash
        >>>health.check_todays_logs(ssh_cnf, logs_folder, ["CRITICAL"])
        [u'/opt/og/Countries/E2ESI/log/error.txt:2017-09-22T12:40:48 : E2ESI eventis_ingest-tva.sh \
        CRITICAL TVA_100003_20170922144048.xml does not exist or is empty, stopping', \
        u'/opt/og/Countries/E2ESI/log/error.txt:2017-09-22T11:45:49 : E2ESI eventis_ingest-tva.sh \
        CRITICAL TVA_100004_20170922134549.xml does not exist or is empty, stopping']
        """
        err_levels = err_levels or ["CRITICAL", "ERR"]
        today = time.strftime("%Y-%m-%dT", time.localtime(time.time()))  # e.g.: "2017-10-03T"
        errors = []
        for err_level in err_levels:
            logs = self.tools.grep_logs(ssh_cnf["host"], ssh_cnf["port"],
                                        ssh_cnf["user"], ssh_cnf["password"],
                                        "%s/*" % logs_folder, err_level, " | grep %s" % today)
            errors.extend(logs)
        return errors

    @easy_debug
    def get_data_from_aws_host(self, ssh_cnf, files, cur_dir):
        """Retrieve data from Airflow web server deployed in AWS, the key horizongodevepam.pem
        will be used to SSH onto the server like it can be done with the command:
         ssh -i ~/.ssh/horizongodevepam.pem ec2-user@webserver1.airflow-lab5a.horizongo.eu <command>

        :param ssh_cnf: an ssh login details - a dictionary with keys: host, port, user, key_path.
        :param files: files names to get content of.
        :param cur_dir: a current directory (usually it is robot/ingestion/healthchecks).
        .. note :: cur_dir can be ${CURDIR} value called from a test case in Robot Framework.

        :return: a dictionary with keys named as files and "errors":
        {'errors': [], 'VERSION': 'v1.50',
        'Revision_airflow': '9875f29a821dfb6b487bbdea90712e0952a8e143',
        'Revision_airflow-dags': '3214665b5bf3affde1e2adcee3c84002ae1ee5d7'}
        """
        result = {"errors": []}
        for item in files:
            result.update({item.split("/")[-1]: None})
        key = paramiko.RSAKey.from_private_key_file(os.path.join(cur_dir, ssh_cnf["key_path"]))
        with paramiko.SSHClient() as ssh:
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                BuiltIn().log_to_console(files)
                ssh.connect(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"], pkey=key, timeout=30)
                for item in files:
                    cmd = "cat %s" % item
                    stdout, stderr = ssh.exec_command(cmd)[1:]
                    stdout = general.insure_text(stdout.read()).strip()
                    stderr = general.insure_text(stderr.read()).strip()
                    result.update({item.split("/")[-1]: stdout})
                    if stderr:
                        result["errors"].append(stderr)
            except (paramiko.SSHException, socket.gaierror, socket.error) as err:
                result["errors"].append("SSH Connection from %s (%s) to %s failed: %s" %
                                        (ssh_cnf["host"], self.host_ip, ssh_cnf["host"], err))
        return result

    @easy_debug
    def check_airflow_manager_version(self, cur_dir, main_conf):
        """Retrieve data from Airflow web server deployed in AWS, the key horizongodevepam.pem
        will be used to SSH onto the server like it can be done with the command:
         ssh -i ~/.ssh/horizongodevepam.pem ec2-user@webserver1.airflow-lab5a.horizongo.eu <command>

        :param conf: an ssh login details - a dictionary with keys: host, port, user, key_path.
        :param cur_dir: a current directory (usually it is robot/ingestion/healthchecks).
        :param main_conf: full E2E_CONF[lab_name] config from conf.py file
        .. note :: cur_dir can be ${CURDIR} value called from a test case in Robot Framework.

        :return: the list of error messages; should be an empty list if no errors occurred.
        """
        helpers = E2E(lab_name=self.lab_name, e2e_conf=self.e2e_conf)
        html_th_tag = ""
        errors = []
        login_creds = main_conf["AIRFLOW_WEB_CREDENTIALS"]
        web_server = main_conf["AIRFLOW_WEB"]
        destination_page_url = "http://%s/version" % web_server["host"]
        with open(os.path.join(cur_dir, "../../../../../airflow-dags/VERSION"), "r+") as _f:
            git_version = _f.read()
            git_version = general.insure_text(git_version).strip()
        # pylint: disable=E1120
        destination_page_html = helpers.get_airflow_page_html(
            destination_page_url, login_creds, web_server)

        if destination_page_html:
            parsed_version_page_html = BeautifulSoup(destination_page_html, "lxml")
            html_th_tag = [txt.string for txt in parsed_version_page_html.findAll("h4")
                           if txt.string is not None and txt.string.startswith("Version:")]

        if not html_th_tag:
            errors.append("No Airflow version information found on the web page")
        else:
            web_version = html_th_tag[0].split()[-1]
            if git_version != web_version:
                errors.append("Web version %s != Git version: %s " % (web_version, git_version))
        return errors

    @easy_debug
    def check_airflow_worker_revisions(self, ssh_cnf, revision_core, revision_dags):
        """A method to compare revision values of airflow-core and airflow-dags
        from Airflow workers to the expected ones taken from Airflow web server.
        In fact, the commands like
            cat /usr/local/airflow/Revision_airflow-dags
        will be executed on the given host (ssh_cnf["host"]) through SSH.

        :param ssh_cnf: an ssh login details - a dictionary with keys: host, port, user, password.
        :param revision_core: a string, content of Revision_airflow file on Airflow web host.
        :param revision_dags: a string, content of Revision_airflow-dags file on Airflow web host.

        :return: the list of error messages; should be an empty list if no errors occurred.

        :Example:

        >>>ssh_cnf = E2E_CONF["AIRFLOW_WORKERS"][0]     # from robot/resources/stages/conf.py
        >>>health = HealthChecks("e2esi", E2E_CONF)
        >>>health.check_airflow_revisions(ssh_cnf, \
        ...  "a60e511bf73fdd525db83a1b7d802469500dba81", "4e0caa758062cf8d2e6cc7f1e2198763398c9e1d")
        []
        """
        errors = []
        folder = "/usr/local/airflow"
        revisions = {"Revision_airflow": revision_core, "Revision_airflow-dags": revision_dags}
        for file_name, revision in list(revisions.items()):
            command = "cat %s/%s" % (folder, file_name)
            stdout, stderr = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"],
                                                    ssh_cnf["user"], ssh_cnf["password"],
                                                    command)
            if stdout != revision:
                errors.append("Wrong revision in %s:%s/%s: %s (actual) != %s (expected)" % \
                              (ssh_cnf["host"], folder, file_name, stdout, revision))
            if stderr:
                errors.append(stderr)
        return errors

    @easy_debug
    def check_group_users_membership(self, ssh_cnf, group, user, expected_gid=5000):
        """A method to check users memebership on the given Airfow worker."""
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], "cat /etc/group | grep %s:" % group)
        if err:
            return "", ["Cannot read /etc/group on Airflow worker %s: %s" % (ssh_cnf["host"], err)]
        if not out:
            return "", ["Group '%s' is missing on Airflow worker %s" % (group, ssh_cnf["host"])]
        errors = []
        group_details = out.split(":")
        # BuiltIn().log_to_console(group_details)
        gid, members = group_details[2], group_details[3].split(",")
        if int(gid) != int(expected_gid):
            errors.append("Group '%s' has unexpected gid='%s' (expected %s) on Airflow worker %s. "
                          % (group, gid, expected_gid, ssh_cnf["host"]))
        if user not in members:
            errors.append("User '%s' is not a member of the group '%s' on Airflow worker %s. "
                          % (user, group, ssh_cnf["host"]))
        return gid, errors

    @easy_debug
    def check_user_details(self, ssh_cnf, expected):
        """A method to check users properties on the given Airfow worker."""
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], "cat /etc/passwd | grep airflow")
        if err:
            return "", ["Cannot read /etc/passwd on Airflow worker %s: %s" % (ssh_cnf["host"], err)]
        if not out:
            return "", ["No airflow users found on Airflow worker %s" % ssh_cnf["host"]]
        errors = []
        data = {}
        # BuiltIn().log_to_console(out)
        for line in out.split("\n"):
            parts = line.split(":")
            user = parts[0]
            actual = {"uid": parts[2], "gid": parts[3], "home": parts[5], "shell": parts[6]}
            if user in list(expected.keys()):
                data.update({user: actual})
                for key, value in list(expected[user].items()):
                    if actual[key].strip() != str(value):
                        errors.append("On Airflow worker %s user '%s' has %s=%s (expected %s)" % (
                            ssh_cnf["host"], user, key, actual[key], expected[user][key]))
        if len(list(data.keys())) < len(list(expected.keys())):
            err = ", ".join(list(set(expected.keys()) - set(data.keys())))
            errors.append("Users %s are not found on Airflow worker %s" % (err, ssh_cnf["host"]))
        return data, errors

    @easy_debug
    def check_users_homes(self, ssh_cnf, expected):
        """A method to check users home directories on the given Airfow worker."""
        cmd = "cat /etc/passwd | grep airflow | awk -F ':' '{print $6}' " + \
              "| xargs ls -ld | awk '{print $1, $3, $4, $9}'"
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], cmd)
        if not out:
            return "", ["No users/homes found on Airflow worker %s: %s" % (ssh_cnf["host"], err)]
        errors = []
        data = {}
        for line in out.split("\n"):
            parts = line.split()
            actual = {"perms": parts[0], "owner": parts[1], "group": parts[2], "home": parts[3]}
            for user in list(expected.keys()):
                if actual["home"] == expected[user]["home"]:
                    data.update({user: actual})
                    for key, value in list(expected[user].items()):
                        if actual[key] != value:
                            err = "On Airflow worker %s user '%s' has %s=%s (expected %s)" % \
                                  (ssh_cnf["host"], user, key, actual[key], expected[user][key])
                            errors.append(err)
        if len(list(data.keys())) < len(list(expected.keys())):
            err = ", ".join(list(set(expected.keys()) - set(data.keys())))
            errors.append("Homeless user(s) %s found on Airflow worker %s" % (err, ssh_cnf["host"]))
        return data, errors

    @easy_debug
    def check_countries_subdirs(self, ssh_cnf, countries_dir, countries, subdirs,
                                exp_uid, exp_gid, exp_perms):
        """A method to check permissions & ownership of subfolders inside countries folders."""
        cmd = "find %s -maxdepth %s -type d | xargs ls -nld | awk '{print $1,$3,$4,$NF}'" % \
              (countries_dir, max([subdir.count('/') for subdir in subdirs]) + 2)
        # does not work with subdirs with slashes:
        #cmd = "echo $(ls -ld %s/* | grep -v total | awk '{print $NF\"/*\"}') " % countries_dir + \
        #      "| tr ' ' '\n' | xargs ls -nld | awk '{print $1,$3,$4,$NF}'"
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], cmd)
        if err and "cannot access" not in err:
            return [err]
        errors = []
        errs = {}
        for line in (err + out).split("\n"):
            perms, uid, gid, path = line.split(" ")[:4]
            if perms == "ls:" and "/" not in path:
                continue
            country, item = path.split("/")[-2:]
            if country != country.upper():
                continue
            if country not in list(errs.keys()):
                errs.update({country: []})
            if not countries or country in countries:
                if perms == "ls:":
                    errs[country].append("missing subdirs - %s" % ", ".join(subdirs))
                elif item in subdirs:
                    if perms != exp_perms:
                        errs[country].append(" subdir '%s' has permissions '%s' (expected '%s')"
                                             % (item, perms, exp_perms))
                    if int(uid) != int(exp_uid):
                        errs[country].append(" subdir '%s' has owner uid '%s' (expected '%s')"
                                             % (item, uid, exp_uid))
                    if int(gid) != int(exp_gid):
                        errs[country].append(" subdir '%s' has owner gid '%s' (expected '%s')"
                                             % (item, gid, exp_gid))
        countries = countries or list(
            {item.replace(countries_dir, "/").split("/")[2] for item in out.split("\n")})
        for country in countries:
            if country != country.upper():
                errors.append("In '%s' folder '%s' does not seem as a valid country code" \
                              % (countries_dir, country))
                continue
            missing = [item for item in subdirs if "/Countries/%s/%s" % (country, item) not in out]
            if missing:
                errs[country].append(" missing subdirs - %s" % ", ".join(missing))
        errors.extend(["Country %s: %s" % (key, ";".join(val)) for key, val in list(errs.items()) if val])
        print(errors)
        return errors

    @easy_debug
    def check_connectivity(self, ssh_cnf, host, port):
        """A method to check connectivity from one remote host to another host:port."""
        cmd = "echo $(timeout 1 bash -c 'cat < /dev/null > /dev/tcp/%s/%s' 2>&1" % (host, port) + \
              " && echo 'OK' || echo 'FAIL') | tr ' ' '\n' | tail -n 1"
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], cmd)
        if err:
            return [err]
        if out != "OK":
            return ["Cannot connect from %s to %s:%s" % (ssh_cnf["host"], host, port)]
        return []

    @easy_debug
    def check_connectivity_from_localhost(self, ssh_cnf):
        """A method to check connectivity from one remote host to another host:port."""
        cmd = "echo $(pwd && echo 'OK' || echo 'FAIL') | tr ' ' '\n' | tail -n 1"
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], cmd)
        if err:
            return [err]
        if out != "OK":
            return ["Cannot connect to transcoder host %s" % ssh_cnf["host"]]
        return []

    @easy_debug
    def check_mount_points(self, ssh_cnf, cmd, src_host, src_folder, fs_type, dst_folder):
        """A method to check active mount points or auto-mounting settings in /etc/fstab."""
        out, err = self.tools.run_ssh_cmd(ssh_cnf["host"], ssh_cnf["port"], ssh_cnf["user"],
                                          ssh_cnf["password"], cmd)
        if err:
            return [err]
        for line in [line for line in out.split("\n") if not line.startswith("#")]:
            parts = line.split(" ")
            if len(parts) == 3:
                act_source, act_fs_type, act_dst_folder = parts
                if act_source == "%s:%s" % (src_host, src_folder) \
                and act_fs_type.startswith(fs_type) and dst_folder.startswith(act_dst_folder):
                    return []
        return ["%s:%s on %s" % (src_host, src_folder, ssh_cnf["host"])]
