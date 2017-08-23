## Description

The PhotoArchive project was proposed as a Senior Design Project by the Los Angeles Bureau of Engineering. This project allows the Bureau of Engineering to upload images with specific tags into a Microsoft Azure database. 

## Table of Contents
  - [Special Note](#special-note)
  - [Key Features](#key-features)
  - [Installation](#installation)
  - [Functionality](#functionality)
    - [Login](#login)
    - [Dashboard Page](#dashboard-page)
    - [Tagging Page](#tagging-page)
    - [Camera Page](#camera-page)
    - [History Page](#history-page)
    - [Settings Page](#settings-page)
    - [Theme Selection](#theme-selection)
  - [Support](#support)

## Special Note

The link to the repo will issue a 404 error because it leads to my private repository due to the project being closed source.

## Key Features

* Image storage
* Thumbnail storage
  * In addition to uploading an image, thumbnails will also be uploaded to increase network efficiency when searching through uploaded images
* Context and Attribute Associations
  * Allows for a tagging system to be as specific or general as needed
  * Context - General purpose of the image
  * Attribute - Specific characteristics of the image, can have multiple attributes per context
  * General Example:
    * Context = Pasadena Rose Bowl Concert
    * Attribute 1 = Which artist is currently playing?
    * Attribute 2 = Which area are you seated in?
    * Attribute ...
  * Specific Example:
    * Context = Meeting on 3/14/17 with Corporate
    * Attribute 1 = How many people are present?
    * Attribute 2 = What were the topics discussed?
    * Attribute 3 = Who is currently in this image? 
    * Attribute ...
* Take images within the application and store them internally
* Import images from the camera roll
* Tag multiple images with multiple context and associated attributes
* Timed automatic deletion of internal images
* Adjust time for when images are automatically deleted
* History view to see all images uploaded by current user and associated contexts
* Timed automatic login feature
* 3 different colored themes
* Privacy feature to wipe all internal application images when a new user logs in
* Microsoft Azure implementation

## Installation

Unnecessary considering this is a closed source project. 
I decided to include this section to reiterate that the link to the repository will lead to a 404 error. 

## Functionality

### Login

- Username and password as standard 
- 'Remember Me' option, which is set to remember the user for 30 days
- User detection built in
  - If the current user logging in is not the previous user which was logged in, the application will purge all data from the previous user

![Login Image](https://github.com/pgulegin/PhotoArchive---Azure-Version/blob/master/Screenshots/IMG_1810.PNG?raw=true)

### Dashboard Page

- Checks with tags database to make sure user has the latest tags
- Permissions status
  - Will inform the user if GPS, Wifi or camera functionality has been blocked
  - If permissions are not correct, displays button to take user to their settings to change those permissions
- Displays images to be uploaded
  - Will only upload over Wifi, unless setting is changed on Settings Page
  - Clears the entire queue with single button
  - Clears individual items
  - Shows larger image if image is selected

(Add screenshot here)

### Tagging Page

- Image selection
  - Selection from user's personal photos
  - Selection from images taken within the application
  - Allows selection of images from either/both previously mentioned categories
- Tag selection
  - Multiple tags can be selected for bulk uploading
- Correctness check
  - Will not allow user to upload photos if tags have not been selected
  - Will not allow user to upload photos if photos have not been selected
- I wish one of those cars were mine! 

In this demonstration you will see:
  1. Selecting a photo from the internal library
  2. Selecting photos from the user's photo library
  3. Selecting a context and adding a 'testing' description
  4. Selecting another context and leaving it blank
  5. Sending the images to the upload queue

(Add screenshot here)

### Camera Page

- Dual functionality
  - Scenario 1: If user has not selected any tags, images taken within the application will be placed within the application photo library
  - Scenario 2: IF user has selected tags, images taken within the application will be placed within the application photo library and sent directly to the upload queue
- Opens the camera to take images
- Records GPS coordinates to send to the tags database

(Add screenshot here)

### History Page

- Displays all images the current user has uploaded
- In the overview, the images are loaded as thumbnails for efficiency purposes both on the device and the Azure server
- When an image is selected, full image is loaded and user can view the tags the image was uploaded with

(Add screenshot here)

### Settings Page

- Wifi only upload toggle
- Manages internal photo library by deleting images after 90 days, by default
- Allows theme selection

(Add screenshot here)

### Theme Selection

- 3 default themes
- Themes apply automatically, no need to restart

(Add screenshot here)

## Support

If it breaks, you can keep both pieces.
