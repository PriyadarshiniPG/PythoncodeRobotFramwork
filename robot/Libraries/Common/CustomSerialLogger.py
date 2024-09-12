"""
Custom logger for serial library to capture full log
"""
import time
from io import FileIO
from threading import BoundedSemaphore


class CustomSerialLogger(object):
    """
    Custom logger for serial library to capture full log
    """
    def __init__(self):
        """
        Constructor for custom serial lib
        """
        self._fp = None
        self._lock = BoundedSemaphore()
        self._read_position = 0
        self._write_position = 0
        self._logging_enabled = False
        self.log_file_name = None

    def open(self, filename):
        """
        Open logger instance
        :param filename: Log file name
        """
        self._lock.acquire()
        self._fp = FileIO(filename, 'a+')
        self._read_position = self._fp.tell()
        self._write_position = self._fp.tell()
        self._lock.release()
        self.log_file_name = filename

    def write(self, data):
        """
        Write in to the log file
        :param data: Date to write
        """
        if self.is_logger_open():
            self._lock.acquire()
            self._fp.seek(self._write_position)
            self._fp.write(data)
            self._write_position = self._fp.tell()
            self._lock.release()
        else:
            raise IOError("Logger is not open")

    def read_line(self):
        """
        Read line from the log file
        :return: Line read
        """
        line = ''
        if self._read_position == self._write_position:
            time.sleep(0.3)
        elif self.is_logger_open():
            self._lock.acquire()
            self._fp.seek(self._read_position)
            line = self._fp.readline()
            self._read_position = self._fp.tell()
            self._lock.release()
        return line

    def is_logger_open(self):
        """
        Checking logger is open
        :return: True if logger is open
        """
        is_open = False
        if self._fp:
            is_open = not self._fp.closed
        return is_open

    def reset_buffer(self):
        """
        Reset the logging buffer to EOF
        """
        self._read_position = self._write_position

    def close(self):
        """
        Close the logger instance
        """
        if self._fp:
            self._lock.acquire()
            self._fp.close()
            self._lock.release()
            self.log_file_name = None
