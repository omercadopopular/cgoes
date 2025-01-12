import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.api import VAR
from plotting import plot_ir
from identification import findM
import copy
from scipy import stats
    
# Encapsulation of input to provide default values and keep modularity
class VAR_input:
    __slots__ = ['df', 'size', 'variables', 'variable_order', 'shocks', 'td_col', 'member_col', 'M', 'sr_constraint', 'lr_constraint', 'sr_sign', 'lr_sign',
                 'maxlags', 'nsteps', 'lagmethod', 'bootstrap', 'ndraws', 'signif', 'plot', 'savefig_path']
    
    def __init__(self, variables, variable_order, shocks, td_col=[], member_col="", M=None, sr_constraint=np.array([]), lr_constraint=np.array([]), sr_sign=np.array([]), lr_sign=np.array([]),
                 maxlags=5, nsteps=12, lagmethod='aic', bootstrap=True, ndraws=2000, signif=0.05,
                 excel_path="", excel_sheet_name="", df=pd.DataFrame(), plot=True, savefig_path=""):
        # Build input dataframe
        if excel_path != "":
            if excel_sheet_name != "":
                self.df = pd.read_excel(excel_path, sheet_name=excel_sheet_name)
            else:
                raise ValueError("Please specify excel sheet name.")
        else:
            if len(df) > 0:
                self.df = df.copy()
            else:
                raise ValueError("Empty input data.")
        
        self.variables = variables
        self.variable_order = variable_order
        for var in variable_order:
            if var not in variables:
                raise Exception("Stationarity of variable " + var + " is not specified.")

        self.shocks = shocks
        self.size = len(self.variables)
        if len(self.shocks) != self.size:
            raise ValueError("Variable and shock have different dimensions.")
        
        self.td_col = td_col
        if len(td_col) == 0:
            print("Td column not specified. Assuming data is sorted.")
        else:
            self.df.sort_values(by=td_col, inplace=True)
        self.member_col = member_col
        
        self.M = M
        self.sr_constraint = sr_constraint
        self.lr_constraint = lr_constraint

        if len(sr_sign) == 0:
            self.sr_sign = np.full((self.size, self.size), '.')
        else:
            if sr_sign.shape != (self.size, self.size):
                raise ValueError("Incorrect dimensions for short-run sign restrictions.")
            self.sr_sign = sr_sign
        
        if len(lr_sign) == 0:
            self.lr_sign = np.full((self.size, self.size), '.')
        else:
            if lr_sign.shape != (self.size, self.size):
                raise ValueError("Incorrect dimensions for long-run sign restrictions.")
            self.lr_sign = lr_sign

        self.maxlags = maxlags
        self.nsteps = nsteps
        self.lagmethod = lagmethod
        self.bootstrap = bootstrap
        self.ndraws = ndraws
        self.signif = signif
        self.plot = plot
        self.savefig_path = savefig_path

class VAR_output:
    __slots__ = ['lag_order', 'shock', 'ir', 'ir_upper', 'ir_lower', 'fevd']
    def __init__(self, lag_order=0, shock=np.array([]), ir=np.array([]),
                 ir_upper=np.array([]), ir_lower=np.array([]), fevd=np.array([])):
        self.lag_order = lag_order
        self.shock = shock
        self.ir = ir
        self.ir_upper = ir_upper
        self.ir_lower = ir_lower
        self.fevd = fevd

def VAR_predict(var_df, coefs, const):
    size = var_df.shape[1]
    order = var_df.shape[0]
    try:
        coefs = np.reshape(coefs, (order, size, size))
    except:
        raise ValueError("Invalid input.")

    # print(coefs)
    # raise Exception

    output = const.copy()
    for l in range(order):
        output += np.dot(var_df.iloc[order-1-l], coefs[l])
    return output

def SVAR(input):
    output = VAR_output()

    if len(input.td_col) > 0:
        # Would raise error if there are duplicate times.
        input.df.set_index(input.td_col, inplace = True)

    df = input.df[input.variable_order]

    # Convert to stationary form
    # This cannot be done in __init__ of VAR_input because, in a data panel,
    # the steady-state data must be averaged first before finding the log diff.
    def log_diff(arr):
        log_arr = np.log(arr)
        return log_arr - log_arr.shift(1)
    for var in input.variables:
        if input.variables[var][0] == 1:
            df[var] = log_diff(df[var])
            input.variables[var][0] = 0
    df.dropna(inplace=True)
    
    model = VAR(df)
    results = model.fit(maxlags=input.maxlags, ic=input.lagmethod)
    # print(results.params) # VAR coefficients
    # print(results.sigma_u) # Covariance matrix Omega_mu

    # Cannot invert to VMA form if no lags selected
    output.lag_order = results.k_ar
    if output.lag_order == 0:
        return output
    
    prediction = model.predict(params=results.params, lags=output.lag_order)
    output.shock = df.iloc[output.lag_order:, :] - prediction # This step calculates mu. Will be tranformed into epsilon

    # Estimate impulse response, without any transformation of the shocks (FACTOR = %identity(m))
    irf = results.irf(input.nsteps)
    # print(irf.irfs)

    if input.M is None:
    # Calculate decomposition matrix M
        F1 = np.zeros((input.size, input.size))
        for f in irf.irfs:
            F1 += f

        input.M = findM(np.cov(output.shock.values.T), F1, input.sr_constraint, input.lr_constraint,
                               input.sr_sign, input.lr_sign)

    output.ir = irf.irfs
    for i in range(input.nsteps+1):
        output.ir[i] = np.dot(output.ir[i], input.M)
    
    if input.bootstrap:
        print("Bootstrapping in progress...")
        normal_interval = False
        draw_from_normal = False
        burn = 100
        
        # Initialize output storage
        if normal_interval:
            mean_accum = np.zeros_like(output.ir)
            sq_diff_accum = np.zeros_like(output.ir)
        if not normal_interval:
            # This uses too much memory when dataset is large
            IRs = np.zeros((input.ndraws, input.nsteps+1, input.size, input.size))

        for i in range(input.ndraws):
            # Initialize input object
            boot_input = copy.deepcopy(input)
            boot_input.bootstrap = False
            boot_input.plot = False
            boot_input.td_col = ""

            shuffled_shock = np.zeros((output.shock.shape[0]+burn, input.size))
            if draw_from_normal:
                shuffled_shock = np.random.multivariate_normal(np.array([0,0]), results.sigma_u, shuffled_shock.shape[0])
            else:
                # Draw randomly with replacement
                for j in range(shuffled_shock.shape[0]):
                    shuffled_shock[j] = output.shock.iloc[np.random.randint(0, output.shock.shape[0]-1)]
            
            # shuffled_shock = shuffled_shock / 1

            # Generate bootstrap data
            drop_const = True

            initial_cond = np.zeros((output.lag_order, input.size))
            initial_cond = df.iloc[output.lag_order:]
            boot_input.df = pd.DataFrame(columns = input.variable_order, data = np.concatenate((initial_cond, shuffled_shock), axis=0))

            coefs = np.array(results.params.iloc[1:])
            const = np.zeros(input.size)

            if not drop_const:
                const = np.array(results.params.iloc[0])

            for p in range(output.lag_order, boot_input.df.shape[0]):
                boot_input.df.iloc[p] += VAR_predict(boot_input.df.iloc[p-output.lag_order : p], coefs, const)

            boot_input.df = boot_input.df.iloc[burn:]

            # Find impulse response subject to structrual restrictions
            
            boot_output = SVAR(boot_input)
            if boot_output.lag_order == 0:
                # Unsuccessful VAR. No lags selected. Treat all VMA coefs as zero.
                continue

            if normal_interval:
                mean_accum += boot_output.ir
                sq_diff_accum += boot_output.ir ** 2
            else:
                IRs[i] = boot_output.ir
            
        if normal_interval:
            boot_mean = mean_accum / input.ndraws
            boot_std = np.sqrt(sq_diff_accum / input.ndraws - boot_mean ** 2)
            z_score = stats.norm.ppf(1 - input.signif / 2)
            output.ir_lower = boot_mean - z_score * boot_std
            output.ir_upper = boot_mean + z_score * boot_std
        else:
            # Sort boot_output.ir in IRs and find thresholds
            output.ir_lower = np.empty_like(output.ir)
            output.ir_upper = np.empty_like(output.ir)
            for lg in range(input.nsteps+1):
                for vr in range(input.size):
                    for sk in range(input.size):
                        output.ir_lower[lg, vr, sk], output.ir_upper[lg, vr, sk] = stats.mstats.mquantiles(
                            IRs[:, lg, vr, sk], [input.signif / 2, 1 - input.signif / 2])
 
    M_inv = np.linalg.inv(input.M)
    for i in range(len(output.shock)):
        # print(output.shock.iloc[i,:])
        output.shock.iloc[i, :] = np.dot(M_inv, output.shock.iloc[i,:].T).T # epsilon = M^(-1) * mu

    # Convert to impulse reponse of steady state for unit root variables
    for i, var in enumerate(input.variable_order):
        if input.variables[var][1] == 1:
            output.ir[:, i, :] = output.ir[:, i, :].cumsum(axis=0)

    # VARIANCE DECOMPOSITION NEEDS MORE WORK
    fevd = results.fevd(input.nsteps)
    # fevd.summary()

    ALALT = []
    for i in range(len(output.ir)):
        ALALT.append(np.dot(output.ir[i], output.ir[i].T))
    ALALT = np.array(ALALT)

    VD = ALALT.cumsum(axis=0)
    VD = np.abs(VD)
    for i in range(len(VD)):
        VD[i] /= VD[i].sum(axis=1, keepdims=True)
    # print(VD)

    if input.plot:
        plot_ir(input.variable_order, input.shocks, output.ir,
                lower_errband=output.ir_lower, upper_errband=output.ir_upper,
                show_plot=True, save_plot=True, plot_path=input.savefig_path)
    
    return output

if __name__ == "__main__":
    pass