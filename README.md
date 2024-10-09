# Optimizing-Data-Utility-with-Context-Aware-Metric-Differential-Privacy

To run the code, make sure Python and all the essential packages have been correctly installed on your local computer. Here is a brief introduction of the files we provide, and more detailed information can be found in the code and comments.

In “lp_ci_test”, we provide the code we used to test the conditional independence between locations, the detailed algorithm can be found in ‘lp_ci_test.py’, and in ‘test_example.py’ you can try the algorithm using synthetic data.

In “DNN”, we provide the deep neural networks model we used and its training process, you can find the detailed training code in ‘CA_mDP.py’, and in ‘DNN_test.py’ we provide a way you can try to use the model to predict, a sample test dataset is included. By running ‘run_example.py’, you can see how the model works.

In “data”, we provide some example data formats we used in the experiment. We mentioned 3 different ways to group data, and here you can find the data format of speed grouped, region grouped, and hour grouped data. You can add your own data in the format we provide here, and you can find the Rome taxi dataset we use at https://ieee-dataport.org/open-access/crawdad-romataxi, and the Porto taxi dataset we use at https://www.kaggle.com/datasets/crailtap/taxi-trajectory.

The main part of CI test is ‘CI_test.py’, 3 different test functions with respect to 3 different group ways are included. You can run ‘run_example.py’ to test the code and its performance.

For the utility test, in "dataperturbation"->"main.m", we implement the five data perturbation methods "1. LP+C-mDP", "2. LP+Markov", "3. LP", "4. ConstOPT", and "5. ExpMech". The perturbation_method can be selected in line 105-107. After running the code, the results of expected utility loss, PL, and expected PL are stored as "expected_utility_loss.mat", "PL.mat", and "expectedPL.mat". 
