import os
import pyodbc
import pandas

import glob

class biReports(object):
	def __init__(self):
		__app_name = 'BI Report'

	@staticmethod
	def connect():
		return pyodbc.connect('DRIVER={0};SERVER={1};PORT={2};DATABASE={3};UID={4};PWD={5}'.format(
		    os.environ.get("SQL_DRIVER"),
		    'afnvbiprod.advfrtsvr.advantagefreight.com',
		    '1433',
		    'bi_prod',
		    'svc_bi_poc',
		    'NoDollar^pocBI#DW'))

	@staticmethod
	def readQuery(path):
		return open(path).read()

	@staticmethod
	def readQueryVars(path, u_id):
		return open(path).read().format(u_id)

	@staticmethod
	def extractData(query, cnxn, params=None):
		return pandas.read_sql_query(query, cnxn, params=params)

	@staticmethod
	def saveFile(workbook, path):
		workbook.save(path)