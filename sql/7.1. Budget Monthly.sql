select
	datename(month, b.budget_month) as 'Month'
	,sum(b.revenue_amt) as 'Budget Revenue'
	,sum(b.spread_amt) as 'Budget Spread'
	,sum(b.volume) as 'Budget Volume'

from bi_prod.bi_denorm.budget_by_mode as b
where
	datepart(year, b.budget_month) = datepart(year, getdate())
and b.mode not in ('TL Total', 'New Sales Spread Total')
group by
	b.budget_month