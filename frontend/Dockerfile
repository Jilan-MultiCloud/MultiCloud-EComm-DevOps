FROM node:18-alpine
WORKDIR /app
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/html" }); \
  res.end("<h1>Frontend is Live</h1><p>Microservices Status: Operational</p>"); \
}).listen(80);' > server.js
EXPOSE 80
CMD ["node", "server.js"]
