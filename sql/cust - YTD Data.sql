declare @t int = 0

select top 25
	rtrim(isnull(cf.[Customer Name], cb.[Customer Name])) as 'Customer Name'

	,isnull(cf.spread, 0) as 'Spread'
	--,isnull(cb.spread, 0) as 'Spread Budget'
	--,iif( isnull(cb.spread, 0) <> 0
	--	,(isnull(cf.spread, 0) - isnull(cb.spread, 0))/isnull(cb.spread, 0)
	--	, 1) as 'Deviation % (Spr Budget)'
	,isnull(cp.spread, 0) as 'Spread PY'
	,iif(isnull(cp.spread, 0) <> 0
		,(isnull(cf.spread, 0) - isnull(cp.spread, 0))/isnull(cp.spread, 0)
		, 1) as 'Deviation % (Spr PY)'

	,isnull(cf.revenue, 0) as 'Revenue'
	--,isnull(cb.revenue, 0) as 'Revenue Budget'
	--,iif(isnull(cb.revenue, 0) <> 0
	--	,(isnull(cf.revenue, 0) - isnull(cb.revenue, 0))/isnull(cb.revenue, 0)
	--	, 1) as 'Deviation % (Rev Budget)'
	,isnull(cp.revenue, 0) as 'Revenue PY'
	,iif(isnull(cp.revenue, 0) <> 0
		,(isnull(cf.revenue, 0) - isnull(cp.revenue, 0))/isnull(cp.revenue, 0)
		, 1) as 'Deviation % (Rev PY)'

	,isnull(cf.volume, 0) as 'Volume'
	--,isnull(cb.volume, 0) as 'Volume Budget'
	--,iif(isnull(cb.volume, 0) <> 0
	--	,cast((isnull(cf.volume, 0) - isnull(cb.volume, 0)) as float)/isnull(cb.volume, 0)
	--	, 1) as 'Deviation % (Vol Budget)'
	,isnull(cp.volume, 0) as 'Volume PY'
	,iif( isnull(cp.volume, 0) <> 0
		,cast((isnull(cf.volume, 0) - isnull(cp.volume, 0)) as float)/isnull(cp.volume, 0)
		, 1) as 'Deviation % (Vol PY)'

from
(
		select
			isnull(byn.[Customer Name], pb.[Customer Name]) as 'Customer Name'

			,(isnull(byn.Revenue, 0) + isnull(pb.Revenue, 0)) as 'Revenue' 
			,(isnull(byn.Spread, 0) + isnull(pb.Spread, 0)) as 'Spread'
			,(isnull(byn.Volume, 0) + isnull(pb.Volume, 0)) as 'Volume'
		from
		(
		select
			cus.customer_name as 'Customer Name'
			,sum(byn.carrier_net_price) as 'Revenue'
			,sum(byn.shipment_spread) as 'Spread'
			,count(distinct byn.load_id) as 'Volume'
		from bi_prod.bi_denorm.byn_shipments as byn
		join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = byn.actual_pickup_date
		join bi_prod.bi_denorm.customers as cus on cus.customer_id = byn.pb_customer_id
		where
			cal.rel_cal_year = 0
		and cal.rel_cal_day <= -1
		group by
			cus.customer_name
		) as byn

		full outer join
		(
		select
			cus.customer_name as 'Customer Name'
			,sum(m.movement_revenue_amt) as 'Revenue'
			,sum(m.movement_spread_amt) as 'Spread'
			,count(distinct m.movement_id) as 'Volume'
		from bi_prod.bi_denorm.movements as m
		join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
		join bi_prod.bi_denorm.customers as cus on cus.customer_id = m.customer_id
		where
			cal.rel_cal_year = 0
		and cal.rel_cal_day <= -1
		group by
			cus.customer_name
		) as pb on pb.[Customer Name] = byn.[Customer Name]
) as cf


left join
(
		select
			cust.bridge_name as 'Customer Name'
			,sum(bud.revenue_amt) as 'Revenue'
			,sum(bud.spread_amt) as 'Spread'
			,sum(bud.volume) as 'Volume'
		from bi_prod.bi_denorm.budget_master_data as bud
		join bi_prod.bi_denorm.customers as cust on cust.customer_id = bud.customer_id
		where
			datepart(YEAR, bud.budget_month) = 2018
		and DATEPART(MONTH, bud.budget_month) <= (datepart(MONTH, getdate()) - 1)
		group by
			cust.bridge_name
) as cb on cb.[Customer Name] = cf.[Customer Name]


left join
(
		select
			isnull(byn.[Customer Name], pb.[Customer Name]) as 'Customer Name'

			,(isnull(byn.Revenue, 0) + isnull(pb.Revenue, 0)) as 'Revenue' 
			,(isnull(byn.Spread, 0) + isnull(pb.Spread, 0)) as 'Spread'
			,(isnull(byn.Volume, 0) + isnull(pb.Volume, 0)) as 'Volume'
		from
		(
		select
			cus.customer_name as 'Customer Name'
			,sum(byn.carrier_net_price) as 'Revenue'
			,sum(byn.shipment_spread) as 'Spread'
			,count(distinct byn.load_id) as 'Volume'
		from bi_prod.bi_denorm.byn_shipments as byn
		join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = byn.actual_pickup_date
		join bi_prod.bi_denorm.customers as cus on cus.customer_id = byn.pb_customer_id
		where
			cal.rel_cal_year = -1
		and cal.rel_cal_month <= -13
		--	cal.calendar_date >= cast(dateadd(yy, DATEDIFF(yy, 0, getdate()) - 1, 0) as date)
		--and cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
		group by
			cus.customer_name
		) as byn

		full outer join
		(
		select
			cus.customer_name as 'Customer Name'
			,sum(m.movement_revenue_amt) as 'Revenue'
			,sum(m.movement_spread_amt) as 'Spread'
			,count(distinct m.movement_id) as 'Volume'
		from bi_prod.bi_denorm.movements as m
		join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
		join bi_prod.bi_denorm.customers as cus on cus.customer_id = m.customer_id
		where 
			cal.rel_cal_year = -1
		and cal.rel_cal_month <= -13
		--	cal.calendar_date >= cast(dateadd(yy, DATEDIFF(yy, 0, getdate()) - 1, 0) as date)
		--and cal.calendar_date <= (select cal.calendar_date from bi_prod.afnapp.calendar_dates as cal where rel_cal_day = -365)
		group by
			cus.customer_name
		) as pb on pb.[Customer Name] = byn.[Customer Name]
) as cp on cp.[Customer Name] = cf.[Customer Name]

order by
	Spread desc
	,Revenue desc
	,Volume desc