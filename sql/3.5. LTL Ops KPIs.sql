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
	,@constraint varchar(5) = 'LTL'

select
	DATENAME(month, DATEADD(month, tot.Month-1, @dt_prev_year_start)) as 'Month'
	,sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.volume, 0)) as 'Spread per Load'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0)) as 'Spread per Load PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.Spread, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.volume, 0)))
	 - (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0))))
	 / (sum(iif(tot.Date_Year = year(@dt_prev), tot.Spread, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0))) as 'YoY Change % (SPL)'
	
	,sum(iif(tot.Date_Year = year(@dt), tot.revenue, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)) as 'Customer Cost Per Pound'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.revenue, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0)) as 'Customer Cost Per Pound PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.revenue, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)))
	 - (sum(iif(tot.Date_Year = year(@dt_prev), tot.revenue, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0))))
	 / (sum(iif(tot.Date_Year = year(@dt_prev), tot.revenue, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0))) as 'YoY Change % (Customer Cost Per Pound)'

	,sum(iif(tot.Date_Year = year(@dt), tot.cost, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)) as 'Carrier Cost Per Pound'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.cost, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0)) as 'Carrier Cost Per Pound PY'
	,((sum(iif(tot.Date_Year = year(@dt), tot.cost, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)))
	 - (sum(iif(tot.Date_Year = year(@dt_prev), tot.cost, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0))))
	 / (sum(iif(tot.Date_Year = year(@dt_prev), tot.cost, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0))) as 'YoY Change % (Carrier Cost Per Pound)'

	,sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.volume, 0)) as 'Avg Weight'
	,sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0)) as 'Avg Weight PY'	
	,((sum(iif(tot.Date_Year = year(@dt), tot.weight, 0)) / sum(iif(tot.Date_Year = year(@dt), tot.volume, 0))) 
	- (sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0))))
	 / (sum(iif(tot.Date_Year = year(@dt_prev), tot.weight, 0)) / sum(iif(tot.Date_Year = year(@dt_prev), tot.volume, 0))) as 'YoY Change % (Avg Weight)'

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
			,sum(m.movement_cost_amt) as 'Cost'
			,count(distinct m.movement_id) as 'Volume'
			,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
			,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss_Volume'
			,sum(m.weight_billed) as 'Weight'
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
			,sum(b.raw_net_price) as 'Cost'
			,count(distinct b.load_id) as 'Volume'
			,sum(iif(b.shipment_spread < 0, b.shipment_spread, 0)) as 'Loss'
			,sum(iif(b.shipment_spread < 0, 1, 0)) as 'Loss_Volume'
			,sum(b.total_weight) as 'Weight'
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
			,sum(m.movement_revenue_amt) as 'Revenue'
			,sum(m.movement_spread_amt) as 'Spread'
			,sum(m.movement_cost_amt) as 'Cost'
			,count(distinct m.movement_id) as 'Volume'
			,sum(iif(m.movement_spread_amt < 0, m.movement_spread_amt, 0)) as 'Loss'
			,sum(iif(m.movement_spread_amt < 0, 1, 0)) as 'Loss_Volume'
			,sum(m.weight_billed) as 'Weight'
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
			,sum(b.carrier_net_price) as 'Revenue'
			,sum(b.shipment_spread) as 'Spread'
			,sum(b.raw_net_price) as 'Cost'
			,count(distinct b.load_id) as 'Volume'
			,sum(iif(b.shipment_spread < 0, b.shipment_spread, 0)) as 'Loss'
			,sum(iif(b.shipment_spread < 0, 1, 0)) as 'Loss_Volume'
			,sum(b.total_weight) as 'Weight'
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