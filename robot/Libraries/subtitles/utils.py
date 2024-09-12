"""
Utility classes for this test library
"""
import abc


class ISubtitleBackground(object, metaclass=abc.ABCMeta):
    """
    Interface that any object implementing subtitle background keywords
    should implement
    """

    @abc.abstractmethod
    def is_subtitles_background_blue(self):
        """
            Check weather subtitles background is blue
        """
        raise NotImplementedError()

    @abc.abstractmethod
    def is_subtitles_background_green(self):
        """
            Check weather subtitles background is green
        """
        raise NotImplementedError()

    @abc.abstractmethod
    def is_subtitles_background_red(self):
        """
            Check weather subtitles background is red
        """
        raise NotImplementedError()


class SubtitlesBackgroundProxy(ISubtitleBackground):
    """
    A proxy class for ISubtitleBackground
    """
    def __init__(self, delegate):
        self.delegate = delegate

    def is_subtitles_background_blue(self):
        """
            Check weather subtitles background is blue
        """
        self.delegate.is_subtitles_background_blue()

    def is_subtitles_background_green(self):
        """
            Check weather subtitles background is green
        """
        self.delegate.is_subtitles_background_green()

    def is_subtitles_background_red(self):
        """
            Check weather subtitles background is red
        """
        self.delegate.is_subtitles_background_red()
