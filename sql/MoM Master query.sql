select
	pb.mnum
	,pb.Month as 'Month'
	,(pb.Revenue + byn.Revenue) as 'Revenue'
	,(pb.[Revenue PY] + byn.[Revenue PY]) as 'Revenue PY'
	,((pb.Revenue + byn.Revenue) - (pb.[Revenue PY] + byn.[Revenue PY]))/(pb.[Revenue PY] + byn.[Revenue PY]) as 'YoY Change % (Rev)'
	,(pb.Spread + byn.Spread) as 'Spread'
	,(pb.[Spread PY] + byn.[Spread PY]) as 'Spread PY'
	,((pb.Spread + byn.Spread) - (pb.[Spread PY] + byn.[Spread PY]))/(pb.[Spread PY] + byn.[Spread PY]) as 'YoY Change % (Spread)'
	,(pb.Volume + byn.Volume) as 'Volume'
	,(pb.[Volume PY] + byn.[Volume PY]) as 'Volume PY'
	,cast(((pb.Volume + byn.Volume) - (pb.[Volume PY] + byn.[Volume PY])) as float)/(pb.[Volume PY] + byn.[Volume PY]) as 'YoY Change % (Vol)'
	--,(pb.Loss + byn.Loss) as 'Loss Spread'
	--,(pb.[Loss PY] + byn.[Loss PY]) as 'Loss Spread PY'
	--,((pb.Loss + byn.Loss) - (pb.[Loss PY] + byn.[Loss PY])) / (pb.[Loss PY] + byn.[Loss PY]) as 'YoY Change % (Loss)'
	--,(pb.[Loss Volume] + byn.[Loss Volume]) as 'Loss Vol'
	--,(pb.[Loss Volume PY] + byn.[Loss Volume PY]) as 'Loss Vol PY'
	--,cast(((pb.[Loss Volume] + byn.[Loss Volume]) - (pb.[Loss Volume PY] + byn.[Loss Volume PY])) as float) / (pb.[Loss Volume PY] + byn.[Loss Volume PY]) as 'YoY Change % (Loss Vol)'
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
					,curr.[Loss Volume] as 'Loss Volume'
					,prior.[Loss Volume] as 'Loss Volume PY'
				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(movement_revenue_amt) as 'Revenue'
									,sum(movement_spread_amt) as 'Spread'
									,count(movement_id) as 'Volume'
									,SUM(IIF(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
									,sum(IIF(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
								from bi_prod.bi_denorm.movements as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
								where
									cal.rel_cal_year = 0
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
									,SUM(IIF(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
									,sum(IIF(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
								from bi_prod.bi_denorm.movements as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
								where
									cal.rel_cal_year = -1
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
					,curr.[Loss Volume] as 'Loss Volume'
					,prior.[Loss Volume] as 'Loss Volume PY'
				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,sum(carrier_net_price) as 'Revenue'
									,sum(shipment_spread) as 'Spread'
									,count(load_id) as 'Volume'
									,SUM(IIF(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
									,sum(IIF(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
								from bi_prod.bi_denorm.byn_shipments as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
								where
									cal.rel_cal_year = 0
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
									,sum(carrier_net_price) as 'Revenue'
									,sum(shipment_spread) as 'Spread'
									,count(load_id) as 'Volume'
									,SUM(IIF(m.shipment_spread < 0, shipment_spread, 0)) as 'Loss'
									,sum(IIF(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
								from bi_prod.bi_denorm.byn_shipments as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
								where
									cal.rel_cal_year = -1
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