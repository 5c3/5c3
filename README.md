# 5c3 – a HTML5 viewer for 29c3

## API description

GET `/event/0000` get JSON of event #0000

POST `/event/0000` increase popularity for event #0000

GET `/events` get JSON of all events

POST `/events` Parameter `url` import/update Pentabarf-XML from URL (requires authorization)



## Backend setup instructions
5c3 features a HTTP-REST-backend using node.js and MongoDB.

1. Install node.js
 - `brew install node` (for Mac OS using Homebrew)
 - `npm install supervisor -g` (not necessary, you can run the backend using `node` as well)
 -  `npm install express`
 -  `npm install mongojs`
 -  `npm install xml2js`

2. Install mongoDB
 - `brew install mongodb`

3. Run the backend
 - `supervisor app.js`

