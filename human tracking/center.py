import mediapipe as mp
import cv2 as cv
import time
import serial

class poseDetector:
    def __init__(self,static_image_mode=False,model_complexity=1,smooth_landmarks=True,enable_segmentation=False,
               smooth_segmentation=True,min_detection_confidence=0.5,min_tracking_confidence=0.5):
        self.static_image_mode=static_image_mode
        self.model_complexity=model_complexity
        self.smooth_landmarks=smooth_landmarks
        self.enable_segmentation=enable_segmentation
        self.smooth_segmentation=smooth_segmentation
        self.min_detection_confidence=min_detection_confidence
        self.min_tracking_confidence=min_tracking_confidence

        self.mpPose=mp.solutions.pose
        self.pose=self.mpPose.Pose(self.static_image_mode,self.model_complexity,self.smooth_landmarks,self.enable_segmentation,
               self.smooth_segmentation,self.min_detection_confidence,self.min_tracking_confidence)
        self.mpDraw=mp.solutions.drawing_utils


    def findPose(self,img,draw=True):
        imgRGB=cv.cvtColor(img,cv.COLOR_BGR2RGB)
        self.results=self.pose.process(imgRGB)
        
        if self.results.pose_landmarks:
            if draw:
                self.mpDraw.draw_landmarks(img, self.results.pose_landmarks,self.mpPose.POSE_CONNECTIONS)
        return img
  
    
    def getPosition(self,img,draw=True,):
        # lmList=[]
        fh,fw,c=img.shape
        # print(fw)1
        angle=2
        cList=[]
        x,y,w,h=[0,0,0,0]
            
        if self.results.pose_landmarks:
            for id,lm in enumerate(self.results.pose_landmarks.landmark):
                cx,cy=int(lm.x*fw),int(lm.y*fh)
                # print(id,cx,cy)
                if(id==11):
                    # print(id,cx,cy)
                    x=cx
                    y=cy
                    cv.circle(img,(cx,cy),7,(0,0,255),cv.FILLED)
                    
                    
                if(id==12):
                    # print(id,cx,cy)
                    w=cx
                    cv.circle(img,(cx,cy),7,(0,0,255),cv.FILLED)
                    
                    
                if(id==23 or id==24):
                    # print(id,cx,cy)
                    h=cy
                    cv.circle(img,(cx,cy),7,(0,0,255),cv.FILLED)
                    
                    
            c1=int((x+w)/2)
            c2=int((y+h)/2)
            center=[c1,c2]
            # if (c1 > fw/2):
            #     xpos += angle
                
            # if (c1 < fw/2):
            #     xpos -= angle

            string='x{:d}'.format(c1)
            print(string)
            # ArduinoSerial.write(string.encode('utf-8'))

            cList.append(center)
            # lmList.append([id,cx,cy])
            if(draw):
                cv.circle(img,(c1,c2),15,(255,0,255),cv.FILLED)
        return cList
    
        

def main():
    cap=cv.VideoCapture(0)
    pTime=0
    detector=poseDetector()
    img=cv.imread("model.jpg")
    # img=cv.resize(img,(766,888))
    img=detector.findPose(img,False)
    detector.getPosition(img)
    cv.imwrite("pose.jpg", img)
    
    cv.imshow("Image",img)
    cv.waitKey(0)
    # ArduinoSerial=serial.Serial('com4',9600,timeout=0.1)
    # while True:
    #     # suc,img=cap.read()
    #     img=cv.imread("mdoel.jpg", cv2.IMREAD_COLOR)
    #     img=detector.findPose(img,True)
        
    #     # lmList=detector.getPosition(img,ArduinoSerial)
    #     # if lmList!=[]:
    #     #     print(lmList)
        
    #     cTime=time.time()
    #     fps=1/(cTime-pTime)
    #     pTime=cTime    
        
    #     cv.putText(img,str(int(fps)),(10,70),cv.FONT_HERSHEY_PLAIN,3,(255,0,255),3)
        
    #     cv.imshow("Image",img)
    #     cv.waitKey(1)
    
if __name__=="__main__":
    main()