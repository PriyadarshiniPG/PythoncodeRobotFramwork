"""
Common utilities
"""
# -*- coding: utf-8 -*-
# pylint: disable=no-self-use


class KeyboardMode(object):
    """
    Virtual keyboard mode.
    """
    CHAR = 'CHAR'
    DIGIT = 'DIGIT'
    SPECIAL = 'SPECIAL'

    def get_char(self):
        """Getter method for self.CHAR"""
        return self.CHAR

    def get_digit(self):
        """Getter method for self.DIGIT"""
        return self.DIGIT

    def get_special(self):
        """Getter method for self.SPECIAL"""
        return self.SPECIAL


class Keyboard(object):
    """
    Virtual keyboard based queries. Currently, 3 special characters are not
    handled in the keyboard detection comparison
    """
    NORMAL_EXTENSION = [
        '-', '.', ',', '_', ' '
    ]
    DIGIT_EXTENSION = [
        '\\', '*', '#', '%', '&', '(', ')',
        '[', ']', '"', ';', ':', '^', '<',
        '>', '?', '!', '/', '\'', '`', '~', '=', '+', '@', '$'
    ]
    CHARACTER_TABLE = [
        ['xx', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
        ['xxx', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '-'],
        ['xxx', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '_', ' ']
    ]
    DIGIT_TABLE = [
        ['xx', '1', '2', '3', '\\', '*', '#', '%', '&', '(', ')', '[', ']'],
        ['xxx', '4', '5', '6', '0', '"', ';', ':', '^', '<', '>', '?', '!'],
        ['XXX', '7', '8', '9', '/', '\'', '`', '~', '=', '+', '@', '$']
    ]

    SPECIAL_CHARACTER_TABLE = [
        ['xx', 'á', 'å', 'ß', 'é', 'ē', 'í', 'î', 'ó', 'ô', 'ł', 'ú', 'û'],
        ['xx', 'ä', 'â', 'ç', 'ë', 'ê', 'ï', 'ī', 'ö', 'ō', 'ñ', 'ü', 'ś'],
        ['xx', 'à', 'ą', 'ć', 'è', 'ę', 'ì', 'į', 'ò', 'õ', 'ń', 'ù', 'ź', 'ż']
    ]

    @staticmethod
    def _parse_table_and_get_position(in_char, table):
        """
        Get position of matching character
        :input_char : input character
        :return: (row,column)
        """
        row, column = None, None
        for index, value in enumerate(table):
            if in_char in value:
                row, column = index, value.index(in_char)
                return (row, column)
        if not row or not column:
            raise ValueError('Position of character not found')
        return row, column

    def get_mode_for_character(self, input_char):
        """
        Get the keyboard mode for the input character
        :input_char : input character
        :return: mode of the keyboard that shows this character
        """
        if (input_char.isalpha() and ord(input_char) not in range(65, 91)
                and ord(input_char) not in range(97, 123)):
            mode = KeyboardMode.SPECIAL
        elif input_char.isalpha() or input_char in self.NORMAL_EXTENSION:
            mode = KeyboardMode.CHAR
        elif input_char.isdigit() or input_char in self.DIGIT_EXTENSION:
            mode = KeyboardMode.DIGIT
        else:
            mode = KeyboardMode.SPECIAL
        return mode

    def get_position_of_character(self,
                                  in_char):
        """
        Get the keyboard mode for the input character
        :input_char : input character
        :return: Position of the character if found, else (-1,-1)
        """
        in_mode = self.get_mode_for_character(in_char)
        if in_mode == KeyboardMode.CHAR:
            small_char = in_char.lower()
            row, column = \
                self._parse_table_and_get_position(small_char,
                                                   self.CHARACTER_TABLE)
        elif in_mode == KeyboardMode.DIGIT:
            row, column = \
                self._parse_table_and_get_position(in_char,
                                                   self.DIGIT_TABLE)
        elif in_mode == KeyboardMode.SPECIAL:
            small_char = in_char.lower()
            row, column = \
                self._parse_table_and_get_position(small_char,
                                                   self.SPECIAL_CHARACTER_TABLE)
        else:
            raise ValueError("Character " + in_char + " not handled yet")
        return row, column
