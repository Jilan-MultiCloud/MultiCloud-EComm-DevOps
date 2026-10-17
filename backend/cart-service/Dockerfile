FROM node:18-alpine
WORKDIR /app
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/plain" }); \
  res.end("Cart Service Running"); \
}).listen(3004);' > server.js
EXPOSE 3004
CMD ["node", "server.js"]
