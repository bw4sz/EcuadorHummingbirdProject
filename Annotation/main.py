import cv2
import tensorflow as tf
import ExtractLetters
import predict
from openpyxl import load_workbook
import glob

if __name__ == "__main__":
    
    glob.glob("C:/Users/Ben/Dropbox/HummingbirdProject/Data/*/Observations_*.xlsx")
    
    ##find which images need to be annotated
    wb = load_workbook(filename = 'C:/Users/Ben/Dropbox/HummingbirdProject/Data/Maquipucuna/observations_maquipucuna.xlsx')
    
    #f = wb[0]
    #print(sheet_ranges['Date'].value)        

    #Get a list of images

    #Create tensorflow model
    sess=tf.Session()
    tf.saved_model.loader.load(sess,[tf.saved_model.tag_constants.SERVING], "C:/Users/Ben/Dropbox/GoogleCloud/Annotation_model/")    
    tensorflow_instance=predict.tensorflow_model()
    
    #pass each image to annotation class, return a list of letter images
    mr=ExtractLetters.Annotate(image="C:/Users/Ben/Dropbox/HummingbirdProject/Data/Maquipucuna/foundframes/201703/MQPC1521/170318AB/6156.jpg")
    
    #Date
    date_letters=mr.getLetters(roi=[600,702,777,759])     

    date_pred=[]
    for x in date_letters:
        date_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))
        
    #Time
    time_pred=[]
    #Hour
    hour_letters=mr.getLetters(roi=[777,702,819,750]) 
    for x in hour_letters:
        time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))

    #colon between 
    time_pred.append(":")
    
    #Minute
    minute_letters=mr.getLetters(roi=[829,702,868,750]) 
    for x in minute_letters:
        time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))

    #colon between 
    time_pred.append(":")
    
    #Second
    second_letters=mr.getLetters(roi=[876,702,915,750]) 
    for x in second_letters:
        time_pred.append(tensorflow_instance.predict(sess=sess,image_array=x))

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
    
    date_number=[]
    for x in date_pred:
        date_number.append(lookup[x])
    
    time_number=[]    
    for x in time_pred:
        time_number.append(lookup[x])
    
    print("Predicted time is " + "".join(time_number))
    print("Predicted date: " + "".join(date_number))