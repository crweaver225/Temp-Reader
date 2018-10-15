# Temp-Reader
An entire Raspberry Pi & iOS project to read and log temperatures, Send Push notifications if temps are too high or low, and handle webservice calls.

## About Temp-Reader:
This project was designed to solve a problem where temperatures in my son's room were not adequately being maintained. I wanted a cheap solution that allowed me to monitor the temperature in his room at any given time as well as throughout a longer peroid of time, such as an entire night. Most importantly, I wanted the raspberry pi to notify me if it got too warm or cold. This project was that culmination. The raspberry pi automatically takes temperature measurements every 15 minutes and stores those measurements in an sqlite databse. The raspberry pi also is programmed using flask to provide webservice calls to provide temperature data over any specified period of time in json format. Finally, the raspberry pi kept track of different iPhone users preferences on when the room was too hot or too cold and would send out individual push notifications to those users when appropriate. 

The iOS app make a serious of webservice calls to the raspberry pi to get current temperature data as well as previous temperature readings. The app would display both current and historic data in a easy to read graphic format. Also, the app would allow users to set high and low temperatures that when reached, would trigger a push notification to their phone from the raspberry pi. 


<p align="center">
  <img src="/Image-1.jpg" width="250"/>
  <img src="/Image-21.jpg" width="250"/>
</p>


## Technologies Used
-Python
-Swift
-Flask
-Sqlite
-Custom UIKit graphics
