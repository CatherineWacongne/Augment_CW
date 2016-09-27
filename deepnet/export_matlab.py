from lasagne.layers import get_output

import numpy as np
import scipy.io as sio


def export_weights(net):
    num_layers = len(net.layers_)
    layers_W = np.zeros((num_layers,), dtype=np.object)
    layers_biais = np.zeros((num_layers,), dtype=np.object)
    layers_pad = np.zeros((num_layers,), dtype=np.object)
    layers_stride = np.zeros((num_layers,), dtype=np.object)
    layers_pool = np.zeros((num_layers,), dtype=np.object)
    layer_nonlinearity = np.zeros((num_layers,), dtype=np.object)
    for lay in range(num_layers):
        if type(net.layers_[lay]).__name__ == 'Conv2DDNNLayer': 
            layers_W[lay]=net.layers_[lay].W.get_value()
            layers_biais[lay]=net.layers_[lay].b.get_value()
            layers_pad[lay] = net.layers_[lay].pad
            layers_stride[lay] = net.layers_[lay].stride
            if  net.layers_[lay].nonlinearity.__name__ == 'rectify':
                layer_nonlinearity[lay]=1.
            elif net.layers_[lay].nonlinearity.__name__ == 'softmax':
                layer_nonlinearity[lay]=2.
                print "softmax layer added"
            print "conv layer added"

        elif type(net.layers_[lay]).__name__ == 'DenseLayer':
            layers_W[lay]=net.layers_[lay].W.get_value()
            layers_biais[lay]=net.layers_[lay].b.get_value()
            layers_pad[lay] = 0
            layers_stride[lay] = (1, 1)
            if  net.layers_[lay].nonlinearity.__name__ == 'rectify':
                layer_nonlinearity[lay]=1.
            elif net.layers_[lay].nonlinearity.__name__ == 'softmax':
                layer_nonlinearity[lay]=2.
                print "softmax layer added"
            print "dense layer added"
        
        elif type(net.layers_[lay]).__name__ =='MaxPool2DDNNLayer':
            layers_pool[lay]=net.layers_[lay].pool_size
            layers_pad[lay] = net.layers_[lay].pad
            layers_stride[lay] = net.layers_[lay].stride
            print "pool layer added"
            
        elif type(net.layers_[lay]).__name__ == 'DropoutLayer':
            layers_W[lay]=-1
        
    sio.savemat('network_weights.mat',{'layers_W': layers_W,'layers_biais':layers_biais, 'layers_pad':layers_pad, 'layers_stride':layers_stride, 'layers_pool':layers_pool, 'layer_nonlinearity':layer_nonlinearity } )
    
    
    
    
    
    
    