declare
	@dt date = cast(getdate() - 1 as date)

declare
	@dt_curr_month_start date = dateadd(day, 1, eomonth(@dt, -1))
	,@dt_curr_month_end date = eomonth(@dt)
	,@dt_curr_year_start date = dateadd(yy, datediff(yy, 0, @dt), 0)
	,@dt_curr_year_end date = dateadd(yy, datediff(yy, 0, @dt) + 1, -1)

declare
	@dt_prev date = dateadd(YEAR, -1, @dt)
	,@dt_prev_month_start date = dateadd(year, -1, @dt_curr_month_start)
	,@dt_prev_month_end date = dateadd(year, -1, @dt_curr_month_end)
	,@dt_prev_year_start date = dateadd(year, -1, @dt_curr_year_start)
	,@dt_prev_year_end date = dateadd(year, -1, @dt_curr_year_end)

declare
	@from_curr date = @dt_curr_month_start
	,@to_curr date = @dt
	,@from_prev date = @dt_prev_month_start
	,@to_prev date = @dt_prev
	,@constraint varchar(5) = '%'
	,@days_passed_month int = datediff(day, @dt_curr_month_start, @dt) + 1
	,@days_in_month int = datediff(day, @dt_curr_month_start, @dt_curr_month_end) + 1
	,@days_passed_year int = datediff(day, @dt_curr_year_start, @dt) + 1
	,@days_in_year int = datediff(day, @dt_curr_year_start, @dt_curr_year_end) + 1


select top 20
	a.[Customer Name] as 'Customer Name'
	,sum(a.Spread) as 'Spread'
	,sum(iif(a.year = year(@dt), b.[Spread Budget], 0)) as 'Spread Budget'
	,sum(a.Spread) - sum(iif(a.year = year(@dt), b.[Spread Budget], 0)) as 'Deviation $ (Spr Budget)'
	,(sum(a.Spread) - sum(iif(a.year = year(@dt), b.[Spread Budget], 0))) / (sum(iif(a.year = year(@dt), b.[Spread Budget], 0)) + 1) as 'Deviation % (Spr Budget)'
	,sum(a.[Spread PY]) as 'Spread PY'
	,(sum(a.Spread) - sum(a.[spread PY])) / (sum(a.[spread PY]) + 1) as 'Deviation % (Spr PY)'

	,sum(a.Revenue) as 'Revenue'
	,sum(iif(a.year = year(@dt), b.[Revenue Budget], 0)) as 'Revenue Budget'
	,sum(a.Revenue) - sum(iif(a.year = year(@dt), b.[Revenue Budget], 0)) as 'Deviation $ (Rev Budget)'
	,(sum(a.Revenue) - sum(iif(a.year = year(@dt), b.[Revenue Budget], 0))) / (sum(iif(a.year = year(@dt), b.[Revenue Budget], 0)) + 1) as 'Deviation % (Rev Budget)'
	,sum(a.[Revenue PY]) as 'Revenue PY'
	,(sum(a.Revenue) - sum(a.[Revenue PY])) / (sum(a.[Revenue PY]) + 1) as 'Deviation % (Rev PY)'

	,sum(a.Volume) as 'Volume'
	,sum(a.[Volume PY]) as 'Volume PY'
	,(sum(a.Volume) - sum(a.[Volume PY])) / (sum(a.[Volume PY]) + 1) as 'Deviation % (Vol PY)'
from
(

		select 

			tot.Date_year as 'Year'
			,tot.Month as 'Month'
			,tot.[customer name] as 'Customer Name'
			,sum(iif(tot.Date_Year = year(@dt), tot.Revenue, 0)) as 'Revenue'
			,sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) as 'Spread'
			,sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) as 'Volume'
			,sum(iif(tot.Date_Year = year(@dt_prev), tot.Revenue, 0)) as 'Revenue PY'
			,sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) as 'Spread PY'
			,sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) as 'Volume PY'

		from
		(
				-- Current year powerbroker
				select
					'pb' as 'Source'
					,year(@dt) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,m.revenue_code_id as 'Revenue_Type'
					,cus.customer_name as 'Customer Name'
					,sum(m.movement_revenue_amt) as 'Revenue'
					,sum(m.movement_spread_amt) as 'Spread'
					,count(distinct m.movement_id) as 'Volume'
				from bi_prod.bi_denorm.movements as m
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
				left join bi_prod.bi_denorm.customers as cus on cus.customer_id = m.customer_id
				where
					cal.calendar_date between @from_curr and @to_curr
				group by
					m.revenue_code_id
					,cal.cal_month_date
					,cus.customer_name
				--------

				union

				-- Previous year powerbroker
				select
					'pb' as 'Source'
					,year(@dt_prev) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,m.revenue_code_id as 'Revenue_Type'
					,cus.customer_name as 'Customer Name'
					,sum(m.movement_revenue_amt) as 'Revenue'
					,sum(m.movement_spread_amt) as 'Spread'
					,count(distinct m.movement_id) as 'Volume'
				from bi_prod.bi_denorm.movements as m
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
				left join bi_prod.bi_denorm.customers as cus on cus.customer_id = m.customer_id
				where
					cal.calendar_date between @from_prev and @to_prev
				group by
					m.revenue_code_id
					,cal.cal_month_date
					,cus.customer_name
				--------

				union

				-- Current year banyan
				select
					'byn' as 'Source'
					,year(@dt) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,iif(b.service_code = 'intermodal', 'IM', b.service_code) as 'Revenue_Type'
					,cus.customer_name as 'Customer Name'
					,sum(b.carrier_net_price) as 'Revenue'
					,sum(b.shipment_spread) as 'Spread'
					,count(distinct b.load_id) as 'Volume'
				from bi_prod.bi_denorm.byn_shipments as b
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date
				left join bi_prod.bi_denorm.customers as cus on cus.customer_id = b.pb_customer_id
				where
					cal.calendar_date between @from_curr and @to_curr
				and b.client_name <> 'Hitach - THD'
				group by
					b.service_code
					,cal.cal_month_date
					,cus.customer_name
				--------

				union

				-- Previous year banyan
				select
					'byn' as 'Source'
					,year(@dt_prev) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,iif(b.service_code = 'intermodal', 'IM', b.service_code) as 'Revenue_Type'
					,cus.customer_name as 'Customer Name'
					,sum(b.carrier_net_price) as 'Revenue'
					,sum(b.shipment_spread) as 'Spread'
					,count(distinct b.load_id) as 'Volume'
				from bi_prod.bi_denorm.byn_shipments as b
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date
				left join bi_prod.bi_denorm.customers as cus on cus.customer_id = b.pb_customer_id
				where
					cal.calendar_date between @from_prev and @to_prev
				and b.client_name <> 'Hitach - THD'
				group by
					b.service_code
					,cal.cal_month_date
					,cus.customer_name
				--------
		) as tot
		where
			tot.revenue_type like @constraint
		group by
			tot.Month
			,tot.[Customer Name]
			,tot.Date_year

) as a

left join
(
		select
			year(bud.budget_month) as year
			,month(bud.budget_month) as Month
			,cust.bridge_name as 'Customer Name'
			,sum(bud.revenue_amt) * @days_passed_month / @days_in_month as 'Revenue Budget'
			,sum(bud.spread_amt) * @days_passed_month / @days_in_month as 'Spread Budget'
			,sum(bud.volume) * @days_passed_month / @days_in_month as 'Volume Budget'
		from bi_prod.bi_denorm.budget_master_data as bud
		join bi_prod.bi_denorm.customers as cust on cust.customer_id = bud.customer_id
		where
			year(bud.budget_month) between year(@to_prev) and year(@to_curr)
		group by
			cust.bridge_name
			,bud.budget_month
) as b on b.Month = a.Month
	and b.year = a.year
	and b.[Customer Name] = a.[Customer Name]

where
	(b.[Revenue Budget] is not null and b.[Spread Budget] is not null and b.[Volume Budget] is not null)
group by
	a.[Customer Name]
order by
	[Deviation $ (Spr Budget)] DESC
