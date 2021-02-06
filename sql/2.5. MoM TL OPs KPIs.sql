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

select
	DATENAME(month, DATEADD(month, tot.Month-1, @dt_prev_year_start)) as 'Month'
	
	,sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1)  as 'Spread Per Load'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1) as 'Spread Per Load PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)))
	/ (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)) 'YoY Change % (Spread Per Load)'

	,sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1)  as 'Loss Per Load'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1) as 'Loss Per Load PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)))
	/ (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)) 'YoY Change % (Loss Per Load)'

	,sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) + 1)  as 'Loss Percent (Spr)'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) + 1) as 'Loss Percent (Spr) PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) + 1))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) + 1)))
	/ (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) + 1)) 'YoY Change % (Loss Percent (Spr))'

	,cast(sum(iif(tot.Date_Year = year(@dt), tot.[Loss Volume], 0)) as float) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1)  as 'Loss Percent (Vol)'
	,cast(sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0)) as float) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1) as 'Loss Percent (Vol) PY'
	,((cast(sum(iif(tot.Date_Year = year(@dt), tot.[Loss Volume], 0)) as float) / (sum(iif(tot.Date_Year = year(@dt), tot.Volume, 0)) + 1))
	- (cast(sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0)) as float) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)))
	/ (cast(sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0)) as float) / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Volume, 0)) + 1)) 'YoY Change % (Loss Percent (Vol))'

	,sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0))  as 'Loss Amount'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) as 'Loss Amount PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.Loss, 0)))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0))))
	/  (sum(iif(tot.Date_Year = year(@dt_prev), tot.Loss, 0)) + 1) as 'YoY Change % (Loss Amount)'

	,sum(iif(tot.Date_Year = year(@dt), tot.[Loss Volume], 0))  as 'Loss Volume'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0)) as 'Loss Volume PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.[Loss Volume], 0)))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0))))
	/  (sum(iif(tot.Date_Year = year(@dt_prev), tot.[Loss Volume], 0)) + 1) as 'YoY Change % (Loss Volume)'

	,sum(iif(tot.Date_Year = year(@dt), tot.[Roll Count], 0))  as 'Roll Count'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.[Roll Count], 0)) as 'Roll Count PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.[Roll Count], 0)))
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.[Roll Count], 0))))
	/  (sum(iif(tot.Date_Year = year(@dt_prev), tot.[Roll Count], 0)) + 1) as 'YoY Change % (Roll Count)'
from
(
		-- Current year powerbroker
		select
			'pb' as 'Source'
			,year(@dt) as 'Date_Year'
			,month(cal.cal_month_date) as 'Month'
			,m.revenue_code_id as 'Revenue_Type'
			,sum(m.movement_spread_amt) + 1 'Spread'
			,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) + 1 'Loss'
			,sum(iif(m.movement_spread_amt < 0, 1, 0)) + 1 as 'Loss Volume'
			,count(distinct m.movement_id) + 1 as 'Volume'
			,sum(m.rolled_cnt) + 1 as 'Roll Count'
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
			,sum(b.shipment_spread) + 1 'Spread'
			,sum(iif(b.shipment_spread < 0, b.shipment_spread, 0)) + 1 'Loss'
			,sum(iif(b.shipment_spread < 0, 1, 0)) + 1 as 'Loss Volume'
			,count(distinct b.load_id) + 1 as 'Volume'
			,1 as 'Roll Count'
		from bi_prod.bi_denorm.byn_shipments as b
		left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date
		where
			cal.calendar_date between @from_curr and @to_curr
		and b.client_name <> 'Hitach - THD'
		group by
			b.service_code
			,cal.cal_month_date
		--------

		union

		-- Previous year powerbroker
		select
			'pb' as 'Source'
			,year(@dt_prev) as 'Date_Year'
			,month(cal.cal_month_date) as 'Month'
			,m.revenue_code_id as 'Revenue_Type'
			,sum(m.movement_spread_amt) + 1 'Spread'
			,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) + 1 'Loss'
			,sum(iif(m.movement_spread_amt < 0, 1, 0)) + 1 as 'Loss Volume'
			,count(distinct m.movement_id) + 1 as 'Volume'
			,sum(m.rolled_cnt) + 1 as 'Roll Count'
		from bi_prod.bi_denorm.movements as m
		left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
		where
			cal.calendar_date between @from_prev and @to_prev
		group by
			m.revenue_code_id
			,cal.cal_month_date
		--------

		union

		-- Previous year banyan
		select
			'byn' as 'Source'
			,year(@dt_prev) as 'Date_Year'
			,month(cal.cal_month_date) as 'Month'
			,iif(b.service_code = 'intermodal', 'IM', b.service_code) as 'Revenue_Type'
			,sum(b.shipment_spread) + 1 'Spread'
			,sum(iif(b.shipment_spread < 0, b.shipment_spread, 0)) + 1 'Loss'
			,sum(iif(b.shipment_spread < 0, 1, 0)) + 1 as 'Loss Volume'
			,count(distinct b.load_id) + 1 as 'Volume'
			,1 as 'Roll Count'
		from bi_prod.bi_denorm.byn_shipments as b
		left join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date
		where
			cal.calendar_date between @from_prev and @to_prev
		and b.client_name <> 'Hitach - THD'
		group by
			b.service_code
			,cal.cal_month_date
		--------
) as tot
where
	tot.revenue_type like @constraint + '%'
group by
	tot.Month
order by
	tot.Month