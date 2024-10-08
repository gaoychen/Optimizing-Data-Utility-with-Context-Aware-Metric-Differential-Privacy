import numpy as np
import pandas as pd
from lp_ci_test import lp_ci_test
import os

'''
This is the main part of CI test code, we mentioned three different ways to group data,
so there are three different functions to use to test the CI status of each grouped data.
You can refer to the data format provided by us to add your own data for testing.

The algorithm will first read the file, and if the data size is too large, it will repeat
the experiment with random samples in groups of 1000 to improve efficiency. Error reduction
by repeating the experiment several times and removing the maximum and minimum values.

A dictionary of all the results is returned for printing and future use.
'''

###########################-------hour test-------################################
def hour_test():
    finalResult={}
    for iteration in range(1,6):
        for col in range(1,6):
            for row in range(1,5):
                for hour in range(24):
                    filename = f'data/group_by_hour/{hour}~{hour+1}_Y={iteration}.csv'
                    if not os.path.exists(filename):
                        continue
                    num_rows = sum(1 for row in open(filename, 'r'))
                    results = []
                    if num_rows > 1000:
                        for i in range(1,12):
                            start_row = np.random.randint(0, num_rows - 1000)
                            data = pd.read_csv(filename, header=None, skiprows=start_row, nrows=1000).values
                            X = data[:, 0:2] 
                            Y = data[:, 2:2*(iteration+1)]
                            Z = data[:, 2*(iteration+1):2*(iteration+2)]
                            result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                            results.append(result)
                        num_rows = 1000
                    else:
                        data = pd.read_csv(filename, header=None).values
                        for i in range(1,12):
                            X = data[:, 0:2]
                            Y = data[:, 2:2*(iteration+1)]
                            Z = data[:, 2*(iteration+1):2*(iteration+2)]
                            result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                            results.append(result)
                    
                    total_pvalue = 0
                    count_H0_true = 0
                    count_H0_false = 0
                    
                    results = sorted(results, key=lambda x: x['pvalue'])[3:-3]
                    
                    for item in results:
                        total_pvalue += item['pvalue']
                        if item['H0']:
                            count_H0_true += 1
                        else:
                            count_H0_false += 1
                    
                    average_pvalue = total_pvalue / len(results)
                    proportion_H0_true = count_H0_true / len(results)
                    proportion_H0_false = count_H0_false / len(results)
                    
                    key = f"regionAndHour_{col}_{row}_{hour}_Y={iteration}"
                    finalResult[key] = {
                        "proportion_H0_true": proportion_H0_true,
                        "proportion_H0_false": proportion_H0_false,
                        "average_pvalue": average_pvalue,
                        "H0avr": "True" if average_pvalue >= 0.05 else "False",
                        "Number of rows": num_rows
                    }
                    return finalResult

###########################-------region test-------################################
def region_test():
    finalResult={}
    for iteration in range(1,6):
        for col in range(1,6):
            for row in range(1,5):
                filename = f'data/group_by_region/12_{col}_{row}_Y={iteration}.csv'
                if not os.path.exists(filename):
                    continue
                num_rows = sum(1 for row in open(filename, 'r'))
                results = []
                if num_rows > 1000:
                    for i in range(1,12):
                        start_row = np.random.randint(0, num_rows - 1000)
                        data = pd.read_csv(filename, header=None, skiprows=start_row, nrows=1000).values
                        X = data[:, 0:2]
                        Y = data[:, 2:2*(iteration+1)]
                        Z = data[:, 2*(iteration+1):2*(iteration+2)]
                        result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                        results.append(result)
                    num_rows = 1000
                else:
                    data = pd.read_csv(filename, header=None).values
                    for i in range(1,12):
                        X = data[:, 0:2]
                        Y = data[:, 2:2*(iteration+1)]
                        Z = data[:, 2*(iteration+1):2*(iteration+2)]
                        result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                        results.append(result)

                total_pvalue = 0
                count_H0_true = 0
                count_H0_false = 0
                
                results = sorted(results, key=lambda x: x['pvalue'])[3:-3]
                
                for item in results:                                    
                    total_pvalue += item['pvalue']
                    if item['H0']:
                        count_H0_true += 1
                    else:
                        count_H0_false += 1
                
                average_pvalue = total_pvalue / len(results)
                proportion_H0_true = count_H0_true / len(results)
                proportion_H0_false = count_H0_false / len(results)
                
                key = f"12_{col}_{row}_Y={iteration}"
                finalResult[key] = {
                    "proportion_H0_true": proportion_H0_true,
                    "proportion_H0_false": proportion_H0_false,
                    "average_pvalue": average_pvalue,
                    "H0avr": "True" if average_pvalue >= 0.05 else "False",
                    "Number of rows": num_rows
                }
                return finalResult

###########################-------speed test-------################################
def speed_test():
    finalResult={}
    for iteration in range(1,6):
        for speed in range(0,120,5):
            filename = f'data/group_by_speed/speed_{speed}~{speed+5}_Y={iteration}.csv'
            if not os.path.exists(filename):
                continue
            num_rows = sum(1 for row in open(filename, 'r'))
            results = []
            if num_rows > 1000:
                for i in range(1,12):
                    start_row = np.random.randint(0, num_rows - 1000)
                    data = pd.read_csv(filename, header=None, skiprows=start_row, nrows=1000).values
                    X = data[:, 0:2]
                    Y = data[:, 2:2*(iteration+1)]
                    Z = data[:, 2*(iteration+1):2*(iteration+2)]
                    result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                    results.append(result)
                num_rows = 1000
            else:
                data = pd.read_csv(filename, header=None).values
                for i in range(1,12):
                    X = data[:, 0:2]
                    Y = data[:, 2:2*(iteration+1)]
                    Z = data[:, 2*(iteration+1):2*(iteration+2)]
                    result = lp_ci_test.test_asymptotic_ci(X, Z, Y, rank=1000, J=10, p_norm=2)
                    results.append(result)
            
            total_pvalue = 0
            count_H0_true = 0
            count_H0_false = 0
            
            results = sorted(results, key=lambda x: x['pvalue'])[3:-3]
            
            for item in results:
                total_pvalue += item['pvalue']
                if item['H0']:
                    count_H0_true += 1
                else:
                    count_H0_false += 1
            
            average_pvalue = total_pvalue / len(results)
            proportion_H0_true = count_H0_true / len(results)
            proportion_H0_false = count_H0_false / len(results)
            
            key = f"speed_{speed}_{speed+5}_Y={iteration}"
            finalResult[key] = {
                "proportion_H0_true": proportion_H0_true,
                "proportion_H0_false": proportion_H0_false,
                "average_pvalue": average_pvalue,
                "H0avr": "True" if average_pvalue >= 0.05 else "False",
                "Number of rows": num_rows
            }
            return finalResult