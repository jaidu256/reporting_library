select
	(pb.[Revenue YTD] + byn.[Revenue YTD]) as 'Revenue YTD'
	,(pb.[Revenue YTD PY] + byn.[Revenue YTD PY]) as 'Revenue YTD PY'
	,((pb.[Revenue YTD] + byn.[Revenue YTD]) - (pb.[Revenue YTD PY] + byn.[Revenue YTD PY])) /((pb.[Revenue YTD PY] + byn.[Revenue YTD PY])) as 'YoY Change % (Rev YTD)'
	
	,(pb.[Spread YTD] + byn.[Spread YTD]) as 'Spread YTD'
	,(pb.[Spread YTD PY] + byn.[Spread YTD PY]) as 'Spread YTD PY'
	,((pb.[Spread YTD] + byn.[Spread YTD]) - (pb.[Spread YTD PY] + byn.[Spread YTD PY])) /((pb.[Spread YTD PY] + byn.[Spread YTD PY])) as 'YoY Change % (Spr YTD)'
	
	,(pb.[Volume YTD] + byn.[Volume YTD]) as 'Volume YTD'
	,(pb.[Volume YTD PY] + byn.[Volume YTD PY]) as 'Volume YTD PY'
	,cast(((pb.[Volume YTD] + byn.[Volume YTD]) - (pb.[Volume YTD PY] + byn.[Volume YTD PY])) as float) / ((pb.[Volume YTD PY] + byn.[Volume YTD PY])) as 'YoY Change % (Vol YTD)'

from
(
				select
					'id' as 'id'
					--,currMtd.order_type_id
					,currMtd.[Revenue MTD] as 'Revenue MTD'
					,priorMtd.[Prior Revenue MTD] as 'Revenue MTD PY'
					,currMtd.[Spread MTD] as 'Spread MTD'
					,priorMtd.[Prior Spread MTD] as 'Spread MTD PY'
					,currMtd.[Volume MTD] as 'Volume MTD'
					,priorMtd.[Prior Volume MTD] as 'Volume MTD PY'
					,currYtd.[Revenue YTD] as 'Revenue YTD'
					,priorYtd.[Prior Revenue YTD] as 'Revenue YTD PY'
					,currYtd.[Spread YTD] as 'Spread YTD'
					,priorYtd.[Prior Spread YTD] as 'Spread YTD PY'
					,currYtd.[Volume YTD] as 'Volume YTD'
					,priorYtd.[Prior Volume YTD] as 'Volume YTD PY'

				from
				(
					select
						'overview' as 'id'
						--,m.order_type_id
						,sum(m.movement_revenue_amt) as 'Revenue MTD'
						,sum(m.movement_spread_amt) as 'Spread MTD'
						,count(movement_id) as 'Volume MTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_month = 0
					and revenue_code_id = 'LTL'

					--group by
					--	m.order_type_id
				) as currMtd


				join
				(
					select
						'overview' as 'id'
						--,m.order_type_id
						,sum(m.movement_revenue_amt) as 'Prior Revenue MTD'
						,sum(m.movement_spread_amt) as 'Prior Spread MTD'
						,count(movement_id) as 'Prior Volume MTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= (select cal.cal_month_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and revenue_code_id = 'LTL'


					--group by
					--	m.order_type_id
				) as priorMtd on priorMtd.id = currMtd.id
							 --and priorMtd.order_type_id = currMtd.order_type_id


				join
				(
					select
						'overview' as 'id'
						--,m.order_type_id
						,sum(m.movement_revenue_amt) as 'Prior Revenue YTD'
						,sum(m.movement_spread_amt) as 'Prior Spread YTD'
						,count(movement_id) as 'Prior Volume YTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= '2018-01-01'
					and revenue_code_id = 'LTL'

					--group by
					--	m.order_type_id
				) as priorYtd on priorYtd.id = currMtd.id
							 --and priorYtd.order_type_id = currMtd.order_type_id

				join
				(
					select
						'overview' as 'id'
						--,m.order_type_id
						,sum(m.movement_revenue_amt) as 'Revenue YTD'
						,sum(m.movement_spread_amt) as 'Spread YTD'
						,count(movement_id) as 'Volume YTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_year = 0
					and revenue_code_id = 'LTL'

					--group by
					--	m.order_type_id
				) as currYtd on currYtd.id = currMtd.id
							--and currMtd.order_type_id = currYtd.order_type_id
) as pb
join
(
				select
					--'Banyan' as 'Order Type'
					'id' as 'id'
					,currMtd.[Revenue MTD] as 'Revenue MTD'
					,priorMtd.[Prior Revenue MTD] as 'Revenue MTD PY'
					,currMtd.[Spread MTD] as 'Spread MTD'
					,priorMtd.[Prior Spread MTD] as 'Spread MTD PY'
					,currMtd.[Volume MTD] as 'Volume MTD'
					,priorMtd.[Prior Volume MTD] as 'Volume MTD PY'
					,currYtd.[Revenue YTD] as 'Revenue YTD'
					,priorYtd.[Prior Revenue YTD] as 'Revenue YTD PY'
					,currYtd.[Spread YTD] as 'Spread YTD'
					,priorYtd.[Prior Spread YTD] as 'Spread YTD PY'
					,currYtd.[Volume YTD] as 'Volume YTD'
					,priorYtd.[Prior Volume YTD] as 'Volume YTD PY'

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
					and m.service_code = 'LTL'
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
					and m.service_code = 'LTL'
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
					and m.service_code = 'LTL'
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
					and m.service_code = 'LTL'
					and m.client_name <> 'Hitachi - Thd'
				) as currYtd on currYtd.id = currMtd.id
) as byn on pb.id = byn.id