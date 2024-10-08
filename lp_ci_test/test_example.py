import numpy as np
import lp_ci_test

'''
This is for you too test the lp_ci-test algorithm
'''

funcs = {
    "linear": lambda x: x,
    "square": lambda x: x**2,
    "exp": lambda x: np.exp(-np.abs(x)),
    "cube": lambda x: x**3,
    "tanh": lambda x: np.tanh(x),
}

func_names = ["linear", "square", "exp", "cube", "tanh"]


def data_gen_1(n_samples, dim, test_type, noise="gaussian"):
    if noise == "gaussian":
        sampler = np.random.normal
    elif noise == "laplace":
        sampler = np.random.laplace

    keys = np.random.choice(range(len(func_names)), 2)
    pnl_funcs = [func_names[k] for k in keys]

    func1 = funcs[pnl_funcs[0]]
    func2 = funcs[pnl_funcs[1]]

    x = sampler(size=(n_samples, 1))
    y = sampler(size=(n_samples, 1))
    z = sampler(size=(n_samples, dim))
    if test_type:
        return func1(x), func2(y), z
    else:
        eb = 0.8 * sampler(size=(n_samples, 1))
        x += eb
        y += eb
        return func1(x), func2(y), z


def data_gen_2(n_samples, dim, test_type, noise="gaussian"):
    if noise == "gaussian":
        sampler = np.random.normal
    elif noise == "laplace":
        sampler = np.random.laplace
    keys = np.random.choice(range(5), 2)
    pnl_funcs = [func_names[k] for k in keys]

    func1 = funcs[pnl_funcs[0]]
    func2 = funcs[pnl_funcs[1]]

    x = sampler(size=(n_samples, 1))
    y = sampler(size=(n_samples, 1))
    z = sampler(size=(n_samples, dim))
    m = np.mean(z, axis=1).reshape(-1, 1)
    x += m
    y += m
    x, y = func1(x), func2(y)

    if test_type:
        return x, y, z
    else:
        eb = sampler(size=(n_samples, 1))
        x += eb
        y += eb
        return x, y, z


def run_exp_synthetic(
    seed, data, test_type, num_samples, dim, J, p_norm, rank, noise="gaussian"
):
    np.random.seed(seed)
    if data == "dataset_1":
        x, y, z = data_gen_1(
            n_samples=num_samples, test_type=test_type, dim=dim, noise=noise
        )
    else:
        x, y, z = data_gen_2(
            n_samples=num_samples, test_type=test_type, dim=dim, noise=noise
        )

    results = lp_ci_test.test_asymptotic_ci(x, y, z, rank, J=J, p_norm=p_norm)
    return results

# Customized Testing, you can choose different way to generate systhetic data and test type ('True' means generating data that is comditional independence)
# Chaning of 'dim' will affect the dimensions of 'Z', when we consider the senario of mobile vehicles, 'X' and 'Y' are Conditional Independent given 'Z', 'Z' here means the size of Markov Blanket
seed = 66
data = "dataset_1"
test_type = False
num_samples = 1000
dim = 5
J = 5
p_norm = 2
rank = 1000
noise = "gaussian"

result = run_exp_synthetic(seed, data, test_type, num_samples, dim, J, p_norm, rank, noise)
print(result)
