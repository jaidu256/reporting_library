select
	all_oth.*
	,b.[Bounce Percent]
	,b.[Bounce Percent PY]
	,b.[% Deviation (Bounce Percent)]
	,b.[Bounce Cost Percent]
	,b.[Bounce Cost Percent PY]
	,b.[% Deviation (Bounce Cost Percent)]
from
(
		select
			pb.mnum
			,pb.Month as 'Month'
	
			,(pb.Spread + byn.Spread)/ (pb.Volume + byn.Volume) as 'Spread Per Load'
			,(pb.[Spread PY] + byn.[Spread PY])/ (pb.[Volume PY] + byn.[Volume PY]) as 'Spread Per Load PY'
			,(((pb.Spread + byn.Spread) / (pb.Volume + byn.Volume)) - ((pb.[Spread PY] + byn.[Spread PY]) / (pb.[Volume PY] + byn.[Volume PY]))) / ((pb.[Spread PY] + byn.[Spread PY]) / (pb.[Volume PY] + byn.[Volume PY])) as 'YoY Change % (SPL)'

			,(pb.Loss + byn.Loss) / (pb.Spread + byn.Spread) as 'Loss percent (Spread)'
			,(pb.[Loss PY] + byn.[Loss PY]) / (pb.[Spread PY] + byn.[Spread PY]) as 'Loss Percent PY (Spread)'
			,(((pb.Loss + byn.loss) / (pb.Spread + byn.Spread)) - ((pb.[Loss PY] + byn.[Loss PY]) / (pb.[Spread PY] + byn.[Spread PY]))) as '% Deviation (Loss % - Spread)'

			,cast((pb.[Loss Vol] + byn.[Loss Vol]) as float) / (pb.Volume + byn.Volume) as 'Loss Percent (Volume)'
			,cast((pb.[Loss Vol PY] + byn.[Loss Vol PY]) as float) / (pb.[Volume PY] + byn.[Volume PY]) as 'Loss Percent PY (Volume)'
			,((cast((pb.[Loss Vol] + byn.[Loss Vol]) as float) / (pb.Volume + byn.Volume)) - (cast((pb.[Loss Vol PY] + byn.[Loss Vol PY]) as float) / (pb.[Volume PY] + byn.[Volume PY]))) as '% Deviation (Loss % - Vol)'

			,(pb.Loss + byn.Loss) as 'Loss Amt'
			,(pb.[Loss PY] + byn.[Loss PY]) as 'Loss Amt PY'
			,((pb.Loss + byn.loss) - (pb.[Loss PY] + byn.[Loss PY]))/(pb.[Loss PY] + byn.[Loss PY]) as 'YoY Change % (Loss)'
	
			,(pb.[Loss Vol] + byn.[Loss Vol]) as 'Loss Vol'
			,(pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'Loss Vol PY'
			,cast(((pb.[Loss Vol] + byn.[Loss Vol]) - (pb.[Loss Vol PY] + byn.[Loss Vol PY])) as float)/(pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'YoY Change % (Loss Vol)'
	
			,(pb.Loss + byn.Loss) / (pb.[Loss Vol] + byn.[Loss Vol]) as 'Loss Per Load'
			,(pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss PY]) as 'Loss Per Load PY'
			,(((pb.Loss + byn.Loss) / (pb.[Loss Vol] + byn.[Loss Vol])) - ((pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss PY])) ) / ((pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss PY])) as 'YoY Change % (Loss Per Load)'
	
			,pb.[Roll Count]
			,pb.[Roll Count PY]
			,cast((pb.[Roll Count] - pb.[Roll Count PY]) as float) / pb.[Roll Count PY] as 'YoY Change % (Roll Count)'

		from
		(
						select
							prior.mnum
							,prior.Month as 'Month'
							,curr.Spread as 'Spread'
							,prior.Spread as 'Spread PY'
							,curr.Volume as 'Volume'
							,prior.Volume as 'Volume PY'
							,curr.Loss as 'Loss'
							,prior.Loss as 'Loss PY'
							,curr.[Loss Volume] as 'Loss Vol'
							,prior.[Loss Volume] as 'Loss Vol PY'
							,curr.[OT Rad Pickup] as 'OT Rad PU'
							,prior.[OT Rad Pickup] as 'OT Rad PU PY'
							,curr.[OT Appt Pickup] as 'OT Appt PU'
							,prior.[OT Appt Pickup] as 'OT Appt PU PY'
							,curr.[OT Rad delivery] as 'OT Rad Del'
							,prior.[OT Rad delivery] as 'OT Rad Del PY'
							,curr.[OT Appt delivery] as 'OT Appt Del'
							,prior.[OT Appt delivery] as 'OT Appt Del PY'
							,curr.[PU Cnt] as 'PU Cnt'
							,prior.[PU Cnt] as 'PU Cnt PY'
							,curr.[Del Cnt] as 'Del Cnt'
							,prior.[Del Cnt] as 'Del Cnt PY'
							,curr.[Roll Count] as 'Roll Count'
							,prior.[Roll Count] as 'Roll Count PY'

						from
						(
										select
											Datepart(MONTH, cal.cal_month_date) as 'mnum'
											,DATENAME(MONTH, cal.cal_month_date) as 'Month'
											,sum(m.movement_spread_amt) as 'Spread'
											,count(m.movement_id) as 'Volume'
											,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
											,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
											,sum(customer_ontime_rad_pickup_cnt) as 'OT Rad Pickup'
											,sum(customer_ontime_appt_pickup_cnt) as 'OT Appt Pickup'
											,sum(customer_ontime_rad_delivery_cnt) as 'OT Rad delivery'
											,sum(customer_ontime_appt_delivery_cnt) as 'OT Appt delivery'
											,sum(pickup_cnt) as 'PU Cnt'
											,sum(delivery_cnt) as 'Del Cnt'
											,sum(rolled_cnt) as 'Roll Count'
										from bi_prod.bi_denorm.movements as m
										join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
										where
											cal.rel_cal_year = 0
										and cal.rel_cal_month <= 0
										and m.revenue_code_id = 'TL'
										group by
											Datepart(MONTH, cal.cal_month_date)
											,DATENAME(MONTH, cal.cal_month_date)
						) as curr

						join
						(
										select
											Datepart(MONTH, cal.cal_month_date) as 'mnum'
											,DATENAME(MONTH, cal.cal_month_date) as 'Month'
											,sum(m.movement_spread_amt) as 'Spread'
											,count(m.movement_id) as 'Volume'
											,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
											,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'									
											,sum(customer_ontime_rad_pickup_cnt) as 'OT Rad Pickup'
											,sum(customer_ontime_appt_pickup_cnt) as 'OT Appt Pickup'
											,sum(customer_ontime_rad_delivery_cnt) as 'OT Rad delivery'
											,sum(customer_ontime_appt_delivery_cnt) as 'OT Appt delivery'
											,sum(pickup_cnt) as 'PU Cnt'
											,sum(delivery_cnt) as 'Del Cnt'
											,sum(rolled_cnt) as 'Roll Count'
										from bi_prod.bi_denorm.movements as m
										join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
										where
											cal.rel_cal_year = -1
										and m.revenue_code_id = 'TL'
										group by
											Datepart(MONTH, cal.cal_month_date)
											,DATENAME(MONTH, cal.cal_month_date)
						) as prior on prior.mnum = curr.mnum
								  and prior.Month = curr.Month
		) as pb

		join
		(
						select
							prior.mnum
							,prior.Month as 'Month'
							,curr.Spread as 'Spread'
							,prior.Spread as 'Spread PY'
							,curr.Volume as 'Volume'
							,prior.Volume as 'Volume PY'
							,curr.Loss as 'Loss'
							,prior.Loss as 'Loss PY'
							,curr.[Loss Volume] as 'Loss Vol'
							,prior.[Loss Volume] as 'Loss Vol PY'
							,curr.[OT Rad Pickup] as 'OT Rad PU'
							,prior.[OT Rad Pickup] as 'OT Rad PU PY'
							,curr.[OT Rad delivery] as 'OT Rad Del'
							,prior.[OT Rad delivery] as 'OT Rad Del PY'
							,curr.[PU Cnt] as 'PU Cnt'
							,prior.[PU Cnt] as 'PU Cnt PY'
							,curr.[Del Cnt] as 'Del Cnt'
							,prior.[Del Cnt] as 'Del Cnt PY'

						from
						(
										select
											Datepart(MONTH, cal.cal_month_date) as 'mnum'
											,DATENAME(MONTH, cal.cal_month_date) as 'Month'
											,sum(m.shipment_spread) as 'Spread'
											,count(m.load_id) as 'Volume'
											,sum(iif(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
											,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
											,sum(pickup_ontime_count) as 'OT Rad Pickup'
											,sum(delivery_ontime_count) as 'OT Rad delivery'
											,(sum(pickup_late_count) + sum(pickup_ontime_count)) as 'PU Cnt'
											,(sum(delivery_ontime_count) + sum(delivery_late_count)) as 'Del Cnt'
										from bi_prod.bi_denorm.byn_shipments as m
										join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
										where
											cal.rel_cal_year = 0
										and cal.rel_cal_month <= 0
										and m.service_code = 'TL'
										and m.client_name <> 'Hitachi - Thd'
										group by
											Datepart(MONTH, cal.cal_month_date)
											,DATENAME(MONTH, cal.cal_month_date)
						) as curr

						join
						(
										select
											Datepart(MONTH, cal.cal_month_date) as 'mnum'
											,DATENAME(MONTH, cal.cal_month_date) as 'Month'
											,sum(m.shipment_spread) as 'Spread'
											,count(m.load_id) as 'Volume'
											,sum(iif(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
											,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
											,sum(pickup_ontime_count) as 'OT Rad Pickup'
											,sum(delivery_ontime_count) as 'OT Rad delivery'
											,(sum(pickup_late_count) + sum(pickup_ontime_count)) as 'PU Cnt'
											,(sum(delivery_ontime_count) + sum(delivery_late_count)) as 'Del Cnt'
										from bi_prod.bi_denorm.byn_shipments as m
										join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
										where
											cal.rel_cal_year = -1
										and m.service_code = 'TL'
										and m.client_name <> 'Hitachi - Thd'
										group by
											Datepart(MONTH, cal.cal_month_date)
											,DATENAME(MONTH, cal.cal_month_date)
						) as prior on prior.mnum = curr.mnum
								  and prior.Month = curr.Month
		) as byn on pb.mnum = byn.mnum
				and pb.Month = byn.month
) as all_oth

full outer join

(
		select
			b17.mnum
			,b17.Month

			,b18.[Bounce Percent] as 'Bounce Percent'
			,b17.[Bounce Percent] as 'Bounce Percent PY'
			,b18.[Bounce Percent] - b17.[Bounce Percent] as '% Deviation (Bounce Percent)'

			,b18.[Bounce Cost Percent] as 'Bounce Cost Percent'
			,b17.[Bounce Cost Percent] as 'Bounce Cost Percent PY'
			,b18.[Bounce Cost Percent] - b17.[Bounce Cost Percent] as '% Deviation (Bounce Cost Percent)'

		from
		(
				select
					DATEPART(MONTH, b.cal_month_date) as 'mnum'
					,DATENAME(Month, b.cal_month_date) as 'Month'
					,b.[Bounce Percent]
					,b.[Bounce Cost Percent]
				from
				(
						SELECT c.cal_month_date
						, count(m.movement_id) as Volume
						, sum(m.movement_spread_amt) as 'Total Spread'
						,bounce_count as 'Total Bounce Count'
						,bounce_cost as 'Total Bounce Cost'
						,cast(bounce_count as float)/count(m.movement_id) as 'Bounce Percent'
						,cast(bounce_cost as float)/ sum(m.movement_spread_amt) as 'Bounce Cost Percent'
						, avg_bounce_cost as 'Avg Total Bounce Cost'

						FROM [bi_prod].[bi_denorm].[movements] m
						join  [bi_prod].[afnapp].[calendar_dates] c on m.actual_pickup_arrival_dt_id = c.calendar_date
						join [bi_prod].[bi_denorm].[employee_history] e on e.employee_version_id = m.[dispatcher_emp_v_id]
						left outer join 
						(
										select 
											c.cal_month_date
											,count(change_event_id) as bounce_count
											,sum(md.bounce_cost_amt) as bounce_cost
											,avg(case when bounce_seq = 1  then md.bounce_cost_amt end) as avg_bounce_cost

										from [bi_prod].[bi_denorm].movement_bounce_details md
										join [bi_prod].[bi_denorm].movements m1 on md.movement_id = m1.movement_id 
										join  [bi_prod].[afnapp].[calendar_dates] c 
										on md.[bounced_date_id] = c.calendar_date
										join  [bi_prod].[bi_denorm].employee_history h
										on md.[disp_employee_version_id] = h.[employee_version_id]

										where  bounce_lead_time_hrs<= 24 and c.rel_cal_month>=-23 and c.rel_cal_week <0 and h.[department_name] = 'Carrier Sales'
										group by c.cal_month_date
						) as bounce on bounce.cal_month_date = c.cal_month_date

						where c.rel_cal_month>=-24 and c.rel_cal_week <0 and e.[department_name] = 'Carrier Sales'
						group by c.cal_month_date
								,bounce_count 
								,bounce_cost 
								,avg_bounce_cost
						--order by cal_month_date
				) as b
				where
					datepart(Year, b.cal_month_date) = 2019
				and datepart(month, b.cal_month_date) <= DATEPART(MONTH, getdate())
		) as b18

		join

		(
				select
					DATEPART(MONTH, b.cal_month_date) as 'mnum'
					,DATENAME(Month, b.cal_month_date) as 'Month'
					,b.[Bounce Percent]
					,b.[Bounce Cost Percent]
				from
				(
						SELECT c.cal_month_date
						, count(m.movement_id) as Volume
						, sum(m.movement_spread_amt) as 'Total Spread'
						,bounce_count as 'Total Bounce Count'
						,bounce_cost as 'Total Bounce Cost'
						,cast(bounce_count as float)/count(m.movement_id) as 'Bounce Percent'
						,cast(bounce_cost as float)/ sum(m.movement_spread_amt) as 'Bounce Cost Percent'
						, avg_bounce_cost as 'Avg Total Bounce Cost'

						FROM [bi_prod].[bi_denorm].[movements] m
						join  [bi_prod].[afnapp].[calendar_dates] c on m.actual_pickup_arrival_dt_id = c.calendar_date
						join [bi_prod].[bi_denorm].[employee_history] e on e.employee_version_id = m.[dispatcher_emp_v_id]
						left outer join 
						(
										select 
											c.cal_month_date
											,count(change_event_id) as bounce_count
											,sum(md.bounce_cost_amt) as bounce_cost
											,avg(case when bounce_seq = 1  then md.bounce_cost_amt end) as avg_bounce_cost

										from [bi_prod].[bi_denorm].movement_bounce_details md
										join [bi_prod].[bi_denorm].movements m1 on md.movement_id = m1.movement_id 
										join  [bi_prod].[afnapp].[calendar_dates] c 
										on md.[bounced_date_id] = c.calendar_date
										join  [bi_prod].[bi_denorm].employee_history h
										on md.[disp_employee_version_id] = h.[employee_version_id]

										where  bounce_lead_time_hrs<= 24 and c.rel_cal_month>=-23 and c.rel_cal_week <0 and h.[department_name] = 'Carrier Sales'
										group by c.cal_month_date
						) as bounce on bounce.cal_month_date = c.cal_month_date

						where c.rel_cal_month>=-24 and c.rel_cal_week <0 and e.[department_name] = 'Carrier Sales'
						group by c.cal_month_date
								,bounce_count 
								,bounce_cost 
								,avg_bounce_cost
						--order by cal_month_date
				) as b
				where
					datepart(Year, b.cal_month_date) = 2018
				and datepart(month, b.cal_month_date) <= DATEPART(MONTH, getdate())
		) as b17 on b17.mnum = b18.mnum
) as b on b.mnum = all_oth.mnum

order by
	all_oth.mnum