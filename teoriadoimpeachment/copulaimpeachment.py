# Escrito por Carlos Góes
# Pesquisador-Chefe do IMP (www.mercadopopular.org)

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
      

fig = plt.figure(facecolor='#F2F2F2')
ax = fig.gca(projection='3d', axisbg='#F2F2F2')

plt.style.use('ggplot')
ax.set_title('Uma teoria sobre o impeachment', loc='left')
ax.set_xlabel('Circunstância Política')
ax.set_ylabel('Justificativa Jurídica')
ax.set_zlabel('Probabilidade de Impeachment')

ax.view_init(elev=22, azim=-118)             
ax.dist=10                                  

ax.set_ylim3d((0,1))
ax.set_xlim3d((0,1))
ax.set_zlim3d((0,1))

ax.scatter(
           x, z, y,  
           color='red',                           
           marker='o',                               
           s=5                                      
           )
ax.grid(True)

fig.savefig('fig1.png', facecolor='#F2F2F2', bbox_inches='tight')



fig2 = plt.figure(facecolor='#F2F2F2')

plt.plot(x, y, 'ro', alpha=0.75)
plt.style.use('ggplot')
plt.title('Probabilidade de Impeachment condicional à política e o direito', loc='left')
plt.xlabel('Circunstância Política ou Justificativa Jurídica')
plt.ylabel('Probabilidade de Impeachment')
plt.axis([0, 1, 0, 1])
plt.grid(True)

fig2.savefig('fig2.png', facecolor='#F2F2F2', bbox_inches='tight')


fig3 = plt.figure(facecolor='#F2F2F2')

plt.plot(z,x, 'ro', alpha=0.75)
plt.style.use('ggplot')
plt.title('Correlação entre política e direito', loc='left')
plt.xlabel('Circunstância Política')
plt.ylabel('Justificativa Jurídica')
plt.axis([0, 1, 0, 1])
plt.grid(True)

plt.show()       

fig3.savefig('fig3.png', facecolor='#F2F2F2', bbox_inches='tight')
