select
	isnull(pb.revenue_code_id, byn.service_code) as 'Mode'
	
	,(isnull(pb.[Revenue MTD], 0) + isnull(byn.[Revenue MTD], 0)) as 'Revenue MTD'
	,(isnull(pb.[Prior Revenue MTD],0) + isnull(byn.[Prior Revenue MTD],0)) as 'Revenue MTD PY'
	,((isnull(pb.[Revenue MTD],0) + isnull(byn.[Revenue MTD],0)) - (isnull(pb.[Prior Revenue MTD],0) + isnull(byn.[Prior Revenue MTD],0))) /((isnull(pb.[Prior Revenue MTD],0) + isnull(byn.[Prior Revenue MTD],0))) as 'YoY Change % (Rev MTD)'
	
	,(isnull(pb.[Spread MTD],0) + isnull(byn.[Spread MTD],0)) as 'Spread MTD'
	,(isnull(pb.[Prior Spread MTD],0) + isnull(byn.[Prior Spread MTD],0)) as 'Spread MTD PY'
	,((isnull(pb.[Spread MTD],0) + isnull(byn.[Spread MTD],0)) - (isnull(pb.[Prior Spread MTD],0) + isnull(byn.[Prior Spread MTD],0))) /((isnull(pb.[Prior Spread MTD],0) + isnull(byn.[Prior Spread MTD],0))) as 'YoY Change % (Spr MTD)'
	
	,(isnull(pb.[Volume MTD],0) + isnull(byn.[Volume MTD],0)) as 'Volume MTD'
	,(isnull(pb.[Prior Volume MTD],0) + isnull(byn.[Prior Volume MTD],0)) as 'Volume MTD PY'
	,cast(((isnull(pb.[Volume MTD],0) + isnull(byn.[Volume MTD],0)) - (isnull(pb.[Prior Volume MTD],0) + isnull(byn.[Prior Volume MTD],0))) as float) / ((isnull(pb.[Prior Volume MTD],0) + isnull(byn.[Prior Volume MTD],0))) as 'YoY Change % (Vol MTD)'
	
	--,(pb.[Revenue YTD] + byn.[Revenue YTD]) as 'Revenue YTD'
	--,(pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD]) as 'Revenue YTD PY'
	--,((pb.[Revenue YTD] + byn.[Revenue YTD]) - (pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD])) /((pb.[Prior Revenue YTD] + byn.[Prior Revenue YTD])) as 'YoY Change % (Rev YTD)'
	
	--,(pb.[Spread YTD] + byn.[Spread YTD]) as 'Spread YTD'
	--,(pb.[Prior Spread YTD] + byn.[Prior Spread YTD]) as 'Spread YTD PY'
	--,((pb.[Spread YTD] + byn.[Spread YTD]) - (pb.[Prior Spread YTD] + byn.[Prior Spread YTD])) /((pb.[Prior Spread YTD] + byn.[Prior Spread YTD])) as 'YoY Change % (Spr YTD)'
	
	--,(pb.[Volume YTD] + byn.[Volume YTD]) as 'Volume YTD'
	--,(pb.[Prior Volume YTD] + byn.[Prior Volume YTD]) as 'Volume YTD PY'
	--,cast(((pb.[Volume YTD] + byn.[Volume YTD]) - (pb.[Prior Volume YTD] + byn.[Prior Volume YTD])) as float) / ((pb.[Prior Volume YTD] + byn.[Prior Volume YTD])) as 'YoY Change % (Vol YTD)'

From
(
				select
					currMtd.revenue_code_id
					,currMtd.[Revenue MTD]
					,priorMtd.[Prior Revenue MTD]
					,currMtd.[Spread MTD]
					,priorMtd.[Prior Spread MTD]
					,currMtd.[Volume MTD]
					,priorMtd.[Prior Volume MTD]

				from
				(
					select
						'overview' as 'id'
						,m.revenue_code_id
						,sum(m.movement_revenue_amt) as 'Revenue MTD'
						,sum(m.movement_spread_amt) as 'Spread MTD'
						,count(movement_id) as 'Volume MTD'


					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where
						cal.rel_cal_month = 0

					group by
						m.revenue_code_id

				) as currMtd


				join
				(
					select
						'overview' as 'id'
						,m.revenue_code_id
						,sum(m.movement_revenue_amt) as 'Prior Revenue MTD'
						,sum(m.movement_spread_amt) as 'Prior Spread MTD'
						,count(movement_id) as 'Prior Volume MTD'

					from bi_prod.bi_denorm.movements as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= (select cal.cal_month_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)

					group by
						m.revenue_code_id
				) as priorMtd on priorMtd.id = currMtd.id
							 and priorMtd.revenue_code_id = currMtd.revenue_code_id

) as pb
full outer join
(
				select
					currMtd.service_code
					,currMtd.[Revenue MTD]
					,priorMtd.[Prior Revenue MTD]
					,currMtd.[Spread MTD]
					,priorMtd.[Prior Spread MTD]
					,currMtd.[Volume MTD]
					,priorMtd.[Prior Volume MTD]
					
				from
				(
					select
						'overview' as 'id'
						,m.service_code
						,sum(m.carrier_net_price) as 'Revenue MTD'
						,sum(m.shipment_spread) as 'Spread MTD'
						,count(load_id) as 'Volume MTD'


					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where
						cal.rel_cal_month = 0
					and m.client_name <> 'Hitachi - Thd'

					group by
						m.service_code

				) as currMtd


				join
				(
					select
						'overview' as 'id'
						,m.service_code
						,sum(m.carrier_net_price) as 'Prior Revenue MTD'
						,sum(m.shipment_spread) as 'Prior Spread MTD'
						,count(load_id) as 'Prior Volume MTD'

					from bi_prod.bi_denorm.byn_shipments as m
					join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date

					where 
						cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and cal.calendar_date >= (select cal.cal_month_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
					and m.client_name <> 'Hitachi - Thd'

					group by
						m.service_code
				) as priorMtd on priorMtd.id = currMtd.id
							 and priorMtd.service_code = currMtd.service_code

) as byn on pb.revenue_code_id = byn.service_code

where
	isnull(pb.revenue_code_id, byn.service_code) in ('TL', 'LTL', 'IM')

order by
	isnull(pb.revenue_code_id, byn.service_code)