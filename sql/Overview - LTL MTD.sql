select
	(Isnull(pb.[Revenue MTD], 0) + Isnull(byn.[Revenue MTD], 0)) as 'Revenue MTD'
	,(Isnull(pb.[Revenue MTD PY], 0) + Isnull(byn.[Revenue MTD PY], 0)) as 'Revenue MTD PY'
	,((Isnull(pb.[Revenue MTD], 0) + Isnull(byn.[Revenue MTD PY], 0)) - (Isnull(pb.[Revenue MTD PY], 0) + Isnull(byn.[Revenue MTD PY], 0))) /((Isnull(pb.[Revenue MTD PY], 0) + Isnull(byn.[Revenue MTD PY], 0))) as 'YoY Change % (Rev MTD)'
	
	,(isnull(pb.[Spread MTD], 0) + isnull(byn.[Spread mTD], 0)) as 'Spread MTD'
	,(isnull(pb.[Spread mTD PY], 0) + isnull(byn.[Spread mTD PY], 0)) as 'Spread MTD PY'
	,((isnull(pb.[Spread mTD], 0) + isnull(byn.[Spread mTD], 0)) - (isnull(pb.[Spread mTD PY], 0) + isnull(byn.[Spread mTD PY], 0))) /((isnull(pb.[Spread mTD PY], 0) + isnull(byn.[Spread mTD PY], 0))) as 'YoY Change % (Spr MTD)'
	
	,(isnull(pb.[Volume mTD], 0) + isnull(byn.[Volume mTD], 0)) as 'Volume MTD'
	,(isnull(pb.[Volume mTD PY], 0) + isnull(byn.[Volume mTD PY], 0)) as 'Volume MTD PY'
	,cast(((isnull(pb.[Volume mTD], 0) + isnull(byn.[Volume mTD], 0)) - (isnull(pb.[Volume mTD PY], 0) + isnull(byn.[Volume MTD PY], 0))) as float) / ((isnull(pb.[Volume MTD PY], 0) + isnull(byn.[Volume MTD PY], 0))) as 'YoY Change % (Vol MTD)'

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

) as byn on pb.id = byn.id