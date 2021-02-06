declare @s int = %s

select
	datepart(DAY, pb.calendar_date) as 'Day'
	,isnull(pb.Revenue, 0) + isnull(byn.Revenue, 0) as 'Revenue'
	,isnull(pb.Spread, 0) + isnull(byn.Spread, 0) as 'Spread'
	,isnull(pb.Volume, 0) + isnull(byn.Volume, 0) as 'Volume'
from
(
				select
					cal.calendar_date
					,sum(m.movement_revenue_amt) as 'Revenue'
					,sum(m.movement_spread_amt) as 'Spread'
					,count(m.movement_id) as 'Volume'

				from bi_prod.bi_denorm.movements as m
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = m.actual_pickup_arrival_dt_id

				where
					rel_cal_month = @s
				and cal.calendar_date < cast(GetDAte() as date)
				and m.revenue_code_id = 'LTL'

				group by
					cal.calendar_date
) as pb
full outer join
(
				select
					cal.calendar_date
					,sum(b.carrier_net_price) as 'Revenue'
					,sum(b.shipment_spread) as 'Spread'
					,count(b.load_id) as 'Volume'

				from bi_prod.bi_denorm.byn_shipments as b
				join bi_prod.afnapp.calendar_dates as cal on cal.calendar_date = b.actual_pickup_date

				where
					rel_cal_month = @s
				and b.service_code = 'LTL'
				and b.client_name <> 'Hitachi - Thd'

				group by
					cal.calendar_date
) as byn on pb.calendar_date = byn.calendar_date

where
	pb.calendar_date is not null

order by
	Day