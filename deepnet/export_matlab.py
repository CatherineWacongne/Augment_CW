from lasagne.layers import get_output

import numpy as np
import scipy.io as sio


def export_weights(net):
    num_layers = len(net.layers_)
    layers_W = np.zeros((num_layers,), dtype=np.object)
    for lay in range(num_layers):
        try:
            layers_W[lay]=net.layers_[lay].W.get_value()
            print "layer added"
            
        except AttributeError:
            print "Doesn't exist"
        
    sio.savemat('network_weights.mat',{'layers_W': layers_W} )
    
    
    
    
    
    
    