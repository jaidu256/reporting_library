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
	@from_curr date = @dt_curr_year_start
	,@to_curr date = @dt
	,@from_prev date = @dt_prev_year_start
	,@to_prev date = @dt_prev
	,@constraint varchar(5) = 'TL'
	,@days_passed_month int = datediff(day, @dt_curr_month_start, @dt) + 1
	,@days_in_month int = datediff(day, @dt_curr_month_start, @dt_curr_month_end) + 1
	,@days_passed_year int = datediff(day, @dt_curr_year_start, @dt) + 1
	,@days_in_year int = datediff(day, @dt_curr_year_start, @dt_curr_year_end) + 1

select
	DATENAME(month, DATEADD(month, a.Month-1, @dt_prev_year_start)) as 'Month'
	,a.Revenue
	,b.[Budget Revenue]
	,(a.Revenue - b.[Budget Revenue]) / b.[Budget Revenue] as 'Deviation % (Rev)'

	,a.Spread
	,b.[Budget Spread]
	,(a.Spread - b.[Budget Spread]) / b.[Budget Spread] as 'Deviation % (Spr)'

	,a.Volume
	,b.[Budget Volume]
	,cast((a.Volume - b.[Budget Volume]) as float) / b.[Budget Volume] as 'Deviation % (Vol)'
from
(
		select
			tot.Month as 'Month'
			,sum(tot.Revenue) as 'Revenue'
			,sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) as 'Spread'
			,sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) as 'Volume'
		from
		(
				-- Current year powerbroker
				select
					'pb' as 'Source'
					,year(@dt) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,m.revenue_code_id as 'Revenue_Type'
					,sum(m.movement_revenue_amt) as 'Revenue'
					,sum(m.movement_spread_amt) as 'Spread'
					,count(distinct m.movement_id) as 'Volume'
				from bi_prod.bi_denorm.movements as m
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
				where
					cal.calendar_date between @from_curr and @to_curr
				group by
					m.revenue_code_id
					,cal.cal_month_date
				--------

				union

				-- Current year banyan
				select
					'byn' as 'Source'
					,year(@dt) as 'Date_Year'
					,month(cal.cal_month_date) as 'Month'
					,iif(b.service_code = 'intermodal', 'IM', b.service_code) as 'Revenue_Type'
					,sum(b.carrier_net_price) as 'Revenue'
					,sum(b.shipment_spread) as 'Spread'
					,count(distinct b.load_id) as 'Volume'
				from bi_prod.bi_denorm.byn_shipments as b
				left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date
				where
					cal.calendar_date between @from_curr and @to_curr
				and b.client_name <> 'Hitach - THD'
				group by
					b.service_code
					,cal.cal_month_date
				--------
		) as tot
		where
			tot.revenue_type like @constraint
		group by
			tot.Month
) as a

left join
(
		select
			month(b.budget_month) as 'Month'
			,sum(b.revenue_amt) as 'Budget Revenue'
			,sum(b.spread_amt) as 'Budget Spread'
			,sum(b.volume) as 'Budget Volume'

		from bi_prod.bi_denorm.budget_by_mode as b
		where
			year(b.budget_month) = year(@dt)
		and b.mode not in ('TL Total', 'New Sales Spread Total')
		and iif(b.mode like 'TL%' or b.mode like 'New Sales Spread TL', 'TL', 
				iif(b.mode like 'LTL%' or b.mode like 'New Sales Spread LTL', 'LTL',
					iif(b.mode like '%FUM%' or b.mode like '%Freight Under Management%', 'FUM',
						iif(b.mode like '%Intermodal%', 'IM',
							'-')))) like @constraint + '%'
		group by
			b.budget_month
) as b on b.Month = a.Month

