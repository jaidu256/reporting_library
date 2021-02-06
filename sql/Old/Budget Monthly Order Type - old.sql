select
	DATEPART(MONTH, bud.budget_month) as 'mnum'
	,DATENAME(MONTH, bud.budget_month) as 'Month'
	,bud.order_type_group as 'Order Type'
	,sum(bud.revenue_amt) as 'Budget Revenue'
	,sum(bud.spread_amt) as 'Budget Spread'
	,sum(bud.volume) as 'Budget Volume'
from bi_prod.bi_denorm.budget_master_data as bud
where
	bud.order_type_group is not null
and	datepart(year,bud.budget_month) = datepart(year, getdate())
group by
	DATEPART(MONTH, bud.budget_month)
	,DATENAME(MONTH, bud.budget_month)
	,bud.order_type_group
order by
	mnum
	,bud.order_type_group