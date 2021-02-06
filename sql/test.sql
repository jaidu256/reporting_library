select
	m.movement_id as 'Id'
	,m.movement_cost_amt as 'Cost'
	,m.movement_revenue_amt as 'Revenue'
from bi_prod.bi_denorm.movements as m
join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id
where
	cal.rel_cal_day = -1