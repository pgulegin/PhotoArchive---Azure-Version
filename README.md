# PhotoArchive

The PhotoArchive project was propsed as a Senior Design Project by the Los Angeles Bureau of Engineering. This project allows the Bureau of Engineering to upload images with specific tags into a Microsoft Azure database. 

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

## Acknowledgments

* Los Angeles Bureau of Engineering
* California State University Los Angeles
* Felipe Vega
* Alejandra Monteon
* Nikko De Guzman
* Edwin Ochoa
* Stephanie Daley
