import tensorflow as tf
import os
import glob
import numpy as np
import argparse
import cv2

class tensorflow_model:    
    
    def __init__(self):
        print("Tensorflow object")
                    
    def predict(self,sess,image_array,wait_time=10):
        
        #frames to be analyzed
        tfimages=[]     
        
        #hold on to numpy frame
        self.image_array=image_array
        
        #read array
        bimage=cv2.imencode(".jpg", self.image_array)[1].tostring()
        tfimages.append(bimage)

        # Loads label file, strips off carriage return
        self.label_lines = [line.rstrip() for line in tf.gfile.GFile("dict.txt")]
        
        # Feed the image_data as input to the graph and get first prediction
        softmax_tensor = sess.graph.get_tensor_by_name('final_ops/softmax:0')
        prediction = sess.run(softmax_tensor, {'Placeholder:0': tfimages})
        
        # Sort to show labels of first prediction in order of confidence
        top_k = prediction.argsort()[-len(prediction):][::-1][0]    
        
        for node_id in top_k:
            human_string = self.label_lines[node_id]
            score = prediction[0][node_id]
            #print('%s (score = %.3f)' % (human_string, score))
        self.pred=self.label_lines[top_k[-1]]
        print("Prediction is " + self.pred)
        return(self.pred)
    
    def show(self,wait_time):
        font = cv2.FONT_HERSHEY_SIMPLEX        
        cv2.putText(self.image_array,self.pred,(10,20), font, 0.75,(0,0,0),2,cv2.LINE_AA)            
        cv2.imshow("Annotation", self.image_array)
        cv2.waitKey(wait_time)