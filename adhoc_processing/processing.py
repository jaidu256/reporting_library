import os
import pandas as pd
import datetime as dt

def del_column(path, data):
    #for col_name in col_names_list:
    #if col_name in data.columns:
    #    del data[col_name]
    
    if 'mnum' in data.columns:
        del data['mnum']
    return data

def readWeights(path):
    file = os.path.join(path, 'Weights.csv')
    weights = pd.read_csv(file)
    weights['Date'] = pd.to_datetime(weights['Date'])
    return weights

def readErrors(path):
    file = os.path.join(path, 'error.csv')
    errors = pd.read_csv(file)
    return errors

def forecast(path, d):

    start_day = 5

    e = readErrors(path)
    percent_rev = e['Average of Rev Error %'].loc[e['Day'] == dt.datetime.today().day].values[0]
    percent_spr = e['Average of Spr Error %'].loc[e['Day'] == dt.datetime.today().day].values[0]

    dic = dict()

    dic['Spread MTD'] = d['Spread'].sum()
    dic['Revenue MTD'] = d['Revenue'].sum()

    dic['Budget Revenue'] = d['Budget (Rev)'].sum()
    dic['Budget Spread'] = d['Budget (Spr)'].sum()

    if dt.datetime.today().day == 1:
        data_new = pd.DataFrame()

        return data_new

    elif dt.datetime.today().day < start_day:
        data_new = pd.DataFrame(dic, index=[0])
        data_new = data_new[['Revenue MTD',
                             'Spread MTD',
                             'Budget Revenue',
                             'Budget Spread',
                             ]]

        return data_new

    elif dt.datetime.today().day >= start_day:
        w = readWeights(path)

        dic['Revenue Forecast'] = (d['Revenue'].sum() / w.loc[(w['Date'] >= d.dropna()['Date'].min()) & (w['Date'] <= d.dropna()['Date'].max())]['Revenue Weight'].sum()) * w.loc[(w['Date'] >= d['Date'].min()) & (w['Date'] <= d['Date'].max())]['Revenue Weight'].sum()
        dic['Spread Forecast'] = (d['Spread'].sum() /  w.loc[(w['Date'] >= d.dropna()['Date'].min()) & (w['Date'] <= d.dropna()['Date'].max())]['Spread Weight'].sum()) * w.loc[(w['Date'] >= d['Date'].min()) & (w['Date'] <= d['Date'].max())]['Spread Weight'].sum()

        dic['Revenue Forecast High'] = dic['Revenue Forecast'] * (1 / (1 - percent_rev))
        dic['Revenue Forecast Low'] = dic['Revenue Forecast'] * (1 / (1 + percent_rev))

        dic['Spread Forecast High'] = dic['Spread Forecast'] * (1 / (1 - percent_spr))
        dic['Spread Forecast Low'] = dic['Spread Forecast'] * (1 / (1 + percent_spr))

        #dic['Deviation % Forecast (Rev Bud)'] = (dic['Revenue Forecast'] - dic['Budget Revenue']) / dic['Budget Revenue']
        #dic['Deviation % Forecast (Spr Bud)'] = (dic['Spread Forecast'] - dic['Budget Spread']) / dic['Budget Spread']

        data_new = pd.DataFrame(dic, index=[0])
        data_new = data_new[['Revenue MTD',
                             'Spread MTD',
                             'Budget Revenue',
                             'Budget Spread',
                             'Revenue Forecast High',
                             'Revenue Forecast Low',
                             'Spread Forecast High',
                             'Spread Forecast Low'
                             ]]

        return data_new

def weightedBudget(path, d):
    weights = readWeights(path)
    w = weights.loc[(weights['Date'] <= d['Date'].max()) & (weights['Date'] >= d['Date'].min())]

    data_new = d.set_index('Date').join(w.set_index('Date')).reset_index()
    data_new['Budget (Rev)'] = (data_new['Budget (Rev)'].sum() / data_new['Revenue Weight'].sum()) * data_new['Revenue Weight']
    data_new['Budget (Spr)'] = (data_new['Budget (Spr)'].sum() / data_new['Spread Weight'].sum())* data_new['Spread Weight']
    data_new['Budget (Margin %)'] = data_new['Budget (Spr)'] / data_new['Budget (Rev)']

    data_new['Deviation $ (Rev)'] = data_new['Revenue'] - data_new['Budget (Rev)']
    data_new['Deviation % (Rev)'] = (data_new['Revenue'] - data_new['Budget (Rev)']) / data_new['Budget (Rev)']
    data_new['Deviation $ (Spr)'] = data_new['Spread'] - data_new['Budget (Spr)']
    data_new['Deviation % (Spr)'] = (data_new['Spread'] - data_new['Budget (Spr)']) / data_new['Budget (Spr)']

    columns = ['Day', 'Date', 'Load Count', 'Revenue', 'Spread', 'Margin %', 'Budget (Rev)', 'Budget (Spr)', 'Budget (Margin %)', 'Deviation $ (Rev)', 'Deviation % (Rev)', 'Deviation $ (Spr)', 'Deviation % (Spr)']
    data = data_new[columns]
    return data

