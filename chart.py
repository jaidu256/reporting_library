import os

import matplotlib.pyplot as plt
import openpyxl

class chart():

	# ************************************************************************************************************* #
	# ******************************************* CHART PROPERTIES ************************************************ #
	# ************************************************************************************************************* #
	# *																											  *	#
	# *				"kind": 'scatter', #(line, bar, barh, hist, box, kde, density, area, pie, scatter, hexbin)	  *	#
	# *				"x": 'Cost',																				  *	#
	# *				"y": 'Revenue',																				  *	#
	# *				"xlabel":'Cost in $',																		  *	#
	# *				"ylabel": 'Revenue in $',																	  *	#
	# *				"use_index": True,																			  *	#
	# *				"title": 'Title of the graph',																  *	#
	# *				"grid": True,																				  *	#
	# *				"legend": True,																				  *	#
	# *				"color": 'green',																			  *	#
	# *				"xlim": None,																				  *	#
	# *				"ylim": None,																				  *	#
	# *				"fontsize": None,																			  *	#
	# *				"label_rotation": 0,																		  *	#
	# *				"c": None,																					  *	#
	# *				"grid_size": [10,10],																		  *	#
	# *				"reduce": 'mean',																			  *	#
	# *				"colorbar": False,																			  *	#
	# *				"stacked": False,																			  *	#
	# *				"Colormap": {},																				  *	#
	# *				"alpha": 0.5,																				  *	#
	# *				"by": 'col_name',																			  *	#
	# *				"subplots": True,																			  *	#
	# *																											  * #
	# ************************************************************************************************************* #
	
	def __init__(self, data, props, save_loc, to_date_str):

		self.data = data
		
		# *** KIND *** #
		if 'kind' in props.keys():
			self.kind = props['kind']
		else:
			self.kind = 'line'
		# ------ #

		# *** X - Values *** #
		if 'x' in props.keys():
			self.x = props['x']
		else:
			self.x = None
		# ------ #

		# *** Y - Values *** #
		if 'y' in props.keys():
			self.y = props['y']
		else:
			self.y = None
		# ------ #
		
		# *** FIG SIZE - Calculation *** #
			# ************************************************************ #
			# * 														 * #
			# * 		No Input from properties, Constant for now		 * #
			# * 										   				 * #
			# ************************************************************ #
		self.fig_size_range = 20
		self.aspect_ratio = 1.8

		self.figsize = (self.fig_size_range*self.aspect_ratio/5,self.fig_size_range/5)
		# ------ #

		# *** USE INDEX *** #
		if 'use_index' in props.keys():
			self.use_index = props['use_index']
		else:
			self.use_index = True
		# ------ #

		# *** TITLE *** #
		if 'title' in props.keys():
			self.title = props['title']
		else:
			self.title = 'Chart'
		# ------ #

		# *** GRID *** #
		if 'grid' in props.keys():
			self.grid = props['grid']
		else:
			self.grid = None
		# ------ #

		# *** LEGEND *** #
		if 'legend' in props.keys():
			self.legend = props['legend']
		else:
			self.legend = False
		# ------ #

		# *** COLOR *** # 
		if 'color' in props.keys():
			self.color = props['color']
		else:
			self.color = None
		# ------ #

		# *** X - LIMIT *** #
		if 'xlim' in props.keys():
			self.xlim = props['xlim']
		else:
			self.xlim = None
		# ------ #

		# *** Y - LIMIT *** #
		if 'ylim' in props.keys():
			self.ylim = props['ylim']
		else:
			self.ylim = None
		# ------ #

		# *** FONTSIZE *** #
		if 'fontsize' in props.keys():
			self.fontsize = props['fontsize']
		else:
			self.fontsize = None
		# ------ #

		# *** LABEL ROTATION *** #
			# -- Denoted as rot in the main function -- #
		if 'label_rotation' in props.keys():
			self.label_rotation = props['label_rotation']
		else:
			self.label_rotation = None
			# -- #
		# ------ #
		
		# *** --- Only for use with scatter plots --- *** #
		# *** COLOR of DATA POINTS *** #
		# -- C -- #
		if 'c' in props.keys():
			self.c = props['c']
		else:
			self.c = None
		# -- #
		# -- COLORMAP -- #
		if 'Colormap' in props.keys():
			self.Colormap = props['Colormap']
		else:
			self.Colormap = None
		# -- #
		# -- S - Size parameter -- #
		if 's' in props.keys():
			self.s = data[props['s']]*30
		else:
			self.s = None
		# -- #
		# ------ #
		# ---====--- #

		# *** --- Only for use with Hexbin plots --- *** #
		# *** GRID SIZE *** #
			# -- Denoted by C in the main function -- #
		if 'grid_size' in props.keys():
			self.grid_size = props['grid_size']
		else:
			self.grid_size = (10, 10)\
			# -- #
		# ------ #
		# *** REDUCE FUNCTION *** #
			# -- Denoted by reduce_C_function in the main function -- #
		if 'reduce' in props.keys():
			self.reduce = props['reduce']
		else:
			self.reduce = 'mean'
			# -- #
		# ------ #
		# ---====--- #

		# *** --- Only for use with scatter plots and hexbin Plots --- *** #
		# *** COLOR BAR on the Side *** #
		if 'colorbar' in props.keys():
			self.colorbar = props['colorbar']
		else:
			self.colorbar = False
		# ------ #
		# ---====--- #

		# *** --- Only for use with Bar Plots --- *** #
		# *** STACKED PLOT *** #
		if 'stacked' in props.keys():
			self.stacked = props['stacked']
		else:
			if self.kind == 'area':
				self.stacked = True
			else:
				self.stacked = False
		# ------ #
		# ---====--- #
		
		# *** X - LABEL *** #
		if 'xlabel' in props.keys():
			self.xlabel = props['xlabel']
		else:
			self.xlabel = ''
		# ------ #

		# *** Y - LABEL *** #
		if 'ylabel' in props.keys():
			self.ylabel = props['ylabel']
		else:
			self.ylabel = ''
		# ------ #

		# *** --- Only for histograms --- *** #
		# *** alpha *** #
		if 'alpha' in props.keys():
			self.alpha = props['alpha']
		else:
			self.alpha = 1
		# ---- #
		# ---====--- #

		# *** --- FOR BOX PLOTS ONLY --- *** #
		# *** BY COLUMN *** #
		if 'by' in props.keys():
			self.by = props['by']
		else:
			self.by = None
		# ---- #
		# ---====--- #

		if 'subplots' in props.keys():
			self.subplots = props['subplots']
		else:
			self.subplots = None



		# * * * * * * * * System utility parameters * * * * * * * * #

		# *** SAVE LOCATION *** #
		self.save_loc = save_loc
		self.to_date_str = to_date_str
		self.save_path =  os.path.join(self.save_loc, (self.title + ' ' + self.to_date_str + '.png'))

		# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #

	# -- Saving figure -- #

	def save(self):
		plt.gcf()
		plt.savefig(self.save_path)
	
	# -- #

	# -- Individual Functions for each plot type -- #

	def line(self):
		plot = self.data.plot(kind = 'line', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							stacked = self.stacke)
		
		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def bar(self):
		plot = self.data.plot(kind = 'bar', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							stacked = self.stacked)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def barh(self):
		plot = self.data.plot(kind = 'barh', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							stacked = self.stacked)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def hist(self):
		plot = self.data.plot(kind = 'hist', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							alpha = self.alpha)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def box(self):
		plot = self.data.plot(kind = 'box', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							by = self.by)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def kde(self):
		plot = self.data.plot(kind = 'kde', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def density(self):
		plot = self.data.plot(kind = 'density', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def area(self):
		plot = self.data.plot(kind = 'area', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							stacked = self.stacked)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def pie(self):
		plot = self.data.plot(kind = 'pie', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation,
							subplots = self.subplots)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def scatter(self):
		plot = self.data.plot(kind = 'scatter', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation)
							#, c = self.c, colormap = self.colorbar, s = self.s)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	def hexbin(self):
		plot = self.data.plot(kind = 'hexbin', x = self.x, y = self.y, figsize = self.figsize, use_index = self.use_index,
							title = self.title, grid = self.grid, legend = self.legend, color = self.color,
							xlim = self.xlim, ylim = self.ylim, fontsize = self.fontsize, rot = self.label_rotation)

		plt.xlabel(self.xlabel)
		plt.ylabel(self.ylabel)
		self.save()

	# --====-- #

	# -- Master function calling individual plotting functions -- #
	def plot(self):
		
		if self.kind == 'line':
			plot = self.line()

		elif self.kind == 'bar':
			plot = self.bar()

		elif self.kind == 'barh':
			plot = self.barh()

		elif self.kind == 'hist':
			plot = self.hist()

		elif self.kind == 'box':
			plot = self.box()

		elif self.kind == 'kde':
			plot = self.kde()

		elif self.kind == 'density':
			plot = self.density()

		elif self.kind == 'area':
			plot = self.area()

		elif self.kind == 'pie':
			plot = self.pie()

		elif self.kind == 'scatter':
			plot = self.scatter()

		elif self.kind == 'hexbin':
			plot = self.hexbin()
	# --====-- #

	def insert_plot(self, sheet, row, col):
		self.plot()
		fig = openpyxl.drawing.image.Image(self.save_path)
		fig.anchor(sheet.cell(row = row, column = col))
		sheet.add_image(fig)



	#plot = data.plot(kind = table['chart-properties']['kind']
					#			   , x = table['chart-properties']['x']
					#			   , y = table['chart-properties']['y']
					#			   , color = table['chart-properties']['color']
					#			   , grid = table['chart-properties']['grid']
					#			   , legend = table['chart-properties']['legend']
					#			   , fontsize = table['chart-properties']['fontsize']
					#			   , rot = table['chart-properties']['label_rotation']
					#			   , figsize = (table['chart-properties']['figsize']*table['chart-properties']['aspect_ratio']/5,table['chart-properties']['figsize']/5))
					
	#fig = plot.get_figure()
	#plt.title(table['table_name'])
	#plt.xlabel(table['chart-properties']['xlabel'])
	#plt.ylabel(table['chart-properties']['ylabel'])
	#print(table['chart-properties']['xlabel'])
	#plt.gcf()
	#plt.savefig("C:\\Users\\adusjai\\Desktop\\Daily Dashboard New\\Test\\bi_ddb_docker\\bi_ddb\\fig.png")
	#fig = openpyxl.drawing.image.Image("C:\\Users\\adusjai\\Desktop\\Daily Dashboard New\\Test\\bi_ddb_docker\\bi_ddb\\fig.png")
	#fig.anchor(sheets[i].cell(row = strtRow, column = 1))
	#sheets[i].add_image(fig)
