select
	pb.mnum
	,pb.Month as 'Month'
	
	,((pb.Spread + byn.Spread) / (pb.Volume + byn.Volume)) as 'Spread Per Load'
	,((pb.[Spread PY] + byn.[Spread PY]) / (pb.[Volume PY] + byn.[Volume PY])) as 'Spread Per Load PY'
	,(((pb.Spread + byn.Spread) / (pb.Volume + byn.Volume)) - ((pb.[Spread PY] + byn.[Spread PY]) / (pb.[Volume PY] + byn.[Volume PY]))) / ((pb.[Spread PY] + byn.[Spread PY]) / (pb.[Volume PY] + byn.[Volume PY])) as 'YoY Change % (SPL)'

	,((pb.[Customer Cost] + byn.[Customer Cost]) / (pb.Weight + byn.Weight)) as 'Customer Cost Per Pound'
	,((pb.[Customer Cost PY] + byn.[Customer Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])) as 'Customer Cost Per Pound PY'
	,(((pb.[Customer Cost] + byn.[Customer Cost]) / (pb.Weight + byn.Weight))
	- ((pb.[Customer Cost PY] + byn.[Customer Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])))
	/ ((pb.[Customer Cost PY] + byn.[Customer Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])) as 'YoY Change % (Customer Cost Per Pound)'

	,((pb.[Carrier Cost] + byn.[Carrier Cost]) / (pb.Weight + byn.Weight)) as 'Carrier Cost Per Pound'
	,((pb.[Carrier Cost PY] + byn.[Carrier Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])) as 'Carrier Cost Per Pound PY'
	,(((pb.[Carrier Cost] + byn.[Carrier Cost]) / (pb.Weight + byn.Weight))
	- ((pb.[Carrier Cost PY] + byn.[Carrier Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])))
	/ ((pb.[Carrier Cost PY] + byn.[Carrier Cost PY]) / (pb.[Weight PY] + byn.[Weight PY])) as 'YoY Change % (Carrier Cost Per Pound)'

	/*

	-- LTL Doesnt have Losses at all, so these fields below are not required

	,(pb.Loss + byn.Loss) as 'Loss'
	,(pb.[Loss PY] + byn.[Loss PY]) as 'Loss PY'
	,((pb.Loss + byn.loss) - (pb.[Loss PY] + byn.[Loss PY]))/(pb.[Loss PY] + byn.[Loss PY]) as 'YoY Change % (Loss)'
	
	,(pb.[Loss Vol] + byn.[Loss Vol]) as 'Loss Vol'
	,(pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'Loss Vol PY'
	,cast(((pb.[Loss Vol] + byn.[Loss Vol]) - (pb.[Loss Vol PY] + byn.[Loss Vol PY])) as float)/(pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'YoY Change % (Loss Vol)'
	
	,(pb.Loss + byn.Loss) / (pb.[Loss Vol] + byn.[Loss Vol]) as 'Loss Per Load'
	,(pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss Vol PY]) as 'Loss Per Load PY'
	,(((pb.Loss + byn.Loss) / (pb.[Loss Vol] + byn.[Loss Vol]))
	- ((pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss Vol PY])))
	/ ((pb.[Loss PY] + byn.[Loss PY]) / (pb.[Loss Vol PY] + byn.[Loss Vol PY])) as 'YoY Change % (Loss Per Load)'
	*/

	,((pb.Weight + byn.Weight) / (pb.Volume + byn.Volume)) as 'Avg Weight'
	,((pb.[Weight PY] + byn.[Weight PY]) / (pb.[Volume PY] + byn.[Volume PY])) as 'Avg Weight PY'
	,(((pb.Weight + byn.Weight) / (pb.Volume + byn.Volume))
	- ((pb.[Weight PY] + byn.[Weight PY]) / (pb.[Volume PY] + byn.[Volume PY])))
	/ ((pb.[Weight PY] + byn.[Weight PY]) / (pb.[Volume PY] + byn.[Volume PY])) as 'YoY Change % (Avg Weight)'
	
from
(
				select
					prior.mnum
					,prior.Month as 'Month'
					,curr.Spread as 'Spread'
					,prior.Spread as 'Spread PY'
					,curr.Loss as 'Loss'
					,prior.Loss as 'Loss PY'
					,curr.[Loss Volume] as 'Loss Vol'
					,prior.[Loss Volume] as 'Loss Vol PY'
					,curr.Volume as 'Volume'
					,prior.Volume as 'Volume PY'
					,curr.Weight as 'Weight'
					,prior.Weight as 'Weight PY'
					,curr.[Customer Cost] as 'Customer Cost'
					,prior.[Customer Cost] as 'Customer Cost PY'
					,curr.[Carrier Cost] as 'Carrier Cost'
					,prior.[Carrier Cost] as 'Carrier Cost PY'
					
				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,count(m.movement_id) as 'Volume'
									,sum(m.weight_billed) as 'Weight'
									,sum(m.movement_spread_amt) as 'Spread'
									,sum(m.movement_revenue_amt) as 'Customer Cost'
									,sum(movement_cost_amt) as 'Carrier Cost'
									,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
									from bi_prod.bi_denorm.movements as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
								where
									cal.rel_cal_year = 0
								and cal.rel_cal_month <= 0
								and m.revenue_code_id = 'LTL'
								group by
									Datepart(MONTH, cal.cal_month_date)
									,DATENAME(MONTH, cal.cal_month_date)
				) as curr

				join
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,count(m.movement_id) as 'Volume'
									,sum(weight_billed) as 'Weight'
									,sum(m.movement_spread_amt) as 'Spread'
									,sum(m.movement_revenue_amt) as 'Customer Cost'
									,sum(movement_cost_amt) as 'Carrier Cost'
									,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
									,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'									
									from bi_prod.bi_denorm.movements as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
								where
									cal.rel_cal_year = -1
								and m.revenue_code_id = 'LTL'
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
					,curr.Loss as 'Loss'
					,prior.Loss as 'Loss PY'
					,curr.[Loss Volume] as 'Loss Vol'
					,prior.[Loss Volume] as 'Loss Vol PY'
					,curr.Volume as 'Volume'
					,prior.Volume as 'Volume PY'
					,curr.Weight as 'Weight'
					,prior.Weight as 'Weight PY'
					,curr.[Customer Cost] as 'Customer Cost'
					,prior.[Customer Cost] as 'Customer Cost PY'
					,curr.[Carrier Cost] as 'Carrier Cost'
					,prior.[Carrier cost] as 'Carrier Cost PY'

				from
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,count(m.load_id) as 'Volume'
									,sum(total_weight) as 'Weight'
									,sum(m.shipment_spread) as 'Spread'
									,sum(m.carrier_net_price) as 'Customer Cost'
									,sum(raw_net_price) as 'Carrier Cost'
									,sum(iif(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
									,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
									from bi_prod.bi_denorm.byn_shipments as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
								where
									cal.rel_cal_year = 0
								and cal.rel_cal_month <= 0
								and m.service_code = 'LTL'
								group by
									Datepart(MONTH, cal.cal_month_date)
									,DATENAME(MONTH, cal.cal_month_date)
				) as curr

				join
				(
								select
									Datepart(MONTH, cal.cal_month_date) as 'mnum'
									,DATENAME(MONTH, cal.cal_month_date) as 'Month'
									,count(load_id) as 'Volume'
									,sum(m.shipment_spread) as 'Spread'
									,sum(m.carrier_net_price) as 'Customer Cost'
									,sum(raw_net_price) as 'Carrier cost'
									,sum(total_weight) as 'Weight'
									,sum(iif(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
									,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
								from bi_prod.bi_denorm.byn_shipments as m
								join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
								where
									cal.rel_cal_year = -1
								and m.service_code = 'LTL'
								group by
									Datepart(MONTH, cal.cal_month_date)
									,DATENAME(MONTH, cal.cal_month_date)
				) as prior on prior.mnum = curr.mnum
						  and prior.Month = curr.Month
) as byn on pb.mnum = byn.mnum
		and pb.Month = byn.month

order by
	pb.mnum