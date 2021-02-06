select
	pb.mnum
	,pb.Month as 'Month'
	
	,cast((pb.[OT Rad Del] + byn.[OT Rad Del]) as float) / (pb.[Del Cnt] + byn.[Del Cnt]) as 'OT Rad Del Percent'
	,cast((pb.[OT Rad Del PY] + byn.[OT Rad Del PY]) as float) / (pb.[Del Cnt PY] + byn.[Del Cnt PY]) as 'OT Rad Del Percent PY'
	,((cast((pb.[OT Rad Del] + byn.[OT Rad Del]) as float) / (pb.[Del Cnt] + byn.[Del Cnt]))
	- (cast((pb.[OT Rad Del PY] + byn.[OT Rad Del PY]) as float) / (pb.[Del Cnt PY] + byn.[Del Cnt PY]))) as '% Deviation (OT Rad Del)'

	,cast((pb.[OT Rad Del] + byn.[OT Rad Del]) as float) / (pb.[Del Cnt] + byn.[Del Cnt]) as 'OT Appt Del Percent'
	,cast((pb.[OT Rad Del PY] + byn.[OT Rad Del PY]) as float) / (pb.[Del Cnt PY] + byn.[Del Cnt PY]) as 'OT Appt Del Percent PY'
	,((cast((pb.[OT Rad Del] + byn.[OT Rad Del]) as float) / (pb.[Del Cnt] + byn.[Del Cnt]))
	- (cast((pb.[OT Rad Del PY] + byn.[OT Rad Del PY]) as float) / (pb.[Del Cnt PY] + byn.[Del Cnt PY]))) as '% Deviation (OT Appt Del)'

	,cast((pb.[OT Rad PU] + byn.[OT Rad PU]) as float) / (pb.[PU Cnt] + byn.[PU Cnt]) as 'OT RAD PU Percent'
	,cast((pb.[OT Rad PU PY] + byn.[OT Rad PU PY]) as float) / (pb.[PU Cnt PY] + byn.[PU Cnt PY]) as 'OT RAD PU Percent PY'
	,((cast((pb.[OT Rad PU] + byn.[OT Rad PU]) as float) / (pb.[PU Cnt] + byn.[PU Cnt]))
	- (cast((pb.[OT Rad PU PY] + byn.[OT Rad PU PY]) as float) / (pb.[PU Cnt PY] + byn.[PU Cnt PY]))) as '% Deviation (OT RAD PU)'

	,cast((pb.[OT Appt PU] + byn.[OT Rad PU]) as float) / (pb.[PU Cnt] + byn.[PU Cnt]) as 'OT Appt PU Percent'
	,cast((pb.[OT Appt PU PY] + byn.[OT Rad PU PY]) as float) / (pb.[PU Cnt PY] + byn.[PU Cnt PY]) as 'OT Appt PU Percent PY'
	,((cast((pb.[OT Appt PU] + byn.[OT Rad PU]) as float) / (pb.[PU Cnt] + byn.[PU Cnt]))
	- (cast((pb.[OT Appt PU PY] + byn.[OT Rad PU PY]) as float) / (pb.[PU Cnt PY] + byn.[PU Cnt PY]))) as '% Deviation (OT Appt PU)'

from
(
				select
					prior.mnum
					,prior.Month as 'Month'
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

				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
									,sum(customer_ontime_rad_pickup_cnt) as 'OT Rad Pickup'
									,sum(customer_ontime_appt_pickup_cnt) as 'OT Appt Pickup'
									,sum(customer_ontime_rad_delivery_cnt) as 'OT Rad delivery'
									,sum(customer_ontime_appt_delivery_cnt) as 'OT Appt delivery'
									,sum(pickup_cnt) as 'PU Cnt'
									,sum(delivery_cnt) as 'Del Cnt'
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
									,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'									
									,sum(customer_ontime_rad_pickup_cnt) as 'OT Rad Pickup'
									,sum(customer_ontime_appt_pickup_cnt) as 'OT Appt Pickup'
									,sum(customer_ontime_rad_delivery_cnt) as 'OT Rad delivery'
									,sum(customer_ontime_appt_delivery_cnt) as 'OT Appt delivery'
									,sum(pickup_cnt) as 'PU Cnt'
									,sum(delivery_cnt) as 'Del Cnt'
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

order by
	pb.mnum