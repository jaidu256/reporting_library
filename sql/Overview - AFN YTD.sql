select
	(pb.[Revenue YTD] + byn.[Revenue YTD]) as 'Revenue YTD'
	,(pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD]) as 'Revenue YTD PY'
	,((pb.[Revenue YTD] + byn.[Revenue YTD]) - (pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD])) /((pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD])) as 'YoY Change % (Rev YTD)'
	
	,(pb.[Spread YTD] + byn.[Spread YTD]) as 'Spread YTD'
	,(pb.[Prior Spread YTD] + byn.[Prior Spread YTD]) as 'Spread YTD PY'
	,((pb.[Spread YTD] + byn.[Spread YTD]) - (pb.[Prior Spread YTD] + byn.[Prior Spread YTD])) /((pb.[Prior Spread YTD] + byn.[Prior Spread YTD])) as 'YoY Change % (Spr YTD)'
	
	,(pb.[Volume YTD] + byn.[Volume YTD]) as 'Volume YTD'
	,(pb.[Prior Volume YTD] + byn.[Prior Volume YTD]) as 'Volume YTD PY'
	,cast(((pb.[Volume YTD] + byn.[Volume YTD]) - (pb.[Prior Volume YTD] + byn.[Prior Volume YTD])) as float) / ((pb.[Prior Volume YTD] + byn.[Prior Volume YTD])) as 'YoY Change % (Vol YTD)'

From
(
				select
					'id' as 'id'
					,currMtd.[Revenue MTD]
					,priorMtd.[Prior Revenue MTD]
					,currMtd.[Spread MTD]
					,priorMtd.[Prior Spread MTD]
					,currMtd.[Volume MTD]
					,priorMtd.[Prior Volume MTD]
					,currYtd.[Revenue YTD]
					,priorYtd.[Prior Revenue YTD]
					,currYtd.[Spread YTD]
					,priorYtd.[Prior Spread YTD]
					,currYtd.[Volume YTD]
					,priorYtd.[Prior Volume YTD]

				from
				(
					select
						'overview' as 'id'
						,sum(m.movement_revenue_amt) as 'Revenue MTD'
						,sum(m.movement_spread_amt) as 'Spread MTD'
						,count(movement_id) as 'Volume MTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_month = 0
				) as currMtd


				join
				(
					select
						'overview' as 'id'
						,sum(m.movement_revenue_amt) as 'Prior Revenue MTD'
						,sum(m.movement_spread_amt) as 'Prior Spread MTD'
						,count(movement_id) as 'Prior Volume MTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= (select cal.cal_month_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
				) as priorMtd on priorMtd.id = currMtd.id


				join
				(
					select
						'overview' as 'id'
						,sum(m.movement_revenue_amt) as 'Prior Revenue YTD'
						,sum(m.movement_spread_amt) as 'Prior Spread YTD'
						,count(movement_id) as 'Prior Volume YTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= '2018-01-01'
				) as priorYtd on priorYtd.id = currMtd.id


				join
				(
					select
						'overview' as 'id'
						,sum(m.movement_revenue_amt) as 'Revenue YTD'
						,sum(m.movement_spread_amt) as 'Spread YTD'
						,count(movement_id) as 'Volume YTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_year = 0
				) as currYtd on currYtd.id = currMtd.id
) as pb
join
(
				select
					'id' as 'id'
					,currMtd.[Revenue MTD]
					,priorMtd.[Prior Revenue MTD]
					,currMtd.[Spread MTD]
					,priorMtd.[Prior Spread MTD]
					,currMtd.[Volume MTD]
					,priorMtd.[Prior Volume MTD]
					,currYtd.[Revenue YTD]
					,priorYtd.[Prior Revenue YTD]
					,currYtd.[Spread YTD]
					,priorYtd.[Prior Spread YTD]
					,currYtd.[Volume YTD]
					,priorYtd.[Prior Volume YTD]

				from
				(
					select
						'overview' as 'id'
						,sum(m.carrier_net_price) as 'Revenue MTD'
						,sum(m.shipment_spread) as 'Spread MTD'
						,count(load_id) as 'Volume MTD'


					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where
						cal.rel_cal_month = 0
					and m.client_name <> 'Hitachi - Thd'
				) as currMtd


				join
				(
					select
						'overview' as 'id'
						,sum(m.carrier_net_price) as 'Prior Revenue MTD'
						,sum(m.shipment_spread) as 'Prior Spread MTD'
						,count(load_id) as 'Prior Volume MTD'

					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= (select cal.cal_month_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and m.client_name <> 'Hitachi - Thd'
				) as priorMtd on priorMtd.id = currMtd.id


				join
				(
					select
						'overview' as 'id'
						,sum(m.carrier_net_price) as 'Prior Revenue YTD'
						,sum(m.shipment_spread) as 'Prior Spread YTD'
						,count(load_id) as 'Prior Volume YTD'

					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= '2018-01-01'
					and m.client_name <> 'Hitachi - Thd'
				) as priorYtd on priorYtd.id = currMtd.id


				join
				(
					select
						'overview' as 'id'
						,sum(m.carrier_net_price) as 'Revenue YTD'
						,sum(m.shipment_spread) as 'Spread YTD'
						,count(load_id) as 'Volume YTD'


					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where
						cal.rel_cal_year = 0
					and m.client_name <> 'Hitachi - Thd'
				) as currYtd on currYtd.id = currMtd.id
) as byn on pb.id = byn.id