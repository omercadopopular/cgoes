import numpy as np
from scipy.optimize import minimize

def Cholesky_Decomposition(matrix):
    
    if not np.array_equal(matrix, matrix.T):
        print(matrix)
        raise ValueError("Matrix for Cholesky Decomposition must be symmetrical.")
    
    n = matrix.shape[0]
    lower = np.zeros((n, n))
 
    # Decomposing a matrix into lower triangular
    for i in range(n): 
        for j in range(i + 1): 
            sum1 = 0
 
            # Summation for diagonals
            if j == i: 
                for k in range(j):
                    sum1 += lower[j][k] ** 2
                lower[j][j] = np.sqrt(matrix[j][j] - sum1)
            else:
                # Evaluating L(i, j) using L(j, j)
                for k in range(j):
                    sum1 += lower[i][k] * lower[j][k]
                if lower[j][j] > 0:
                    lower[i][j] = (matrix[i][j] - sum1) / lower[j][j]
    
    return lower

def shortAndLong(Omega_mu, sr_constraint_list, lr_constraint_list, F1):
    if np.array_equal(Omega_mu, Omega_mu.T):
        size = Omega_mu.shape[0]
    else:
        raise ValueError("Covariance matrix must be symmetrical.")
    
    M = np.identity(size) # initialize M

    # Flatten M and omega for scipy.optimize
    m = M.flatten()

    # Get 0-indexed column of a flattened matrix.
    def get_col(x, col):
        return x[(col) * size : (col+1) * size]

    def objective_func(x):
        # The Forbenius norm of (MM'-Omega)
        recovered = x.reshape((size, size)).T
        return np.linalg.norm(np.dot(recovered, recovered.T)-Omega_mu, 'fro')

    def sr_constraint_func(x, sr_cons):
        return x[size*(sr_cons[1]) + sr_cons[0]]
    def lr_constraint_func(x, lr_cons):
        return np.dot(F1[lr_cons[0], :], get_col(x, lr_cons[1]))
    cons = []
    for sr_cons in sr_constraint_list:
        cons.append({'type':'eq', 'fun':sr_constraint_func, 'args':(sr_cons,)})
    for lr_cons in lr_constraint_list:
        cons.append({'type':'eq', 'fun':lr_constraint_func, 'args':(lr_cons,)})
    
    ftol = 1e-7
    for i, val in np.ndenumerate(Omega_mu):
        if 0<val<ftol:
            ftol = val

    options = {
        'ftol': ftol*1e-3,  # Function tolerance. Must be set carefully as the covariance numbers could be small
        'disp': False    # Display the solver information
    }

    result = minimize(objective_func, m, constraints = cons, options = options)
    M = result.x.reshape((size, size)).T

    return M

def findM(Omega_mu, F1, sr_constraint=np.array([]), lr_constraint=np.array([]), sr_sign=np.array([]), lr_sign=np.array([])):
    constraint_allowed = np.array(['0','.'])
    sign_allowed = np.array(['+','-','.'])
    if not np.all(np.isin(sr_constraint, constraint_allowed)):
        raise ValueError("Unidentified character in short-run constraint.")
    if not np.all(np.isin(lr_constraint, constraint_allowed)):
        raise ValueError("Unidentified character in long-run constraint.")
    if not np.all(np.isin(sr_sign, sign_allowed)):
        raise ValueError("Unidentified character in short-run sign restriction.")
    if not np.all(np.isin(lr_sign, sign_allowed)):
        raise ValueError("Unidentified character in long-run sign restriction.")
    
    sr_constraint_list = []
    lr_constraint_list = []

    n = len(Omega_mu)
    
    default = np.full((n,n),'.')
    if sr_constraint.size == 0:
        sr_constraint = default
    if lr_constraint.size == 0:
        lr_constraint = default
    if sr_sign.size == 0:
        sr_sign = default
    if lr_sign.size == 0:
        lr_sign = default
    
    # Zero-constraint and sign restriction cannot be set on the same index
    # Can short- and long-term constraints be set simultaneously?
    if np.any((sr_constraint!='.') & (sr_sign!='.')):
        raise ValueError("(Short-run) zero-constraint and sign restriction cannot be set on the same index.")
    if np.any((lr_constraint!='.') & (lr_sign!='.')):
        raise ValueError("(Long-run) zero-constraint and sign restriction cannot be set on the same index.")

    # Short- and long-term constraints set simultaneously are count as 2 constraints
    has_constraint = (sr_constraint=='0').astype(int) + (lr_constraint=='0').astype(int)

    constraint_count_col = np.sum(has_constraint, axis=0)
    constraint_count_row = np.sum(has_constraint, axis=1)

    if not np.array_equal(sorted(constraint_count_col), np.arange(0,n)):
        raise ValueError("Check constraints. For shocks to be uniquely identified, "+\
                         "each column must have 0, 1, 2, ... constraints respectively.")
    if not np.array_equal(sorted(constraint_count_row), np.arange(0,n)):
        raise ValueError("Check constraints. For shocks to be uniquely identified, "+\
                         "each row must have 0, 1, 2, ... constraints respectively.")

    for i in range(n):
        for j in range(n):
            if sr_constraint[i,j] == '0':
                sr_constraint_list.append((i,j))
            if lr_constraint[i,j] == '0':
                lr_constraint_list.append((i,j))

    if len(sr_constraint_list)>0 and len(lr_constraint_list)>0:
        M = shortAndLong(Omega_mu, sr_constraint_list, lr_constraint_list, F1)
    else:
        # If the variables could be arranged so that M is a lower-triangular matrix, use Cholesky.
        sorted_rows = np.argsort(constraint_count_row)[::-1]
        sorted_columns = np.argsort(constraint_count_col)

        if not np.array_equal(sorted_rows, sorted_columns):
            M = shortAndLong(Omega_mu, sr_constraint_list, lr_constraint_list, F1)

        else:
            sorted_Omega = Omega_mu[:, sorted_columns][sorted_columns, :]
            sorted_F1 = F1[:, sorted_columns][sorted_columns, :]
            if sr_constraint_list:
                # print("Short-run Cholesky")
                M = np.linalg.cholesky(sorted_Omega)
            else:
                # print("Long-run Cholesky")
                M = np.dot(np.linalg.inv(sorted_F1), np.linalg.cholesky(np.dot(np.dot(sorted_F1, sorted_Omega), sorted_F1.T)))
            
            # Revert back to original column order
            order_columns = np.argsort(sorted_columns)
            M = M[:, order_columns][order_columns, :]

    # Sign constraint
    if not np.all(np.sum((sr_sign == '+') | (sr_sign == '-'), axis = 0)
                    + np.sum((lr_sign == '+') | (lr_sign == '-'), axis = 0) == 1):
        raise ValueError("Each column must have exactly one sign restriction.")

    flip_col = (np.sum((sr_sign!='.') & np.logical_xor(M<0, sr_sign=='-'),
                        axis=0) | np.sum((lr_sign!='.') & np.logical_xor(np.dot(F1, M)<0, lr_sign=='-'), axis=0)).astype(int)
    M = np.dot(M, np.diag(1-flip_col*2)) # 1(flip) -> -1, 0(don't flip) -> 1

    print("Transformation matrix M:")
    print(M, "\n")

    return M

def test():
    Omega_mu = np.array([[4, 12, 16],
                        [12, 37, 43],
                        [16, 43, 98]])
    F1 = np.array([[4,5,6],
                   [7,8,9],
                   [10,11,12]])
    lr_sign = np.array([['-','.','.'],
                        ['.','+','+'],
                         ['.','.','.']])
    lr_constraint = np.array([['.','.','0'],
                             ['.','.','.'],
                             ['.','.','.']])
    sr_constraint = np.array([['.','.','0'],
                             ['.','0','.'],
                             ['.','.','.']])
    M = findM(Omega_mu, F1, sr_constraint=sr_constraint, lr_constraint=lr_constraint, lr_sign=lr_sign)
    print(Omega_mu)
    print(np.dot(F1,M))
    print(np.dot(M,M.T))


    # print("Omega_mu:")
    # print(Omega_mu, '\n')
    # print("M*M^{-1}:")
    # print(np.dot(M, M.T), '\n')

if __name__ == "__main__":
    test()