FROM node:18-alpine
WORKDIR /app
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/plain" }); \
  res.end("Order Service Running"); \
}).listen(3003);' > server.js
EXPOSE 3003
CMD ["node", "server.js"]
