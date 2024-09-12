"""
Classes for testing subtitles background
"""


class SubtitlesBackgroundImpl(object):
    """
    Keywords stateless implementation for subtitle background analysis
    """
    # pylint: disable=too-few-public-methods

    COLORS = {'BLUE': [128, 1, 1],
              'TELE_BLUE': [243, 0, 0],
              'GREEN': [1, 128, 1],
              'RED': [0, 0, 254],
              'WHITE': [254, 254, 254],
              'FREE SPEECH GREEN': [19, 255, 6],
              'GREY': [127, 143, 126]}

    def __init__(self, grabber_classobj, analyzer_classobj):
        self.analyzer_classobj = analyzer_classobj
        self.grabber_classobj = grabber_classobj

    def is_subtitles_background_color(self, color, selector):
        """
        :param color: name of the color. Valid color names are BLUE, GREEN, RED
        :param selector: path or url to image
        :return: True or False
        """
        if color not in self.COLORS:
            raise ValueError("Unexpected color")

        color_bgr = self.COLORS[color]
        analyzer = self.analyzer_classobj()
        grabber = self.grabber_classobj()
        return analyzer.is_color(grabber.grab_frame(selector).image, color_bgr)

    def is_teletext_available(self, selector):
        """
        :param selector: path or url to image
        :return: True or False
        """
        color_bgr = self.COLORS['TELE_BLUE']
        analyzer = self.analyzer_classobj()
        grabber = self.grabber_classobj()
        frame_area = {'x1': 1500, 'x2': 1550, 'y1': 200, 'y2': 250}
        return analyzer.is_color_in_region(
            grabber.grab_frame(selector).image, color_bgr, frame_area)

    def is_teletext_subtitle_page(self, selector, color, shape):
        """
        :param selector: path or url to image
        :param color: name of the color. Valid color names are BLUE, GREEN, RED
        :param shape: list of shape descriptors
            [0] - left bound of color region
            [1] - upper bound of color region
            [2] - width of color region
            [3] - height of color region
        :return: True or False
        """
        if color not in self.COLORS:
            raise ValueError("Unexpected color", color)

        color_bgr = self.COLORS[color]
        analyzer = self.analyzer_classobj()
        grabber = self.grabber_classobj()
        top_left_x = int(shape[0])
        top_left_y = int(shape[1])
        height = int(shape[2])
        width = int(shape[3])
        region = {'x1': top_left_x,
                  'x2': top_left_x + width,
                  'y1': top_left_y,
                  'y2': top_left_y + height}
        return analyzer.is_color_in_region(
            grabber.grab_frame(selector).image, color_bgr, region)

    def check_screen_area_has_specific_colour(self, selector, color, shape):
        """
        :param selector: path or url to image
        :param color: name of the color. Valid color names are available
                      in COLORS dictionary
        :param shape: list of shape descriptors
            [0] - left bound of color region
            [1] - upper bound of color region
            [2] - width of color region
            [3] - height of color region
        :return: True or False
        """
        if color not in self.COLORS:
            raise ValueError("Unexpected color", color)

        color_bgr = self.COLORS[color]
        analyzer = self.analyzer_classobj()
        grabber = self.grabber_classobj()
        top_left_x = int(shape[0])
        top_left_y = int(shape[1])
        height = int(shape[2])
        width = int(shape[3])
        region = {'x1': top_left_x,
                  'x2': top_left_x + width,
                  'y1': top_left_y,
                  'y2': top_left_y + height}
        return analyzer.is_color_in_region(
            grabber.grab_frame(selector).image, color_bgr, region)
