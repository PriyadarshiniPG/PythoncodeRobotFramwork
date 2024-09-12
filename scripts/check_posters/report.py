import tools
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image
from reportlab.lib.styles import getSampleStyleSheet


class Analyzer(object):
    """A class to provide statistics for the report."""

    def __init__(self, db_file):
        self.db_conn = tools.db_connect(db_file)

    def get_dates(self):
        sql = "SELECT DISTINCT date FROM recs"
        dates = [item[0] for item in tools.db_query(self.db_conn, sql)]
        return dates

    def get_channels(self, date):
        sql = "SELECT DISTINCT channel FROM recs WHERE date = '%s'" % date
        channels = [item[0] for item in tools.db_query(self.db_conn, sql)]
        return channels

    def get_events_poster_missing(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'poster' AND url IS NULL" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_poster_unreachable(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'poster' \
                     AND url IS NOT NULL AND response_code != 200" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_poster_ok(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'poster' AND response_code = 200" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_wall_missing(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'wall' AND url IS NULL" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_wall_unreachable(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'wall' \
                     AND url IS NOT NULL and response_code != 200" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_wall_ok(self, date, channel):
        sql = "SELECT * FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'wall' AND response_code = 200" \
              % (date, channel)
        rows = tools.db_query(self.db_conn, sql)
        return rows

    def get_events_info(self, day, channel):
        sql = "SELECT channel, title, start, own_id, own_title, own_start, own_end FROM recs \
               WHERE date = '%s' AND channel = '%s' AND category = 'wall' " % (day, channel)
        info = {"day": day, "channel": channel,
                "total": tools.db_query(self.db_conn, sql),
                "no_id": tools.db_query(self.db_conn, sql + "AND own_id = 'missing';"),
                "no_title": tools.db_query(self.db_conn, sql + "AND own_title = 'missing';"),
                "no_start": tools.db_query(self.db_conn, sql + "AND own_start = 'missing';"),
                "no_end": tools.db_query(self.db_conn, sql + "AND own_end = 'missing';")}
        return info

    def get_images_info(self, day, channel):
        info = {"no_posters": self.get_events_poster_missing(day, channel),
                "bad_posters": self.get_events_poster_unreachable(day, channel),
                "ok_posters": self.get_events_poster_ok(day, channel),
                "no_walls": self.get_events_wall_missing(day, channel),
                "bad_walls": self.get_events_wall_unreachable(day, channel),
                "ok_walls": self.get_events_wall_ok(day, channel)}
        return info

    @staticmethod
    def get_info_counts(info):
        return {k: v if k in ["day", "channel"] else len(v) for k, v in info.items()}


class PDF(object):
    """A class to generate PDF files. Supported elements are: text (paragraphs), images, tables."""

    def __init__(self, file_name):
        self.doc = SimpleDocTemplate(file_name, pagesize=letter)
        self.styles = getSampleStyleSheet()
        self.elements = []

    def save(self):
        """Write all the elements to a PDF file.
        A file name provided at class initialization stage will be used.
        """
        self.doc.build(self.elements)

    def add_paragraph(self, text, style=None):
        """Create and return a text element (paragraph) using given or default style,
        append it to the list of report's elements.
        """
        paragraph = self.make_paragraph(text, style)
        self.elements.append(paragraph)
        return paragraph

    def add_table(self, data, style=None):
        """Create and return a table element using given or default style,
        append it to the list of report's elements.
        """
        table = self.make_table(data, style)
        self.elements.append(table)
        return table

    def add_image(self, image_file_name, image_height_cm=1, image_width_cm=1):
        """Create and return an image element of the desired image size
        (in centimeters, default is 1x1), append it to the list of report's elements.
        """
        image = self.make_image(image_file_name, image_height_cm, image_width_cm)
        self.elements.append(image)
        return image

    def make_paragraph(self, text, style=None):
        """Create and return a text element (paragraph) using given or default style."""
        style = style or self.styles["BodyText"]
        paragraph = Paragraph(text, style)
        return paragraph

    @staticmethod
    def make_table(data, style=None):
        """Create and return a table element using given or default style."""
        style = style or [('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                          ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                          ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                          ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.gray),
                          ('BOX', (0, 0), (-1, -1), 1, colors.gray)]
        table = Table(data)
        table.setStyle(TableStyle(style))
        return table

    @staticmethod
    def make_image(image_file_name, image_height_cm=1, image_width_cm=1):
        """Create and return an image element of the desired size in centimeters, default is 1x1."""
        image = Image(image_file_name)
        image.drawHeight = image_height_cm * cm * image.drawHeight / image.drawWidth
        image.drawWidth = image_width_cm * cm
        return image


class Report(object):

    def __init__(self):
        self.images_ok = None
        self.events_ok = None
        self.styles = [('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
                       ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                       ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                       ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.gray),
                       ('BOX', (0, 0), (-1, -1), 1, colors.gray)]

    def make_table_images(self, data):
        self.images_ok = True
        styles = [style for style in self.styles]
        i = 1
        while i < len(data):
            if data[i][1] != data[i][4]:
                styles.append(('TEXTCOLOR', (2, i), (4, i), colors.red))
                self.images_ok = False
            if data[i][1] != data[i][7]:
                styles.append(('TEXTCOLOR', (5, i), (-1, i), colors.red))
                self.images_ok = False
            j = 2
            while j < len(data[i]):
                data[i][j] = "%s\n%.2f %%" % (data[i][j], 100 * data[i][j] / data[i][1])
                j += 1
            i += 1
        table = Table(data)
        table.setStyle(TableStyle(styles))
        #for x in range(len(data[0])):
        #    table._argW[x] = 3 * cm
        return table

    def make_table_events(self, data):
        self.events_ok = True
        styles = [style for style in self.styles]
        i = 1
        while i < len(data):
            j = 2
            while j < len(data[i]):
                if data[i][j] != 0:
                    styles.append(('TEXTCOLOR', (j, i), (j, i), colors.red))
                    self.events_ok = False
                data[i][j] = "%s\n%.2f %%" % (data[i][j], 100 * data[i][j] / data[i][1])
                j += 1
            i += 1
        table = Table(data)
        table.setStyle(TableStyle(styles))
        #for x in range(len(data[0])):
        #    table._argW[x] = 3 * cm
        return table

    @staticmethod
    def make_images_appendix(day, channel, events):
        text = ""
        for item in events["no_posters"]:
            text += "[%s] Missing poster: '%s' at %s<br/>" % (channel, item[8], item[2])
        for item in events["no_walls"]:
            text += "[%s] Missing wall: '%s' at %s<br/>" % (channel, item[8], item[2])
        for item in events["bad_posters"]:
            text += "[%s] Unreachable poster: '%s' at %s<br/>" % (channel, item[8], item[2])
        for item in events["bad_walls"]:
            text += "[%s] Unreachable wall: '%s' at %s<br/>" % (channel, item[8], item[2])
        if text:
            text += '<a href="#%s"><u><i>Go Up to day %s</i></u></a>' % (day, day)
            text = '<a name="%s_%s"/><b>%s, Channel %s - Bad items:</b><br/>%s' % \
                   (day, channel, day, channel, text)
        return text

    @staticmethod
    def make_events_appendix(day, channel, events):
        text = ""
        for item in events["no_id"]:
            text += "[%s] Missing ID: '%s' at %s<br/>" % (channel, item[1], item[2])
        for item in events["no_title"]:
            text += "[%s] Missing title: '%s' at %s<br/>" % (channel, item[1], item[2])
        for item in events["no_start"]:
            text += "[%s] Missing startTime: '%s' at %s<br/>" % (channel, item[1], item[2])
        for item in events["no_end"]:
            text += "[%s] Missing endTime: '%s' at %s<br/>" % (channel, item[1], item[2])
        if text:
            text += '<a href="#%s"><u><i>Go Up to day %s</i></u></a>' % (day, day)
            text = '<a name="%s_%s"/><b>%s, Channel %s - Bad items:</b><br/>%s' % \
                   (day, channel, day, channel, text)
        return text

    def create_images_report(self, db_fname, report_fname):
        report = PDF(report_fname)
        analyzer = Analyzer(db_fname)
        for day in analyzer.get_dates():
            day_appendices = []
            report.add_paragraph('<a name="%s"/>%s' % (day, day))
            day_table = [["Channel", "Events", "No poster", "Bad poster", "Ok Poster",
                                               "No Wall", "Bad Wall", "Ok Wall"]]
            for channel in analyzer.get_channels(day):
                events = analyzer.get_events_info(day, channel)
                events.update(analyzer.get_images_info(day, channel))
                counts = analyzer.get_info_counts(events)
                if not (counts["total"] == counts["ok_posters"] == counts["ok_walls"]):
                    channel_link = report.make_paragraph('<a href="#%s_%s"><u>%s</u></a>' % \
                                                         (day, channel, channel))
                    text = self.make_images_appendix(day, channel, events)
                    if text:
                        day_appendices.append(report.make_paragraph(text))
                    else:
                        channel_link = channel
                else:
                    channel_link = channel
                day_table.append([channel_link, counts["total"],
                                  counts["no_posters"], counts["bad_posters"], counts["ok_posters"],
                                  counts["no_walls"], counts["bad_walls"], counts["ok_walls"]])
            report.elements.append(self.make_table_images(day_table))
            for item in day_appendices:
                report.elements.append(item)
        report.save()

    def create_events_report(self, db_fname, report_fname):
        report = PDF(report_fname)
        analyzer = Analyzer(db_fname)
        for day in analyzer.get_dates():
            day_appendices = []
            report.add_paragraph('<a name="%s"/>%s' % (day, day))
            day_table = [["Channel", "Events", "No ID", "No Title", "No Start", "No End"]]
            for channel in analyzer.get_channels(day):
                events = analyzer.get_events_info(day, channel)
                counts = analyzer.get_info_counts(events)
                if not (counts["no_id"] == counts["no_title"] ==
                        counts["no_start"] == counts["no_end"] == 0):
                    channel_link = report.make_paragraph('<a href="#%s_%s"><u>%s</u></a>' % \
                                                         (day, channel, channel))
                    text = self.make_events_appendix(day, channel, events)
                    if text:
                        day_appendices.append(report.make_paragraph(text))
                    else:
                        channel_link = channel
                else:
                    channel_link = channel
                day_table.append([channel_link, counts["total"], counts["no_id"],
                                  counts["no_title"], counts["no_start"], counts["no_end"]])
            report.elements.append(self.make_table_events(day_table))
            for item in day_appendices:
                report.elements.append(item)
        report.save()


if __name__ == "__main__":
    Report().create_images_report("DE-de.db", "report-images-links.pdf")
    Report().create_events_report("DE-de.db", "report-events-items.pdf")
