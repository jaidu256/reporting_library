select
	isnull(pb.revenue_code_id, byn.service_code) as 'Mode'
	
	,(isnull(pb.[Revenue YTD], 0) + isnull(byn.[Revenue YTD], 0)) as 'Revenue YTD'
	,(isnull(pb.[Prior Revenue YTD], 0) + isnull(byn.[Prior Revenue YTD], 0)) as 'Revenue YTD PY'
	,((isnull(pb.[Revenue YTD], 0) + isnull(byn.[Revenue YTD], 0)) - (isnull(pb.[Prior Revenue YTD], 0) + isnull(byn.[Prior Revenue YTD], 0))) /((isnull(pb.[Prior Revenue YTD], 0) + isnull(byn.[Prior Revenue YTD], 0))) as 'YoY Change % (Rev YTD)'
	
	,(isnull(pb.[Spread YTD], 0) + isnull(byn.[Spread YTD], 0)) as 'Spread YTD'
	,(isnull(pb.[Prior Spread YTD], 0) + isnull(byn.[Prior Spread YTD], 0)) as 'Spread YTD PY'
	,((isnull(pb.[Spread YTD], 0) + isnull(byn.[Spread YTD], 0)) - (isnull(pb.[Prior Spread YTD], 0) + isnull(byn.[Prior Spread YTD], 0))) /((isnull(pb.[Prior Spread YTD], 0) + isnull(byn.[Prior Spread YTD], 0))) as 'YoY Change % (Spr YTD)'
	
	,(isnull(pb.[Volume YTD], 0) + isnull(byn.[Volume YTD], 0)) as 'Volume YTD'
	,(isnull(pb.[Prior Volume YTD], 0) + isnull(byn.[Prior Volume YTD], 0)) as 'Volume YTD PY'
	,cast(((isnull(pb.[Volume YTD], 0) + isnull(byn.[Volume YTD], 0)) - (isnull(pb.[Prior Volume YTD], 0) + isnull(byn.[Prior Volume YTD], 0))) as float) / ((isnull(pb.[Prior Volume YTD], 0) + isnull(byn.[Prior Volume YTD], 0))) as 'YoY Change % (Vol YTD)'

From
(
				select
					priorYtd.revenue_code_id
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
						,m.revenue_code_id
						,sum(m.movement_revenue_amt) as 'Prior Revenue YTD'
						,sum(m.movement_spread_amt) as 'Prior Spread YTD'
						,count(movement_id) as 'Prior Volume YTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= '2018-01-01'

					group by
						m.revenue_code_id
				) as priorYtd

				join
				(
					select
						'overview' as 'id'
						,m.revenue_code_id
						,sum(m.movement_revenue_amt) as 'Revenue YTD'
						,sum(m.movement_spread_amt) as 'Spread YTD'
						,count(movement_id) as 'Volume YTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_year = 0

					group by
						m.revenue_code_id
				) as currYtd on currYtd.id = priorYtd.id
							and currYtd.revenue_code_id = priorYtd.revenue_code_id
) as pb
full outer join
(
				select
					priorYtd.service_code
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
						,m.service_code
						,sum(m.carrier_net_price) as 'Prior Revenue YTD'
						,sum(m.shipment_spread) as 'Prior Spread YTD'
						,count(load_id) as 'Prior Volume YTD'

					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= '2018-01-01'
					and m.client_name <> 'Hitachi - Thd'

					group by
						m.service_code
				) as priorYtd

				join
				(
					select
						'overview' as 'id'
						,m.service_code
						,sum(m.carrier_net_price) as 'Revenue YTD'
						,sum(m.shipment_spread) as 'Spread YTD'
						,count(load_id) as 'Volume YTD'


					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where
						cal.rel_cal_year = 0
					and m.client_name <> 'Hitachi - Thd'

					group by
						m.service_code
				) as currYtd on currYtd.id = priorYtd.id
							and currYtd.service_code = priorYtd.service_code
) as byn on pb.revenue_code_id = byn.service_code

where
	isnull(pb.revenue_code_id, byn.service_code) in ('TL', 'LTL', 'IM')
order by
	isnull(pb.revenue_code_id, byn.service_code)