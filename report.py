import os
import glob
import pandas
import datetime
import traceback

from .sys_config import sys

from reports_base.base import biReports
from reports_base import cell, sheet

# -- for emailing report -- #
import smtplib
from email import encoders
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
# -- #

# -- For Docker -- #
from afn_config.afn_config import get_list_from_config
import logging
from afn_logging import configure_logging
# -- #

class Report():
    def __init__(self, config):

        super(Report, self).__init__()
        configure_logging()

        # -- sys attributes -- #

        self.today = datetime.date.today()
        self.to = self.today.strftime('%Y.%m.%d')

        self.root_loc = sys['dir']['root']

        self.smtp_server = sys['mail']['server']
        self.fromAddr = sys['mail']['fromaddr']
        self.reply_to = sys['mail']['team']
        self.toAddr_error = sys['mail']['team']

        # -- General attributes -- #

        self.__app_name = config['app_name']
        self.app_name_modified = (' '.join(x.capitalize() for x in self.__app_name.replace('_', ' ').split()))

        self.writer = pandas.ExcelWriter((config['app_name'] + '.xlsx'), engine='openpyxl')
        self.workbook = self.writer.book

        self.qryLoc = config['dir']['qry_loc']
        self.fileLoc = os.path.join(self.root_loc, config['dir']['save_loc'])
        self.chart_loc = os.path.join(self.root_loc, config['dir']['chart_loc'])

        self.mail_body = config['mail']['gen']['body']

        self.error_subject = self.app_name_modified + " - failed"
        self.error_body = config['mail']['error']['body']

        self.worksheets = config['worksheets']

        # -- Docker Attributes -- #
        if 'multiple_reports' not in config.keys() or config['multiple_reports'] == False:
            self.toAddr = get_list_from_config(config['app_name'],',')
            self.filename = self.app_name_modified + ' - ' + self.to + '.xlsx'
            self.subject = self.app_name_modified + " - " + self.to
            self.MAX_ARCHIVE_COUNT = sys['general']['max_archive_count']

        elif config['multiple_reports']:
            self.u_id = config['u_id']
            self.name = config['name']
            self.name_modified = (' '.join(x.capitalize() for x in self.name.replace('_', ' ').split()))
            self.toAddr = config['email']
            self.filename = self.app_name_modified + ' - ' + self.to + " - " + self.name_modified + '.xlsx'
            self.subject = self.app_name_modified + " - " + self.to + ": " + self.name_modified

            self.MAX_ARCHIVE_COUNT = config['max_archive_count']

        if 'base' not in config.keys() or config['base'] == None:
            self.base = None
        else:
            self.base = config['base']

        self.cnxn = biReports.connect()

        self.logger = logging.getLogger(self.__app_name)

    def base_execution(self):
        if self.base != None:
            cursor = self.cnxn.cursor()

            qry = biReports.readQuery(os.path.join(self.qryLoc, self.base))
            cursor.execute(qry)

    def extract_data(self, table_config):
        self.logger.info('Running Extract Data Function')
        if 'query' not in table_config.keys():
            data = pandas.DataFrame()
            pass
        else:
            if table_config['query'] is not None:
                if 'filter' not in  table_config.keys() or table_config['filter'] == False:
                    qry = biReports.readQuery(os.path.join(self.qryLoc, table_config['query']))
                    data = biReports.extractData(qry, self.cnxn)
                elif table_config['filter']:
                    qry = biReports.readQueryVars(os.path.join(self.qryLoc, table_config['query']), self.u_id)
                    data = biReports.extractData(qry, self.cnxn)
            else:
                data = pandas.DataFrame()
        return data


    def data_processing(self, data, table_config):
        self.logger.info('Running Data_processing function')
        if 'ad_hoc_processing' not in table_config:
            pass
        else:
            if table_config['ad_hoc_processing'] is None:
                pass
            else:
                data = table_config['ad_hoc_processing'](self.qryLoc, data)
        return data

    def lev(self, data):
        if type(data.columns) == pandas.MultiIndex:
            levels_col = len(data.columns.levels)
        else:
            levels_col = 0

        if type(data.index) == pandas.MultiIndex:
            levels_in = len(data.index.levels)
        elif type(data.index) not in (pandas.Int64Index, pandas.RangeIndex):
            levels_in = 1
        else:
            levels_in = 0

        return levels_col, levels_in

    def data_dump(self, data, table_config, tab_name, start_row, start_column = 0, levels_col = 0, levels_in = 0):
        self.logger.info('Running data_dump function')
        if 'table_name' not in table_config.keys():
            pass
        else:
            if table_config['table_name'] is not None:
                start_row += 1

        if levels_col == 0 and levels_in == 0:
            index = False
        else:
            index = True

        if len(data) != 0:
            data.to_excel(self.writer, sheet_name=tab_name, startrow=start_row, startcol=start_column, index=index)
            if levels_col == 0:
                start_row += (len(data) + 1)
            else:
                start_row += (len(data) + 1 + (levels_col))
        else:
            d = pandas.DataFrame({'No Data': 'No Data'}, index = [0])
            d.to_excel(self.writer, sheet_name=tab_name, startrow=start_row, startcol=start_column, index=index)
            start_row += (len(d) + 1)

        if 'description' not in table_config:
            pass
        else:
            if table_config['description'] is not None:
                start_row += 1

        start_row += 2
        return start_row

    def save_sheet(self, list_of_sheets, tab_name):
        self.logger.info('Running save_sheet function')
        worksheet = self.writer.sheets[tab_name]
        list_of_sheets.append(worksheet)

    def preliminary_formatting(self, list_of_sheets):
        self.logger.info('Running preliminary_formatting function')
        for s in list_of_sheets:
            sheet.autofit(s)
            sheet.hide_grid_lines(s)

    def format_table_heading(self, data, sheet, table_config, start_row, start_column = 1, levels_col = 0, levels_in = 0):
        self.logger.info('Running format_table_heading function')
        if 'table_name' not in table_config.keys():
            pass
        else:
            if table_config['table_name'] is not None:
                if len(data) != 0:
                    if levels_col == 0:
                        if len(data.columns) >= 4:
                            end_column = 4
                        else:
                            end_column = len(data.columns)
                    else:
                        e = 1
                        x = -1
                        for i in range(len(data.columns.levels)):
                            e = e * len(data.columns.levels[x])
                            x = x - 1
                        e += levels_in
                        if e > 4:
                            end_column = 4
                        else:
                            end_column = e

                else:
                    end_column = 4

                horizontal_alignment = 'center'
                vertical_alignment = 'center'

                sheet.cell(row = start_row, column = start_column).value = table_config['table_name']
                sheet.merge_cells(start_row = start_row, start_column = start_column, end_row = start_row, end_column = end_column)
                cell.align(sheet, start_row=start_row, end_row=start_row, start_col=start_column, end_col=end_column,
                            horizontal = horizontal_alignment, vertical = vertical_alignment)
                cell.table_head(sheet, start_row=start_row, end_row=start_row, start_col=start_column, end_col=end_column)
                start_row += 1

        return start_row

    def format_table_body(self, data, sheet, table_config, start_row, start_column = 1, levels_col = 0, levels_in = 0):
        self.logger.info('Running format_table_body function')
        if len(data) == 0:
            data = pandas.DataFrame({'No Data': 'No Data'}, index = [0])

        if levels_col == 0 and levels_in == 0:
            end_row = start_row + len(data)
            end_column = len(data.columns)
            levels = 1
        elif levels_col == 0 and levels_in != 0:
            end_row = start_row + len(data)
            end_column = len(data.columns) + levels_in
            levels = 1
        else:
            end_row = start_row + len(data) + len(data.columns.levels)
            end_column = 1
            x = -1
            for i in range(len(data.columns.levels)):
                end_column = end_column * len(data.columns.levels[x])
                x = x - 1
            end_column = (end_column + levels_in)
            if levels_in == 0:
                levels = len(data.columns.labels)
            else:
                levels = len(data.columns.labels) + 1

        cell.align(sheet, start_row=start_row, end_row= end_row, start_col=start_column, end_col= end_column, horizontal = 'center', vertical = 'center')

        for i in range(levels):
            cell.column_head(sheet, start_row = start_row, end_row = start_row, start_col = start_column, end_col = end_column)
            start_row += 1
        start_row -= 1

        cell.column_rows(sheet, start_row = start_row+1, end_row = end_row, start_col = start_column, end_col = end_column)
        cell.num_format(sheet, start_row = start_row, end_row = end_row, start_col = start_column, end_col = end_column)
        cell.conditional_formatting(sheet, len(data), data, self.today, start_row = start_row, end_row = end_row, start_col = 1, end_col = end_column)

        cell.totals(sheet, len(data), data, self.today, start_row = start_row, end_row = end_row, start_col = 1, end_col = end_column)

        start_row += (len(data) + 1)

        return start_row

    def format_table_footer(self, data, sheet, table_config, start_row, start_column = 1, levels_col = 0, levels_in = 0):
        self.logger.info('Running format_table_footer function')
        if len(data) != 0:
            if levels_col == 0:
                end_column = len(data.columns)
            else:
                end_column = 1
                x = -1
                for i in range(len(data.columns.levels)):
                    end_column = end_column * len(data.columns.levels[x])
                    x = x - 1
                end_column = (end_column + levels_in)
        else:
            end_column = 10

        if 'description' not in table_config:
            pass
        else:
            if table_config['description'] is not None:
                sheet.cell(row = start_row, column = start_column).value = table_config['description']

                sheet.merge_cells(start_row = start_row, start_column = start_column, end_row = start_row, end_column = end_column)
                cell.align(sheet, start_row=start_row, end_row=start_row, start_col=start_column, end_col=1, horizontal = 'center', vertical = 'center')
                cell.table_foot(sheet, start_row = start_row, end_row = start_row, start_col = start_column, end_col = end_column)
                start_row += 1
        start_row += 2

        return start_row

    def clear_archive(self):
        self.logger.info('Running clear_archive function')
        archived_reports = glob.glob(self.fileLoc + self.__app_name + '*.xlsx')
        if len(archived_reports) > self.MAX_ARCHIVE_COUNT:
            archived_reports.sort()
            oldest_report = archived_reports[0]
            os.remove(oldest_report)

    def mail_report(self):
        self.logger.info('Running mail_report function')
        msg = MIMEMultipart()

        msg['From'] = self.fromAddr
        msg['Subject'] = self.subject
        msg.add_header('reply-to', self.reply_to)

        msg.attach(MIMEText(self.mail_body, 'plain'))

        filename = '{0}.xlsx'.format(self.filename)
        attachment = open(os.path.join(self.fileLoc, self.filename), "rb")

        part = MIMEBase('application', 'octet-stream')
        part.set_payload((attachment).read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', "attachment; filename= %s" % filename)
        msg.attach(part)
        with smtplib.SMTP(self.smtp_server) as s:
            s.sendmail(self.fromAddr, self.toAddr, msg.as_string())

    def mail_error(self, error_code):
        self.logger.info('Running mail_error function')
        a = traceback.format_exception(None,  # <- type(error_code) by docs, but ignored
                                           error_code, error_code.__traceback__)
        msg = MIMEMultipart()

        msg['From'] = self.fromAddr
        msg['Subject'] = self.error_subject

        msg.attach(MIMEText('error:\n' + str(a) + '\n' + self.error_body))

        with smtplib.SMTP(self.smtp_server) as s:
            s.sendmail(self.fromAddr, self.toAddr_error, msg.as_string())

    def genReport(self):

        self.logger.info('Running genReport function')
        try:
            self.base_execution()
            sheets = list()

            self.logger.info('Building Sheets in Workbook')
            for tabName, tables in self.worksheets.items():

                self.logger.info(tabName)
                strtRow = 0
                for table in tables:
                    data = self.extract_data(table)
                    data = self.data_processing(data, table)

                    levels_c, levels_i = self.lev(data)
                    strtRow = self.data_dump(data, table, tabName, strtRow, levels_col = levels_c, levels_in = levels_i)

                self.save_sheet(sheets, tabName)

            self.logger.info('Formatting Workbook.')
            self.preliminary_formatting(sheets)
            i = 0
            for tabName, tables in self.worksheets.items():

                self.logger.info(tabName)
                strtRow = 1
                for table in tables:

                    data = self.extract_data(table)
                    data = self.data_processing(data, table)

                    levels_c, levels_i = self.lev(data)

                    strtRow = self.format_table_heading(data, sheets[i], table, strtRow, levels_col = levels_c, levels_in = levels_i)
                    strtRow = self.format_table_body(data, sheets[i], table, strtRow, levels_col = levels_c, levels_in = levels_i)
                    strtRow = self.format_table_footer(data, sheets[i], table, strtRow, levels_col = levels_c, levels_in = levels_i)

                i += 1

            self.logger.info('Saving Workbook.')
            biReports.saveFile(self.workbook, os.path.join(self.fileLoc, self.filename))

            self.logger.info('Emailing Workbook.')
            self.mail_report()

            self.logger.info('Cleaning Repoitory')
            self.clear_archive()

            self.cnxn.close()

        except Exception as e:
            self.logger.info('Sending Error Message')
            self.logger.error(e)
            self.mail_error(e)

            self.cnxn.close()


        # ------------------------------------------------------------------------------------------------- #

        '''
        # -- Provision for Charts -- #
                if table['chart']:
                    strtRow += 20
                    strtRow += 3
                # -- #
        '''
        # ------------------------------------------------------------------------------------------------- #

        '''
        # -- Inserting Chart -- #
                if table['chart']:
                    plot = chart(data, table['chart-properties'], self.chart_loc, self.to)
                    plot.insert_plot(sheets[i], row = strtRow, col = 1)
                    
                    strtRow += 20
                    strtRow += 3
                # -- #
        '''
        # ------------------------------------------------------------------------------------------------- #

        '''
        "formatting":
                {
                    "column_header":
                    {
                        "FFE0B2": ["Day", "Date"],
                        "C8E6C9": ["Budget (Rev)", "Budget (Spr)", "Budget (Margin %)"],
                    }
                },
        '''