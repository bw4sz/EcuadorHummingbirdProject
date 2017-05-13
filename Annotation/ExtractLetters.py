#Text reader
import cv2
import numpy as np
import glob
from imutils import contours
import os
import csv
#import matplotlib.pyplot as plt                

class Annotate:
    def __init__(self,image,debug=False,size=300,limit=None):    
        print("MeerkatReader object created")    
        self.debug=debug
        self.size=size
        self.image=image
        
    def getLetters(self,roi):        

        #container for parsed letter images
        letters=[]
        
        if self.debug: fig = plt.figure()
                                                            
        img=cv2.imread(self.image)
        display_image=img[roi[1]:roi[3], roi[0]:roi[2]]     
        display_image=cv2.cvtColor(display_image,cv2.COLOR_RGB2GRAY)
        
        if self.debug: view(display_image)
    
        #resize by 10
        display_image = cv2.resize(display_image,None,fx=10, fy=10, interpolation = cv2.INTER_CUBIC)
        
        if self.debug: view(display_image)
    
        #threshold
        ret,display_image=cv2.threshold(display_image,245,255,cv2.THRESH_BINARY)
        
        if self.debug: view(display_image)
                    
        #Closing
        kernel = np.ones((20,20),np.uint8)
        display_image=cv2.morphologyEx(display_image,cv2.MORPH_CLOSE,kernel)
        
        if self.debug: view(display_image)

        ##split into letters##
        #get contours
        draw=display_image.copy()
        
        _,cnts,hierarchy = cv2.findContours(display_image.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE )
        len(cnts)
        
        for x in cnts:
            cv2.drawContours(draw,[x],-1,(100,100,255),3)
        if self.debug: view(display_image)
    
        #get rid of child
        #order contour left to right
        (cnts, _) = contours.sort_contours(cnts)    
        
        #remove tiny contours
        contsize = []
        for x in cnts:
            area=cv2.contourArea(x)
            if area > self.size:
                contsize.append(x)
            else:
                print(str(area) + " is removed")
        
        #bouding boxes
        bounding_box_list=[]
        for cnt in contsize:
            cbox = cv2.boundingRect( cnt )
            bounding_box_list.append( cbox )
                        
        for bbox in bounding_box_list:
            
            #boxes as seperate matrices, make slightly larger so edges don't touch                
            letter=display_image[bbox[1]-10:bbox[1]+bbox[3]+10,bbox[0]-10:bbox[0]+bbox[2]+10]
            #inverse
            letter = cv2.bitwise_not(letter)    
            
            if letter is None:
                print("no letter")
                break
            
            if self.debug: view(display_image)            
                            
            letters.append(letter)
        return(letters)

#Helper functions
#debug viewer function
def view(display_image):
    plt.imshow(display_image,cmap="Greys")    
    fig = plt.show()        
    plt.pause(0.00001)    