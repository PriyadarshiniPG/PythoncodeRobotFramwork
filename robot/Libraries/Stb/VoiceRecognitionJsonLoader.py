#!/usr/bin/python2
"""
Module handling importation and return of vrex json files
This is intended to be used a local RF library
"""

import json

from os.path import join, dirname


class VoiceRecognitionJsonLoader(object):
    """
    Class responsible for reading voice recognition commands from
    json files and parsing them
    """

    # Following pylint warnings were disabled for these classes
    # R0903 - Too few public methods
    # C0103 - Invalid name - we want as descriptive test names as possible
    # pylint: disable=C0103,R0903

    _commands_directory = join(dirname(__file__), 'voice_recognition_files')

    def _read_command_file(self, command_file):
        command_file_path = join(self._commands_directory, command_file)
        with open(command_file_path, 'r') as opened_file:
            file_content = json.loads(opened_file.read())
        return file_content

    def get_voice_recognition_json_command(self, command_file):
        """
        Loads a voice recognition command from json file and returns it
        as a string
        :param command_file: name of the json file with voice command
        :return: String representation of the command
        """
        command = self._read_command_file(command_file)
        return json.dumps(command, encoding='utf-8', separators=(',', ':'))
