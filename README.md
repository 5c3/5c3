# 5c3 – a HTML5 viewer for 29c3

## Backend setup instructions
5c3 features a HTTP-REST-backend using node.js and MongoDB.

1. Install node.js
 - `brew install node` (for Mac OS using Homebrew)
 - `curl http://npmjs.org/install.sh | sh` (Install Node packet manager npm)
 - `npm install supervisor -g` (not necessary, you can run the backend using `node` as well)

2. Install mongoDB
 - `brew install mongodb`

3. Run the backend
 - `supervisor backend.js`
