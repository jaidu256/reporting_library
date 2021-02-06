select
	datename(month, b.budget_month) as 'Month'
	,iif(b.mode like 'TL%' or b.mode like 'New Sales Spread TL', 'Truckload', 
		iif(b.mode like 'LTL%' or b.mode like 'New Sales Spread LTL', 'LTL',
			iif(b.mode like '%FUM%' or b.mode like '%Freight Under Management%', 'FUM',
				iif(b.mode like '%Intermodal%', 'Intermodal',
					'-')))) as 'Revenue Type'
	,sum(b.revenue_amt) as 'Budget Revenue'
	,sum(b.spread_amt) as 'Budget Spread'
	,sum(b.volume) as 'Budget Volume'

from bi_prod.bi_denorm.budget_by_mode as b
where
	datepart(year, b.budget_month) = datepart(year, getdate())
and b.mode not in ('TL Total', 'New Sales Spread Total')
group by
	b.budget_month
	,iif(b.mode like 'TL%' or b.mode like 'New Sales Spread TL', 'Truckload', 
		iif(b.mode like 'LTL%' or b.mode like 'New Sales Spread LTL', 'LTL',
			iif(b.mode like '%FUM%' or b.mode like '%Freight Under Management%', 'FUM',
				iif(b.mode like '%Intermodal%', 'Intermodal',
					'-'))))
order by
	b.budget_month
	,[Revenue Type]