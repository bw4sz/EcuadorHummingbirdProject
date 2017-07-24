import cv2

img=cv2.imread("C:/Users/Ben/Dropbox/HummingbirdProject/Data/Maquipucuna/foundframes/201703/MQPC1521/170318AB/6156.jpg")
roi=[605,704,624,750]
display_image=img[roi[1]:roi[3], roi[0]:roi[2]]     
cv2.imshow("img",display_image)
cv2.waitKey(0)

Month_1
Year_1=roi=[750,704,770,750]
Year_4=roi=[750,704,770,750]
