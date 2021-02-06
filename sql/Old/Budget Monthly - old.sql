select
	DATEPART(MONTH, budget_month) as 'mnum'
	,datename(Month, budget_month) as 'Month'
	,sum(revenue_amt) as 'Budget Revenue'
	,sum(spread_amt) as 'Budget Spread'
	,sum(volume) as 'Budget Volume'
from bi_prod.bi_denorm.budget_master_data as bud
where
	datepart(year,bud.budget_month) = datepart(year, getdate())
group by
	DATEPART(MONTH, budget_month)
	,datename(Month, budget_month)
order by
	mnum