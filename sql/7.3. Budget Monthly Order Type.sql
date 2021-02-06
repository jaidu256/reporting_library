select
	datename(month, b.budget_month) as 'Month'
	,iif(b.mode like '% Contract', 'Contract',
		iif(b.mode like '% Outsource', 'Outsource',
			iif(b.mode like '% Primary', 'Primary',
				iif(b.mode like '% Transactional', 'Transactional','Sales Owned Accounts')))) as 'Order Type'
	,sum(b.revenue_amt) as 'Budget Revenue'
	,sum(b.spread_amt) as 'Budget Spread'
	,sum(b.volume) as 'Budget Volume'

from bi_prod.bi_denorm.budget_by_mode as b
where
	datepart(year, b.budget_month) = datepart(year, getdate())
and b.mode not in ('TL Total', 'New Sales Spread Total')
and b.mode like 'TL %'
group by
	b.budget_month
	,iif(b.mode like '% Contract', 'Contract',
		iif(b.mode like '% Outsource', 'Outsource',
			iif(b.mode like '% Primary', 'Primary',
				iif(b.mode like '% Transactional', 'Transactional','Sales Owned Accounts'))))
order by
	b.budget_month
	,[Order Type]