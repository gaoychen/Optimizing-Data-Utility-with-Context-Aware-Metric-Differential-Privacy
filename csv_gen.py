import csv

'''
This is for using the output of CI_test to generate proper format of csv file for future use
'''
text_data = """
(paste the output here)
"""

results = text_data.strip().split('result of ')

with open('regionAndHour_Y=3_results.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Result', 'Proportion H0 True', 'Proportion H0 False', 'Average Pvalue', 'H0avr', 'Number of rows'])
    
    for result in results:
        if result:
            lines = result.strip().split('\n')
            result_id = lines[0].split(' ')[-1]
            h0_true = lines[1].split(': ')[-1]
            h0_false = lines[2].split(': ')[-1]
            avg_pvalue = lines[3].split(': ')[-1]
            h0_avr = lines[4].split(': ')[-1]
            num_of_rows = lines[5].split(': ')[-1]
            writer.writerow([result_id, h0_true, h0_false, avg_pvalue, h0_avr, num_of_rows])