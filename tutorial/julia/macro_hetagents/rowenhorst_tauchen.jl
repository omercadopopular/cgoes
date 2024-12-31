using Distributions, LinearAlgebra

function rowenhorst(mean, uncond_sd, rho, num_states)
    """
    Rowenhort's method to approximate AR(1) process with Markov chain (ln y_t = mu + rho y_{t-1} + e_t)
    Note: this function also normalizes effective labour to one.
    
    #### Fields
    
    - 'mean': unconditional mean of income process
    - 'uncond_sd': unconditional standard deviation
    - 'rho': autocorrelation coefficient
    - 'num_states': number of states we want discretized
    
    #### Returns
    
    - 'transition_matrix': num_states x num_states array where
    transition_matrx[i,j] is prob. of going from i to j
    - 'ygrid': vector of income state space of length num_states
    
    """
    
    # construct grids
    step_r = uncond_sd*sqrt(num_states-1)
    ygrid = -1:2/(num_states-1):1
    ygrid = mean .+ step_r*ygrid
    
    # initialize transition probabilities 
    p = (rho+1)/2
    q = p
    
    transition_matrix = [p 1-p; 1-q q]
    
    # rowenhort's method
    for i = 2:num_states-1
        a1 = [transition_matrix zeros(i, 1); zeros(1, i+1)] 
        a2 = [zeros(i,1) transition_matrix; zeros(1, i+1)]
        a3 = [zeros(1, i+1); transition_matrix zeros(i,1)]
        a4 = [zeros(1, i+1); zeros(i,1) transition_matrix]
        
        transition_matrix = p*a1 + (1-p)*a2 + (1-q)*a3 + q*a4
        transition_matrix[2:i, :] = transition_matrix[2:i, :]/2
    end
    
    for i = 1:num_states
       transition_matrix[i,:] = transition_matrix[i,:]/sum(transition_matrix[i,:])
    end
    
    # get stationary distribution to normalize effective labour to L=1
    pi = eigvecs(transition_matrix')[:,num_states]
    
    # normalize pi
    pi = pi./sum(pi)
    
    # exponentiate
    ygrid = exp.(ygrid)
    
    # normalize effective labour
    ygrid = ygrid/sum(pi.*ygrid)
    
    return transition_matrix, ygrid
end


function tauchen(mean, sd, rho, num_states; q=3)

    """
    Tauchen's method to approximate AR(1) process with Markov Chain
    
    ##### Fields
    
    - 'num_states': Number of points in markov process
    - 'sd' : Standard deviation of innovation
    - 'rho' : Autocorrelation coefficient
    - 'mean': Unconditional mean
    -  'q' : The number of standard deviations to each side of the process
    
    ##### Returns
    
    - 'transition_matrix': num_states x num_states array where
    transition_matrx[i,j] is prob. of going from i to j
    - 'ygrid': vector of income state space of length num_states
    
    """
    

      uncond_sd = sd/sqrt(1-rho^2)
      y = range(-q*uncond_sd, stop = q*uncond_sd, length = num_states)
      d = y[2]-y[1]

      Pi = zeros(num_states,num_states)

      for row = 1:num_states
        # end points
            Pi[row,1] = cdf(Normal(),(y[1] - rho*y[row] + d/2)/sd)
            Pi[row,num_states] = 1 - cdf(Normal(), (y[num_states] - rho*y[row] - d/2)/sd)

        # middle columns
            for col = 2:num_states-1
                Pi[row, col] = (cdf(Normal(),(y[col] - rho*y[row] + d/2) / sd) -
                               cdf(Normal(),(y[col] - rho*y[row] - d/2) / sd))
            end
      end

    yy = y .+ mean # center process around its mean

    Pi = Pi./sum(Pi, dims = 2) # renormalize

    return Pi, yy
end 
