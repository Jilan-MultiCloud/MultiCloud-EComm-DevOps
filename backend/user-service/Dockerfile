FROM node:18-alpine
WORKDIR /app
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/plain" }); \
  res.end("User Service Running"); \
}).listen(3001);' > server.js
EXPOSE 3001
CMD ["node", "server.js"]
