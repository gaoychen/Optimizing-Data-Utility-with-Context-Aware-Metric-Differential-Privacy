import CI_test
from DNN import DNN_test

'''
You can run the 'CI pvalue test' part to see how we use the grouped data and its output, this will use 
lp_ci_test to compute the pvalue, reflecting the conditional independence status of 
mobile vehicle trajectories.

You can run 'DNN test' part to see the predicted results of given test example, CI labeled as '1' means
conditional independent, '0' means not conditional independent.
'''

############## CI pvalue test #############
results = CI_test.hour_test()
# results = CI_test.region_test()
# results = CI_test.speed_test()

for key, values in results.items():
    print(f"result of {key}")
    print(f"proportion of H0 True: {values['proportion_H0_true']}")
    print(f"proportion of H0 False: {values['proportion_H0_false']}")
    print(f"average pvalue: {values['average_pvalue']}")
    print(f"H0avr: {values['H0avr']}")
    print(f"Number of rows: {values['Number of rows']}")

# ################ DNN test ###################
# DNN_test.DNN_test()