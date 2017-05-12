import tensorflow as tf
import os
import glob
import numpy as np
import argparse
import cv2

class tensorflow_model:    
    
    def __init__(self):
        print("Tensorflow object")
                    
    def predict(self,read_from,sess,image_array=None,imagedir=None,numpy_name=None,wait_time=10):
        
        #frames to be analyzed
        tfimages=[]     
        
        #names for those frames
        self.image_name=[]
        
        # Read in the image_data
        if read_from=="file":
            if os.path.isdir(imagedir):
                find_photos=glob.glob(imagedir+"*.jpg")            
                for x in find_photos:
                    image_data = tf.gfile.FastGFile(x, 'rb').read()    
                    tfimages.append(image_data)
                    self.image_name.append(x)
            else:
                image_data = tf.gfile.FastGFile(imagedir, 'rb').read()                    
                tfimages.append(image_data)
                self.image_name.append(imagedir)
                
        if read_from=="numpy":
            for x in image_array:
                bimage=cv2.imencode(".jpg", x)[1].tostring()
                tfimages.append(bimage)
                
                #set imagedir for dict recall
                self.image_name.append(numpy_name)

        # Loads label file, strips off carriage return
        self.label_lines = [line.rstrip() for line in tf.gfile.GFile("dict.txt")]
        
        # Feed the image_data as input to the graph and get first prediction
        softmax_tensor = sess.graph.get_tensor_by_name('final_ops/softmax:0')
        prediction = sess.run(softmax_tensor, {'Placeholder:0': tfimages})
        
        # Sort to show labels of first prediction in order of confidence
        top_k = prediction.argsort()[-len(prediction):][::-1]    
        
        for node_id in top_k:
            human_string = self.label_lines[node_id]
            score = prediction[node_id]
            print('%s (score = %.4f)' % (human_string, score))
        self.pred=self.label_lines[top_k[0]]            
    
    def show(self,wait_time):
        font = cv2.FONT_HERSHEY_SIMPLEX        
        cv2.putText(image_array,self.pred,(10,20), font, 0.75,(255,255,255),1,cv2.LINE_AA)            
        cv2.imshow("Annotation", image_array)
        cv2.waitKey(wait_time)