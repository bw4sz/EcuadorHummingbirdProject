import cv2
import tensorflow as tf
import ExtractLetters
import predict
from openpyxl import load_workbook
import glob
import os
import csv
if __name__ == "__main__":

    #date images to be processed
    date_images=[]
    
    #time images to be processed
    time_images=[]

    #Create tensorflow model
    sess=tf.Session()
    tf.saved_model.loader.load(sess,[tf.saved_model.tag_constants.SERVING], "C:/Users/Ben/Dropbox/GoogleCloud/Annotation_model/")    
    tensorflow_instance=predict.tensorflow_model()
    
    #lookup table to convert numeric characters
    lookup={}
    lookup["One"]="1"
    lookup["Two"]="2"
    lookup["Three"]="3"
    lookup["Four"]="4"
    lookup["Five"]="5"
    lookup["Six"]="6"
    lookup["Seven"]="7"
    lookup["Eight"]="8"
    lookup["Nine"]="9"
    lookup["Zero"]="0"
    lookup["Forward_slash"]="/"
    lookup[":"]=":"
        
    image_annotations={}
    
    images=glob.glob("C:/Users/Ben/Dropbox/HummingbirdProject/Data/**/foundframes/**/**.jpg",recursive=True)
    for image_path in images:        
            
            #extract letters
            date_letters=ExtractLetters.getLetters(image=image_path,roi=[600,702,777,759])     
        
            date_pred=[]
            for x in date_letters:
                date_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
        
            #lookup numeric value
            date_number=[]
            for x in date_pred:
                date_number.append(lookup[x])
            print("Predicted date: " + "".join(date_number))
                
            #Annotate time
            time_pred=[]
         
            hour_letters=ExtractLetters.getLetters(image=image_path,roi=[777,702,915,750]) 
            for x in hour_letters:
                time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
             
             ##Hour
            #hour_letters=ExtractLetters.getLetters(image=image_path,roi=[777,702,821,750]) 
            #for x in hour_letters:
                #time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
         
             ##colon between hour and minute
            #time_pred.append(":")
             
             ##Minute
            #minute_letters=ExtractLetters.getLetters(image=image_path,roi=[829,702,868,750]) 
            #for x in minute_letters:
                #time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
         
             ##colon between minute and second
            #time_pred.append(":")
            ##Second
            #second_letters=ExtractLetters.getLetters(image=image_path,roi=[876,702,915,750]) 
            #for x in second_letters:
                #time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
             
             #lookup numeric value
            time_number=[]    
            for x in time_pred:
                time_number.append(lookup[x])
             
            print("Predicted time is " + "".join(time_number))
            #view image
            image=cv2.imread(image_path)
            cv2.namedWindow("image",cv2.WINDOW_NORMAL)                 
            cv2.imshow("image",image)
            cv2.waitKey(0)
            
            #write annotations to dictionary
            image_annotations[image_path]=["".join(date_number),"".join(time_number)]
    