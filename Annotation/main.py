import cv2
import tensorflow as tf
import ExtractLetters
import predict
import csv

if __name__ == "__main__":
    
    #find which images need to be annotated
    
    #Get a list of images
    
    #pass each image to annotation class, return a list of letter images
    mr=ExtractLetters.Annotate(image="C:/Users/Ben/Dropbox/HummingbirdProject/Data/Maquipucuna/foundframes/201703/MQPC1521/170318AB/6156.jpg")
    
    #Date
    date_letters=mr.getLetters(roi=[600,702,777,759],asset="Date")     
    
    #pass each letter image to tensorflow
    sess=tf.Session()
    tf.saved_model.loader.load(sess,[tf.saved_model.tag_constants.SERVING], "C:/Users/Ben/Dropbox/GoogleCloud/Annotation_model/")    
    tensorflow_instance=predict.tensorflow_model()

    for x in date_letters:
        pred=tensorflow_instance.predict(read_from="numpy",sess=sess,image_array=[x])
        tensorflow_instance.show(wait_time=0)
    
    #Time
    time_letters=mr.getLetters(roi=[777,701,919,750],asset="Time") 
    
    for x in time_letters:
        pred=tensorflow_instance.predict(read_from="numpy",sess=sess,image_array=[x])
        tensorflow_instance.show(wait_time=0)    
    

    
    
            
