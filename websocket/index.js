const httpServer = require("http").createServer();

const io = require("socket.io")(httpServer, {
  allowEIO3: true,
  cors: {
    origin: "http://127.0.0.1:80",
    methods: ["GET", "POST"],
    credentials: true,
  },
});

httpServer.listen(8080, function () {
  console.log("listening on *:8080");
});

io.on("connection", function (socket) {
  console.log(`client ${socket.id} has connected`);

  socket.on("logged_in", function (userId, userType) {
    userId = parseInt(userId);
    socket.join(userId);
    if (userType == 'A') {
      socket.join("administrators")
    }
  });

  socket.on("logged_out", function (userId) {
    userId = parseInt(userId);
    socket.leave(userId);
  });

  socket.on("divisionUpdate", function (userId) {
    userId = parseInt(userId);
    io.to(userId).emit("divisionUpdate");
    io.to(userId).emit("navbarUpdate");
  });

  socket.on("equipmentUpdate", function (userId) {
    userId = parseInt(userId);
    io.to(userId).emit("equipmentUpdate");
    io.to(userId).emit("navbarUpdate");
  });

  socket.on("affiliateUpdate", function (userId) {
    userId = parseInt(userId);
    io.to(userId).emit("affiliateUpdate");
    io.to(userId).emit("navbarUpdate");
  });

  socket.on("profileUpdate", function (userId) {
    userId = parseInt(userId);
    io.to(userId).emit("profileUpdate");
    io.to(userId).emit("navbarUpdate");
  });

  socket.on("trainingExamples", function (userId) {
    userId = parseInt(userId);
    io.to(userId).emit("trainingExamples");
    io.to(userId).emit("navbarUpdate");
  });

  socket.on("usersUpdate", function () {
    io.to("administrators").emit("usersUpdate");
  });

  socket.on("equipmentTypeUpdate", function () {
    io.to("administrators").emit("equipmentTypeUpdate");
  });

  socket.on("userBlock", function (userToBlock, block) {
    if (block) {
      userToBlock = parseInt(userToBlock);
      io.to(userToBlock).emit("userBlock");
      socket.leave(userToBlock)
    }
  });

  socket.on("userDeleted", function (userDeleted) {
    userDeleted = parseInt(userDeleted);
    io.to(userDeleted).emit("userDeleted");
    socket.leave(userDeleted)
  });

});
