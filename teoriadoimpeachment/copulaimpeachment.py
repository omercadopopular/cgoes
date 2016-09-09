# Coded by Carlos Góes (www.mercadopopular.org)

from mpl_toolkits.mplot3d import axes3d
import matplotlib.pyplot as plt
import numpy as np

#1. create copula

#define correlation tightness parameter
theta = 5

#draw two random vectors
x = np.random.rand(10000,1)
k = np.random.rand(10000,1)
    
#derive variable
w = 1 - ( 1 - ( 1 - ( 1 - x ) ** theta ) ** ( 1 / k ) ) ** ( 1 /  theta )
z = 1 - ( 1 - ( 1 - ( 1 - w ) ** theta ) ** (1 - k ) ) ** (1 / theta )

#2. derive marginal logistical distributions

#define average
mu = 0.5
    
#define standard deviation
s = 0.05
    
y1 = ( 1 / (1 + np.exp( - ( ( x - mu) / s) ) ) )
y2 = ( 1 / (1 + np.exp( - ( ( z - mu) / s) ) ) )
y = y1 * y2
      

fig = plt.figure()
ax = fig.gca(projection='3d')

ax.set_title('Uma teoria sobre o impeachment', loc='left')
ax.set_xlabel('Circunstância Política')
ax.set_ylabel('Justificativa Jurídica')
ax.set_zlabel('Probabilidade de Impeachment')

ax.view_init(elev=22, azim=-118)              # elevation and angle
ax.dist=10                                  # distance

ax.set_ylim3d((0,1))
ax.set_xlim3d((0,1))
ax.set_zlim3d((0,1))

ax.scatter(
           x, z, y,  # data
           color='red',                            # marker colour
           marker='o',                                # marker shape
           s=5                                       # marker size
           )
ax.grid(True)


fig2 = plt.figure()

plt.plot(x, y, 'ro', alpha=0.75)
plt.xlabel('Circunstância Política ou Justificativa Jurídica')
plt.ylabel('Probabilidade de Impeachment')
plt.axis([0, 1, 0, 1])
plt.grid(True)


fig3 = plt.figure()

plt.plot(z,x, 'ro', alpha=0.75)
plt.xlabel('Circunstância Política')
plt.ylabel('Justificativa Jurídica')
plt.axis([0, 1, 0, 1])
plt.grid(True)

plt.show()                                      
