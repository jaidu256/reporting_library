import os
import json
import datetime

def dayBack():
	if (datetime.date.today().isocalendar()[2] == 1):
		return 3
	else:
		return 1

def process_config(config, root_path):
	for tab, tables in config['worksheets'].items():
		for table in tables:
			if 'ad_hoc_processing' not in table.keys():
				pass
			else:
				if table['ad_hoc_processing'] is not None:
					# importing module
					module_name = table['ad_hoc_module']
					module = __import__(module_name, fromlist = [module_name.split('.')[-1]])

					# importing function
					function_name = table['ad_hoc_processing']
					exec('func = module.' + function_name)

					# susbstiting string function name with actual function
					table['ad_hoc_processing'] = eval('func')
	config['dir']= dict()
	config['dir']['qry_loc'] = os.path.join(root_path, 'sql')
	config['dir']['save_loc'] = '/reports/'
	config['dir']['chart_loc'] = root_path
	return config

def read_json(config):
	config = json.load(open(config))
	return config