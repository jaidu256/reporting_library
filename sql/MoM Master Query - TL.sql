declare @days int = datediff(day, dateadd(day, 1-day(GETDATE()), getdate()),
					dateadd(month, 1, dateadd(day, 1-day(getdate()), getdate())))
declare @month_start date = DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
declare @today date = getdate()
declare @days_td int = DATEDIFF(day, DATEADD(month, DATEDIFF(month, 0, getdate()), 0), getdate())

select
	pb.mnum
	,pb.Month as 'Month'
	,(isnull(pb.Revenue, 0) + isnull(byn.Revenue, 0)) as 'Revenue'
	,(isnull(pb.[Revenue PY], 0) + isnull(byn.[Revenue PY], 0)) * @days_td / @days as 'Revenue PY'
	,((isnull(pb.Revenue, 0) + isnull(byn.Revenue, 0)) - (isnull(pb.[Revenue PY], 0) + isnull(byn.[Revenue PY], 0)))/(isnull(pb.[Revenue PY], 0) + isnull(byn.[Revenue PY], 0)) as 'YoY Change % (Rev)'
	,(isnull(pb.Spread, 0) + isnull(byn.Spread, 0)) as 'Spread'
	,(isnull(pb.[Spread PY], 0) + isnull(byn.[Spread PY], 0)) * @days_td / @days as 'Spread PY'
	,((isnull(pb.Spread, 0) + isnull(byn.Spread, 0)) - (isnull(pb.[Spread PY], 0) + isnull(byn.[Spread PY], 0)))/(isnull(pb.[Spread PY], 0) + isnull(byn.[Spread PY], 0)) as 'YoY Change % (Spread)'
	,(isnull(pb.Volume, 0) + isnull(byn.Volume, 0)) as 'Volume'
	,(isnull(pb.[Volume PY], 0) + isnull(byn.[Volume PY], 0)) * @days_td / @days as 'Volume PY'
	,cast(((isnull(pb.Volume, 0) + isnull(byn.Volume, 0)) - (isnull(pb.[Volume PY], 0) + isnull(byn.[Volume PY], 0))) as float)/(isnull(pb.[Volume PY], 0) + isnull(byn.[Volume PY], 0)) as 'YoY Change % (Vol)'
	--,(pb.Loss + byn.Loss) as 'Loss Spread'
	--,(pb.[Loss PY] + byn.[Loss PY]) as 'Loss Spread PY'
	--,((pb.Loss + byn.Loss) - (pb.[Loss PY] + byn.[Loss PY])) / (pb.[Loss PY] + byn.[Loss PY]) as 'YoY Change % (Loss)'
	--,(pb.[Loss Vol] + byn.[Loss Vol]) as 'Loss Vol'
	--,(pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'Loss Vol PY'
	--,cast(((pb.[Loss Vol] + byn.[Loss Vol]) - (pb.[Loss Vol PY] + byn.[Loss Vol PY])) as float) / (pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'YoY Change % (Loss Vol)'

from
(
				select
					prior.mnum
					,prior.Month as 'Month'
					,curr.Revenue as 'Revenue'
					,prior.Revenue as 'Revenue PY'
					,(curr.Revenue - prior.Revenue)/ prior.Revenue as 'YoY Change % (Rev)'
					,curr.Spread as 'Spread'
					,prior.Spread as 'Spread PY'
					,(curr.Spread - prior.Spread)/ prior.Spread as 'YoY Change % (Spread)'
					,curr.Volume as 'Volume'
					,prior.Volume as 'Volume PY'
					,cast((curr.Volume - prior.Volume) as float)/cast(prior.Volume as float) as 'YoY Change % (Vol)'
					,curr.Loss as 'Loss'
					,prior.Loss as 'Loss PY'
					,curr.[Loss Vol] as 'Loss Vol'
					,prior.[Loss Vol] as 'Loss Vol PY'

				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(movement_revenue_amt) as 'Revenue'
									,sum(movement_spread_amt) as 'Spread'
									,count(movement_id) as 'Volume'
									,sum(iif(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Vol'
								from bi_prod.bi_denorm.movements as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
								where
									cal.rel_cal_year = 0
								and rel_cal_month <= 0
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
									,sum(movement_revenue_amt) as 'Revenue'
									,sum(movement_spread_amt) as 'Spread'
									,count(movement_id) as 'Volume'
									,sum(iif(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Vol'
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

full outer join
(
				select
					prior.mnum
					,prior.Month as 'Month'
					,curr.Revenue as 'Revenue'
					,prior.Revenue as 'Revenue PY'
					,(curr.Revenue - prior.Revenue)/ prior.Revenue as 'YoY Change % (Rev)'
					,curr.Spread as 'Spread'
					,prior.Spread as 'Spread PY'
					,(curr.Spread - prior.Spread)/ prior.Spread as 'YoY Change % (Spread)'
					,curr.Volume as 'Volume'
					,prior.Volume as 'Volume PY'
					,cast((curr.Volume - prior.Volume) as float)/cast(prior.Volume as float) as 'YoY Change % (Vol)'
					,curr.Loss as 'Loss'
					,prior.Loss as 'Loss PY'
					,curr.[Loss Vol] as 'Loss Vol'
					,prior.[Loss Vol] as 'Loss Vol PY'
					

				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(carrier_net_price) as 'Revenue'
									,sum(shipment_spread) as 'Spread'
									,count(load_id) as 'Volume'
									,sum(iif(m.shipment_spread < 0, shipment_spread, 0)) as 'Loss'
									,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Vol'
								from bi_prod.bi_denorm.byn_shipments as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
								where
									cal.rel_cal_year = 0
								and m.service_code = 'TL'
								and m.client_name <> 'Hitachi - Thd'
								group by
									Datepart(MONTH, cal.cal_month_date)
									,DATENAME(MONTH, cal.cal_month_date)
				) as curr

				full outer join
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(carrier_net_price) as 'Revenue'
									,sum(shipment_spread) as 'Spread'
									,count(load_id) as 'Volume'
									,sum(iif(m.shipment_spread < 0, shipment_spread, 0)) as 'Loss'
									,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Vol'
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
where pb.Month is not null

order by
	pb.mnum