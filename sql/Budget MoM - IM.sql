select
	DATENAME(MONTH, fin.Month) as 'Month'

	,fin.Revenue
	,bud.[Budget Revenue]
	,cast((fin.Revenue - bud.[Budget Revenue]) as float) / bud.[Budget Revenue] as 'Deviation % (Rev)'

	,fin.Spread
	,bud.[Budget Spread]
	,cast((fin.Spread - bud.[Budget Spread]) as float) / bud.[Budget Spread] as 'Deviation % (Spr)'

	,fin.Volume
	,bud.[Budget Volume]
	,cast((fin.Volume - bud.[Budget Volume]) as float) / bud.[Budget Volume] as 'Deviation % (Vol)'
from
(
		select
			isnull(pb.Month, byn.Month) as 'Month'
			,(isnull(pb.Revenue, 0) + isnull(byn.Revenue, 0)) as 'Revenue'
			,(isnull(pb.Spread, 0) + isnull(byn.Spread, 0)) as 'Spread'
			,(isnull(pb.Volume, 0) + isnull(byn.Volume, 0)) as 'Volume'
	
		from
		(
				select
					cal.cal_month_date as 'Month'
					,sum(movement_revenue_amt) as 'Revenue'
					,sum(movement_spread_amt) as 'Spread'
					,count(movement_id) as 'Volume'
					,sum(iif(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
					,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss Vol'
				from bi_prod.bi_denorm.movements as m
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
				where
					cal.rel_cal_year = 0
				and cal.rel_cal_month <= 0
				and m.revenue_code_id = 'IM'
				group by
					cal.cal_month_date
		) as pb

		full outer join
		(
				select
					cal.cal_month_date as 'Month'
					,sum(carrier_net_price) as 'Revenue'
					,sum(shipment_spread) as 'Spread'
					,count(load_id) as 'Volume'
					,sum(iif(m.shipment_spread < 0, shipment_spread, 0)) as 'Loss'
					,sum(iif(m.shipment_spread < 0, 1, 0)) as 'Loss Vol'
				from bi_prod.bi_denorm.byn_shipments as m
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
				where
					cal.rel_cal_year = 0
				and cal.rel_cal_month <= 0
				and m.client_name <> 'Hitachi - Thd'
				and m.service_code = 'Intermodal'
				group by
					cal.cal_month_date
		) as byn on pb.Month = byn.month
) as fin

left join
(
		select
			b.budget_month as 'Month'
			,iif(b.mode like 'TL%' or b.mode like 'New Sales Spread TL', 'Truckload', 
				iif(b.mode like 'LTL%' or b.mode like 'New Sales Spread LTL', 'LTL',
					iif(b.mode like '%FUM%' or b.mode like '%Freight Under Management%', 'FUM',
						iif(b.mode like '%Intermodal%', 'Intermodal',
							'-')))) as 'Revenue Type'
			,sum(b.revenue_amt) as 'Budget Revenue'
			,sum(b.spread_amt) as 'Budget Spread'
			,sum(b.volume) as 'Budget Volume'

		from bi_prod.bi_denorm.budget_by_mode as b
		where
			datepart(year, b.budget_month) = datepart(year, getdate()-1)
		and b.mode not in ('TL Total', 'New Sales Spread Total')
		group by
			b.budget_month
			,iif(b.mode like 'TL%' or b.mode like 'New Sales Spread TL', 'Truckload', 
				iif(b.mode like 'LTL%' or b.mode like 'New Sales Spread LTL', 'LTL',
					iif(b.mode like '%FUM%' or b.mode like '%Freight Under Management%', 'FUM',
						iif(b.mode like '%Intermodal%', 'Intermodal',
							'-'))))
) as bud on bud.Month = fin.Month
		and bud.[Revenue Type] = 'Intermodal'

order by
	fin.Month