FROM node:18-alpine
WORKDIR /app
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/plain" }); \
  res.end("Product Service Running"); \
}).listen(3002);' > server.js
EXPOSE 3002
CMD ["node", "server.js"]
