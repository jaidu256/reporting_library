select
	Datename(Month, fin.Month) as 'Month'

	,fin.Revenue
	,bud.[Budget Revenue]
	,cast((fin.Revenue - bud.[Budget Revenue]) as float) / bud.[Budget Revenue] as 'Deviation % (Rev)'

	,fin.Spread
	,bud.[Budget Spread]
	,cast((fin.Spread - bud.[Budget Spread]) as float) / bud.[Budget Spread] as 'Deviation % (Spr)'

	,fin.Volume
	,bud.[Budget Volume]
	,cast((fin.Volume - bud.[Budget Volume]) as float) / bud.[Budget Volume] 'Deviation % (Vol)'

from
(
		select
			isnull(pb.Month, byn.Month) as 'Month'
			,(isnull(pb.Revenue, 0) + isnull(byn.Revenue, 0)) as 'Revenue'
			,(isnull(pb.Spread,0) + isnull(byn.Spread,0)) as 'Spread'
			,(isnull(pb.Volume,0) + isnull(byn.Volume,0)) as 'Volume'
	
		from
		(
				select
					cal.cal_month_date as 'Month'
					,sum(movement_revenue_amt) as 'Revenue'
					,sum(movement_spread_amt) as 'Spread'
					,count(movement_id) as 'Volume'
					,SUM(IIF(m.movement_spread_amt < 0, movement_spread_amt, 0)) as 'Loss'
					,sum(IIF(m.movement_spread_amt < 0, 1, 0)) as 'Loss Volume'
				from bi_prod.bi_denorm.movements as m
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
				where
					cal.rel_cal_year = 0
				and cal.rel_cal_month <= 0
				group by
					cal.cal_month_date
		) as pb

		join
		(
				select
					cal.cal_month_date as 'Month'
					,sum(carrier_net_price) as 'Revenue'
					,sum(shipment_spread) as 'Spread'
					,count(load_id) as 'Volume'
					,SUM(IIF(m.shipment_spread < 0, m.shipment_spread, 0)) as 'Loss'
					,sum(IIF(m.shipment_spread < 0, 1, 0)) as 'Loss Volume'
				from bi_prod.bi_denorm.byn_shipments as m
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_date
				where
					cal.rel_cal_year = 0
				and cal.rel_cal_month <= 0
				and m.client_name <> 'Hitachi - Thd'
				group by
					cal.cal_month_date
		) as byn on pb.Month = byn.month
) as fin

join
(
		select
			b.budget_month as 'Month'
			,sum(b.revenue_amt) as 'Budget Revenue'
			,sum(b.spread_amt) as 'Budget Spread'
			,sum(b.volume) as 'Budget Volume'

		from bi_prod.bi_denorm.budget_by_mode as b
		where
			datepart(year, b.budget_month) = datepart(year, getdate())
		and b.mode not in ('TL Total', 'New Sales Spread Total')
		group by
			b.budget_month
) as bud on bud.Month = fin.Month

 order by
	fin.Month
